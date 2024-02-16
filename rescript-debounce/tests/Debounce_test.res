@@warning("-20-21")

open Jest

module Fn = {
  let make = (~mockFn, ~debounceFn) => {
    mockFn->Obj.magic->debounceFn->Obj.magic->MockJs.fn
  }
}

module Timeout = {
  let default = 100 + 10
  let make = timeout => timeout + 10
}

describe("Debounce", () => {
  open Expect

  test("is not called immediately", () => {
    let mockFn = JestJs.inferred_fn()
    let fn = Fn.make(~mockFn, ~debounceFn=Debounce.make(_))

    fn("1")

    expect(mockFn->MockJs.calls)->toEqual([])
  })

  testAsync("called after timeout", finish => {
    let mockFn = JestJs.inferred_fn()
    let fn = Fn.make(~mockFn, ~debounceFn=Debounce.make(_))

    fn()

    let fx = () => expect(mockFn->MockJs.calls)->toEqual([()])->finish

    fx->setTimeout(Timeout.default)->ignore
  })

  testAsync("called with provided argument after timeout", finish => {
    let mockFn = JestJs.inferred_fn()
    let fn = Fn.make(~mockFn, ~debounceFn=Debounce.make(_))

    fn("1")

    let fx = () => expect(mockFn->MockJs.calls)->toEqual(["1"])->finish

    fx->setTimeout(Timeout.default)->ignore
  })

  testAsync("called only once with the latest argument", finish => {
    let mockFn = JestJs.inferred_fn()
    let fn = Fn.make(~mockFn, ~debounceFn=Debounce.make(_))

    fn("1")
    fn("2")
    fn("3")

    let fx = () => expect(mockFn->MockJs.calls)->toEqual(["3"])->finish

    fx->setTimeout(Timeout.default)->ignore
  })

  testAsync("called with provided timeout", finish => {
    let timeout = 500

    let mockFn = JestJs.inferred_fn()
    let fn = Fn.make(~mockFn, ~debounceFn=Debounce.make(~wait=timeout, _))

    fn("1")

    let fx = () => expect(mockFn->MockJs.calls)->toEqual(["1"])->finish

    fx->setTimeout(timeout->Timeout.make)->ignore
  })

  testAsync("can be scheduled", finish => {
    let timeout = 500

    let mockFn = JestJs.inferred_fn()
    let fn: Debounce.debounced<string> = Fn.make(
      ~mockFn,
      ~debounceFn=Debounce.makeControlled(~wait=timeout, _),
    )

    fn.schedule("1")

    let fx = () => expect(mockFn->MockJs.calls)->toEqual(["1"])->finish

    fx->setTimeout(timeout->Timeout.make)->ignore
  })

  test("can be called immediately", () => {
    let mockFn = JestJs.inferred_fn()
    let fn: Debounce.debounced<string> = Fn.make(~mockFn, ~debounceFn=Debounce.makeControlled(_))

    fn.invoke("1")

    expect(mockFn->MockJs.calls)->toEqual(["1"])
  })

  testAsync("not called after immediate invocation", finish => {
    let mockFn = JestJs.inferred_fn()
    let fn: Debounce.debounced<string> = Fn.make(~mockFn, ~debounceFn=Debounce.makeControlled(_))

    fn.schedule("1")
    fn.invoke("2")

    let fx = () => expect(mockFn->MockJs.calls)->toEqual(["2"])->finish

    fx->setTimeout(Timeout.default)->ignore
  })

  testAsync("can be canceled", finish => {
    let mockFn = JestJs.inferred_fn()
    let fn: Debounce.debounced<string> = Fn.make(~mockFn, ~debounceFn=Debounce.makeControlled(_))

    fn.schedule("1")
    fn.cancel()

    let fx = () => expect(mockFn->MockJs.calls)->toEqual([])->finish

    fx->setTimeout(Timeout.default)->ignore
  })

  test("reports scheduled true when invocation is scheduled", () => {
    let mockFn = JestJs.inferred_fn()
    let fn: Debounce.debounced<string> = Fn.make(~mockFn, ~debounceFn=Debounce.makeControlled(_))

    fn.schedule("1")

    expect(fn.scheduled())->toEqual(true)
  })

  test("reports scheduled false when invocation is not scheduled", () => {
    let mockFn = JestJs.inferred_fn()
    let fn: Debounce.debounced<string> = Fn.make(~mockFn, ~debounceFn=Debounce.makeControlled(_))

    expect(fn.scheduled())->toEqual(false)
  })
})
