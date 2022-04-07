# MIT License
# Copyright (c) 2022 Yuta Saito
# https://github.com/kateinoigakukun/irb.wasm

module Reline
  HISTORY = []

  def self.readline(header)
    print header
    STDIN.gets
  end

  def self.get_screen_size
    raise Errno::EINVAL
  end

  class Unicode
    def self.calculate_width(str, allow_escape_code = false)
      1
    end
  end
end
