
defrecord ZplPreview.Font, name: "A", orientation: :normal, width: 12, height: 15

defmodule ZplPreview.Primitive do
  defrecord Label, x: 0, y: 0, text: "", font: nil
  defrecord GraphicBox, x: 0, y: 0, width: 1, height: 1, thickness: 1, color: "B", radius: 0
  defrecord Barcode, type: nil, x: 0, y: 0, orientation: :normal, use_check_digit: false, height: 1, print_ipl: false, print_ipl_above_code: false, data: ""

  defrecordp :state, x: 0, y: 0, font: ZplPreview.Font[], barcode: nil

  def from_zpl(commands) do
    from_zpl(commands, [], state())
  end

  defp from_zpl([], primitives, _state) do
    Enum.reverse(primitives)
  end

  defp from_zpl([{:command, "FD", [text]}|rest], primitives, state) do
    case state(state, :barcode) do
      nil -> make_label(text, rest, primitives, state)
      barcode -> make_barcode(text, barcode, rest, primitives, state)
    end
  end

  defp from_zpl([{:command, "FO", args}|rest], primitives, state) do
    [x, y] = fill_in_defaults(args, ["0", "0"])
    from_zpl(rest, primitives, state(state, x: binary_to_integer(x), y: binary_to_integer(y)))
  end

  defp from_zpl([{:command, "A", args}|rest], primitives, state) do
    [name_and_orientation, height, width] = fill_in_defaults(args, ["AN", "15", "12"])
    name = String.at(name_and_orientation, 0)
    orientation = String.at(name_and_orientation, 1)
    font = ZplPreview.Font[name: name, orientation: parse_orientation(orientation), width: binary_to_integer(width), height: binary_to_integer(height)]
    from_zpl(rest, primitives, state(state, font: font))
  end

  defp from_zpl([{:command, "GB", args}|rest], primitives, state) do
    [w, h, t, c, r] = fill_in_defaults(args, ["", "", "1", "B", "0"])

    w = if w == "", do: t, else: w
    h = if h == "", do: t, else: h

    box = ZplPreview.Primitive.GraphicBox[x: state(state, :x),
                                          y: state(state, :y),
                                          width: binary_to_integer(w),
                                          height: binary_to_integer(h),
                                          thickness: binary_to_integer(t),
                                          color: c,
                                          radius: box_radius(binary_to_integer(w), binary_to_integer(h), binary_to_integer(r))]
    from_zpl(rest, [box|primitives], state)
  end

  defp from_zpl([{:command, "B3", args}|rest], primitives, state) do
    [orientation, check_digit, height, ipl, ipl_above_code] = fill_in_defaults(args, ["N", "N", "10", "Y", "N"])

    barcode = ZplPreview.Primitive.Barcode[type: :code39,
                                           x: state(state, :x),
                                           y: state(state, :y),
                                           orientation: parse_orientation(orientation),
                                           height: binary_to_integer(height),
                                           use_check_digit: to_bool(check_digit),
                                           print_ipl: to_bool(ipl),
                                           print_ipl_above_code: to_bool(ipl_above_code)]
    from_zpl(rest, primitives, state(state, barcode: barcode))
  end

  defp from_zpl([{:command, "XA", _args}|rest], primitives, state) do
    from_zpl(rest, primitives, state)
  end

  defp from_zpl([{:command, "XZ", _args}|rest], primitives, state) do
    from_zpl(rest, primitives, state)
  end

  defp from_zpl([{:command, "FS", _args}|rest], primitives, state) do
    from_zpl(rest, primitives, state)
  end

  defp from_zpl([ignore|rest], primitives, state) do
    :io.format(:standard_error, "Ignoring command: ~p~n", [ignore])
    from_zpl(rest, primitives, state)
  end

  defp make_label(text, commands, primitives, state) do
    label = Label[text: text, x: state(state, :x), y: state(state, :y), font: state(state, :font)]
    from_zpl(commands, [label|primitives], state)
  end

  defp make_barcode(data, barcode=Barcode[], commands, primitives, state) do
    from_zpl(commands, [barcode.data(data)|primitives], state(state, barcode: nil))
  end

  # Fills in default values in the arg list in case some ars are missing.
  # Args are considered missing if they are either omitted or blank ("").
  defp fill_in_defaults(args, defaults) do
    default_and_provided = Enum.zip(defaults, args)
    Enum.map(default_and_provided, (fn ({default, provided}) ->
      case provided do
        nil -> default
        "" -> default
        _ -> provided
      end
    end))
  end

  defp parse_orientation("N"), do: :normal
  defp parse_orientation("R"), do: :rotated
  defp parse_orientation("I"), do: :inverted
  defp parse_orientation("B"), do: :bottom_up
  defp parse_orientation(_), do: :normal

  defp to_bool("Y"), do: true
  defp to_bool(_), do: false

  defp box_radius(width, height, rounding_index) do
    max_rounding_index = 8
    shorter = Enum.min([width, height])
    (rounding_index / max_rounding_index) * (shorter / 2)
  end
end
