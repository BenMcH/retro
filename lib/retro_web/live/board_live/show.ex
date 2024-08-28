defmodule RetroWeb.BoardLive.Show do
  import Ecto.Query, warn: false
  alias Retro.Cards

  use RetroWeb, :live_view

  alias Retro.Boards

  @impl true
  def mount(%{"id" => slug}, _session, socket) do
    board = Boards.get_board(slug)

    Phoenix.PubSub.subscribe(Retro.PubSub, board.slug)

    cards = Cards.list_cards(board.id)

    socket =
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:board, board)
      |> assign(:form, input_form())
      |> stream(:cards, cards)

    {:ok, socket}
  end

  defp input_form, do: to_form(%{"data" => "", "id" => :rand.uniform(2000)})

  defp page_title(:show), do: "Show Board"
  defp page_title(:edit), do: "Edit Board"

  @impl true
  def handle_event("add_card", %{"card_title" => ""}, socket), do: {:noreply, socket}

  @impl true
  def handle_event("add_card", %{"card_title" => title, "column" => column}, socket) do
    %{assigns: %{board: board}} = socket

    {:ok, card} = Cards.create_card(%{title: title, column: column, board_id: board.id})

    Phoenix.PubSub.broadcast(Retro.PubSub, board.slug, {:add_card, card})

    {:noreply, socket |> assign(form: input_form())}
  end

  @impl true
  def handle_event("remove", %{"value" => id}, socket) do
    %{assigns: %{board: board}} = socket

    {:ok, card} = id |> Cards.get_card!() |> Cards.delete_card()

    Phoenix.PubSub.broadcast(Retro.PubSub, board.slug, {:remove_card, card})

    {:noreply, socket}
  end

  @impl true
  def handle_event("add_category", %{"category_title" => name}, socket) do
    %{assigns: %{board: board}} = socket

    unless name in board.categories do
      categories = board.categories ++ [name]
      {:ok, board} = Boards.update_board(board, %{categories: categories})
      Phoenix.PubSub.broadcast(Retro.PubSub, board.slug, {:update_board, board})
    end

    {:noreply, socket |> assign(form: input_form())}
  end

  @impl true
  def handle_event("delete_category", %{"value" => name}, socket) do
    %{assigns: %{board: board}} = socket

    categories = board.categories -- [name]
    {:ok, board} = Boards.update_board(board, %{categories: categories})
    Cards.delete_by_board_id_and_column(board.id, name)

    Phoenix.PubSub.broadcast(Retro.PubSub, board.slug, {:update_board, board})
    {:noreply, socket}
  end

  @impl true
  def handle_info({:add_card, card}, socket) do
    {:noreply, socket |> stream_insert(:cards, card)}
  end

  @impl true
  def handle_info({:remove_card, card}, socket) do
    {:noreply, socket |> stream_delete(:cards, card)}
  end

  @impl true
  def handle_info({:update_board, board}, socket) do
    {:noreply, socket |> assign(:board, board)}
  end
end
