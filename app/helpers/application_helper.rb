# frozen_string_literal: true

module ApplicationHelper
  def format_string(string, *args)
    string.gsub(/\{(\d+)\}/) { |s| args[s.to_i] }
  end
end
