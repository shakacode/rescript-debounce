# rescript-debounce-react

[![version](https://img.shields.io/npm/v/rescript-debounce-react.svg?style=flat-square)](https://www.npmjs.com/package/rescript-debounce-react)
[![license](https://img.shields.io/npm/l/rescript-debounce-react.svg?style=flat-square)](https://www.npmjs.com/package/rescript-debounce-react)
[![build](https://github.com/shakacode/rescript-debounce/actions/workflows/ci.yml/badge.svg)](https://github.com/shakacode/rescript-debounce/actions/workflows/ci.yml)

Debounce hooks for `@rescript/react`.

> ### ShakaCode
> If you are looking for help with the development and optimization of your project, [ShakaCode](https://www.shakacode.com) can help you to take the reliability and performance of your app to the next level.
>
> If you are a developer interested in working on ReScript / TypeScript / Rust / Ruby on Rails projects, [we're hiring](https://www.shakacode.com/career/)!

## Installation

```shell
# yarn
yarn add rescript-debounce-react
# or npm
npm install --save rescript-debounce-react
```

Then add it to `rescript.json`:

```json
"bs-dependencies": [
  "rescript-debounce-react"
]
```

## Usage

```rescript
// With default timeout (100ms)
let fn = fn->ReactDebounce.useDebounced

// With configured timeout
let fn = fn->ReactDebounce.useDebounced(~wait=250)

// Controlled hook
let fn = fn->ReactDebounce.useControlled
```

See [`rescript-debounce`](https://www.npmjs.com/package/rescript-debounce) for more details.

## License

MIT.
