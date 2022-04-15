require "json"
require "yaml"

i18n = {}
Dir["bcdice/i18n/**/*.yml"].each do |path|
  i18n = i18n.merge(YAML.load_file(path)) do |_key, oldval, newval|
    oldval.merge(newval)
  end
end

File.write('fake-gems/i18n.json', JSON.dump(i18n))