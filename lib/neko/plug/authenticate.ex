defmodule Neko.Plug.Authenticate do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, opts) do
    conn |> get_auth_header |> authenticate(opts[:token])
  end

  defp get_auth_header(conn) do
    {conn, get_req_header(conn, "authorization")}
  end

  defp authenticate({conn, [token]}, token), do: conn
  defp authenticate({conn, _}, _token) do
    conn |> send_resp(401, "Not Authorized") |> halt
  end
end
