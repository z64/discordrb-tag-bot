require "sqlite3"

class Tag
  DB = SQLite3::Database.new("tags.db")

  def self.init_db
    DB.execute(<<~SQL)
      CREATE TABLE IF NOT EXISTS tags(
        name      TEXT    NOT NULL,
        server_id INTEGER NOT NULL,
        content   TEXT    NOT NULL,
        owner_id  INTEGER NOT NULL,
        PRIMARY KEY (name, server_id),
        UNIQUE (name, server_id)
      )
    SQL
  end

  def self.create(name, server, content, owner)
    server_id = server.resolve_id
    owner_id = owner.resolve_id

    DB.execute(<<~SQL, name, server_id, content, owner_id)
      INSERT INTO tags
      VALUES (?, ?, ?, ?)
    SQL

    Tag.new(name, server_id, content, owner_id)
  end

  def self.find(name, server)
    server_id = server.resolve_id

    result = DB.execute(<<~SQL, name, server_id).first
      SELECT name, server_id, content, owner_id
        FROM tags
       WHERE name      = ?
         AND server_id = ?
    SQL

    Tag.new(*result) if result
  end

  def self.delete(name, server)
    server_id = server.resolve_id

    DB.execute(<<~SQL, name, server_id)
      DELETE FROM tags
       WHERE name      = ?
         AND server_id = ?
    SQL
  end

  def self.modify(name, server, content, owner)
    server_id = server.resolve_id
    owner_id = owner.resolve_id

    DB.execute(<<~SQL, content, owner_id, name, server_id)
      UPDATE tags
         SET content   = ?,
             owner_id  = ?
       WHERE name      = ?
         AND server_id = ?
    SQL
  end

  attr_reader :name, :server_id, :content, :owner_id

  def initialize(name, server_id, content, owner_id)
    @name = name
    @server_id = server_id
    @content = content
    @owner_id = owner_id
  end

  def delete
    Tag.delete(name, server_id)
  end

  def edit(new_content)
    Tag.modify(name, server_id, new_content, owner_id)
    @content = new_content
  end
end
