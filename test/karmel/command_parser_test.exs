defmodule Karmel.CommandParserTest do
  use ExUnit.Case, async: true
  import Karmel.CommandParser
  doctest Karmel.CommandParser

  @my_id "U1J28HCKC"
  @sending_user_id "U12345678"

  test "info" do
    assert parse_req("<@#{@my_id}>") == :info
    assert parse_req("<@#{@my_id}>:") == :info
    assert parse_req("<@#{@my_id}>: ") == :info
    assert parse_req("<@#{@my_id}> info") == :info
    assert parse_req("<@#{@my_id}>:info") == :info
    assert parse_req("<@#{@my_id}>: info") == :info
  end

  test "reset" do
    assert parse_req("<@#{@my_id}> reset") == :reset
    assert parse_req("<@#{@my_id}>:reset") == :reset
    assert parse_req("<@#{@my_id}>: reset") == :reset
  end

  test "update" do
    expected = {:update, %{is_cheater: false, scores: [{"U174NDB8F", 1}]}}
    assert parse_req("<@U174NDB8F>: ++") == expected
    assert parse_req("<@#{@my_id}> <@U174NDB8F>: ++") == expected
    assert parse_req("<@#{@my_id}>:<@U174NDB8F>: ++") == expected
    assert parse_req("<@#{@my_id}>: <@U174NDB8F>: ++") == expected
  end

  test "detects cheater" do
    msg = "<@#{@sending_user_id}>: ++++"

    assert {:update, %{is_cheater: true, scores: []}} == parse_req(msg)
  end

  test "multiple updates" do
    scores = [{"U174NDB8F", 1}, {"U32132132", -3}] |> Enum.sort()
    expected = {:update, %{is_cheater: false, scores: scores}}
    msg = "<@U32132132> ---- and <@U174NDB8F>: ++"

    assert {:update, %{is_cheater: false, scores: new_scores}} = parse_req(msg)

    assert Enum.sort(new_scores) == scores
  end

  test "multiple updates with cheater" do
    scores = [{"U32132132", -3}]
    msg = "<@U32132132> ---- and <@#{@sending_user_id}>: ++"

    assert {:update, %{is_cheater: true, scores: scores}} == parse_req(msg)
  end

  test "other message" do
    assert parse_req("<@#{@my_id}>: informations") == nil
    assert parse_req("<@#{@my_id}>: resetting") == nil
    assert parse_req("<@#{@my_id}>: <@U174NDB8F>: +") == nil
    assert parse_req("<@U174NDB8F>: +") == nil
  end

  test "message with no karma" do
    assert extract_scores("") == []
    assert extract_scores("<@U07A2APBP>: hey") == []
    assert extract_scores("<@U07A2APBP>: +--") == []
  end

  test "simple ++" do
    expected = [{"U174NDB8F", 1}]
    assert extract_scores("<@U174NDB8F>: ++") == expected
    assert extract_scores("<@U174NDB8F> ++") == expected
    assert extract_scores("<@U174NDB8F>++") == expected
  end

  test "simple --" do
    expected = [{"U174NDB8F", -1}]
    assert extract_scores("<@U174NDB8F>: --") == expected
    assert extract_scores("<@U174NDB8F> --") == expected
    assert extract_scores("<@U174NDB8F>--") == expected
  end

  test "higher values" do
    assert extract_scores("<@U174NDB8F>: +++++") == [{"U174NDB8F", 4}]
    assert extract_scores("<@U174NDB8F>: -----") == [{"U174NDB8F", -4}]
  end

  test "limit very high values to 5" do
    assert extract_scores("<@U174NDB8F>: ++++++++++++++++++++++") == [{"U174NDB8F", 5}]
    assert extract_scores("<@U174NDB8F>: ----------------------") == [{"U174NDB8F", -5}]
  end

  test "multiple occurrences" do
    assert extract_scores("I'll give <@U174NDB8F>: +++++ and for <@U07A2APBP>---") == [
             {"U174NDB8F", 4},
             {"U07A2APBP", -2}
           ]
  end

  defp parse_req(msg) do
    case parse(req(msg), @my_id) do
      nil -> nil
      %Karmel.Command{command: cmd} -> cmd
    end
  end

  defp req(msg) do
    %Karmel.Request{text: msg, user_id: @sending_user_id}
  end
end
