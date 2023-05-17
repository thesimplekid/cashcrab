import 'package:cashcrab/bridge_definitions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:cashcrab/bridge_generated.dart';

import '../screens/send.dart';
import '../screens/receive.dart';
import '../shared/models/transaction.dart';
import '../shared/utils.dart';

class Home extends StatefulWidget {
  final int balance;
  final int activeBalance;
  final String? activeMint;
  final RustImpl cashu;
  final List<CashuTransaction> pendingCashuTransactions;
  final List<CashuTransaction> cashuTransactions;
  final List<LightningTransaction> pendingLightningTransactions;
  final List<LightningTransaction> lightningTransactions;
  final Map<String, int> mints;
  final TokenData? tokenData;
  final Function decodeToken;
  final Function receiveToken;
  final Function clearToken;
  final Function send;
  final Function addMint;
  final Function checkTransactionStatus;
  final Function checkLightningTransaction;
  final Function setInvoices;

  const Home(
      {super.key,
      required this.balance,
      required this.activeBalance,
      required this.activeMint,
      required this.pendingCashuTransactions,
      required this.cashuTransactions,
      required this.cashu,
      required this.pendingLightningTransactions,
      required this.lightningTransactions,
      required this.mints,
      required this.decodeToken,
      required this.receiveToken,
      required this.clearToken,
      required this.send,
      required this.addMint,
      required this.checkTransactionStatus,
      required this.checkLightningTransaction,
      required this.setInvoices,
      this.tokenData});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  _HomeState();
  int amountToSend = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Transaction> transactions = [
      ...widget.cashuTransactions,
      ...widget.lightningTransactions
    ];
    transactions.sort((a, b) => a.time.compareTo(b.time));

