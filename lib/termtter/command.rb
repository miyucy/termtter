module Termtter
  class Command
    attr_accessor :name, :aliases, :exec_proc, :completion_proc, :help, :pattern

    # args
    #   name:            Symbol as command name
    #   aliases:         Array of command alias (ex. ['u', 'up'])
    #   exec_proc:       Proc for procedure of the command. If need the proc must return object for hook.
    #   completion_proc: Proc for input completion. The proc must return Array of candidates (Optional)
    #   help:            help text for the command (Optional)
    def initialize(args)
      raise ArgumentError, ":name is not given." unless args.has_key?(:name)
      @name = args[:name].to_sym
      @aliases = args[:aliases] || []
      @exec_proc = args[:exec_proc] || proc {|arg|}
      @completion_proc = args[:completion_proc]
      @help = args[:help]
    end

    def complement(input)
      command_info = match?(input)
      if command_info
        [completion_proc.call(command_info[0], command_info[1])].flatten.compact
      else
        [name.to_s]
      end
    end

    # MEMO: Termtter:Client からはこのメソッドを呼び出すことになると思う。
    def exec_if_match(input)
      command_info = match?(input)
      if command_info
        return exec_proc.call(command_info[1])
      else
        return nil
      end
    end

    # return array like [command, arg]
    def match?(input)
      if pattern =~ input
        [$2 || $3, $4]  # $2 or $3 => command, $4 => argument
      else
        nil
      end
    end

    def pattern
      commands_regex = commands.map {|i| Regexp.quote(i) }.join('|')
      /^\s*((#{commands_regex})|(#{commands_regex})\s+(.*?))\s*$/
    end

    def commands
      aliases.unshift(name.to_s)
    end
  end
end
