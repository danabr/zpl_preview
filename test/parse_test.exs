Code.require_file "test_helper.exs", __DIR__

defmodule ZplPreview.ParserTest do
  use ExUnit.Case

  test "it can properly tokenize the first example in the ZPL reference" do
    zpl = "^XA\n^FO50,50^ADN,36,20^FDDaniel Abrahamsson^FS"
    output = ZplPreview.Parser.tokenize(zpl)
    assert output == ["^XA", "^FO", "50", "50", "^A", "DN", "36", "20", "^FD", "Daniel Abrahamsson", "^FS"]
  end

  test "it can properly parse the first example in the ZPL reference" do
    zpl = "^XA\n^FO50,50^ADN,36,20^FDDaniel Abrahamsson^FS"
    commands = ZplPreview.Parser.parse(zpl)
    assert commands == [{:command, "XA", []}, {:command, "FO", ["50", "50"]}, {:command, "A", ["DN", "36", "20"]}, {:command, "FD",  ["Daniel Abrahamsson"]}, {:command, "FS", []}]
  end
end
