# frozen_string_literal: true

module ApplicationHelper
  require 'json/ext'

  def format_string(string, *args)
    string.gsub(/\{(\d+)\}/) { args[::Regexp.last_match(1).to_i] }
  end

  def to_json(hash)
    hash.to_json
  end

  def example_available?(example)
    !(example['SkipForLanguages']) or !example['SkipForLanguages'].include? 'ruby'
  end
end
