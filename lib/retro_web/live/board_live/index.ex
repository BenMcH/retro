defmodule RetroWeb.BoardLive.Index do
  use RetroWeb, :live_view

  alias Retro.Boards
  alias Retro.Boards.Board

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :boards, Boards.list_boards())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Board")
    |> assign(:board, Boards.get_board!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Board")
    |> assign(:board, %Board{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Boards")
    |> assign(:board, nil)
  end

  @impl true
  def handle_info({RetroWeb.BoardLive.FormComponent, {:saved, board}}, socket) do
    {:noreply, stream_insert(socket, :boards, board)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    board = Boards.get_board!(id)
    {:ok, _} = Boards.delete_board(board)

    {:noreply, stream_delete(socket, :boards, board)}
  end
end
