defmodule Retro.BoardsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Retro.Boards` context.
  """

  @doc """
  Generate a board.
  """
  def board_fixture(attrs \\ %{}) do
    {:ok, board} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Retro.Boards.create_board()

    board
  end
end
