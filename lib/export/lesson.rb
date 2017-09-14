require 'export'

require 'env_relative_path'

module Export
  module Lesson
    FOLDER = Rails.root.join 'app', 'exports', 'lessons'
  end
end
