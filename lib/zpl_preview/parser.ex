defmodule ZplPreview.Parser do

  @doc """
  Prases the given string of ZPL commands,
  or list of tokens and returns a list of
  commands and their arguments.
    iex> ZPLPreview.Parser.parse("^FDHello")
    [{:command, "FD", ["Hello"]}]

    iex> ZPLPreview.Parser.parse(["^FD", "Hello"])
    [{:command, "FD", ["Hello"]}]
  """
  def parse(str) when is_binary(str) do
    str |> tokenize |> parse
  end

  def parse(tokens) when is_list(tokens) do
    parse(tokens, [])
  end

  defp parse([], commands) do
    Enum.reverse(commands)
  end

  defp parse([<<"^", command::binary>>|rest], commands) do
    {args, rest_of_tokens} = Enum.split_while(rest, is_arg(&1))
    parse(rest_of_tokens, [{:command, command, args}|commands])
  end

  defp parse([<<"~", command::binary>>|rest], commands) do
    {args, rest_of_tokens} = Enum.split_while(rest, is_arg(&1))
    parse(rest_of_tokens, [{:command, command, args}|commands])
  end

  defp is_arg(<<"^", _command::binary>>) do
    false
  end

  defp is_arg(<<"~", _command::binary>>) do
    false
  end

  defp is_arg(_arg) do
    true
  end

  @doc """
  Breaks the given string of ZPL into tokens.
  The string is expected to be UTF-8 encoded.
    iex> ZPLPreview.Parser.tokenize("^FDHello^FS")
    ["^FD", "^Hello", "^FS"]
  """  
  def tokenize(str) do
    skip_blanks(str) |> tokenize([])
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
    tokenize(new_rest, [command|buffer]) end

  defp tokenize(str, buffer) do
    new_command = %r{^[^\^~]+}
    [data] = Regex.run(new_command, str)
    [_, rest] = String.split(str, new_command)
    tokenize(rest, tokenize_args(data) ++ buffer)
  end

  defp tokenize_args(arg_str) do
    Enum.reverse(String.split(arg_str, ","))
  end

  defp skip_blanks(str) do
    String.replace(str, "\n", "")
  end
end
