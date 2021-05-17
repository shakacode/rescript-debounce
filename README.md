# rescript-debouncer

[![version](https://img.shields.io/npm/v/rescript-debouncer.svg?style=flat-square)](https://www.npmjs.com/package/rescript-debouncer)
[![license](https://img.shields.io/npm/l/rescript-debouncer.svg?style=flat-square)](https://www.npmjs.com/package/rescript-debouncer)
[![build](https://github.com/shakacode/rescript-debouncer/actions/workflows/ci.yml/badge.svg)](https://github.com/shakacode/rescript-debouncer/actions/workflows/ci.yml)

Debouncer for ReScript.

## Installation

```shell
# yarn
yarn add rescript-debouncer
# or npm
npm install --save rescript-debouncer
```

Then add it to `bsconfig.json`:

```json
"bs-dependencies": [
  "rescript-debouncer"
]
```

## Usage

```rescript
// Pass function you want to debounce
let fn = Debouncer.make(fn)

// You can configure timeout. Default is 100ms
let fn = Debouncer.make(~wait=500, fn)

// This call is debounced
fn()
```

Also, you can make debounced function calls cancelable:

```rescript
let fn = Debouncer.makeCancelable(fn)

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

## Example

```rescript
type state = {
  input: string,
  response: option<string>,
}

type action =
  | UpdateInput(string)
  | UpdateResponse(string)
  | ResetResponse

let reducer = (state, action) =>
  switch (action) {
  | UpdateInput(value) => {...state, input: value}
  | UpdateResponse(response) => {...state, response: response->Some}
  | ResetResponse => {...state, response: None}
  }

let initialState = {input: "", response: None}

module Api = {
  let getResponse =
    Debouncer.make(((input, dispatch)) => {
      // Defined elsewhere in your code
      getResponseAsync(input, response => UpdateResponse(response)->dispatch)
    })
};

@react.component
let make = () => {
  let (state, dispatch) = reducer->React.useReducer(initialState)

  React.useEffect1(
    () => {
      switch (state.input) {
      | "" => ResetResponse->dispatch
      | _ as input => Api.getResponse((input, dispatch))
      }
      None
    },
    [state.input],
  );

  <>
    <TextField
      value={state.input}
      onChange={event =>
        UpdateInput(event->ReactEvent.Form.target["value"])->dispatch
      }
    />
    {switch (state.response) {
     | Some(response) => `Response: ${response}`->React.string
     | None => React.null
     }}
  </>
};
```

## Caveats
#### I need to pass multiple arguments to debounced function
Pack those in tuple:

```rescript
let fn = Debouncer.make(((one, two)) => /* use `one` & `two` */)
fn(("one", "two"))
```

#### It doesn't work, function is not debounced
The result of `Debouncer.make(fn)` call **must** be bound to a variable (or a record property, a ref etc) for the later invocations. I.e. don't inline `Debouncer.make(fn)` calls in `React.useEffect` and such, this won't work since debounced function will be re-created on every re-render:

```rescript
@react.component
let make = () => {
  let (state, dispatch) = reducer->React.useReducer(initialState)

  // Don't do this
  let fn = Debouncer.make(() => DoStuff(state)->dispatch)

  React.useEffect1(
    () => {
      state->fn
      None
    },
    [state],
  )
}
```

#### I need this function to be defined inside React component body
If you want, for whatever reason, to define debounced function in a React component body, you can use `React.useRef` for this. Don't use `React.useMemo` though because React doesn't guarantee that memoized value won't be re-evaluated at some point.

```rescript
@react.component
let make = () => {
  let fn = React.useRef(None)

  let (state, dispatch) = reducer->React.useReducer(initialState)

  React.useEffect0(() => {
    fn.current = Some(Debouncer.make(x => Action(x)->dispatch))
    None
  })

  // somewhere in the body:
  switch (fn.current) {
  | Some(fn) => x->fn
  | None => ()
  }
}
```

## License

MIT.