    List<Transaction> pendingTransactions = [
      ...widget.pendingCashuTransactions,
      ...widget.pendingLightningTransactions
    ];
    pendingTransactions.sort((a, b) => a.time.compareTo(b.time));

    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 120.0,
            child: Column(
              children: [
                const Text(
                  "Active Mint Balance",
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.activeBalance.toString(),
                        style: const TextStyle(
                          fontSize: 60.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ), // Balance Text
                      const SizedBox(
                        height: 60.0,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Text(" sats"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ), // Balance Container
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.balance),
                Text(
                  " Total Balance: ${widget.balance.toString()} sats",
                  style: const TextStyle(
                    fontSize: 20.0,
                  ),
                )
              ],
            ),
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.home),
                Flexible(
                  child: Text(
                    (widget.activeMint != null)
                        ? " ${widget.activeMint!}"
                        : ' no mint set',
                    style: const TextStyle(
                      fontSize: 20.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (pendingTransactions.isNotEmpty)
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  const Text(
                    "Pending Transactions",
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                if (pendingTransactions.isNotEmpty)
                  Flexible(
                    child: TransactionList(
                      transactions: pendingTransactions,
                      checkSpendable: widget.checkTransactionStatus,
                      checkLightingPaid: widget.checkLightningTransaction,
                      sendToken: _sendTokenDialog,
                      lightningDialog: _createLightningDialog,
                    ),
                  ),
                const Text(
                  "Transactions",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
                Flexible(
                  child: TransactionList(
                      transactions: transactions,
                      checkSpendable: null,
                      lightningDialog: _createLightningDialog,
                      sendToken: _sendTokenDialog),
                ),
              ],
            ),
          ),
          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 70),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Send(
                          setInvoices: widget.setInvoices,
                          cashu: widget.cashu,
                          wallets: widget.mints,
                          decodeToken: widget.decodeToken,
                          send: widget.send,
                          activeMint: widget.activeMint,
                          activeBalance: widget.activeBalance,
                        ),
                      ),
                    );
                  },
                  child: const Text('Send'),
                ),
              ),
              Flexible(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 70),
                  ),
                  onPressed: () {
                    widget.clearToken();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReceviceToken(
                          activeWallet: widget.activeMint,
                          cashu: widget.cashu,
                          setInvoices: widget.setInvoices,
                          invoices: widget.lightningTransactions,
                          pendingInvoices: widget.pendingLightningTransactions,
                          decodeToken: widget.decodeToken,
                          receiveToken: widget.receiveToken,
                          mints: widget.mints,
                          addMint: widget.addMint,
                        ),
                      ),
                    );
                  },
                  child: const Text('Receive'),
                ),
              ),
            ], // Button row children
          ), // Button Row
        ], // body children
      ), // Body column
    );
  } // Build widget

  void _createLightningDialog(int amount, String mintUrl,
      LightningTransaction passedTransaction) async {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Send'),
            content: SizedBox(
              height: 200,
              child: Column(
                children: [
                  SizedBox(
                    height: 50,
                    child: SingleChildScrollView(
                      child: Text(passedTransaction.invoice.invoice!),
                    ),
                  ),
                  Wrap(
                    children: [
                      Text(
                        "Invoice ${passedTransaction.amount.toString()}",
                      ), // Mint Text
                    ],
                  ), // Wrap
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await Clipboard.setData(
                      ClipboardData(text: passedTransaction.invoice.invoice));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied to clipboard'),
                      ),
                    );
                  }
                },
                child: const Text('Copy'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _sendTokenDialog(int amount, TokenData? token) async {
    late TokenData tokenData;
    if (token == null) {
      String result = await widget.send(amount);
      tokenData = await widget.decodeToken(result);
    } else {
      tokenData = token;
    }

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Send'),
            content: SizedBox(
              height: 200,
              child: Column(
                children: [
                  SizedBox(
                    height: 50,
                    child: SingleChildScrollView(
                      child: Text(tokenData.encodedToken),
                    ),
                  ),
                  Wrap(
                    children: [
                      Text(
                        "Mint: ${tokenData.mint}",
                      ), // Mint Text
                    ],
                  ), // Wrap
                  Text("Amount: ${tokenData.amount} sat(s)")
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: tokenData.encodedToken),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied to clipboard'),
                      ),
                    );
                  }
                },
                child: const Text('Copy'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  final Function? checkSpendable;
  final Function? checkLightingPaid;
  final Function sendToken;
  final Function lightningDialog;

  const TransactionList(
      {super.key,
      required this.transactions,
      this.checkSpendable,
      this.checkLightingPaid,
      required this.sendToken,
      required this.lightningDialog});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ListView.builder(
        reverse: true,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: transactions.length,
        itemBuilder: (BuildContext context, int index) {
          IconData statusIcon = Icons.pending;
          Transaction transaction = transactions[index];
          Text amountText;
          switch (transaction.status) {
            case TransactionStatus.sent:
              statusIcon = Icons.call_made;
              amountText = Text(
                "${transaction.amount} sats",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w100,
                  color: Colors.red,
                ),
              );
              break;
            case TransactionStatus.received:
              statusIcon = Icons.call_received;
              amountText = Text(
                "${transaction.amount} sats",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w100,
                  color: Colors.green,
                ),
              );
              break;
            default:
              amountText = Text(
                "${transaction.amount} sats",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w100,
                  color: Colors.red,
                ),
              );
          }

          return GestureDetector(
            onTap: () {
              if (transaction is CashuTransaction) {
                sendToken(transaction.amount, transaction.token);
              } else if (transaction is LightningTransaction) {
                lightningDialog(
                    transaction.amount, transaction.mintUrl, transaction);
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon),
                if (checkSpendable != null || checkLightingPaid != null)
                  GestureDetector(
                    onTap: () {
                      if (transaction is CashuTransaction) {
                        checkSpendable!(transaction);
                      } else if (transaction is LightningTransaction) {
                        checkLightingPaid!(transaction);
                      }
                    },
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
                amountText,
              ],
            ),
          );
        },
      ),
    );
  }
}
