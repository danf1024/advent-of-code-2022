sums = File.read(ARGV.first).split("\n\n").map(&:split).map { |arr| arr.map(&:to_i).sum }

# part 1
puts sums.max

# part 2
puts sums.sort.reverse.first(3).sum
