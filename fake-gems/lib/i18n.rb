# BSD 3-Clause License
# Copyright (c) 2019, ukatama All rights reserved.
# https://github.com/bcdice/bcdice-js

require "json"

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

      source = File.read("/gems/i18n.json")
      table = JSON.parse(source)
      @@table = trans(table)
    end

    def trans(hash)
      return hash unless hash.is_a?(Hash)

      hash = hash.transform_keys do |k|
        Integer(k, 10, exception: false) || k.to_sym
      end

      hash = hash.transform_values do |v|
        trans(v)
      end

      return hash
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
