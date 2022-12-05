defmodule Infra.CouchDB.Databases do
  use Tesla

  # TODO: Pull from environment when hardened
  plug Tesla.Middleware.BaseUrl, "http://localhost:5984"
  plug Tesla.Middleware.BasicAuth, username: "couchdb", password: "password"
  plug Tesla.Middleware.JSON

  def create_db(database_name) do
    put("/#{database_name}", nil)
  end

  def get_db(database_name) do
    get("/#{database_name}")
  end

  def all_docs(database_name, params) do
    post("/#{database_name}/_all_docs", params)
  end
end
