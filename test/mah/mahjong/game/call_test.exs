defmodule Mah.Mahjong.Game.CallTest do
  use ExUnit.Case, async: true

  alias Mah.Mahjong.Game.Call

  describe "new/3" do
    test "can chi from only kamicha" do
      assert {:ok, _} = Call.new(:chi, :kamicha, [0, 4, 8])
      assert {:error, _} = Call.new(:chi, :toimen, [0, 4, 8])
      assert {:error, _} = Call.new(:chi, :shimocha, [0, 4, 8])
    end

    test "can chi with shuntsu" do
      assert {:ok, _} = Call.new(:chi, :kamicha, [0, 4, 8])
      assert {:error, _} = Call.new(:chi, :kamicha, [0, 4, 12])
      assert {:error, _} = Call.new(:chi, :kamicha, [35, 39, 43])
    end

    test "can pon with kotsu" do
      assert {:ok, _} = Call.new(:pon, :kamicha, [0, 1, 2])
      assert {:ok, _} = Call.new(:pon, :shimocha, [133, 134, 135])
      assert {:error, _} = Call.new(:pon, :toimen, [0, 1, 4])
    end

    test "can ankan with kantsu" do
      assert {:ok, _} = Call.new(:ankan, nil, [0, 1, 2, 3])
      assert {:error, _} = Call.new(:ankan, :kamicha, [0, 1, 2, 3])
    end

    test "can minkan with kantsu" do
      assert {:ok, _} = Call.new(:minkan, :toimen, [0, 1, 2, 3])
      assert {:error, _} = Call.new(:minkan, :kamicha, [0, 1, 2, 4])
    end
  end

  describe "kakan/2" do
    test "can kakan with pon" do
      {:ok, pon} = Call.new(:pon, :toimen, [0, 1, 2])
      {:ok, call} = Call.kakan(pon, 3)

      assert call.type == :kakan
      assert call.from == :toimen
      assert call.tiles == [3, 0, 1, 2]
    end

    test "cannot kakan with incorrect tile" do
      {:ok, pon} = Call.new(:pon, :toimen, [0, 1, 2])

      assert {:error, :not_kantsu} = Call.kakan(pon, 4)
    end
  end
end
