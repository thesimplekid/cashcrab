import 'dart:convert';
import 'dart:io';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:cashcrab/bridge_definitions.dart';
import 'package:cashcrab/screens/cashu/inbox.dart';
import 'package:cashcrab/bridge_generated.dart';
import 'package:cashcrab/screens/contacts/contacts.dart';

import 'color_schemes.g.dart';
import 'screens/home.dart';
import 'screens/settings/settings.dart';

const base = "rust";
final path = Platform.isWindows ? "$base.dll" : "lib$base.so";
final dylib = Platform.isIOS
    ? DynamicLibrary.process()
    : Platform.isMacOS
        ? DynamicLibrary.executable()
        : DynamicLibrary.open(path);

final api = RustImpl(dylib);

void main() => runApp(const MyApp());

class AppData {}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cashu',
      theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
      themeMode: ThemeMode.dark,
      home: const MyHomePage(title: 'Cashu Wallet'),
    );
  }

  const MyApp({Key? key}) : super(key: key);
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 2;

  Map<String, int> mints = {};
  int balance = 0;
  String? activeMint;
  int activeBalance = 0;

  TokenData? tokenData;

  Map<String, Transaction> pendingTransactions = {};
  Map<String, Transaction> transactions = {};

  List<Contact> contacts = [];

  late List<Widget> _widgetOptions;

  late Home _homeTab;
  late Settings _settingsTab;
  late Contacts _contactsTab;
  late Inbox _inboxTab;

  @override
  void initState() {
    super.initState();
    _initDB();
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<void> _initDB() async {
    await api.initDb(storagePath: await _localPath);
    await api.initCashu();
    String? key = await getNostrKey();
    String privKey =
        await api.initNostr(storagePath: await _localPath, privateKey: key);

    saveNostrKey(privKey);

    await _loadMints();

    // Load transaction
    await _loadTransactions();

    await _getActiveMint();

    await _loadContacts();

    // TODO: Fetech new messages

    // Set balances
    await _getBalances();
    // Set Balance
    _getBalance();
  }

  _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    _contactsTab = Contacts(
      api: api,
      mints: mints,
      receiveToken: receiveToken,
      sendToken: sendToken,
      createInvoice: createInvoice,
      payInvoice: payInvoice,
      contacts: contacts,
      addContact: addContact,
      loadContacts: _loadContacts,
      removeContact: removeContact,
      activeMint: activeMint,
      activeMintBalance: activeBalance,
    );
    _homeTab = Home(
      api: api,
      balance: balance,
      activeBalance: activeBalance,
      activeMint: activeMint,
      tokenData: tokenData,
      pendingTransactions: pendingTransactions,
      transactions: transactions,
      mints: mints,
      decodeToken: _decodeToken,
      clearToken: clearToken,
      receiveToken: receiveToken,
      send: sendToken,
      addMint: _addNewMint,
      checkTransactionStatus: _checkTransactionStatus,
      createInvoice: createInvoice,
      payInvoice: payInvoice,
    );

    _settingsTab = Settings(
      api: api,
      mints: mints,
      contacts: contacts,
      loadContacts: _loadContacts,
      addContact: addContact,
      addMint: _addNewMint,
      removeMint: removeMint,
      activeMint: activeMint,
      setActiveMint: _setActiveMint,
      nostrLogOut: nostrLogout,
      mintSwap: swapMint,
      loadMints: _loadMints,
      restoreTokens: restoreTokens,
    );

    _inboxTab = Inbox(api: api, redeamInbox: redeamInbox);

    _widgetOptions = <Widget>[_inboxTab, _contactsTab, _homeTab, _settingsTab];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 40.0),
        child: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.inbox), label: 'Inbox'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Messages'),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  void redeamInbox() async {
    await api.redeamInbox();
    await _loadTransactions();
    await _getBalances();
  }

  Future<void> restoreTokens() async {
    await api.restoreTokens();

    await _loadTransactions();
    await _getBalances();
  }

  void saveNostrKey(String key) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: "nostr_private_key", value: key);
  }

  Future<String?> getNostrKey() async {
    const storage = FlutterSecureStorage();
    return await storage.read(key: "nostr_private_key");
  }

  void deleteNostrKey() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: "nostr_private_key");
  }

  void nostrLogout() async {
    deleteNostrKey();
    await api.nostrLogout();
  }

  Future<LNTransaction> createInvoice(int amount, String mint) async {
    Transaction result = await api.requestMint(amount: amount, mintUrl: mint);

    LNTransaction lnt = result.field0 as LNTransaction;
    setState(() {
      pendingTransactions[lnt.id!] = result;
    });

    return lnt;
  }

  Future<LNTransaction?> payInvoice(
      String bolt11, String? mint, int amount) async {
    mint ??= activeMint;
    LNTransaction? lnt;
    try {
      Transaction transaction =
          await api.melt(invoice: bolt11, mint: mint!, amount: amount);

      setState(() {
        lnt = transaction.field0 as LNTransaction;
        transactions[lnt!.id!] = transaction;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
    await _getBalances();
    return lnt;
  }

  Future<void> _getBalances() async {
    final gotBalances = await api.getBalances();
    Map<String, dynamic> bal = json.decode(gotBalances);
    setState(() {
      mints = bal.cast<String, int>();
    });
    _getBalance();
  }

  Future<void> swapMint(String fromMint, String toMint, int amount) async {
    await api.mintSwap(fromMint: fromMint, toMint: toMint, amount: amount);
    print("mints swapped?");
  }

  /// Get total balance of all mints
  void _getBalance() {
    int bal = mints.values.fold(0, (acc, value) => acc + value);

    setState(() {
      balance = bal;
      if (activeMint != null) {
        activeBalance = mints[activeMint] ?? 0;
      }
    });
  }

  Future<TokenData?> _decodeToken(String token) async {
    try {
      final data = await api.decodeToken(encodedToken: token);
      setState(() {
        tokenData = data;
      });
      return data;
    } catch (e) {
      debugPrint('Failed to decode token: $e');
      return null;
    }
  }

  Future<TransactionStatus> _checkTransactionStatus(
      Transaction transaction) async {
    final TransactionStatus status =
        await api.checkSpendable(transaction: transaction);

    if (status != const TransactionStatus.pending(Pending.Send) &&
        (status != const TransactionStatus.pending(Pending.Receive))) {
      String id = transaction.field0 is LNTransaction
          ? (transaction.field0 as LNTransaction).id!
          : (transaction.field0 as CashuTransaction).id!;
      Transaction? updatedTransaction = await api.getTransaction(tid: id);
      setState(() {
        String id = transaction.field0 is LNTransaction
            ? (transaction.field0 as LNTransaction).id!
            : (transaction.field0 as CashuTransaction).id!;
        pendingTransactions.remove(id);

        transactions[id] = updatedTransaction!;
      });
    }

    _getBalances();

    return status;
  }

  void clearToken() async {
    setState(() {
      tokenData = null;
    });
  }

  void receiveToken(String? encodedToken) async {
    if (encodedToken != null) {
      await _decodeToken(encodedToken);
    }
    if (tokenData?.encodedToken != null) {
      Transaction transaction =
          await api.receiveToken(encodedToken: tokenData!.encodedToken);
      // REVIEW: how does this handle a failed token that shouldned be added
      String id = transaction.field0 is LNTransaction
          ? (transaction.field0 as LNTransaction).id!
          : (transaction.field0 as CashuTransaction).id!;

      if (activeMint == null) {
        await api.setActiveMint(mintUrl: tokenData!.mint);
      }

      setState(() {
        transactions[id] = transaction;
        activeMint ??= tokenData!.mint;
      });

      await _getBalances();
    }
  }

  Future<Transaction?> sendToken(int amount) async {
    if (activeMint == null) {
      return null;
    }

    Transaction transaction =
        await api.send(amount: amount, activeMint: activeMint!);
    CashuTransaction t = transaction.field0 as CashuTransaction;
    String id = t.id!;

    setState(() {
      pendingTransactions[id] = transaction;
    });

    // Recaulate balances
    await _getBalances();
    _getBalance();

    debugPrint("AFTER $mints");
    return (transaction);
  }

  Future<Mint?> _getActiveMint() async {
    Mint? mint = await api.getActiveMint();
    setState(() {
      activeMint = mint?.url;
    });
    await _getBalances();
    _getBalance();

    return mint;
  }

  // Set active in storage
  Future<void> _setActiveMint(String? newActiveMint) async {
    await api.setActiveMint(mintUrl: newActiveMint);
    Mint? active = await api.getActiveMint();

    setState(() {
      activeMint = active!.url;
    });
    await _getBalances();
    _getBalance();
  }

  Future<void> _loadTransactions() async {
    List<Transaction> gotTransactions = await api.getTransactions();

    Map<String, Transaction> loadedTransactions = {};
    Map<String, Transaction> loadedPendingTransactions = {};

    for (var transaction in gotTransactions) {
      dynamic t = transaction.field0;
      String id;
      TransactionStatus status;
      Transaction newTransaction;
      if (t is CashuTransaction) {
        CashuTransaction trans = t;
        id = trans.id!;
        status = trans.status;
        newTransaction = Transaction.cashuTransaction(trans);
      } else {
        LNTransaction trans = t as LNTransaction;

        id = trans.id!;
        status = trans.status;
        newTransaction = Transaction.lnTransaction(trans);
      }

      if (status == const TransactionStatus.pending(Pending.Send) ||
          (status == const TransactionStatus.pending(Pending.Receive))) {
        loadedPendingTransactions[id] = newTransaction;
      } else {
        loadedTransactions[id] = newTransaction;
      }
    }

    setState(() {
      transactions = loadedTransactions;
      pendingTransactions = loadedPendingTransactions;
    });
  }

  /// Load Contacts
  Future<void> _loadContacts() async {
    List<Contact> gotContacts = await api.getContacts();

    setState(() {
      contacts = gotContacts;
    });
  }

  Future<void> addContact(String pubkey) async {
    if (pubkey.length >= 63) {
      await api.addContact(pubkey: pubkey);

      await _loadContacts();
    }
  }

  Future<void> fetchContacts(String pubkey) async {
    await api.fetchContacts(pubkey: pubkey);
    _loadContacts();
  }

  Future<void> removeContact(String pubkey) async {
    if (pubkey.length >= 63) {
      await api.removeContact(pubkey: pubkey);

      await _loadContacts();
    }
  }

  Future<void> _loadMints() async {
    List<Mint> gotMints = await api.getMints();

    Map<String, int> m = {};
    for (var mint in gotMints) {
      m[mint.url] = 0;
    }

    setState(() {
      mints = m;
    });
  }

  Future<void> removeMint(String mintUrl) async {
    // Should only allow if balance is 0
    await _getBalances();

    if (mints[mintUrl] == 0) {
      mints.remove(mintUrl);
      await api.removeWallet(url: mintUrl);
      if (activeMint != null && mintUrl == activeMint) {
        String? newActive;

        List<String> mintUrls = mints.keys.toList();

        if (mints.isNotEmpty) {
          newActive = mintUrls[0];
        }

        _setActiveMint(newActive);
      }
    }
  }

  Future<void> _addNewMint(String mintUrl) async {
    // TODO: Should handle error connecting to mint
    await api.addMint(url: mintUrl);
    _loadMints();
    mints[mintUrl] = 0;
  }
}
