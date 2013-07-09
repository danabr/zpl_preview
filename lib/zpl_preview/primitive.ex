
defrecord ZplPreview.Font, name: "A", orientation: :normal, width: 15, height: 12

defmodule ZplPreview.Primitive do
  defrecord Label, x: 0, y: 0, text: "", font: nil
  defrecord GraphicBox, x: 0, y: 0, width: 1, height: 1, thickness: 1, color: "B", radius: 0

  defrecordp :state, x: 0, y: 0, font: ZplPreview.Font[]

  def from_zpl(commands) do
    from_zpl(commands, [], state())
  end

  defp from_zpl([], primitives, _state) do
    Enum.reverse(primitives)
  end

  defp from_zpl([{:command, "FD", [text]}|rest], primitives, state) do
    label = Label[text: text, x: state(state, :x), y: state(state, :y), font: state(state, :font)]
    from_zpl(rest, [label|primitives], state)
  end

  defp from_zpl([{:command, "FO", [x, y]}|rest], primitives, state) do
    from_zpl(rest, primitives, state(state, x: binary_to_integer(x), y: binary_to_integer(y)))
  end

  defp from_zpl([{:command, "A", [name_and_orientation, height, width]}|rest], primitives, state) do
    name = String.at(name_and_orientation, 0)
    orientation = String.at(name_and_orientation, 1)
    font = ZplPreview.Font[name: name, orientation: parse_orientation(orientation), width: binary_to_integer(width), height: binary_to_integer(height)]
    from_zpl(rest, primitives, state(state, font: font))
  end

  defp from_zpl([{:command, "GB", [w, h, t, c, r]}|rest], primitives, state) do
    box = ZplPreview.Primitive.GraphicBox[x: state(state, :x),
                                          y: state(state, :y),
                                          width: binary_to_integer(w),
                                          height: binary_to_integer(h),
                                          thickness: binary_to_integer(t),
                                          color: c,
                                          radius: box_radius(binary_to_integer(w), binary_to_integer(h), binary_to_integer(r))]
    from_zpl(rest, [box|primitives], state)
  end

  defp from_zpl([ignore|rest], primitives, state) do
    :io.format(:standard_error, "Ignoring command: ~p~n", [ignore])
    from_zpl(rest, primitives, state)
  end

  defp parse_orientation("N"), do: :normal
  defp parse_orientation("R"), do: :rotated
  defp parse_orientation("I"), do: :inverted
  defp parse_orientation("B"), do: :bottom_up
  defp parse_orientation(_), do: :normal

  defp box_radius(width, height, rounding_index) do
    max_rounding_index = 8
    shorter = Enum.min([width, height])
    (rounding_index / max_rounding_index) * (shorter / 2)
  end
end
