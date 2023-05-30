import 'package:flutter/material.dart';

import 'package:cashcrab/bridge_definitions.dart';
import 'package:cashcrab/screens/send.dart';
import 'package:cashcrab/bridge_generated.dart';
import 'package:cashcrab/screens/ln/invoice_info.dart';

import '../screens/receive.dart';
import '../screens/token_info.dart';
import '../shared/utils.dart';

class Home extends StatefulWidget {
  final int balance;
  final int activeBalance;
  final String? activeMint;
  final RustImpl cashu;
  final Map<String, Transaction> pendingTransactions;
  final Map<String, Transaction> transactions;
  final Map<String, int> mints;
  final TokenData? tokenData;
  final Function decodeToken;
  final Function receiveToken;
  final Function clearToken;
  final Function send;
  final Function addMint;
  final Function checkTransactionStatus;
  final Function createInvoice;

  const Home(
      {super.key,
      required this.balance,
      required this.activeBalance,
      required this.activeMint,
      required this.pendingTransactions,
      required this.transactions,
      required this.cashu,
      required this.mints,
      required this.decodeToken,
      required this.receiveToken,
      required this.clearToken,
      required this.send,
      required this.addMint,
      required this.checkTransactionStatus,
      required this.createInvoice,
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
                if (widget.pendingTransactions.isNotEmpty)
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  const Text(
                    "Pending Transactions",
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                if (widget.pendingTransactions.isNotEmpty)
                  Flexible(
                    child: TransactionList(
                      ptransactions: widget.pendingTransactions,
                      checkSpendable: widget.checkTransactionStatus,
                      checkLightingPaid: widget.checkTransactionStatus,
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
                    ptransactions: widget.transactions,
                    checkSpendable: null,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
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
                          decodeToken: widget.decodeToken,
                          receiveToken: widget.receiveToken,
                          mints: widget.mints,
                          addMint: widget.addMint,
                          createInvoice: widget.createInvoice,
                        ),
                      ),
                    );
                  },
                  child: const Text('Receive'),
                ),
              ),
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
            ], // Button row children
          ), // Button Row
        ], // body children
      ), // Body column
    );
  } // Build widget
}

class TransactionList extends StatelessWidget {
  final Map<String, Transaction> ptransactions;
  final Function? checkSpendable;
  final Function? checkLightingPaid;

  const TransactionList({
    super.key,
    required this.ptransactions,
    this.checkSpendable,
    this.checkLightingPaid,
  });

  List<Transaction> sortTransactions(Map<String, Transaction> transactions) {
    List<Transaction> transactionsList = transactions.values.toList();

    transactionsList.sort((a, b) {
      int timeA, timeB;
      if (a.field0 is CashuTransaction) {
        timeA = (a.field0 as CashuTransaction).time;
      } else {
        timeA = (a.field0 as LNTransaction).time;
      }

      if (b.field0 is CashuTransaction) {
        timeB = (b.field0 as CashuTransaction).time;
      } else {
        timeB = (b.field0 as LNTransaction).time;
      }

      return timeA.compareTo(timeB);
    });

    return transactionsList;
  }

  @override
  Widget build(BuildContext context) {
    List<Transaction> transactions = sortTransactions(ptransactions);
    return SingleChildScrollView(
      child: ListView.builder(
        reverse: true,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: transactions.length,
        itemBuilder: (BuildContext context, int index) {
          IconData statusIcon = Icons.pending;
          Transaction t = transactions[index];
          dynamic transaction = t.field0 is LNTransaction
              ? (t.field0 as LNTransaction)
              : (t.field0 as CashuTransaction);
          Text amountText;
          switch (transaction.status) {
            case TransactionStatus.Sent:
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
            case TransactionStatus.Received:
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
            case TransactionStatus.Pending:
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
            case TransactionStatus.Expired:
              statusIcon = Icons.close;
              amountText = Text(
                "${transaction.amount} sats",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w100,
                  color: Colors.grey,
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
              } else if (transaction is LNTransaction) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InvoiceInfoScreen(
                        mintUrl: transaction.mint,
                        amount: transaction.amount,
                        invoice: transaction),
                  ),
                );
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
                        Transaction t =
                            Transaction.cashuTransaction(transaction);
                        checkSpendable!(t);
                      } else if (transaction is LNTransaction) {
                        Transaction t = Transaction.lnTransaction(transaction);
                        checkLightingPaid!(t);
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
