defmodule MantraWeb.PageController do
  use MantraWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
