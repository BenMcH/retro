defmodule RetroWeb.BoardLive.Show do
  use RetroWeb, :live_view

  alias Retro.Boards

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:board, Boards.get_board!(id))}
  end

  defp page_title(:show), do: "Show Board"
  defp page_title(:edit), do: "Edit Board"
end
