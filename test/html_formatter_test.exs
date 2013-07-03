Code.require_file "test_helper.exs", __DIR__

defmodule ZplPreview.HtmlFormatterTest do
  use ExUnit.Case

  test "it renders properly when there are no primitives" do
    output = ZplPreview.HtmlFormatter.to_html([], width: 2.36, height: 1.18, dpi: 300)
    assert output == File.read!("test/fixtures/bare.html")
  end

  test "it renders labels properly" do
    primitives = [ZplPreview.Primitive.Label[x: 50, y: 50, text: "Daniel Abrahamsson", font: ZplPreview.Font[name: "D", orientation: :normal, height: 36, width: 20]]]
    output = ZplPreview.HtmlFormatter.to_html(primitives, width: 2.36, height: 1.18, dpi: 300)
    assert output == File.read!("test/fixtures/single_label.html")
  end
end

