import 'package:flutter/material.dart';

class AddMintDialog extends StatelessWidget {
  const AddMintDialog(this.title, this.subTitle, this.mintUrl, this.onAdd,
      this.addMintController, {super.key});

  final String title;
  final String subTitle;
  final String mintUrl;
  final Function onAdd;
  final TextEditingController? addMintController;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: SizedBox(
        height: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title),
            Text(subTitle),
            Text("Add Mint: $mintUrl"),
            const Spacer(),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    onAdd(mintUrl);
                    Navigator.of(context).pop();
                    if (addMintController != null) {
                      addMintController!.clear();
                    }
                  },
                  child: const Text("Add"),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (addMintController != null) {
                      addMintController!.clear();
                    }
                  },
                  child: const Text("Cancel"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
