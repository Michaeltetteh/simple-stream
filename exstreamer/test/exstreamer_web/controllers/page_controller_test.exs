defmodule ExstreamerWeb.PageControllerTest do
  use ExstreamerWeb.ConnCase

  test "GET / returns 200 with home content", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "EXSTREAMER"
  end
end
