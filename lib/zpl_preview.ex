defmodule ZplPreview do
  @doc """
    Process the given zpl input string and returns an output string formatted
    according to the options.

    Valid options are:
      * format (required) - Output format. Valid options are: "html".
      * dpi (required) - dots per inch
      * width (required) - width in inches
      * height (required) - height in inches
  """
  def process(input, options) do
    input
    |> ZplPreview.Parser.parse
    |> ZplPreview.Primitive.from_zpl
    |> format(options)
  end

  defp format(primitives, options) do
    formatter(Keyword.fetch!(options, :format)).(primitives, options)
  end

  defp formatter("html") do
    # Below should be fn ZplPreview.HtmlFormatter.to_html/2 or similar
    fn (primitives, options) -> ZplPreview.HtmlFormatter.to_html(primitives, options) end
  end
end
