# Custom scan that returns a boolean indicating whether the regex matched.
# TODO: Is there a way to avoid doing this?
class String
  def my_scan(re)
    hit = false
    scan(re) { |arr|
      yield arr if block_given?
      hit = true
    }
    hit
  end
end
