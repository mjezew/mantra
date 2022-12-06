defmodule Mix.Tasks.Couch.View.Sync do
  @moduledoc """
  Sync design docs to couchdb instance

  The expected format of views is as follows.

  ```
  # priv/couchdb
    [database-name]/
      [design-doc-name]/
        views/
          [view-1-name]/
            map.js
          [view-2-name]/
            map.js
  ```

  A real world example would be:

  ```
  blocks/
    page-blocks/
      views/
        page-todos/
          map.js
        page-blocks/
          map.js
  ```

  """
  alias Infra.CouchDB
  alias Infra.CouchDB.Client

  @couch_dir Path.join(:code.priv_dir(:mantra), "couch")

  def run(_args) do
    load_definitions()
    |> filter_definitions()
    |> update_definitions()
  end

  # load current definitions from filesystem
  defp load_definitions() do
    @couch_dir
    |> File.ls!()
    |> Enum.flat_map(fn database_name ->
      path = Path.join([@couch_dir, database_name])

      path
      |> File.ls!()
      |> Enum.map(fn design_doc_name ->
        path = Path.join([path, design_doc_name, "views"])

        views =
          path
          |> File.ls!()
          |> Enum.reduce(%{}, fn view_name, views ->
            path = Path.join([path, view_name, "map.js"])

            map_fn =
              path
              |> File.read!()
              |> String.trim()

            Map.put(views, view_name, %{"map" => map_fn})
          end)

        %{"database_name" => database_name, "name" => design_doc_name, "views" => views}
      end)
    end)
  end

  # filter definitions to ones needing to be inserted/updated
  defp filter_definitions(definitions) do
    definitions
    |> Enum.reduce([], fn expected_definition, defs_to_update ->
      case Client.get("/blocks/_design/#{Map.get(expected_definition, "name")}") do
        {:error, %CouchDB.NotFound{}} ->
          [{:insert, expected_definition} | defs_to_update]

        {:ok, actual_definition} ->
          if Map.equal?(actual_definition["views"], expected_definition["views"]) do
            defs_to_update
          else
            [
              {:update,
               Map.merge(
                 expected_definition,
                 Map.new(["_rev"], fn key -> {key, Map.get(actual_definition, key)} end)
               )}
              | defs_to_update
            ]
          end
      end
    end)
  end

  defp update_definitions(definitions) do
    definitions
    |> Enum.map(fn
      {:update, definition} ->
        definition = Map.drop(definition, ["id"])

        Client.put(
          "#{Map.get(definition, "database_name")}/_design/#{Map.get(definition, "name")}",
          definition
        )

      {:insert, definition} ->
        Client.put(
          "#{Map.get(definition, "database_name")}/_design/#{Map.get(definition, "name")}",
          definition
        )
    end)
  end
end
