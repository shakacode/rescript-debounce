type t('a) = {
  invoke: 'a => unit,
  schedule: 'a => unit,
  scheduled: unit => bool,
  cancel: unit => unit,
};
