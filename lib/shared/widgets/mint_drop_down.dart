import 'package:flutter/material.dart';

class MintDropdownButton extends StatefulWidget {
  final List<String> mints;
  final Function setMint;
  final String? activeMint;

  const MintDropdownButton(
      {super.key,
      required this.mints,
      required this.activeMint,
      required this.setMint});

  @override
  State<MintDropdownButton> createState() => _MintDropdownButtonState();
}

class _MintDropdownButtonState extends State<MintDropdownButton> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: widget.activeMint,
      icon: const Icon(Icons.arrow_downward),
      elevation: 6,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? value) {
        if (value != null) {
          widget.setMint(value);
        }
      },
      items: widget.mints.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.90,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
