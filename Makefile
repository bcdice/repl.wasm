RUBY_CHANNEL = head-wasm32-unknown-wasi-full
RUBY_SNAPSHOT = ruby-head-wasm-wasi-0.3.0
RUBY_ROOT = rubies/$(RUBY_CHANNEL)

all: static/repl.wasm

$(RUBY_ROOT):
	mkdir -p rubies
	cd rubies && curl -L https://github.com/ruby/ruby.wasm/releases/download/$(RUBY_SNAPSHOT)/ruby-$(RUBY_CHANNEL).tar.gz | tar xz
	mv $(RUBY_ROOT)/usr/local/bin/ruby $(RUBY_ROOT)/ruby.wasm

racc:
	cd bcdice && bundle exec rake racc

i18n/i18n.json:
	mkdir -p i18n
	ruby script/build_i18n.rb

static/repl.wasm: $(RUBY_ROOT) racc i18n/i18n.json
	rm -rf $(RUBY_ROOT)/usr/local/include
	rm -f $(RUBY_ROOT)/usr/local/lib/libruby-static.a
	wasi-vfs pack $(RUBY_ROOT)/ruby.wasm --mapdir /usr::$(RUBY_ROOT)/usr --mapdir /gems::./fake-gems --mapdir /usr/local/lib/ruby/site_ruby::./bcdice/lib -o static/repl.wasm
