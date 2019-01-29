require "spec_helper"

RSpec.describe "TagBot" do
  after do
    # Clear the DB of any tags we made after running a test
    Tag::DB.execute("DELETE FROM tags")
  end

  it "is a Discordrb::Bot" do
    expect(TagBot).to be_a Discordrb::Bot
  end

  it "responds to !ping with Pong!" do
    event = message_event(content: "!ping", author_id: 1, server_id: 2)
    expect(event).to receive(:respond).with "Pong!"
    dispatch(Discordrb::Events::MessageEvent, event)
  end

  it "creates a tag" do
    event = message_event(content: "!tag create foo bar", author_id: 1, server_id: 2)
    expect(event).to receive(:respond).with "Created tag `foo`"
    dispatch(Discordrb::Events::MessageEvent, event)

    tag = Tag.find("foo", 2)
    expect(tag.name).to eq "foo"
    expect(tag.content).to eq "bar"
    expect(tag.owner_id).to eq 1
    expect(tag.server_id).to eq 2
  end

  it "deletes a tag" do
    Tag.create("foo", 2, "bar", 1)
    event = message_event(content: "!tag delete foo", author_id: 1, server_id: 2)
    expect(event).to receive(:respond).with "Deleted tag `foo`"
    dispatch(Discordrb::Events::MessageEvent, event)

    tag = Tag.find("foo", 2)
    expect(tag).to eq nil
  end

  it "recalls a tag" do
    Tag.create("foo", 2, "bar", 1)
    event = message_event(content: "!tag foo", author_id: 1, server_id: 2)
    expect(event).to receive(:respond).with "bar"
    dispatch(Discordrb::Events::MessageEvent, event)
  end

  it "modifies a tag" do
    Tag.create("foo", 2, "bar", 1)
    event = message_event(content: "!tag edit foo edited content", author_id: 1, server_id: 2)
    expect(event).to receive(:respond).with "Updated tag `foo`"
    dispatch(Discordrb::Events::MessageEvent, event)

    tag = Tag.find("foo", 2)
    expect(tag.content).to eq "edited content"
  end
end
