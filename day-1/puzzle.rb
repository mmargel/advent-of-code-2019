require_relative 'input'

def calculate_fuel_needed(mass)
  mass / 3 - 2
end

def calculate_fuel_recursively(mass)
  fuel_needed = calculate_fuel_needed(mass)
  if fuel_needed <= 0
    return 0
  else
    return fuel_needed + calculate_fuel_recursively(fuel_needed)
  end
end

def puzzle_1
  input
    .map { |mass| calculate_fuel_needed(mass) }
    .reduce(:+)
end

def puzzle_2
  input
    .map { |mass| calculate_fuel_recursively(mass) }
    .reduce(:+)
end


# 3291356
# puts puzzle_1

# 4934153
# puts puzzle_2