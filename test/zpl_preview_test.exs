Code.require_file "test_helper.exs", __DIR__

defmodule ZplPreviewTest do
  use ExUnit.Case

  test "it can process zpl" do
    input = File.read!("test/fixtures/zpl_reference_exercise1.zpl")
    options = [format: "html", width: 2.36, height: 1.18, dpi: 300]
    output = ZplPreview.process(input, options)
    assert output == File.read!("test/fixtures/single_label.html")
  end

  test "it works end to end" do
    args = ["--format", "html", "--width", "2.36", "--height", "1.18", "--dpi", "300", "test/fixtures/zpl_reference_exercise1.zpl"]
    output = ExUnit.CaptureIO.capture_io(fn -> ZplPreview.main(args) end)
    assert output == File.read!("test/fixtures/single_label.html")
  end
end
