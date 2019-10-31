defmodule TestHelpers.Game do
  def events(pid, event_name \\ nil) do
    {:messages, messages} = :erlang.process_info(pid, :messages)

    messages
    |> Enum.filter(&is_map(&1))
    |> filter_messages(fn message -> message.event |> String.starts_with?("game:") end)
    |> filter_by_name(event_name)
  end

  defp filter_by_name(messages, nil) do
    messages
  end

  defp filter_by_name(messages, name) do
    filter_messages(messages, fn message -> message.event == name end)
  end

  defp filter_messages(messages, fun) do
    Enum.filter(messages, fn message -> fun.(message) end)
  end
end
