import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pcplus/models/users/ship_infor_model.dart';
import 'package:pcplus/themes/text_decor.dart';

class DeliveryInfor extends StatefulWidget {
  final ShipInformationModel currentAddress;
  const DeliveryInfor({super.key, required this.currentAddress});
  static const String routeName = 'delivery_infor';

  @override
  State<DeliveryInfor> createState() => _DeliveryInforState();
}

class _DeliveryInforState extends State<DeliveryInfor> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController provinceController;
  late TextEditingController districtController;
  late TextEditingController detailAddressController;

  Map<String, List<String>> addressData = {};
  List<String> provinces = [];
  List<String> districts = [];
  String selectedProvince = '';
  bool isDistrictEnabled = false;
  bool isLoadingAddress = true;

  @override
  void initState() {
    super.initState();
    nameController =
        TextEditingController(text: widget.currentAddress.receiverName);
    phoneController = TextEditingController(text: widget.currentAddress.phone);

    // Initialize new controllers
    provinceController = TextEditingController();
    districtController = TextEditingController();
    detailAddressController = TextEditingController();

    _loadAddressData();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    provinceController.dispose();
    districtController.dispose();
    detailAddressController.dispose();
    super.dispose();
  }

  Future<void> _loadAddressData() async {
    try {
      final String response = await rootBundle.loadString('address.json');
      final Map<String, dynamic> data = json.decode(response);
      setState(() {
        addressData =
            data.map((key, value) => MapEntry(key, List<String>.from(value)));
        provinces = addressData.keys.toList();
        isLoadingAddress = false;

        // Re-parse existing address after data is loaded
        _parseExistingAddress(widget.currentAddress.location);
      });
    } catch (e) {
      print('Error loading address data: $e');
      setState(() {
        isLoadingAddress = false;
      });
    }
  }

  void _parseExistingAddress(String? existingAddress) {
    if (existingAddress != null &&
        existingAddress.isNotEmpty &&
        addressData.isNotEmpty) {
      // Try to parse existing address format: "Số nhà, Phường, Tỉnh"
      final parts = existingAddress.split(', ');
      if (parts.length >= 3) {
        detailAddressController.text = parts[0];
        districtController.text = parts[1];
        provinceController.text = parts[2];
        selectedProvince = parts[2];

        // Enable district selection if province is set and exists in data
        if (selectedProvince.isNotEmpty &&
            addressData.containsKey(selectedProvince)) {
          isDistrictEnabled = true;
          districts = addressData[selectedProvince] ?? [];
        }
      } else {
        // If can't parse, put everything in detail address
        detailAddressController.text = existingAddress;
      }
    }
  }

  void _showProvincePicker() {
    if (isLoadingAddress) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đang tải dữ liệu địa chỉ...')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          children: provinces.map((province) {
            return ListTile(
              title: Text(province),
              onTap: () {
                setState(() {
                  provinceController.text = province;
                  selectedProvince = province;
                  districts = addressData[province] ?? [];
                  isDistrictEnabled = true;
                  districtController
                      .clear(); // Clear previous district selection
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  void _showDistrictPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          children: districts.map((district) {
            return ListTile(
              title: Text(district),
              onTap: () {
                setState(() {
                  districtController.text = district;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thay đổi địa chỉ',
          style: TextDecor.robo24Medi.copyWith(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                },
                decoration: const InputDecoration(labelText: "Tên người nhận"),
                validator: (value) =>
                    value!.isEmpty ? "Vui lòng nhập tên" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: phoneController,
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                },
                decoration: const InputDecoration(labelText: "Số điện thoại"),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value!.isEmpty ? "Vui lòng nhập số điện thoại" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: provinceController,
                readOnly: true,
                onTap: _showProvincePicker,
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                },
                decoration: const InputDecoration(
                  labelText: "Tỉnh/Thành phố",
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Vui lòng chọn tỉnh/thành phố" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: districtController,
                readOnly: true,
                enabled: isDistrictEnabled,
                onTap: isDistrictEnabled ? _showDistrictPicker : null,
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                },
                style: TextStyle(
                  color: isDistrictEnabled ? Colors.black : Colors.grey,
                ),
                decoration: InputDecoration(
                  labelText: "Xã/Phường/Đặc khu",
                  suffixIcon: Icon(
                    Icons.arrow_drop_down,
                    color: isDistrictEnabled ? null : Colors.grey,
                  ),
                  hintText: isDistrictEnabled
                      ? null
                      : 'Vui lòng chọn tỉnh/thành phố trước',
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Vui lòng chọn xã/phường/đặc khu" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: detailAddressController,
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                },
                decoration: const InputDecoration(
                  labelText: "Địa chỉ chi tiết",
                  hintText: "Số nhà, tên đường, thôn...",
                ),
                validator: (value) =>
                    value!.isEmpty ? "Vui lòng nhập địa chỉ chi tiết" : null,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 58,
        width: size.width,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          border: Border(
            top: BorderSide(
              color: Colors.black,
            ),
          ),
        ),
        child: InkWell(
          onTap: () {
            if (_formKey.currentState!.validate()) {
              // Additional validation for address completeness
              if (provinceController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng chọn tỉnh/thành phố')),
                );
                return;
              }
              if (districtController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Vui lòng chọn xã/phường/đặc khu')),
                );
                return;
              }
              if (detailAddressController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Vui lòng nhập địa chỉ chi tiết')),
                );
                return;
              }

              // Combine address parts into full address
              String fullAddress =
                  '${detailAddressController.text}, ${districtController.text}, ${provinceController.text}';

              Navigator.pop(context, {
                ShipInformationModel(
                  receiverName: nameController.text,
                  phone: phoneController.text,
                  location: fullAddress,
                  isDefault: true,
                )
              });
            }
          },
          child: Container(
            alignment: Alignment.center,
            height: 50,
            width: size.width - 20,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text('Xác nhận',
                style: TextDecor.robo18Bold.copyWith(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
