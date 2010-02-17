# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'
require 'term/ansicolor'
require 'pp'

describe Termtter::Client, " when the storage plugin is loaded" do
  before do
    setup_null_output
    Termtter::Client.plug "storage"
    setup_storage
  end

  it "should define search_storage method" do
    Termtter::Client.command_exists?("search_storage").should be_true
    Termtter::Client.command_exists?("ss").should be_true
  end

  it "should match output of search_storage" do
    word = @status_1[:text].split.first
    Term::ANSIColor.uncolored{
      be_quiet{
        Termtter::Client.find_command("search_storage").call(nil, word)
      }[:stdout]
    }.should match /#{word}/
  end

  it "should define search_storage_user method" do
    Termtter::Client.command_exists?("search_storage_user").should be_true
    Termtter::Client.command_exists?("ssu").should be_true
  end

  it "should match output of search_storage_user" do
    word = @user_1[:screen_name]
    Term::ANSIColor.uncolored{
      be_quiet{
        Termtter::Client.find_command("search_storage_user").call(nil, word)
      }[:stdout]
    }.should match /#{word}/
  end

  it "should register storage hook" do
    Termtter::Client.get_hook(:storage).should_not be_nil
  end

  def setup_null_output
    Termtter::Client.plug "defaults/stdout"
    config.plugins.stdout.show_reply_chain = false
    config.plugins.stdout.colors = [:none]
    Termtter::Client.clear_hooks
    Termtter.module_eval %Q{
      class Termtter::NullOut < Termtter::StdOut
        def colorize_users(text) text end
      end
    }
    Termtter::Client.register_hook(Termtter::NullOut.new)
  end

  def setup_storage
    config.plugins.storage.path = ":memory:"

    @user_1 = { :id => 1, :screen_name => 'home' }
    @user_2 = { :id => 2, :screen_name => 'logout' }
    @status_1 = {
      :id => 1,
      :created_at => Time.now.to_s,
      :text => 'need more test #termtter',
      :in_reply_to_status_id => nil,
      :in_reply_to_user_id => nil,
      :user => @user_1
    }
    @status_2 = {
      :id => 1,
      :created_at => Time.now.to_s,
      :text => 'no more test #termtter',
      :in_reply_to_status_id => nil,
      :in_reply_to_user_id => nil,
      :user => @user_2
    }

    Termtter::Client.get_hook(:storage).call([Termtter::ActiveRubytter.new(@status_1),
                                              Termtter::ActiveRubytter.new(@status_2)],
                                             :dummy_event)
  end
end
