# Adding desired methods not available in Ruby 2.3
#
module StringRefinements
  refine String do
    def match?(pattern)
      !match(pattern).nil?
    end
  end
end

