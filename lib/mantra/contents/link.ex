defmodule Mantra.Contents.Link do
  @type t :: String.t()

  @spec parse_links(String.t()) :: [t()]
  def parse_links(string) do
    ~r/\[\[([^\[]+)\]\]/
    |> Regex.scan(string)
    |> Enum.map(fn [_match, captured_link] -> captured_link end)
  end
end
