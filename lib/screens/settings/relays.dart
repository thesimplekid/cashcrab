import 'package:flutter/material.dart';

import 'package:cashcrab/bridge_generated.dart';
import 'package:cashcrab/shared/colors.dart';

// Nostr Relays
class Relays extends StatefulWidget {
  final RustImpl api;
  const Relays({super.key, required this.api});

  @override
  State<Relays> createState() => _RelaysState();
}

class _RelaysState extends State<Relays> {
  List<String> relays = [];

  _RelaysState();

  @override
  void initState() {
    super.initState();
    _loadRelays();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadRelays() async {
    List<String> clientRelays = await widget.api.getRelays();

    setState(() {
      relays = clientRelays;
    });
  }

  Future<void> _addRelay(String newRelay) async {
    await widget.api.addRelay(relay: newRelay);
    _loadRelays();
  }

  Future<void> _removeRelay(String relay) async {
    await widget.api.removeRelay(relay: relay);
    _loadRelays();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nostr Relays")),
      body: Column(
        children: [
          SizedBox(
            height: 100.0,
            child: AddRelayForm(
              addRelay: _addRelay,
            ),
          ),
          Flexible(
            child: ListView.builder(
              itemCount: relays.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 45.0,
                    decoration: const BoxDecoration(),
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding:
                              const EdgeInsets.only(left: 15.0, right: 15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10.0),
                                        topRight: Radius.circular(10.0))),
                                child: Text(
                                  relays[index],
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(fontSize: 15.0),
                                  maxLines: 1,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _removeRelay(relays[index]);
                                },
                                child: Container(
                                  margin: const EdgeInsets.all(0.0),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 30.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          color: purpleColor,
                          height: 1,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(
            height: 100.0,
          )
        ],
      ),
    );
  }
}

class AddRelayForm extends StatefulWidget {
  final Function addRelay;
  const AddRelayForm({super.key, required this.addRelay});

  @override
  State<AddRelayForm> createState() => _AddRelayFormState();
}

class _AddRelayFormState extends State<AddRelayForm> {
  final addRelayController = TextEditingController();

  _AddRelayFormState();

  @override
  void initState() {
    super.initState();
    addRelayController.addListener(() => {});
  }

  @override
  void dispose() {
    addRelayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Stack(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Add new relay',
                  ),
                  controller: addRelayController,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: ElevatedButton(
                    style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(purpleColor)),
                    onPressed: () {
                      widget.addRelay(addRelayController.text);
                    },
                    child: const Icon(Icons.add),
                  ), // Elevated Button
                ), // Positioned
              ],
            ) // Stack
          ],
        ), // Column
      ),
    );
  } // Widget Build
}
