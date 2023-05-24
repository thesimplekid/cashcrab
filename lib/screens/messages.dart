import 'package:cashcrab/shared/widgets/invoice_message.dart';
import 'package:cashcrab/shared/widgets/text_message.dart';
import 'package:cashcrab/shared/widgets/token_message.dart';
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
  final ScrollController _scrollController = ScrollController();

  List<Message> messages = List.empty(growable: true);
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

  // Scroll to bottom when new message is added
  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

// Call _scrollToBottom() after adding new message
  void _addMessage(Message message) {
    setState(() {
      messages.add(message);
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  invoice: (dir, time, bolt11, amount, status) {
                    messageRow = InvoiceMessageWidget(
                      dir,
                      amount ?? 0,
                      time,
                      bolt11,
                      status,
                      widget.activeMint ?? "",
                      widget.payInvoice,
                    );
                  },
                  token: (dir, time, token, mint, amount, status) {
                    messageRow = TokenMessageWidget(
                      amount ?? 0,
                      token,
                      mint,
                      widget.receiveToken,
                      dir,
                    );
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
