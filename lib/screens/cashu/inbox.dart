import 'package:cashcrab/screens/token_info.dart';
import 'package:cashcrab/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:cashcrab/bridge_generated.dart';
import 'package:cashcrab/bridge_definitions.dart';

class Inbox extends StatefulWidget {
  final RustImpl api;
  final Function redeamInbox;

  const Inbox({super.key, required this.api, required this.redeamInbox});

  @override
  State<Inbox> createState() => _InboxState();
}

class _InboxState extends State<Inbox> {
  List<Transaction> transactions = [];
  _InboxState();

  @override
  void initState() {
    super.initState();
    getTransactios();
  }

  Future<void> getTransactios() async {
    List<Transaction> trans = await widget.api.getInbox();

    setState(() {
      transactions = trans;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 70),
            ),
            onPressed: () {
              widget.redeamInbox();
              getTransactios();
            },
            child: const Text(
              'Redeam All',
              style: TextStyle(fontSize: 20),
            ),
          ), // Send button
          SingleChildScrollView(
            child: ListView.builder(
              reverse: true,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              itemBuilder: (BuildContext context, int index) {
                Transaction t = transactions[index];
                dynamic transaction = t.field0 is LNTransaction
                    ? (t.field0 as LNTransaction)
                    : (t.field0 as CashuTransaction);

                return GestureDetector(
                  onTap: () {
                    if (transaction is CashuTransaction) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TokenInfo(
                            amount: transaction.amount,
                            mintUrl: transaction.mint,
                            cashuTransaction: transaction,
                          ),
                        ),
                      );
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.pending),
                      GestureDetector(
                        onTap: () {},
                        child: const Icon(Icons.refresh),
                      ),
                      const Spacer(),
                      Column(
                        children: [
                          const Text(
                            // TODO: Show real memo
                            "No Memo",
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            formatTimeAgo(transaction.time),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w100,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        "${transaction.amount} sats",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w100,
                          color: Colors.green,
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
