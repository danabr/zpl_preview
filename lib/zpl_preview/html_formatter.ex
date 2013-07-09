
defmodule ZplPreview.HtmlFormatter do

  def to_html(primitives, options) do
    dpi = Keyword.fetch!(options, :dpi)
    base_html(primitive_html(primitives, dpi), options)
  end

  defp base_html(primitive_data, options) do
    width = :io_lib.format("~.3f", [Keyword.fetch!(options, :width)])
    height = :io_lib.format("~.3f", [Keyword.fetch!(options, :height)])
    """
    <html>
      <head><title>ZPL Label preview</title></head>
      <body style="margin:0; padding: 0;">
        <div class="format" style="width:#{width}in; height:#{height}in; border-bottom: 1px solid black; border-right: 1px solid black;">
          #{primitive_data}
        </div>
      </body>
    </html>
    """
  end

  defp primitive_html(primitives, dpi) do
    primitive_html(primitives, dpi, [])
  end

  defp primitive_html([], _dpi, output) do
    Enum.join(Enum.reverse(output), "\n")
  end

  defp primitive_html([label=ZplPreview.Primitive.Label[]|rest], dpi, output) do
    primitive_html(rest, dpi, [label_html(label, dpi)|output])
  end

  defp primitive_html([box=ZplPreview.Primitive.GraphicBox[]|rest], dpi, output) do
    primitive_html(rest, dpi, [box_html(box, dpi)|output])
  end

  defp label_html(label=ZplPreview.Primitive.Label[], dpi) do
    left = to_inch(label.x(), dpi)
    top = to_inch(label.y(), dpi)
    font_size = to_inch(label.font().height(), dpi)
    content = label.text()
    """
    <div class="label" style="position: absolute; left: #{left}in; top: #{top}in; font-family: Courier New; font-size: #{font_size}in">#{content}</div>
    """
  end

  defp box_html(box=ZplPreview.Primitive.GraphicBox[], dpi) do
    left = to_inch(box.x(), dpi)
    top = to_inch(box.y(), dpi)
    width = to_inch(box.width(), dpi)
    height = to_inch(box.height(), dpi)
    thickness = to_inch(box.thickness(), dpi)
    color = box_color_to_html_color(box.color())
    radius = to_inch(box.radius(), dpi)
    """
    <div class="graphic_box" style="position: absolute; left: #{left}in; top: #{top}in; width: #{width}in; height: #{height}in; border: #{thickness}in solid #{color}; border-radius: #{radius}in;">&nbsp;</div>
    """
  end

  defp to_inch(value_in_dots, dpi) do
    :io_lib.format("~.3f", [value_in_dots / dpi])
  end

  defp box_color_to_html_color("B") do
    "#000000"
  end

  defp box_color_to_html_color("W") do
    "#FFFFFF"
  end
end
