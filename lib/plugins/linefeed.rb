# -*- coding: utf-8 -*-
config.plugins.linefeed.set_default(:width, 50)
config.plugins.linefeed.set_default(:right, 10)

Termtter::Client.register_hook(
  :name => :linefeed,
  :point => :filter_for_output,
  :exec => lambda {|statuses, event|
    width = config.plugins.linefeed.width
    right = config.plugins.linefeed.right
    statuses.each do |s|
      t = s.text
      ocs = []
      sz = nil
      t.gsub!(%r{(https?://)}, "\n\\1")
      t.split("\n").each do |line|
        cs = line.unpack 'U*'
        while cs.size > 0
          sz = 0
          l = cs.take_while do |c|
            sz2 = c < 0x100 ? 1 : 2
            sz += sz2
            sz < width || (sz2 == 1 && c != 32)
          end
          ocs += l
          cs = cs.drop(l.size)
          cs = cs.drop(1) if cs[0] == 32
          ocs += [0x0a]
        end
      end
      t2 = ocs.pack('U*')
      t2.chop! if sz < (width - right)
      s.text[0, t.size] = t2
    end
  }
)
