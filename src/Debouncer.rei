let make: (~wait: int=?, 'a => unit, 'a) => unit;
let makeCancelable: (~wait: int=?, 'a => unit) => Debounced.t('a);
