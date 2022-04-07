# repl.wasm
BCDice playground by ruby.wasm

## Dependencies

- [wasi-vfs](https://github.com/kateinoigakukun/wasi-vfs/): Only CLI tool is required

## Development

```console
$ make
$ npm install
$ npm start
```

## Known issues
- i18n is not working. `I18n.t` returns nil every time.
- Dynamic loading of some game systems fails. e.g.) `FutariSouda`, `Nechronica:Korean`
