import 'package:flutter/material.dart';
import 'package:pcplus/themes/text_decor.dart';
import 'package:pcplus/models/orders/order_address_model.dart';

class DeliveryInfor extends StatefulWidget {
  final OrderAddressModel currentAddress;
  const DeliveryInfor({
    super.key,
    required this.currentAddress
  });
  static const String routeName = 'delivery_infor';

  @override
  State<DeliveryInfor> createState() => _DeliveryInforState();
}

class _DeliveryInforState extends State<DeliveryInfor> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController address1Controller;
  late TextEditingController address2Controller;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.currentAddress.receiverName);
    phoneController =
        TextEditingController(text: widget.currentAddress.phone);
    address1Controller =
        TextEditingController(text: widget.currentAddress.address1);
    address2Controller =
        TextEditingController(text: widget.currentAddress.address2);
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    address1Controller.dispose();
    address2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Address',
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
                decoration: const InputDecoration(labelText: "Tên người nhận"),
                validator: (value) =>
                    value!.isEmpty ? "Vui lòng nhập tên" : null,
              ),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Số điện thoại"),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value!.isEmpty ? "Vui lòng nhập số điện thoại" : null,
              ),
              TextFormField(
                controller: address1Controller,
                decoration: const InputDecoration(
                  hintText: "số nhà, tên đường",
                  labelText: "Địa chỉ 1",
                ),
                validator: (value) =>
                    value!.isEmpty ? "Vui lòng nhập địa chỉ" : null,
              ),
              TextFormField(
                controller: address2Controller,
                decoration: const InputDecoration(
                  labelText: "Địa chỉ 2",
                  hintText: "xã/phường, quận/huyện, tỉnh/thành phố",
                ),
                validator: (value) =>
                    value!.isEmpty ? "Vui lòng nhập địa chỉ" : null,
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
              Navigator.pop(context, {
                OrderAddressModel(
                  receiverName: nameController.text,
                  phone: phoneController.text,
                  address1: address1Controller.text,
                  address2: address2Controller.text,
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
            child: Text('Confirm',
                style: TextDecor.robo18Bold.copyWith(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
