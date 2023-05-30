import 'package:cashcrab/screens/contact_payment.dart';
import 'package:cashcrab/shared/utils.dart';
import 'package:cashcrab/shared/widgets/invoice_message.dart';
import 'package:cashcrab/shared/widgets/text_message.dart';
import 'package:cashcrab/shared/widgets/token_message.dart';
import 'package:flutter/material.dart';
import 'package:cashcrab/bridge_generated.dart';
import 'package:cashcrab/bridge_definitions.dart';

class Messages extends StatefulWidget {
  final RustImpl api;
  final String peerPubkey;
  final String? peerName;
  final String? activeMint;
  final int activeMintBalance;
  final Function receiveToken;
  final Function sendToken;
  final Function createInvoice;
  final Function payInvoice;
  final Map<String, int> mints;

  const Messages({
    super.key,
    required this.activeMint,
    required this.activeMintBalance,
    required this.peerPubkey,
    required this.peerName,
    required this.mints,
    required this.receiveToken,
    required this.sendToken,
    required this.createInvoice,
    required this.payInvoice,
    required this.api,
  });

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Message> messages = [];
  Map<String, Transaction> transactions = {};

  _MessagesState();

  @override
  void initState() {
    super.initState();
    getMessages(widget.peerPubkey);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Future<void> getMessages(String pubkey) async {
    Conversation c = await widget.api.getConversation(pubkey: pubkey);

    Map<String, Transaction> t = {};

    for (var transaction in c.transactions) {
      transaction.when(cashuTransaction: (cashu) {
        if (cashu.id != null) {
          t[cashu.id!] = transaction;
        }
      }, lnTransaction: (ln) {
        if (ln.id != null) {
          t[ln.id!] = transaction;
        }
      });
    }

    setState(() {
      messages = c.messages;
      transactions = t;
    });
  }

  Future<void> sendMessage(Message msg) async {
    Conversation c =
        await widget.api.sendMessage(pubkey: widget.peerPubkey, message: msg);
    _textEditingController.clear();

    setState(() {
      _addMessage(c);
    });
  }

  Future<Message> createMessage() async {
    String msg = _textEditingController.text;
    Message message;
    if (msg.startsWith("/send")) {
      List<String> splits = msg.split(' ');

      Transaction transaction = await widget.sendToken(int.parse(splits[1]));

      CashuTransaction cTransaction = transaction.field0 as CashuTransaction;

      message = Message.token(
          direction: Direction.Sent,
          time: cTransaction.time,
          transactionId: cTransaction.id!);
    } else if (msg.startsWith("/request")) {
      List<String> splits = msg.split(' ');
      LNTransaction transaction =
          await widget.createInvoice(int.parse(splits[1]), widget.activeMint);

      message = Message.invoice(
          direction: Direction.Sent,
          time: transaction.time,
          transactionId: transaction.id!);
    } else {
      message = Message.text(
          content: msg,
          time: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          direction: Direction.Sent);
    }

    return message;
  }

  // Scroll to bottom when new message is added
  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

// Call _scrollToBottom() after adding new message
  void _addMessage(Conversation addedConversation) {
    setState(() {
      messages = messages + addedConversation.messages;

      for (var transaction in addedConversation.transactions) {
        transaction.when(cashuTransaction: (cashu) {
          if (cashu.id != null) {
            transactions[cashu.id!] = transaction;
          }
        }, lnTransaction: (ln) {
          if (ln.id != null) {
            transactions[ln.id!] = transaction;
          }
        });
      }
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.peerName ?? truncateText(widget.peerPubkey)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: messages.length,
              itemBuilder: (BuildContext context, int index) {
                int reversedIndex = messages.length - 1 - index;
                Message message = messages[reversedIndex];
                Widget messageRow = Container();

                message.when(
                  text: (dir, time, textContent) {
                    messageRow = TextMessageWidget(time, textContent, dir);
                  },
                  invoice: (dir, time, transactionId) {
                    LNTransaction? transaction;

                    if (transactions[transactionId] != null) {
                      transaction =
                          transactions[transactionId]!.field0 as LNTransaction;
                    }
                    messageRow = InvoiceMessageWidget(
                      dir,
                      transaction,
                      widget.payInvoice,
                    );
                  },
                  token: (dir, time, transactionId) {
                    CashuTransaction? transaction;

                    if (transactions[transactionId] != null) {
                      transaction = transactions[transactionId]!.field0
                          as CashuTransaction;
                    }

                    messageRow = TokenMessageWidget(
                        widget.receiveToken, dir, transaction);
                  },
                );

                return GestureDetector(
                  onTap: () {},
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: messageRow,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.wallet),
                  onPressed: () {
                    if (widget.activeMint != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContactPayment(
                            peerPubkey: widget.peerPubkey,
                            peerName: widget.peerName,
                            api: widget.api,
                            createInvoice: widget.createInvoice,
                            sendToken: widget.sendToken,
                            send: sendMessage,
                            activeMint: widget.activeMint!,
                            activeBalance: widget.activeMintBalance,
                          ),
                        ),
                      );
                    }
                    // ELSE set mint modal
                  },
                ),
                Flexible(
                  child: TextField(
                    controller: _textEditingController,
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      labelText: 'Message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    if (_textEditingController.text.isNotEmpty) {
                      // Handle send button action
                      Message msg = await createMessage();
                      await sendMessage(msg);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
