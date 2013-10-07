class Array
  def self.toy n = 10
    Array.new(n) { |i| i }.shuffle
  end
end

class Hash
  def self.toy n = 5
    keys = ('a'..'z').to_a.take(n).shuffle
    values = Array.toy(n)
    Hash[keys.zip(values)]
  end
end
