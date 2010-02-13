require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../../../lib/plugins/storage/sqlite3'

module Termtter::Storage
  describe "sqlite3" do
    DB_FILE = ':memory:'
    before(:each) do
      @db = Termtter::Storage::SQLite3.new(DB_FILE)
      @status = {
        :post_id => 1,
        :created_at => 12345,
        :in_reply_to_status_id => -1,
        :in_reply_to_user_id => -1,
        :text => 'bomb',
        :user_id => 1,
        :screen_name => 'termtter',
      }
    end

    it 'update should not return false' do
      @db.update(@status).should_not be_false
    end

    it 'find_id returns status' do
      @db.update(@status)
      @db.find_id(@status[:post_id])[:id].should == @status[:post_id]
    end

    it 'find_text returns status' do
      @db.update(@status)
      @db.find_text('om').map{ |e| e[:text].should match(/om/) }
    end

    it 'find_user returns status' do
      @db.update(@status)
      @db.find_user('rmt').map{ |e| e[:user][:screen_name].should match(/rmt/) }
    end

    it 'size of statuses' do
      lambda{ @db.update(@status) }.should change(@db, :size).by(1)
    end
  end
end
