> **Warning**
> This project is in early development, it does however work with real sats! Always use amounts you don't mind loosing.

# cashcrab

A [Cashu](https://github.com/cashubtc/cashu) wallet with a flutter UI and with as much logic as possible in rust using [cashu-crab](https://github.com/thesimplekid/cashu-crab). 

## Flutter Rust Bridge

Generate Dart from rust
```sh
flutter_rust_bridge_codegen --rust-input ./src/api.rs --dart-output ../lib/bridge_generated.dart --c-output ../ios/Runner/bridge_generated.h --dart-decl-output ../lib/bridge_definitions.dart

```


## Credit
Thanks to [calle](https://github.com/callebtc) for the name.

Flutter Rust Example: https://github.com/sccheruku/flutter_rust_example