defmodule Karmel.ParserTest do
  use ExUnit.Case, async: true
  import Karmel.Parser

  @my_id "U1J28HCKC"

  test "info" do
    assert parse("<@#{@my_id}>", @my_id) == :info
    assert parse("<@#{@my_id}>:", @my_id) == :info
    assert parse("<@#{@my_id}>: ", @my_id) == :info
    assert parse("<@#{@my_id}> info", @my_id) == :info
    assert parse("<@#{@my_id}>:info", @my_id) == :info
    assert parse("<@#{@my_id}>: info", @my_id) == :info
  end

  test "reset" do
    assert parse("<@#{@my_id}> reset", @my_id) == :reset
    assert parse("<@#{@my_id}>:reset", @my_id) == :reset
    assert parse("<@#{@my_id}>: reset", @my_id) == :reset
  end

  test "update" do
    expected = {:update, [{"U174NDB8F", 1}]}
    assert parse("<@U174NDB8F>: ++", @my_id) == expected
    assert parse("<@#{@my_id}> <@U174NDB8F>: ++", @my_id) == expected
    assert parse("<@#{@my_id}>:<@U174NDB8F>: ++", @my_id) == expected
    assert parse("<@#{@my_id}>: <@U174NDB8F>: ++", @my_id) == expected
  end

  test "other message" do
    assert parse("<@#{@my_id}>: informations", @my_id) == nil
    assert parse("<@#{@my_id}>: resetting", @my_id) == nil
    assert parse("<@#{@my_id}>: <@U174NDB8F>: +", @my_id) == nil
    assert parse("<@U174NDB8F>: +", @my_id) == nil
  end

  test "message with no karma" do
    assert extract_karma("") == []
    assert extract_karma("<@U07A2APBP>: hey") == []
    assert extract_karma("<@U07A2APBP>: +--") == []
  end

  test "simple ++" do
    expected = [{"U174NDB8F", 1}]
    assert extract_karma("<@U174NDB8F>: ++") == expected
    assert extract_karma("<@U174NDB8F> ++") == expected
    assert extract_karma("<@U174NDB8F>++") == expected
  end

  test "simple --" do
    expected = [{"U174NDB8F", -1}]
    assert extract_karma("<@U174NDB8F>: --") == expected
    assert extract_karma("<@U174NDB8F> --") == expected
    assert extract_karma("<@U174NDB8F>--") == expected
  end

  test "higher values" do
    assert extract_karma("<@U174NDB8F>: +++++") == [{"U174NDB8F", 4}]
    assert extract_karma("<@U174NDB8F>: -----") == [{"U174NDB8F", -4}]
  end

  test "limit very high values to 5" do
    assert extract_karma("<@U174NDB8F>: ++++++++++++++++++++++") == [{"U174NDB8F", 5}]
    assert extract_karma("<@U174NDB8F>: ----------------------") == [{"U174NDB8F", -5}]
  end

  test "multiple occurrences" do
    assert extract_karma("I'll give <@U174NDB8F>: +++++ and for <@U07A2APBP>---") == [
             {"U174NDB8F", 4},
             {"U07A2APBP", -2}
           ]
  end
end
