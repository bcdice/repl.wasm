# MIT License
# Copyright (c) 2022 Yuta Saito
# https://github.com/kateinoigakukun/irb.wasm

class IO
  def winsize
    [24, 80]
  end

  def wait_readable(timeout = nil)
    false
  end
end
