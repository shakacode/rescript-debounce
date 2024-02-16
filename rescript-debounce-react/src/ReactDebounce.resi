let useDebounced: (~wait: int=?, 'a => unit) => 'a => unit
let useControlled: (~wait: int=?, 'a => unit) => Debounce.debounced<'a>
