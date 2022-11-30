defmodule Infra.Graph.Repo do
  @behaviour Mantra.Contents.Repo
  alias Garf.Graph.QueryResult

  @impl Mantra.Contents.Repo
  def get_page_by(key, value) do
    case Garf.Graph.query("Garf", "MATCH (p :Page {#{key}: '#{value}'}) RETURN p") do
      {:ok, %QueryResult{results: []}} -> nil
      {:ok, %QueryResult{results: [[%{properties: page}]]}} -> page
    end
  end

  def get_block_by(key, value) do
    case Garf.Graph.query("Garf", "MATCH (b :Block {#{key}: '#{value}'}) RETURN b") do
      {:ok, %QueryResult{results: []}} -> nil
      {:ok, %QueryResult{results: [[%{properties: block}]]}} -> block
    end
  end

  def get_page_with_blocks(key, value) do
    case Garf.Graph.query(
           "Garf",
           ~s"""
           MATCH path = (p :Page {#{key}: '#{value}'})<-[:BELONGS_TO*]-(b :Block) 
           RETURN path ORDER BY length(relationships(path)) DESC
           """
         ) do
      {:ok, %QueryResult{results: []}} -> nil
      {:ok, %QueryResult{results: results}} -> results
    end
  end

  @impl Mantra.Contents.Repo
  def create_page(%Ecto.Changeset{valid?: true} = changeset) do
    with {:ok, page} <- Ecto.Changeset.apply_action(changeset, :insert),
         {:ok, %QueryResult{results: [[%{properties: page}]]}} <-
           Garf.Graph.query(
             "Garf",
             "CREATE (p :Page {title: '#{page.title}', id: '#{Ecto.UUID.generate()}'}) RETURN p"
           ) do
      {:ok, page}
    end
  end

  def create_page(%Ecto.Changeset{valid?: false} = changeset), do: {:error, changeset}

  @impl Mantra.Contents.Repo
  def add_block_to_page(page, block_changeset) do
    with {:ok, block} <- Ecto.Changeset.apply_action(block_changeset, :insert),
         {:ok, %QueryResult{results: [[%{properties: block}]]}} <-
           Garf.Graph.query(
             "Garf",
             "MATCH (p :Page {id: '#{page.id}'}) CREATE (p)<-[:BELONGS_TO]-(b :Block {content: '#{block.content}', order: #{block.order}, id: '#{Ecto.UUID.generate()}'}) RETURN b"
           ) do
      {:ok, block}
    end
  end

  @impl Mantra.Contents.Repo
  def add_block_to_block(block, block_changeset) do
    with {:ok, new_block} <- Ecto.Changeset.apply_action(block_changeset, :insert),
         {:ok, %QueryResult{results: [[%{properties: created_block}]]}} <-
           Garf.Graph.query(
             "Garf",
             "MATCH (b1 :Block {id: '#{block.id}'}) CREATE (b1)<-[:BELONGS_TO]-(b2 :Block {content: '#{new_block.content}', order: #{new_block.order}, id: '#{Ecto.UUID.generate()}'}) RETURN b2"
           ) do
      {:ok, created_block}
    end
  end

  def list_all_pages() do
    case Garf.Graph.query("Garf", "MATCH (p :Page) RETURN p") do
      {:ok, %QueryResult{results: []}} ->
        []

      {:ok, %QueryResult{results: pages}} ->
        Enum.flat_map(pages, fn page -> Enum.map(page, &Map.get(&1, :properties)) end)
    end
  end

  def clear_database() do
    Garf.Graph.query("Garf", "MATCH (n) DELETE n")
  end
end
