defmodule Karmel.BotsSupervisor do
  use DynamicSupervisor

  def count_children() do
    DynamicSupervisor.count_children(__MODULE__)
  end

  def start_child(child_spec) do
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def terminate_child(pid) do
    DynamicSupervisor.terminate_child(__MODULE__, pid)
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
