type debounced<'a> = {
  invoke: 'a => unit,
  schedule: 'a => unit,
  scheduled: unit => bool,
  cancel: unit => unit,
}

let make: (~wait: int=?, 'a => unit, 'a) => unit
let makeControlled: (~wait: int=?, 'a => unit) => debounced<'a>
