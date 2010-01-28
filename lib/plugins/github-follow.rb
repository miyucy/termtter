require 'octopi'
require 'pp'

class OctopiBox
  include Octopi

  def has_repos?(args)
    authenticated do
      tw_users(args).each do |tw_user|
        gh_users = User.find_all(tw_user)
        puts "seach by #{tw_user}, found #{gh_users.size} user(s)"
        gh_users.each do |gh_user|
          pp gh_user
        end
      end
    end
  end

  def follow(args)
    authenticated do
      tw_users(args).each do |tw_user|
        Api.me.follow! tw_user
      end
    end
  end

  private

  def tw_users(args)
    args.split(/ /).map do |arg|
      arg.strip.sub(/^@/, '')
    end
  end
end

module Termtter::Client
  @octopi = OctopiBox.new
  register_command(:has_repos) do |args|
    @octopi.has_repos?(args)
  end

  register_command(:github_follow) do |args|
    @octopi.follow(args)
  end
end
