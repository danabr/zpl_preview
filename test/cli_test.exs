Code.require_file "test_helper.exs", __DIR__

defmodule ZplPreview.CLITest do
  use ExUnit.Case

  test "parse_args properly parses valid args" do
    result = ZplPreview.CLI.parse_args(valid_args)
    assert result == {:ok, [height: 8.0, width: 10.0, dpi: 300.0, format: "html", file: existing_file]}
  end

  test "parse_args returns error if mandatory flags are missing" do
    assert ZplPreview.CLI.parse_args([existing_file]) == {:error, ["The following options must be specified: height, width, dpi, format."]}
  end

  test "parse_args returns error if an invalid format is given" do
    assert ZplPreview.CLI.parse_args(valid_args ++ ["--format", "bmp"]) == {:error, ["Unknown format."]}
  end

  test "parse_args returns help if an invalid dpi is given" do
    assert ZplPreview.CLI.parse_args(valid_args ++ ["--dpi", "0"]) == {:error, ["DPI must be positive."]}
  end

  test "parse_args returns help if an invalid width is given" do
    assert ZplPreview.CLI.parse_args(valid_args ++ ["--width", "0"]) == {:error, ["Width must be positive."]}
  end

  test "parse_args returns help if an invalid height is given" do
    assert ZplPreview.CLI.parse_args(valid_args ++ ["--height", "0"]) == {:error, ["Height must be positive."]}
  end

  test "parse_args returns help if an invalid file is given" do
    [_|reversed_args_without_file] =  Enum.reverse(valid_args())
    args = Enum.reverse(["noexisting.zpl"|reversed_args_without_file])
    assert ZplPreview.CLI.parse_args(args) == {:error, ["The file noexisting.zpl does not exist."]}
  end

  def valid_args do
    ["--format", "html", "--dpi", "300", "--width", "10", "--height", "8", existing_file]
  end

  def existing_file do
    "test/fixtures/zpl_reference_exercise1.zpl"
  end
end
