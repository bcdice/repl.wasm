# BSD 3-Clause License
# Copyright (c) 2019, ukatama All rights reserved.
# https://github.com/bcdice/bcdice-js

require 'yaml'

# Simple emulator
module I18n
  class << self
    @@load_path = []
    @@table = nil
    def load_path
      @@load_path
    end

    def default_locale=(locale)
      @@default_locale = locale
    end

    def fallbacks
      I18n::Locale::Fallbacks.new
    end

    def load_translations
      return unless @@table.nil?

      table = {}
      @@load_path.flatten.each do |path|
        deep_merge!(table, YAML.load_file(path))
      end

      @@table = table
    end

    def translate(key, locale: nil, **options)
      load_translations

      path = key.split('.').map(&:to_sym)
      table = @@table
      default_locale = @@default_locale

      result = table.dig(locale, *path) || table.dig(default_locale, *path)
      begin
        result = format(result, **options) if result.is_a?(String)
      rescue ArgumentError, KeyError
        # Ignore
      end

      result || options[:default]
    end
    alias t translate

    private

    def deep_merge(hash, other_hash, &block)
      deep_merge!(hash.dup, other_hash, &block)
    end

    def deep_merge!(hash, other_hash, &block)
      hash.merge!(other_hash) do |key, this_val, other_val|
        if this_val.is_a?(Hash) && other_val.is_a?(Hash)
          deep_merge(this_val, other_val, &block)
        elsif block_given?
          yield key, this_val, other_val
        else
          other_val
        end
      end
    end
  end

  module Locale
    # Stub
    class Fallbacks < Hash
      def defaults=(value); end
    end
  end

  module Backend
    module Simple; end
    module Fallbacks; end
  end

  # Stub
  module Thread
    class << self
      def current
        {
          i18n_fallbacks: nil
        }
      end
    end
  end
end
