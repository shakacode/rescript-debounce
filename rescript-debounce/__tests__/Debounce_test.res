open Jest

describe("Debounce", () => {
  open Expect

  test("is not called immediately", () => {
    let mockFn = JestJs.fn(_ => ())
    let fn = mockFn |> Obj.magic |> Debounce.make

    MockJs.fn(fn |> Obj.magic, "1") |> ignore

    expect(mockFn |> MockJs.calls) |> toEqual([])
  })

  testAsync("called after timeout", finish => {
    let mockFn = JestJs.fn(_ => ())
    let fn = mockFn |> Obj.magic |> Debounce.make

    MockJs.fn(fn |> Obj.magic, ()) |> ignore

    110
    |> Js.Global.setTimeout(() => expect(mockFn |> MockJs.calls) |> toEqual([()]) |> finish)
    |> ignore
  })

  testAsync("called with provided argument after timeout", finish => {
    let mockFn = JestJs.fn(_ => ())
    let fn = mockFn |> Obj.magic |> Debounce.make

    MockJs.fn(fn |> Obj.magic, "1") |> ignore

    110
    |> Js.Global.setTimeout(() => expect(mockFn |> MockJs.calls) |> toEqual(["1"]) |> finish)
    |> ignore
  })

  testAsync("called only once with the latest argument", finish => {
    let mockFn = JestJs.fn(_ => ())
    let fn = mockFn |> Obj.magic |> Debounce.make

    MockJs.fn(fn |> Obj.magic, "1") |> ignore
    MockJs.fn(fn |> Obj.magic, "2") |> ignore
    MockJs.fn(fn |> Obj.magic, "3") |> ignore

    110
    |> Js.Global.setTimeout(() => expect(mockFn |> MockJs.calls) |> toEqual(["3"]) |> finish)
    |> ignore
  })

  testAsync("called with provided timeout", finish => {
    let mockFn = JestJs.fn(_ => ())
    let fn = mockFn |> Obj.magic |> Debounce.make(~wait=500)

    MockJs.fn(fn |> Obj.magic, "1") |> ignore

    510
    |> Js.Global.setTimeout(() => expect(mockFn |> MockJs.calls) |> toEqual(["1"]) |> finish)
    |> ignore
  })

  testAsync("can be scheduled", finish => {
    let mockFn = JestJs.fn(_ => ())
    let fn = mockFn |> Obj.magic |> Debounce.makeControlled(~wait=500)

    MockJs.fn(fn.schedule |> Obj.magic, "1") |> ignore

    510
    |> Js.Global.setTimeout(() => expect(mockFn |> MockJs.calls) |> toEqual(["1"]) |> finish)
    |> ignore
  })

  test("can be called immediately", () => {
    let mockFn = JestJs.fn(_ => ())
    let fn = mockFn |> Obj.magic |> Debounce.makeControlled

    MockJs.fn(fn.invoke |> Obj.magic, "1") |> ignore

    expect(mockFn |> MockJs.calls) |> toEqual(["1"])
  })

  testAsync("not called after immediate invocation", finish => {
    let mockFn = JestJs.fn(_ => ())
    let fn = mockFn |> Obj.magic |> Debounce.makeControlled

    MockJs.fn(fn.schedule |> Obj.magic, "1") |> ignore
    MockJs.fn(fn.invoke |> Obj.magic, "2") |> ignore

    110
    |> Js.Global.setTimeout(() => expect(mockFn |> MockJs.calls) |> toEqual(["2"]) |> finish)
    |> ignore
  })

  testAsync("can be canceled", finish => {
    let mockFn = JestJs.fn(_ => ())
    let fn = mockFn |> Obj.magic |> Debounce.makeControlled

    MockJs.fn(fn.schedule |> Obj.magic, "1") |> ignore
    fn.cancel()

    110
    |> Js.Global.setTimeout(() => expect(mockFn |> MockJs.calls) |> toEqual([]) |> finish)
    |> ignore
  })

  test("reports scheduled true when invocation is scheduled", () => {
    let mockFn = JestJs.fn(_ => ())
    let fn = mockFn |> Obj.magic |> Debounce.makeControlled

    MockJs.fn(fn.schedule |> Obj.magic, "1") |> ignore

    expect(fn.scheduled()) |> toEqual(true)
  })

  test("reports scheduled false when invocation is not scheduled", () => {
    let mockFn = JestJs.fn(_ => ())
    let fn = mockFn |> Obj.magic |> Debounce.makeControlled

    expect(fn.scheduled()) |> toEqual(false)
  })
})
