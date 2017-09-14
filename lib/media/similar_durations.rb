require 'media'

module Media

  # Provides logic for comparing durations considering <tt>self.class::DURATION_THRESHOLD</tt>
  module SimilarDurations

    private
    # Compare two duration values, returning +true+ if their difference is lower than the +DURATION_THRESHOLD+ class constant, +false+ otherwise
    def similar_durations?(duration, other_duration)
      ((duration-self.class::DURATION_THRESHOLD)..(duration+self.class::DURATION_THRESHOLD)).include? other_duration
    end

  end
end