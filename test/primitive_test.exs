Code.require_file "test_helper.exs", __DIR__

defmodule ZplPreview.PrimitiveTest do
  use ExUnit.Case

  test "it can properly construct primitives from the parse output" do
    commands = [{:command, "XA", []}, {:command, "FO", ["50", "50"]}, {:command, "A", ["DN", "36", "20"]}, {:command, "FD",  ["Daniel Abrahamsson"]}, {:command, "FS", []}]
    primitives = ZplPreview.Primitive.from_zpl(commands)
    assert primitives == [ZplPreview.Primitive.Label[x: 50, y: 50, text: "Daniel Abrahamsson", font: ZplPreview.Font[name: "D", orientation: :normal, height: 36, width: 20]]]
  end

  test "it can create a graphic box primitive" do
    commands = [{:command, "XA", []}, {:command, "FO", ["0", "5"]}, {:command, "GB",  ["10", "2", "1", "B", "8"]}, {:command, "FS", []}]
    primitives = ZplPreview.Primitive.from_zpl(commands)
    assert primitives == [ZplPreview.Primitive.GraphicBox[x: 0, y: 5, width: 10, height: 2, thickness: 1, color: "B", radius: 1]]
  end

  test "it can handle a label with omitted parameters" do
    commands = [{:command, "A", []}, {:command, "FD",  [""]}, {:command, "FS", []}] # FD requires one parameter
    primitives = ZplPreview.Primitive.from_zpl(commands)
    assert primitives == [ZplPreview.Primitive.Label[x: 0, y: 0, text: "", font: ZplPreview.Font[name: "A", orientation: :normal, height: 15, width: 12]]]
  end

  test "it can handle a label with blank parameters" do
    commands = [{:command, "A", ["", "", ""]}, {:command, "FD",  [""]}, {:command, "FS", []}]
    primitives = ZplPreview.Primitive.from_zpl(commands)
    assert primitives == [ZplPreview.Primitive.Label[x: 0, y: 0, text: "", font: ZplPreview.Font[name: "A", orientation: :normal, height: 15, width: 12]]]
  end

  test "it can handle a graphic box with omitted parameters" do
    commands = [{:command, "FO", []}, {:command, "GB", []}, {:command, "FS", []}]
    primitives = ZplPreview.Primitive.from_zpl(commands)
    assert primitives == [ZplPreview.Primitive.GraphicBox[x: 0, y: 0, width: 1, height: 1, thickness: 1, color: "B", radius: 0]]
  end

  test "it can handle a graphic box with blank parameters" do
    commands = [{:command, "FO", ["", ""]}, {:command, "GB", ["", "", "", "", ""]}, {:command, "FS", []}]
    primitives = ZplPreview.Primitive.from_zpl(commands)
    assert primitives == [ZplPreview.Primitive.GraphicBox[x: 0, y: 0, width: 1, height: 1, thickness: 1, color: "B", radius: 0]]
  end

  test "the default value for graphic box width and height is the thickness of the box" do
    commands = [{:command, "GB", ["", "", "2"]}, {:command, "FS", []}]
    primitives = ZplPreview.Primitive.from_zpl(commands)
    assert primitives == [ZplPreview.Primitive.GraphicBox[x: 0, y: 0, width: 2, height: 2, thickness: 2, color: "B", radius: 0]]
  end
end

