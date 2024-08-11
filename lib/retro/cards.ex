defmodule Retro.Cards do
  @moduledoc """
  The Cards context.
  """

  import Ecto.Query, warn: false
  alias Retro.Repo

  alias Retro.Boards.Card

  @doc """
  Returns the list of Cards.

  ## Examples

      iex> list_cards()
      [%Card{}, ...]

  """
  def list_cards do
    Repo.all(Card)
  end

  def list_cards(id) do
    Card
    |> where(board_id: ^id)
    |> Repo.all()
  end

  @doc """
  Gets a single Card.

  Raises `Ecto.NoResultsError` if the Card does not exist.

  ## Examples

      iex> get_card!(123)
      %Card{}

      iex> get_card!(456)
      ** (Ecto.NoResultsError)

  """
  def get_card!(id), do: Repo.get!(Card, id)

  @doc """
  Creates a Card.

  ## Examples

      iex> create_card(%{field: value})
      {:ok, %Card{}}

      iex> create_card(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_card(attrs \\ %{}) do
    %Card{}
    |> Card.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a Card.

  ## Examples

      iex> update_card(Card, %{field: new_value})
      {:ok, %Card{}}

      iex> update_card(Card, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_card(%Card{} = Card, attrs) do
    Card
    |> Card.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Card.

  ## Examples

      iex> delete_card(Card)
      {:ok, %Card{}}

      iex> delete_card(Card)
      {:error, %Ecto.Changeset{}}

  """
  def delete_card(%Card{} = card) do
    Repo.delete(card)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking Card changes.

  ## Examples

      iex> change_card(Card)
      %Ecto.Changeset{data: %Card{}}

  """
  def change_card(%Card{} = Card, attrs \\ %{}) do
    Card.changeset(Card, attrs)
  end
end
