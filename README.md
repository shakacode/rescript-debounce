# re-debouncer

[![npm version](https://img.shields.io/npm/v/re-debouncer.svg?style=flat-square)](https://www.npmjs.com/package/re-debouncer)
[![build status](https://img.shields.io/travis/alexfedoseev/re-debouncer/master.svg?style=flat-square)](https://travis-ci.org/alexfedoseev/re-debouncer)
[![license](https://img.shields.io/npm/l/re-debouncer.svg?style=flat-square)](https://www.npmjs.com/package/re-debouncer)

Simple debouncer for Reason(React).

## Installation

```shell
# yarn
yarn add re-debouncer
# or npm
npm install --save re-debouncer
```

Then add it to `bsconfig.json`:

```json
"bs-dependencies": [
  "re-debouncer"
]
```

## Usage

```reason
/* Pass function you want to debounce */
let fn = Debouncer.make(fn);

/* You can configure timeout. Default is 100ms */
let fn = Debouncer.make(~wait=500, fn);

/* This call is debounced */
fn();
```

Also, you can make debounced function calls cancelable:

```reason
let fn = Debouncer.makeCancelable(fn);

/* Schedule invocation */
fn.schedule();

/* Cancel invocation */
fn.cancel();

/* Check if invocation is scheduled */
fn.scheduled(); /* => false */

/* Invoke immediately */
fn.invoke();
```

Note that if you invoke immediately all scheduled invocations (if any) are canceled.

## Example
In this example requests to remote server will be debounced.

```reason
type state = {value: bool};

type action =
  | UpdateLocalState(bool)
  | RequestServerUpdate(bool);

module Handlers = {
  let requestServerUpdate = Debouncer.make(
    ({React.state, send}) => RequestServerUpdate(state.value)->send,
  );
};

let component = React.reducerComponent(__MODULE__);

let make = _ => {
  ...component,
  initialState: () => {value: false},
  reducer: (action, state) =>
    switch (action) {
    | UpdateLocalState(nextValue) =>
      React.UpdateWithSideEffects(
        {value: nextValue},
        Handlers.requestServerUpdate, /* debounced */
      )
    | RequestServerUpdate(nextValue) =>
      React.SideEffects((_ => ...))
    },
  render: ({state, send}) =>
    <Checkbox
      checked={state.value}
      onChange={
        event =>
          event->ReactEvent.Form.target##checked->UpdateLocalState->send
      }
    />,
};
```

## Caveats
#### I need to pass multiple arguments to debounced function
Pack those in tuple:

```reason
let fn = Debouncer.make(((one, two)) => /* use `one` & `two` */);
fn(("one", "two"));
```

#### It doesn't work, function is not debounced
The result of `Debouncer.make(fn)` call **must** be bound to a variable (or a record property etc) for the later invocations. I.e. don't inline `Debouncer.make(fn)` calls in reducer, this won't work since debounced function will be re-created on every dispatch:

```reason
reducer: (action, state) =>
  switch (action) {
  | UpdateLocalState(nextValue) =>
    React.UpdateWithSideEffects(
      {value: nextValue},
      /* Don't do this */
      Debouncer.make(
        ({state, send}) => RequestServerUpdate(state.value)->send,
      ),
    )
  }
```

## License

MIT.
