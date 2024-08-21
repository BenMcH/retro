defmodule RetroWeb.BoardLive.Show do
  import Ecto.Query, warn: false
  alias Retro.Cards

  use RetroWeb, :live_view

  alias Retro.Boards

  @impl true
  def mount(%{"id" => slug}, _session, socket) do
    id = Integer.parse(slug)

    board =
      if id === :error do
        Boards.get_board(slug)
      else
        id = id |> elem(0)
        Boards.get_board!(id)
      end

    slug = board.slug

    Phoenix.PubSub.subscribe(Retro.PubSub, slug)

    id = board.id
    cards = Cards.list_cards(id)
    categories = board.categories || []
    categories = categories |> Enum.map(&String.to_atom(&1))

    socket =
      socket
      |> assign(:keys, categories)
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:board_id, id)
      |> assign(:board, board)
      |> assign(:form, input_form())

    socket =
      categories
      |> Enum.reduce(socket, fn category, socket ->
        cards = cards |> Enum.filter(&(&1.column === to_string(category)))
        socket |> stream(category, cards)
      end)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    Phoenix.PubSub.subscribe(Retro.PubSub, id)

    {:noreply,
     socket
     |> assign(:form, input_form())}
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
      categories = board.categories || []
      categories = categories ++ [name]
      {:ok, board} = Boards.update_board(board, %{categories: categories})
      Phoenix.PubSub.broadcast(Retro.PubSub, board.slug, {:update_board, board})
    end

    {:noreply, socket |> assign(form: input_form())}
  end

  @impl true
  def handle_info({:add_card, card}, socket) do
    socket = socket |> stream_insert(card.column |> String.to_atom(), card)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:remove_card, card}, socket) do
    {:noreply, socket |> stream_delete(card.column |> String.to_atom(), card)}
  end

  @impl true
  def handle_info({:update_board, board}, socket) do
    socket =
      socket
      |> assign(:keys, board.categories |> Enum.map(&String.to_atom(&1)))
      |> assign(:board, board)

    socket =
      Enum.reduce(board.categories, socket, fn category, socket ->
        stream(socket, String.to_atom(category), [])
      end)

    {:noreply, socket}
  end
end
