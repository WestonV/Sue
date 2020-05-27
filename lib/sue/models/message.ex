defmodule Sue.Models.Message do
  alias __MODULE__
  alias Sue.Models.{Account, Buddy, Chat}

  @type t() :: %__MODULE__{}
  defstruct [
    :platform,
    :id,
    :buddy,
    :body,
    :time,
    :chat,
    :account,
    :from_me,
    :ignorable,
    :attachments,
    :has_attachments,
    :command,
    :args
  ]

  def new(kw, :imessage) do
    [
      id: handle_id,
      person_centric_id: handle_person_centric_id,
      cache_has_attachments: has_attachments,
      text: body,
      ROWID: message_id,
      cache_roomnames: chat_id,
      is_from_me: from_me,
      utc_date: utc_date
    ] = kw

    from_me = from_me == 1

    %Message{
      platform: :imessage,
      id: message_id,
      buddy: %Buddy{id: handle_id, guid: handle_person_centric_id},
      body: body,
      time: DateTime.from_unix!(utc_date),
      chat: %Chat{
        platform: :imessage,
        id: chat_id || "direct;#{handle_id}",
        is_direct: chat_id == nil
      },
      from_me: from_me,
      ignorable: is_ignorable?(from_me, body),
      has_attachments: has_attachments == 1
    }
    |> augment_one()
  end

  defp augment_one(%Message{ignorable: true} = msg), do: msg

  defp augment_one(msg) do
    "!" <> newbody = msg.body |> String.trim()
    [command | args] = String.split(newbody, " ", parts: 2)

    %Message{
      msg
      | body: newbody,
        command: command |> String.downcase(),
        args: if(args == [], do: "", else: args |> hd())
    }
  end

  @spec augment_two(Sue.Models.Message.t()) :: Sue.Models.Message.t()
  def augment_two(msg) do
    account = Account.resolve_and_relate(msg)
    %Message{msg | account: account}
  end

  # This binary classifier will grow in complexity over time.
  defp is_ignorable?(true, _body), do: true

  defp is_ignorable?(_from_me, nil), do: true

  defp is_ignorable?(_from_me, body) do
    not Regex.match?(~r/^!(?! )./u, body |> String.trim_leading())
  end

  # to_string override
  defimpl String.Chars, for: Message do
    def to_string(%Message{platform: protocol, buddy: %Buddy{id: bid}, chat: %Chat{id: cid}}) do
      "#Message<#{protocol},#{bid},#{cid}>"
    end
  end
end
