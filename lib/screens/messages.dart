import 'package:flutter/material.dart';
import 'package:cashcrab/bridge_generated.dart';
import 'package:cashcrab/bridge_definitions.dart';

class Messages extends StatefulWidget {
  final RustImpl api;
  final String peerPubkey;
  final String? activeMint;
  final Function receiveToken;
  final Function sendToken;
  final Function createInvoice;
  final Function payInvoice;
  final Map<String, int> mints;

  const Messages({
    super.key,
    required this.activeMint,
    required this.peerPubkey,
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
  List<Message> messages = List.empty(growable: true);
  _MessagesState();

  @override
  void initState() {
    super.initState();
    getMessages(widget.peerPubkey);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Future<void> getMessages(String pubkey) async {
    List<Message> gotMessages = await widget.api.getMessages(pubkey: pubkey);

    setState(() {
      messages = gotMessages;
    });
  }

  Future<void> sendMessage(Message msg) async {
    Message message =
        await widget.api.sendMessage(pubkey: widget.peerPubkey, message: msg);
    _textEditingController.clear();

    setState(() {
      messages.add(message);
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
          time: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          token: cTransaction.token,
          mint: widget.activeMint!,
          amount: int.parse(splits[1]),
          status: TokenStatus.Spendable);
    } else if (msg.startsWith("/request")) {
      List<String> splits = msg.split(' ');
      LNTransaction transaction =
          await widget.createInvoice(int.parse(splits[1]), widget.activeMint);

      message = Message.invoice(
          direction: Direction.Sent,
          time: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          bolt11: transaction.bolt11,
          amount: int.parse(splits[1]),
          status: InvoiceStatus.Unpaid);
    } else {
      message = Message.text(
          content: msg,
          time: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          direction: Direction.Sent);
    }

    return message;
  }

  String truncateText(String text) {
    if (text.length <= 10) {
      return text; // No truncation needed
    } else {
      return "${text.substring(0, 10)} ...";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: messages.length,
                itemBuilder: (BuildContext context, int index) {
                  Message message = messages[index];
                  String content;
                  Direction msgDirection;
                  Widget messageRow = Container();

                  message.when(
                    text: (dir, time, textContent) {
                      msgDirection = dir;
                      content = textContent;
                      messageRow = Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (msgDirection == Direction.Received) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(content),
                            ),
                          ] else ...[
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.purple,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(content,
                                  style: const TextStyle(color: Colors.white)),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ],
                      );
                    },
                    invoice: (dir, time, bolt11, amount, status) {
                      msgDirection = dir;
                      content = bolt11;
                      messageRow = Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (msgDirection == Direction.Received) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(content),
                            ),
                          ] else ...[
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.purple,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Column(
                                    children: [
                                      const Text("Lightning Invoice"),
                                      Text("Amount: ${amount ?? 0}"),
                                      ElevatedButton(
                                        onPressed: () async {
                                          widget.payInvoice(bolt11,
                                              widget.activeMint, amount);
                                        },
                                        // TODO: Check if paid
                                        child: const Text('Pay Invoice'),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ],
                      );
                    },
                    token: (dir, time, token, mint, amount, status) {
                      msgDirection = dir;
                      content = token;
                      // TODO: Decode token
                      messageRow = Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (msgDirection == Direction.Received) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(content),
                            ),
                          ] else ...[
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.purple,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Column(
                                    children: [
                                      const Text("Cashu Token"),
                                      Text("Amount: ${amount ?? 0}"),
                                      Text("Mint: $mint"),
                                      // TODO: Check if spendable
                                      ElevatedButton(
                                        onPressed: () async {
                                          widget.receiveToken(token);
                                        },
                                        child: const Text('Redeam'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ],
                      );
                    },
                  );

                  return GestureDetector(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: messageRow,
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
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
                ElevatedButton(
                  onPressed: () async {
                    // Handle send button action
                    Message msg = await createMessage();
                    await sendMessage(msg);
                  },
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
