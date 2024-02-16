# rescript-debounce

[![version](https://img.shields.io/npm/v/rescript-debounce.svg?style=flat-square)](https://www.npmjs.com/package/rescript-debounce)
[![license](https://img.shields.io/npm/l/rescript-debounce.svg?style=flat-square)](https://www.npmjs.com/package/rescript-debounce)
[![build](https://github.com/shakacode/rescript-debounce/actions/workflows/ci.yml/badge.svg)](https://github.com/shakacode/rescript-debounce/actions/workflows/ci.yml)

Debounce for ReScript. For usage with React, see [`rescript-debounce-react`](https://www.npmjs.com/package/rescript-debounce-react).

> ### ShakaCode
> If you are looking for help with the development and optimization of your project, [ShakaCode](https://www.shakacode.com) can help you to take the reliability and performance of your app to the next level.
>
> If you are a developer interested in working on ReScript / TypeScript / Rust / Ruby on Rails projects, [we're hiring](https://www.shakacode.com/career/)!

## Installation

```shell
# yarn
yarn add rescript-debounce
# or npm
npm install --save rescript-debounce
```

Then add it to `rescript.json`:

```json
"bs-dependencies": [
  "rescript-debounce"
]
```

## Usage

```rescript
// Pass function you want to debounce
let fn = fn->Debounce.make

// You can configure timeout. Default is 100ms.
let fn = fn->Debounce.make(~wait=500)

// This call is debounced
fn()
```

Also, you can get more control over the debouncing:

```rescript
let fn = fn->Debounce.makeControlled

// Schedule invocation
fn.schedule()

// Cancel invocation
fn.cancel()

// Check if invocation is scheduled
fn.scheduled() // => false

// Invoke immediately
fn.invoke()
```

Note that if you invoke immediately all scheduled invocations (if any) are canceled.

## Caveats
#### I need to pass multiple arguments to debounced function
Pack those in a tuple:

```rescript
let fn = Debounce.make(((one, two)) => /* use `one` & `two` */)
fn(("one", "two"))
```

#### It doesn't work, function is not debounced
The result of `Debounce.make(fn)` call **must** be bound to a variable (or a record property, a ref etc) for the later invocations. I.e. don't inline `Debounce.make(fn)` calls in `React.useEffect` and such, this won't work since debounced function will be re-created on every re-render:

```rescript
@react.component
let make = () => {
  let (state, dispatch) = reducer->React.useReducer(initialState)

  // Don't do this
  let fn = Debounce.make(() => DoStuff->dispatch)

  React.useEffect1(
    () => {
      fn()
      None
    },
    [state],
  )
}
```

If you want to define debounced function within component's body, use [`rescript-debounce-react`](https://www.npmjs.com/package/rescript-debounce-react).

## License

MIT.
