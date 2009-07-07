module Merb
  module AssetsHelper
    def title(t)
      title = t.dup # can't modify frozen string
      title[0..0] = title[0..0].upcase
      title
    end

    def category_cloud(categories, classes)
      cat_hash = {}
      categories.each do |cat|
        cat_hash[cat] ||= 0
        cat_hash[cat] += 1
      end

      max, min = 0, 0
      cat_hash.each do |cat, size|
        max = size if size > max
        min = size if size < min
      end

      divisor = ((max - min) / classes.size) + 1

      cat_hash.sort.each do |category, size|
        yield category, classes[(size - min) / divisor]
      end
    end
  end
end # Merb
