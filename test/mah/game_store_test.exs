defmodule Mah.GameStoreTest do
  use ExUnit.Case, async: true

  alias Mah.GameStore

  setup do
    %{uuid: UUID.uuid4()}
  end

  describe "start/2" do
    test "start for each games" do
      assert {:ok, _pid} = GameStore.start(UUID.uuid4(), :a)
      assert {:ok, _pid} = GameStore.start(UUID.uuid4(), :b)
    end

    test "cannot start with non-unique id", %{uuid: uuid} do
      {:ok, pid} = GameStore.start(uuid, :a)

      assert {:error, {:already_started, pid}} == GameStore.start(uuid, :b)
    end
  end

  describe "get/1" do
    test "returns state", %{uuid: uuid} do
      {:ok, _pid} = GameStore.start(uuid, :hello)

      assert :hello == GameStore.get(uuid)
    end

    test "returns error on not found" do
      assert {:error, :not_found} == GameStore.get("unstarted")
    end
  end

  describe "put/2" do
    test "replace state", %{uuid: uuid} do
      {:ok, _pid} = GameStore.start(uuid, :a)

      assert :ok = GameStore.put(uuid, :b)
      assert :b == GameStore.get(uuid)
    end

    test "returns error on not found" do
      assert {:error, :not_found} == GameStore.put("unstarted", :hey)
    end
  end

  describe "update/2" do
    test "updates state", %{uuid: uuid} do
      {:ok, _pid} = GameStore.start(uuid, 1)

      assert :ok = GameStore.update(uuid, &(&1 + 1))
      assert 2 == GameStore.get(uuid)
    end
  end

  describe "stop/1" do
    test "stops store", %{uuid: uuid} do
      {:ok, _pid} = GameStore.start(uuid, :a)

      assert :ok == GameStore.stop(uuid)
      assert {:error, :not_found} == GameStore.get(uuid)
    end

    test "returns error on not found" do
      assert {:error, :not_found} == GameStore.stop("unstarted")
    end
  end

  describe "alive?/1" do
    test "returns true if process is alive", %{uuid: uuid} do
      {:ok, _pid} = GameStore.start(uuid, :state)

      assert true == GameStore.alive?(uuid)
    end

    test "returns false if process does not exist", %{uuid: uuid} do
      assert false == GameStore.alive?(uuid)
    end
  end
end
