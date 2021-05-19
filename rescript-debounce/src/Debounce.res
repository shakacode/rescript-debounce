type debounced<'a> = {
  invoke: 'a => unit,
  schedule: 'a => unit,
  scheduled: unit => bool,
  cancel: unit => unit,
}

let makeControlled = (~wait=100, fn: 'a => unit): debounced<'a> => {
  let timerId = ref(None)
  let lastArg = ref(None)
  let lastCallTime = ref(None)

  let shouldCall = time =>
    switch lastCallTime.contents {
    | None => true
    | Some(lastCallTime) =>
      let timeSinceLastCall = time - lastCallTime
      timeSinceLastCall >= wait || timeSinceLastCall < 0
    }

  let remainingWait = time =>
    switch lastCallTime.contents {
    | None => wait
    | Some(lastCallTime) =>
      let timeSinceLastCall = time - lastCallTime
      wait - timeSinceLastCall
    }

  let rec timerExpired = () => {
    switch timerId.contents {
    | Some(timerId) => timerId->Js.Global.clearTimeout
    | None => ()
    }
    let time = Js.Date.now()->Belt.Int.fromFloat
    if time->shouldCall {
      call()
    } else {
      timerId := Some(time->remainingWait->Js.Global.setTimeout(timerExpired, _))
    }
  }
  and call = () => {
    let x = lastArg.contents
    switch x {
    | Some(x) =>
      lastArg := None
      timerId := None
      x->fn
    | None => timerId := None
    }
  }

  let schedule = x => {
    let time = Js.Date.now()->Belt.Int.fromFloat
    lastArg := Some(x)
    lastCallTime := Some(time)
    timerId := Some(wait->Js.Global.setTimeout(timerExpired, _))
  }

  let scheduled = () =>
    switch timerId.contents {
    | Some(_) => true
    | None => false
    }

  let cancel = () =>
    switch timerId.contents {
    | Some(timerId') =>
      timerId'->Js.Global.clearTimeout
      timerId := None
      lastArg := None
      lastCallTime := None
    | None => ()
    }

  let invoke = x => {
    cancel()
    x->fn
  }

  {
    invoke: invoke,
    schedule: schedule,
    scheduled: scheduled,
    cancel: cancel,
  }
}

let make = (~wait=?, fn) => makeControlled(~wait?, fn).schedule
