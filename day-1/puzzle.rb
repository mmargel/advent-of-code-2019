require_relative 'input'

# Calculates the amount of fuel needed for a single component.
# This amount is (mass / 3).floor - 2, but we can omit the
# .floor, since we're using integer math.
def calculate_fuel_needed(mass)
  mass / 3 - 2
end

# Calculates the fuel needs of a component, including the fuel
# needs of the fuel needs, recursively. We use tail recursion here.
#
# This is basically a budget reduce function.
def calculate_fuel_recursively(mass, total_cost = 0)
  fuel_needed = calculate_fuel_needed(mass)
  if fuel_needed <= 0
    # Base case, no extra fuel is needed, so return the total cost
    return total_cost
  else
    # Recursive case, we need extra fuel, so figure out how much
    # fuel we need for _that_ fuel.
    return calculate_fuel_recursively(fuel_needed, total_cost + fuel_needed)
  end
end

# Calculates the total fuel cost, given some fuel calculator function.
def run(calculator)
  input
    .map { |mass| calculator.call(mass) }
    .reduce(:+)
end

def part_1
  run(method(:calculate_fuel_needed))
end

def part_2
  run(method(:calculate_fuel_recursively))
end

# 3291356
puts part_1

# 4934153
puts part_2