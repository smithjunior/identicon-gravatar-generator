defmodule Identicon do
  @moduledoc """
  Documentation for `Identicon`.
  """
  @doc """
  The main function.
  """
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  @doc """
  Return a `Idention.Image` with a hash inside of structure. 

  ## Examples
      iex> Identicon.hash_input("banana")
      %Identicon.Image{
        hex: [114, 179, 2, 191, 41, 122, 34, 138, 117, 115, 1, 35, 239, 239, 124, 65]
      }
  """
  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
          |> :binary.bin_to_list
    %Identicon.Image{hex: hex}
  end

  @doc """
  Return rgb color as enum.

  ## Examples
      iex> image = Identicon.hash_input("banana")
      iex> Identicon.pick_color(image)
      %Identicon.Image{
        color: {114, 179, 2},
        hex: [114, 179, 2, 191, 41, 122, 34, 138, 117, 115, 1, 35, 239, 239, 124, 65]
      }
  """
  def pick_color(%Identicon.Image{hex: [r, g, b  | _tails]} = image) do
    %Identicon.Image{image | color: {r, g, b}}
  end

  @doc """
  Return a grid elements of Enum with Enums

  ## Examples
      iex> image = Identicon.hash_input("banana")
      iex> Identicon.build_grid(image)
      %Identicon.Image{
        color: nil,
        grid: [
          {114, 0},
          {179, 1},
          {2, 2},
          {179, 3},
          {114, 4},
          {191, 5},
          {41, 6},
          {122, 7},
          {41, 8},
          {191, 9},
          {34, 10},
          {138, 11},
          {117, 12},
          {138, 13},
          {34, 14},
          {115, 15},
          {1, 16},
          {35, 17},
          {1, 18},
          {115, 19},
          {239, 20},
          {239, 21},
          {124, 22},
          {239, 23},
          {239, 24}
        ],
        hex: [114, 179, 2, 191, 41, 122, 34, 138, 117, 115, 1, 35, 239, 239, 124, 65]
      }
  """
  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid = hex
      |> Enum.chunk(3)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index
    %Identicon.Image{image | grid: grid}
  end

  @doc """
  Return a list mirrored.

  ## Exsamples
      iex> Identicon.mirror_row([1, 2, 3])
      [1, 2, 3, 2, 1]
  """
  def mirror_row(row) do
    [first, second |  _tail] = row
    row ++ [second, first]
  end

  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn({code, _index}) -> 
      rem(code, 2) == 0
    end

    %Identicon.Image{image | grid: grid}
  end

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_code, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50
      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}
      {top_left, bottom_right}
    end

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({start, stop}) ->
      image = :egd.filledRectangle(image, start, stop, fill)
    end  

    :egd.render(image)
    
  end

  def save_image(image, input) do
    File.write("#{input}.png", image)

  end
end
