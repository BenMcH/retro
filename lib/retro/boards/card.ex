defmodule Retro.Boards.Card do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cards" do
    field :title, :string
    field :column, :string
    field :board_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(card, attrs) do
    card
    |> cast(attrs, [:title, :column, :board_id])
    |> validate_required([:title, :column, :board_id])
  end
end
