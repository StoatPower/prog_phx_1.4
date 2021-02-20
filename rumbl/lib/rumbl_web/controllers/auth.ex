defmodule RumblWeb.Auth do
  import Plug.Conn
  import Phoenix.Controller
  alias RumblWeb.Router.Helpers, as: Routes

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)
    
    # match on the current_user already in place in the assigns
    # if exists, we return connection as is
    #
    # From the book:
    # What we’re doing here is controversial. We’re adding this code
    # to make our implementation more testable. We think the trade-off is worth
    # it. We are improving the contract. If a user is in the conn.assigns, we honor it, no
    # matter how it got there. We have an improved testing story that doesn’t require
    # us to write mocks or any other elaborate scaffolding.
    cond do
      conn.assigns[:current_user] ->
        conn

      user = user_id && Rumbl.Accounts.get_user(user_id) ->
        assign(conn, :current_user, user)

      true ->
        assign(conn, :current_user, nil)
    end
  end

  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true) #protects from session fixation attacks
  end

  def logout(conn) do
    configure_session(conn, drop: true)
  end

  def authenticate_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end

  end
end