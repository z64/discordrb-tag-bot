# frozen_string_literal: true

ENV["TAGBOT_ENV"] = "test"

require "./src/bot"
require "rspec"

module Discordrb::EventContainer
  attr_reader :event_handlers
end

module Helper
  def dispatch(klass, event)
    allow(event).to receive(:"is_a?").with(klass).and_return(true)
    TagBot.event_handlers[klass].each do |handler|
      handler.match(event)
    end
  end

  def message_event(content:, author_id:, server_id:)
    double("event",
           content: content,
           channel: double("channel", "private?": false),
           server: double("server", id: server_id, resolve_id: server_id),
           author: double("author", id: author_id, resolve_id: author_id),
           timestamp: double("timestamp"))
  end
end

RSpec.configure do |config|
  config.expose_dsl_globally = false
  config.include(Helper)
  config.order = :defined
end
