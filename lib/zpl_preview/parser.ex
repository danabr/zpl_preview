defmodule ZplPreview.Parser do
  @doc """
  Breaks the given string of ZPL into tokens.
  The string is expected to be UTF-8 encoded.
    iex> ZPLPreview.Parser.tokenize("^FDHello^FS")
    ["^FD", "^Hello", "^FS"]
  """  
  def tokenize(str) do
    tokenize(str, []) |> skip_blanks
  end

  defp tokenize("", buffer) do
    Enum.reverse(buffer)
  end

  # Special handling because of ^A, which is the only
  # ZPL command that is not two characters long.
  defp tokenize(<<"^A@", rest::binary>>, buffer) do
    tokenize(rest, ["^A@"|buffer])
  end

  defp tokenize(<<"^A", rest::binary>>, buffer) do
    tokenize(rest, ["^A"|buffer])
  end

  defp tokenize(<<"^", rest::binary>>, buffer) do
    command = "^" <> String.at(rest, 0) <> String.at(rest, 1)
    [_, new_rest] = String.split(rest, %r{^..}, global: false)
    tokenize(new_rest, [command|buffer])
  end

  defp tokenize(<<"~", rest::binary>>, buffer) do
    command = "~" <> String.at(rest, 0) <> String.at(rest, 1)
    [_, new_rest] = String.split(rest, %r{^..}, global: false)
    tokenize(new_rest, [command|buffer])
  end

  defp tokenize(str, buffer) do
    new_command = %r{^[^\^~]+}
    [data] = Regex.run(new_command, str)
    [_, rest] = String.split(str, new_command)
    tokenize(rest, tokenize_args(data) ++ buffer)
  end

  defp tokenize_args(arg_str) do
    Enum.reverse(String.split(arg_str, ","))
  end

  defp skip_blanks(tokens) do
    Enum.filter(tokens, &1 != "\n")
  end
end
