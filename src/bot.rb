require "discordrb"
require "./src/tags"

Tag.init_db
TagBot = Discordrb::Bot.new(token: ENV["TOKEN"] || "")
bot = TagBot

bot.message(content: "!ping") do |event|
  event.respond("Pong!")
end

bot.message(start_with: "!tag") do |event|
  _tag, name = event.content.split(" ", 3)
  next if %(create delete edit).include?(name)
  tag = Tag.find(name, event.server)
  event.respond(tag.content)
end

bot.message(start_with: "!tag create") do |event|
  _tag, _command, name, content = event.content.split(" ", 4)
  Tag.create(name, event.server, content, event.author)
  event.respond("Created tag `#{name}`")
end

bot.message(start_with: "!tag delete") do |event|
  _tag, _command, name = event.content.split(" ", 3)
  Tag.delete(name, event.server)
  event.respond("Deleted tag `#{name}`")
end

bot.message(start_with: "!tag edit") do |event|
  _tag, _command, name, content = event.content.split(" ", 4)
  tag = Tag.find(name, event.server)
  tag.edit(content)
  event.respond("Updated tag `#{name}`")
end

bot.run unless ENV["TAGBOT_ENV"] == "test"
