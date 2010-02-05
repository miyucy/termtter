require 'yaml'

module Termtter::Client
  register_command('version', :alias => :v) do
    parent = File.join(File.dirname($0), '..')
    puts Termtter::VERSION && return unless FileTest.directory? File.join(parent, '.git')
    refs = YAML.load_file(File.join(parent, '.git', 'HEAD'))['ref']
    branch = refs[%r'refs/(.*)\Z',1]
    revision = File.read(File.join(parent, '.git', refs)).strip
    puts TermColor.parse "#{Termtter::VERSION}(<red>#{branch}</red>:<red>#{revision}</red>)"
  end
end
