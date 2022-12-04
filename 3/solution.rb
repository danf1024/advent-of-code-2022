require 'set'

priorities = Enumerator::Chain.new(('a'..'z'), ('A'..'Z')).zip((1..52)).to_h

lines = File.read(ARGV.first).split("\n")

# part 1
total = lines.sum do |ln|
  (ln[...ln.length/2].chars.to_set & ln[ln.length/2...].chars.to_set).sum { |x| priorities[x] }
end
puts total

# part 2
total = lines.each_slice(3).to_a.sum do |a, b, c|
  (a.chars.to_set & b.chars.to_set & c.chars.to_set).sum { |x| priorities[x] }
end
puts total
