require_relative 'input'

def preprocess_1(data) 
  # Instructions from the problem
  data[1] = 12
  data[2] = 2
  data
end

def part_1
  tape = preprocess_1(input).dup
  tape
    .each_slice(4)
    .reduce(tape) do |acc, step|
      case step[0]
      when 1
        acc[step[3]] = acc[step[1]] + acc[step[2]]
      when 2
        acc[step[3]] = acc[step[1]] * acc[step[2]]
      when 99
        break acc
      else
        break acc
      end
      acc
    end
  tape[0]
end

# Setup for part 2. We need to calculate A dn B, so we set the 
# values of data[1] and data[2] to those algebraic constructs.
def preprocess_2(data) 
  data[1] = {A: 1, B: 0, C: 0 }
  data[2] = {A: 0, B: 1, C: 0 }
  data
end

# Wherever possible, we want to return an integer instead of an
# algebraic construct. This makes it easier to manipulate later.
def try_make_int(input)
  return input if input.is_a?(Integer)
  return input[:A] == 0 && input[:B] == 0 ? input[:C] : input
end

def add(a, b)
  a = {A: 0, B: 0, C: a} if a.is_a?(Integer)
  b = {A: 0, B: 0, C: b} if b.is_a?(Integer)
  
  try_make_int({
    A: (a[:A] || 0) + (b[:A] || 0),
    B: (a[:B] || 0) + (b[:B] || 0),
    C: (a[:C] || 0) + (b[:C] || 0),
  })
end

# A basic multiplier. This implicitly assumes that the final
# equation will be linear. If it's quadratic, this will fail.
def multiply(s, a)
  if a.is_a?(Integer) && s.is_a?(Integer)
    s * a
  elsif a.is_a? Integer
    multiply(a, s)
  else
    try_make_int({
      A: (a[:A] || 0) * s,
      B: (a[:B] || 0) * s,
      C: (a[:C] || 0) * s
    })
  end
end

def part_2
  tape = preprocess_2(input).dup
  tape
    .each_slice(4)
    .reduce(tape) do |acc, step|
      # The next step should _never_ contain a hash
      # This would only happen on the first step, and we can 
      # skip it anyways
      next acc if step[1].is_a?(Hash) || step[2].is_a?(Hash)

      case step[0]
      when 1
        acc[step[3]] = add(acc[step[1]], acc[step[2]])
      when 2
        acc[step[3]] = multiply(acc[step[1]], acc[step[2]])
      when 99
        break acc
      else
        break acc
      end
      acc
    end
  tape[0]
end

# 7210630
puts part_1

# 480_000*A + B + 1450628 = 19690720
# 480_000*A + B = 18240092
# 480_000*A + B = 480_000*38 + 92
# A = 38
# B = 92
# {:A=>480000, :B=>1, :C=>1450628}
puts part_2
puts({noun: (19_690_720 - 1_450_628) / 480_000, verb: (19_690_720 - 1_450_628) % 480_000})