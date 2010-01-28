# -*- coding: utf-8 -*-

require 'sqlite3'
require 'termtter/active_rubytter'

module Termtter::Storage
  class SQLite3

    def initialize(file = Termtter::CONF_DIR + '/storage.db')
      @db = ::SQLite3::Database.new(file)
      @db.type_translation = true
      create_table
    end

    def name
      "sqlite3"
    end

    CREATE_TABLE = <<-SQL
CREATE TABLE IF NOT EXISTS user (
    id          int NOT NULL,
    screen_name text,
    protected   int,
    PRIMARY KEY (id)
);
CREATE TABLE IF NOT EXISTS post (
    post_id               int NOT NULL,  -- twitter側のpostのid
    created_at            int,           -- 日付(RubyでUNIX時間に変換)
    in_reply_to_status_id int,           -- あったほうがよいらしい
    in_reply_to_user_id   int,           -- あったほうがよいらしい
    post_text             text,
    user_id               int NOT NULL,
    source                text,
    PRIMARY KEY (post_id)
);
    SQL
    def create_table
      @db.execute_batch(CREATE_TABLE)
    end

    def update(status)
      @db.transaction
      begin
        return nil if find_id(status[:post_id])
        insert(status)
      ensure
        @db.commit
      end
    end

    def update_user(user_id, screen_name, protectedp)
      return nil if find_user_id(user_id)
      @db.execute("INSERT OR REPLACE INTO user VALUES(?,?,?)",
                  user_id,
                  screen_name,
                  protectedp ? 1 : 0)
    end

    FIND_USER_ID = <<-EOS
 SELECT
  id,
  screen_name,
  protected
 FROM
  user
 WHERE
  id = ?
EOS
    def find_user_id(user_id)
      result = nil
      @db.execute(FIND_USER_ID, user_id) do |id, screen_name, protectedp|
        result = { :id => id, :screen_name => screen_name, :protected => (protectedp != 0) }
      end
      result
    end

    def insert(status)
      return nil unless status[:text]
      @db.execute("INSERT OR IGNORE INTO post VALUES(?,?,?,?,?,?,?)",
                  status[:post_id],
                  status[:created_at],
                  status[:in_reply_to_status_id],
                  status[:in_reply_to_user_id],
                  status[:text],
                  status[:user_id],
                  status[:source])
      update_user(status[:user_id], status[:screen_name], status[:protected])
    end

    FIND_ID = <<-EOS
 SELECT
  post_id, created_at, in_reply_to_status_id, post_text, user_id, source, screen_name, protected
 FROM
  post INNER JOIN user ON post.user_id = user.id
 WHERE
  post_id = ?
EOS
    def find_id(id)
      result = nil
      @db.execute(FIND_ID, id) do |post_id, created_at, in_reply_to_status_id, post_text, user_id, source, screen_name, protectedp|
        created_at = Time.at(created_at).to_s
        result = Termtter::ActiveRubytter.new({
                                                :id                    => post_id,
                                                :created_at            => created_at,
                                                :text                  => post_text,
                                                :in_reply_to_status_id => in_reply_to_status_id,
                                                :in_reply_to_user_id   => nil,
                                                :source                => source,
                                                :user                  => {
                                                  :id          => user_id,
                                                  :screen_name => screen_name,
                                                  :protected   => (protectedp != 0)
                                                },
                                              })
      end
      result
    end

    FIND = <<-EOS
 SELECT
  post_id, created_at, in_reply_to_status_id, post_text, user_id, source, screen_name, protected
 FROM
  post INNER JOIN user ON post.user_id = user.id
 WHERE
  post_text LIKE '%' || ? || '%'
EOS
    def find_text(text = '')
      result = []
      @db.execute(FIND, text) do |post_id, created_at, in_reply_to_status_id, post_text, user_id, source, screen_name, protectedp|
        created_at = Time.at(created_at).to_s
        result << Termtter::ActiveRubytter.new({
                                                :id                    => post_id,
                                                :created_at            => created_at,
                                                :text                  => post_text,
                                                :in_reply_to_status_id => in_reply_to_status_id,
                                                :in_reply_to_user_id   => nil,
                                                :source                => source,
                                                :user                  => {
                                                  :id          => user_id,
                                                  :screen_name => screen_name,
                                                  :protected   => (protectedp != 0)
                                                },
                                               })
      end
      result
    end

    FIND_USER = <<-EOS
 SELECT
  post_id, created_at, in_reply_to_status_id, post_text, user_id, source, screen_name, protected
 FROM
  post INNER JOIN user ON post.user_id = user.id
 WHERE
EOS
    def find_user(user = "")
      result = []
      sql = FIND_USER + ' ' + user.split(' ').map!{|que| que.gsub(/(\w+)/, 'screen_name LIKE \'%\1%\'')}.join(' OR ')
      @db.execute(sql) do |post_id, created_at, in_reply_to_status_id, post_text, user_id, source, screen_name, protectedp|
        created_at = Time.at(created_at).to_s
        result << Termtter::ActiveRubytter.new({
                                                :id                    => post_id,
                                                :created_at            => created_at,
                                                :text                  => post_text,
                                                :in_reply_to_status_id => in_reply_to_status_id,
                                                :in_reply_to_user_id   => nil,
                                                :source                => source,
                                                :user                  => {
                                                  :id          => user_id,
                                                  :screen_name => screen_name,
                                                  :protected   => (protectedp != 0)
                                                },
                                               })
      end
      result
    end

    def size
      @db.get_first_value("SELECT count(*) FROM post").to_i
    end
  end
end
