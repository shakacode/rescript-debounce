let useDebounced = (~wait=?, fn) => {
  let ref = fn->Debounce.make(~wait?)->React.useRef
  ref.current
}

let useControlled = (~wait=?, fn) => {
  let ref = fn->Debounce.makeControlled(~wait?)->React.useRef
  ref.current
}
