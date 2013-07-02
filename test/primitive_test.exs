Code.require_file "test_helper.exs", __DIR__

defmodule ZplPreview.PrimitiveTest do
  use ExUnit.Case

  test "it can properly construct primitives from the parse output" do
    commands = [{:command, "XA", []}, {:command, "FO", ["50", "50"]}, {:command, "A", ["DN", "36", "20"]}, {:command, "FD",  ["Daniel Abrahamsson"]}, {:command, "FS", []}]
    primitives = ZplPreview.Primitive.from_zpl(commands)
    assert primitives == [ZplPreview.Primitive.Label[x: 50, y: 50, text: "Daniel Abrahamsson", font: ZplPreview.Font[name: "D", orientation: :normal, height: 36, width: 20]]]
  end
end

