defmodule Ist.Recorder.Device do
  use Ecto.Schema

  import Ecto.Changeset
  import Ist.Accounts.Account, only: [prefix: 1]

  alias Ist.Recorder.Device
  alias Ist.Accounts.Account
  alias Ist.Repo

  schema "devices" do
    field :uuid, :string
    field :name, :string
    field :description, :string
    field :status, :string
    field :url, :string
    field :lock_version, :integer, default: 1

    timestamps type: :utc_datetime
  end

  @statuses ~w(unknown starting recording failing stopped)

  @doc false
  def changeset(%Account{} = account, %Device{} = device, attrs) do
    device
    |> put_uuid()
    |> put_status()
    |> put_prefix(account)
    |> cast(attrs, [:uuid, :name, :description, :status, :url, :lock_version])
    |> validate_required([:uuid, :name, :url, :status])
    |> validate_length(:name, max: 255)
    |> validate_length(:uuid, max: 255)
    |> validate_length(:status, max: 255)
    |> validate_length(:url, max: 2047)
    |> validate_inclusion(:status, @statuses)
    |> validate_url(:url)
    |> unsafe_validate_unique(:name, Repo, prefix: prefix(account))
    |> unsafe_validate_unique(:uuid, Repo, prefix: prefix(account))
    |> unique_constraint(:name)
    |> unique_constraint(:uuid)
    |> optimistic_lock(:lock_version)
  end

  def record({:ok, device}, session) do
    Ist.PubSub.Notifier.notify(session, device)
    Ist.Recorder.update_device(session, device, %{status: "starting"})
  end

  def record(result, _session), do: result

  defp put_uuid(%Device{uuid: nil} = device) do
    device |> Map.put(:uuid, Ecto.UUID.generate())
  end

  defp put_uuid(device), do: device

  defp put_status(%Device{status: nil} = device) do
    device |> Map.put(:status, "unknown")
  end

  defp put_status(device), do: device

  defp put_prefix(%Device{__meta__: %{prefix: nil}} = device, %Account{} = account) do
    meta = device.__meta__ |> Map.put(:prefix, prefix(account))

    Map.put(device, :__meta__, meta)
  end

  defp put_prefix(%Device{} = device, _account), do: device

  defp validate_url(%Ecto.Changeset{} = changeset, field, opts \\ []) do
    validate_change(changeset, field, fn _, value ->
      message =
        case URI.parse(value) do
          %URI{scheme: nil} ->
            "has invalid format"

          %URI{host: nil} ->
            "has invalid format"

          %URI{host: host} ->
            case :inet.gethostbyname(Kernel.to_charlist(host)) do
              {:ok, _} -> nil
              {:error, _} -> "has invalid format"
            end
        end

      case message do
        error when is_binary(error) -> [{field, Keyword.get(opts, :message, error)}]
        _ -> []
      end
    end)
  end
end
