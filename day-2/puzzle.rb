require_relative 'input'

def preprocess_1(data) 
  # Instructions from the problem
  data[1] = 12
  data[2] = 2
  data
end

def puzzle_1
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

def preprocess_2(data) 
  data[1] = {A: 1, B: 0, C: 0 }
  data[2] = {A: 0, B: 1, C: 0 }
  data
end

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

def puzzle_2
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
# puts puzzle_1

# 480_000*A + B + 1450628 = 19690720
# 480_000*A + B = 18240092
# 480_000*A + B = 480_000*38 + 92
# A = 38
# B = 92
# {:A=>480000, :B=>1, :C=>1450628}
puts puzzle_2