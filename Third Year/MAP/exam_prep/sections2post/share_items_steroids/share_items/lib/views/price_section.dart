// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../models/item.dart';
import '../repositories/network.dart';
import '../services/data.dart';
import '../widgets/message.dart';
import 'edit_data.dart';



class PriceSection extends StatefulWidget {
  const PriceSection({super.key});

  @override
  _PriceSectionState createState() => _PriceSectionState();
}

class _PriceSectionState extends State<PriceSection> {
  var logger = Logger();
  bool online = true;
  late List<Item> discountedItems = [];
  bool isLoading = false;
  Map _source = {ConnectivityResult.none: false};
  final NetworkConnectivity _connectivity = NetworkConnectivity.instance;
  String string = '';

  @override
  void initState() {
    super.initState();
    connection();
  }

  void connection() {
    _connectivity.initialize();
    _connectivity.myStream.listen((source) {
      _source = source;
      var newStatus = true;
      switch (_source.keys.toList()[0]) {
        case ConnectivityResult.mobile:
          string =
              _source.values.toList()[0] ? 'Mobile: online' : 'Mobile: offline';
          break;
        case ConnectivityResult.wifi:
          string =
              _source.values.toList()[0] ? 'Wifi: online' : 'Wifi: offline';
          newStatus = _source.values.toList()[0] ? true : false;
          break;
        case ConnectivityResult.none:
        default:
          string = 'Offline';
          newStatus = false;
      }
      if (online != newStatus) {
        online = newStatus;
      }
      getDiscountedItems();
    });
  }

  getDiscountedItems() async {
    final dataService = Provider.of<DataService>(context, listen: false);
    setState(() {
      isLoading = true;
    });
    logger.log(Level.info, 'getDiscountedItems');
    try {
      if (online) {
        discountedItems = await dataService.getDiscountedItems();
      } else {
        message(context, "No internet connection", "Error");
      }
    } catch (e) {
      logger.log(Level.error, e.toString());
      message(context, "Error loading items from server", "Error");
    }
    setState(() {
      isLoading = false;
    });
  }

  updatePrice(Item item) async {
    final dataService = Provider.of<DataService>(context, listen: false);
    setState(() {
      isLoading = true;
    });
    logger.log(Level.info, 'updatePrice');
    try {
      if (online) {
        await dataService.updatePrice(item.id!, item.price);
      } else {
        message(context, "No internet connection", "Error");
      }
    } catch (e) {
      logger.log(Level.error, e.toString());
      message(context, "Error updating price", "Error");
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Price section'),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: ListView(children: [
                ListView.builder(
                  itemCount: discountedItems.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(discountedItems[index].name),
                      subtitle: Text(
                          '${discountedItems[index].description}, ${discountedItems[index].image}, ${discountedItems[index].category}, units: ${discountedItems[index].units}, price: ${discountedItems[index].price}'),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: const BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EditData(
                                        item: discountedItems[index])))
                            .then((value) {
                          if (value != null) {
                            setState(() {
                              updatePrice(value);
                              getDiscountedItems();
                            });
                          }
                        });
                      },
                    );
                  },
                  physics: const ScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  padding: const EdgeInsets.all(10),
                )
              ])));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
