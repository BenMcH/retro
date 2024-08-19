defmodule Retro.Repo.Migrations.AddCategoriesToBoards do
  use Ecto.Migration

  def change do
    alter table(:boards) do
      add :categories, {:array, :string}
    end
  end
end
