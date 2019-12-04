# Gets the next value abcdef where f >= e ... >= a
#
# Given this restriction, we can just increment the number by 1
# and then enforce the restriction by setting each digit to (at least)
# the value of the digit before it. This approach lets us easily skip
# all invalid numbers.
# 
# e.g. 2531 --> 2532
#   5 > 2, so we don't change it (2532)
#   3 < 5, so we set it to 5 (2552)
#   2 < 5, so we set it to 5 (2555)
def step(value)
  str = (value + 1).to_s
  (1...str.length).each do |i|
    str[i] = [str[i], str[i-1]].max
  end
  str.to_i
end

# Checks if the number has any repeating digits
def number_is_valid_1?(number)
  number.to_s =~ /(\d)\1/
end

# Checks if the number has any repeating digits that repeat exactly twice.
# We do this by calculating (number of double+ digits) - (number of triple+ digits),
# and if the number is non-zero, then it means that there's at least one set of
# double digits (that aren't also triple or greater)
def number_is_valid_2?(number)
  str = number.to_s
  str.scan(/(\d)\1+/).length - str.scan(/(\d)\1\1+/).length > 0
end

# Loops from the lower bound to the upper bound (inclusive), counting the number
# of numbers that satisfy the validator.
# 
# We use a counter so we don't need to store anything large in memory.
def run(lower, upper, validator)
  count = 0
  current_value = lower - 1

  # Each iteration, we skip to the next valid number in range and check whether
  # it satisfies the validator.
  while (current_value = step(current_value)) <= upper
    count += 1 if validator.call(current_value)
  end

  count
end

def part_1(lower, upper)
  run(lower, upper, method(:number_is_valid_1?))
end

def part_2(lower, upper)
  run(lower, upper, method(:number_is_valid_2?))
end

# 1605
puts part_1(193651, 649729)

# 1102
puts part_2(193651, 649729)