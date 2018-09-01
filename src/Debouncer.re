let make = (~wait=100, fn) => {
  let timerId = ref(None);
  let lastArg = ref(None);
  let lastCallTime = ref(None);

  let shouldInvoke = time =>
    switch (lastCallTime^) {
    | None => true
    | Some(lastCallTime) =>
      let timeSinceLastCall = time - lastCallTime;
      timeSinceLastCall >= wait || timeSinceLastCall < 0;
    };

  let remainingWait = time =>
    switch (lastCallTime^) {
    | None => wait
    | Some(lastCallTime) =>
      let timeSinceLastCall = time - lastCallTime;
      wait - timeSinceLastCall;
    };

  let rec timerExpired = () => {
    switch (timerId^) {
    | Some(timerId) => timerId |> Js.Global.clearTimeout
    | None => ()
    };
    let time = Js.Date.now() |> int_of_float;
    if (time |> shouldInvoke) {
      invoke();
    } else {
      timerId :=
        Some(time |> remainingWait |> Js.Global.setTimeout(timerExpired));
    };
  }
  and invoke = () => {
    let x = lastArg^;
    switch (x) {
    | Some(x) =>
      lastArg := None;
      timerId := None;
      x |> fn;
    | None => timerId := None
    };
  };

  let debounced = x => {
    let time = Js.Date.now() |> int_of_float;
    lastArg := Some(x);
    lastCallTime := Some(time);
    timerId := Some(wait |> Js.Global.setTimeout(timerExpired));
  };

  debounced;
};
