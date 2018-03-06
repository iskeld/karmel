defmodule Karmel.SlackTest do
  import Karmel.Slack
  use ExUnit.Case, async: true

  test "parses regular channel message to request" do
    evt = %{
      "event" => %{
        "channel" => "C3ABCD234",
        "text" => "let's add <@U12345678> ++",
        "type" => "message",
        "user" => "U1234A5BC"
      },
      "team_id" => "T123ABCDE",
      "token" => "randomslacktoken",
      "type" => "event_callback"
    }

    assert {:ok, req} = parse_event(evt)

    assert req == %Karmel.Request{
             team_id: "T123ABCDE",
             user_id: "U1234A5BC",
             channel_id: "C3ABCD234",
             thread_id: nil,
             is_direct: false,
             text: "let's add <@U12345678> ++"
           }
  end

  test "parses direct message" do
    evt = %{
      "event" => %{
        "channel" => "D3ABCD234",
        "text" => "version",
        "type" => "message",
        "user" => "U1234A5BC"
      },
      "team_id" => "T123ABCDE",
      "token" => "randomslacktoken",
      "type" => "event_callback"
    }

    assert {:ok, req} = parse_event(evt)

    assert req == %Karmel.Request{
             team_id: "T123ABCDE",
             user_id: "U1234A5BC",
             channel_id: "D3ABCD234",
             thread_id: nil,
             is_direct: true,
             text: "version"
           }
  end

  test "parses threaded channel message to request" do
    evt = %{
      "event" => %{
        "channel" => "C3ABCD234",
        "event_ts" => "1519768468.000187",
        "parent_user_id" => "U1234A5BC",
        "text" => "now in thread <@U12345678> ++ yes",
        "thread_ts" => "1519768453.000455",
        "ts" => "1519768468.000187",
        "type" => "message",
        "user" => "U1234A5BC"
      },
      "team_id" => "T123ABCDE",
      "token" => "randomslacktoken",
      "type" => "event_callback"
    }

    assert {:ok, req} = parse_event(evt)

    assert req == %Karmel.Request{
             team_id: "T123ABCDE",
             user_id: "U1234A5BC",
             channel_id: "C3ABCD234",
             thread_id: "1519768453.000455",
             is_direct: false,
             text: "now in thread <@U12345678> ++ yes"
           }
  end

  test "parses file initial comment" do
    evt = %{
      "event" => %{
        "channel" => "C3ABCD234",
        "file" => %{
          "initial_comment" => %{
            "comment" => "let's give <@U12345678> ++",
            "is_intro" => true,
            "user" => "U1234A5BC"
          }
        },
        "subtype" => "file_share",
        "text" =>
          "<@U1234A5BC> uploaded a file: <https://something.slack.com/x.png|x> and commented: let's give <@U12345678> ++",
        "type" => "message",
        "user" => "U1234A5BC"
      },
      "team_id" => "T123ABCDE",
      "token" => "randomslacktoken",
      "type" => "event_callback"
    }

    assert {:ok, req} = parse_event(evt)

    assert req == %Karmel.Request{
             team_id: "T123ABCDE",
             user_id: "U1234A5BC",
             channel_id: "C3ABCD234",
             thread_id: nil,
             is_direct: false,
             text: "let's give <@U12345678> ++"
           }
  end

  test "parses subsequent files comments" do
    evt = %{
      "event" => %{
        "channel" => "C3ABCD234",
        "comment" => %{
          "comment" => "you will be downvoted <@U87654321> --",
          "created" => 1_519_768_344,
          "id" => "Fc9F6P6B96",
          "is_intro" => false,
          "timestamp" => 1_519_768_344,
          "user" => "UABC012DE"
        },
        "file" => %{
          "initial_comment" => %{
            "comment" => "let's give <@U12345678> ++",
            "is_intro" => true,
            "user" => "U1234A5BC"
          }
        },
        "subtype" => "file_comment",
        "text" =>
          "<@U1234A5BC> uploaded a file: <https://something.slack.com/x.png|x> and commented: let's give <@U12345678> ++",
        "type" => "message",
        "user" => "U1234A5BC"
      },
      "team_id" => "T123ABCDE",
      "token" => "randomslacktoken",
      "type" => "event_callback"
    }

    assert {:ok, req} = parse_event(evt)

    assert req == %Karmel.Request{
             team_id: "T123ABCDE",
             user_id: "UABC012DE",
             channel_id: "C3ABCD234",
             is_direct: false,
             thread_id: nil,
             is_direct: false,
             text: "you will be downvoted <@U87654321> --"
           }
  end

  test "returns error for struct without event" do
    evt = %{"team_id" => "T123"}

    assert :error = parse_event(evt)
  end

  test "returns error for malformed event" do
    evt = %{"team_id" => "T123", "event" => %{"channel" => "C123", "type" => "message"}}

    assert :error = parse_event(evt)
  end
end
