defmodule Retro.Repo.Migrations.AddSlugToBoards do
  use Ecto.Migration

  def change do
    alter table(:boards) do
      add :slug, :string
    end
  end
end
