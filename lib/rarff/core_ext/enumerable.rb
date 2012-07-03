module Enumerable
# This map_with_index hack allows access to the index of each item as the map
# iterates.
# TODO: Is there a better way?
  def map_with_index
    # Ugly, but I need the yield to be the last statement in the map.
    i = -1
    return map { |item|
      i += 1
      yield item, i
    }
  end
end
