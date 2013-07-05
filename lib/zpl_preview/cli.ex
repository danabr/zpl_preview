
defmodule ZplPreview.CLI do
  def parse_args(args) do
    {options, args} = OptionParser.parse(args, aliases: [h: :help])
    Keyword.put(options, :file, args_to_path(args))
    |> format
    |> validate
  end

  def process({:error, errors}) do
    IO.puts :stderr, Enum.join(errors, " ")
    print_help
    System.halt(1)
  end

  def process({:ok, options}) do
    zpl = File.read!(Keyword.fetch!(options, :file))
    output = ZplPreview.process(zpl, options)
    IO.write :stdio, output
  end

  def process(args) when is_list(args) do
    parse_args(args) |> process
  end

  defp print_help do
    IO.puts :stderr, """
    zpl_preview - convert ZPL to HTML

    Options (all are required):
    --format  - Output format. Supported formats: html
    --width   - The width of the label in inches
    --height  - The height of the label in inches
    --dpi     - Dots per inch

    Example:
    $ zpl_preview --format html --width 2.36 --height 1.18 --dpi 300 input_file.zpl > output_file.html

    """
  end

  defp format(options) do
    format(options, [])
  end

  defp format([], formatted_options) do
    formatted_options
  end

  defp format([{:dpi, val}|options], formatted_options) do
    format(options, [{:dpi, parse_float(val)}|formatted_options])
  end

  defp format([{:width, val}|options], formatted_options) do
    format(options, [{:width, parse_float(val)}|formatted_options])
  end

  defp format([{:height, val}|options], formatted_options) do
    format(options, [{:height, parse_float(val)}|formatted_options])
  end

  defp format([{_option, _arg}=unformatted|options], formatted_options) do
    format(options, [unformatted|formatted_options])
  end

  defp validate(options) do
    case validate(options, []) do
      [] -> validate_mandatory_options(options)
      errors -> {:error, errors}
    end
  end

  defp validate([], errors), do: errors

  defp validate([{:width, val}|options], errors) when is_number(val) and val > 0 do
    validate(options, errors)
  end

  defp validate([{:width, _}|options], errors) do
    validate(options, ["Width must be positive."|errors])
  end

  defp validate([{:height, val}|options], errors) when is_number(val) and val > 0 do
    validate(options, errors)
  end

  defp validate([{:height, _}|options], errors) do
    validate(options, ["Height must be positive."|errors])
  end

  defp validate([{:dpi, val}|options], errors) when is_number(val) and val > 0 do
    validate(options, errors)
  end

  defp validate([{:dpi, _}|options], errors) do
    validate(options, ["DPI must be positive."|errors])
  end

  defp validate([{:format, "html"}|options], errors), do: validate(options, errors)

  defp validate([{:format, _}|options], errors) do
    validate(options, ["Unknown format."|errors])
  end

  defp validate([{:file, file}|options], errors) do
    case File.regular?(file) do
      true -> validate(options, errors)
      false -> validate(options, ["The file \"#{file}\" does not exist."|errors])
    end
  end

  defp validate([{unknown, _arg}|options], errors) do
    validate(options, ["Unrecognized argument #{unknown}."|errors])
  end

  defp validate_mandatory_options(options) do
    mandatory = [:format, :dpi, :width, :height, :file]
    missing =  Enum.reduce(mandatory, [], (fn(key, missing) ->
      case Keyword.has_key?(options, key) do
        true -> missing
        false -> [key|missing]
      end
    end))
    case missing do
      [] -> {:ok, options}
      _ -> {:error, ["The following options must be specified: #{Enum.join(missing, ", ")}."]}
    end
  end

  defp args_to_path([path]), do: path
  defp args_to_path(_), do: ""

  defp parse_float(str) do
    case String.to_float(str) do
      {val, _} -> val
      :error -> :NaN
    end
  end
end
