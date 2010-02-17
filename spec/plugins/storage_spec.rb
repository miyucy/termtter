# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'
require 'term/ansicolor'
require 'pp'

describe Termtter::Client, " when the storage plugin is loaded" do
  before do
    setup_null_output
    Termtter::Client.plug "storage"
  end

  it "should define search_storage method" do
    Termtter::Client.command_exists?("search_storage").should be_true
    Termtter::Client.command_exists?("ss").should be_true
  end

  it "should match output of search_storage" do
    word = '#termtter'
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
    word = 'yukihiro_matz'
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
end
