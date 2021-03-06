defmodule Mix.Tasks.PowAssent.Ecto.Gen.Migration do
  @shortdoc "Generates user identities migration file"

  @moduledoc """
  Generates a user identity migrations file.

      mix pow_assent.ecto.gen.migration -r MyApp.Repo

      mix pow_assent.ecto.gen.migration -r MyApp.Repo Accounts.Identity identities

  This generator will add a migration file in `priv/repo/migrations` for the
  `user_identities` table

  ## Arguments

    * `-r`, `--repo` - the repo module
    * `--binary-id` - use binary id for primary key
    * `--users-table` - what users table to reference, defaults to "users"
  """
  use Mix.Task

  alias PowAssent.Ecto.UserIdentities.Schema.Migration, as: UserIdentitiesMigration
  alias Mix.{Ecto, Pow, Pow.Ecto.Migration, PowAssent}

  @switches [binary_id: :boolean, users_table: :string]
  @default_opts [binary_id: false, users_table: "users"]
  @mix_task "pow_assent.ecto.gen.migration"

  @impl true
  def run(args) do
    Pow.no_umbrella!(@mix_task)

    args
    |> Pow.parse_options(@switches, @default_opts)
    |> parse()
    |> create_migrations_files(args)
  end

  defp parse({config, parsed, _invalid}) do
    parsed
    |> PowAssent.validate_schema_args!(@mix_task)
    |> Map.merge(config)
  end

  defp create_migrations_files(config, args) do
    args
    |> Ecto.parse_repo()
    |> Enum.map(&Ecto.ensure_repo(&1, args))
    |> Enum.map(&Map.put(config, :repo, &1))
    |> Enum.each(&create_migration_files/1)
  end

  defp create_migration_files(%{repo: repo, binary_id: binary_id, users_table: users_table, schema_plural: schema_plural}) do
    context_base  = Pow.app_base(Pow.otp_app())
    schema        = UserIdentitiesMigration.new(context_base, schema_plural, repo: repo, binary_id: binary_id, users_table: users_table)
    content       = UserIdentitiesMigration.gen(schema)

    Migration.create_migration_files(repo, schema.migration_name, content)
  end
end
