RUBY_CHANNEL = head-wasm32-unknown-wasi-full
RUBY_SNAPSHOT = 2022-04-06-a
RUBY_ROOT = rubies/$(RUBY_CHANNEL)

all: static/repl.wasm

$(RUBY_ROOT):
	mkdir -p rubies
	cd rubies && curl -L https://github.com/ruby/ruby.wasm/releases/download/$(RUBY_SNAPSHOT)/ruby-$(RUBY_CHANNEL).tar.gz | tar xz
	mv $(RUBY_ROOT)/usr/local/bin/ruby $(RUBY_ROOT)/ruby.wasm

racc:
	cd bcdice && rake racc

static/repl.wasm: $(RUBY_ROOT) racc
	rm -rf $(RUBY_ROOT)/usr/local/include
	rm -f $(RUBY_ROOT)/usr/local/lib/libruby-static.a
	wasi-vfs pack $(RUBY_ROOT)/ruby.wasm --mapdir /usr::$(RUBY_ROOT)/usr --mapdir /gems::./fake-gems --mapdir /bcdice::./bcdice/lib --mapdir /i18n::./bcdice/i18n -o static/repl.wasm
