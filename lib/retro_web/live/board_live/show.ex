defmodule RetroWeb.BoardLive.Show do
  use RetroWeb, :live_view

  alias Retro.Boards

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    Phoenix.PubSub.subscribe(Retro.PubSub, id)
    {:noreply,
     socket
     |> assign(:cards, [])
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:page_id, id)
     |> assign(:board, Boards.get_board!(id))
     |> assign(:form, input_form())}
  end

  defp input_form, do: to_form(%{"data" => "", "id" => :rand.uniform(2000)})

  defp page_title(:show), do: "Show Board"
  defp page_title(:edit), do: "Edit Board"

  @impl true
  def handle_event("add_card", %{"card_title" => title}, socket) do
    %{assigns: %{page_id: id}} = socket

    if String.trim(title) !== "", do: Phoenix.PubSub.broadcast(Retro.PubSub, id, {:new_card, title})

    {:noreply, socket}
  end

  @impl true
  def handle_event("remove", %{"value" => title}, socket) do
    %{assigns: %{page_id: id}} = socket

    if String.trim(title) !== "", do: Phoenix.PubSub.broadcast(Retro.PubSub, id, {:remove_card, title})

    {:noreply, socket}
  end

  @impl true
  def handle_info({:new_card, title}, socket) do
    %{assigns: %{cards: cards}} = socket

    socket = socket
    |> assign(:cards, [title] ++ cards)

    {:noreply, assign(socket, cards: [title] ++ cards, form: input_form())}
  end

  @impl true
  def handle_info({:remove_card, title}, socket) do
    %{assigns: %{cards: cards}} = socket

    socket = socket
    |> assign(:cards, cards -- [title])

    {:noreply, socket}
  end
end
