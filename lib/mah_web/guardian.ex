defmodule MahWeb.Guardian do
  use Guardian, otp_app: :mah

  def subject_for_token(%{id: id}, _claims) do
    {:ok, to_string(id)}
  end

  def resource_from_claims(%{"sub" => id}) do
    {:ok, %{id: id}}
  end
end
