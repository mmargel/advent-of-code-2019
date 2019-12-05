require_relative 'input'

class Tape
  def initialize(values)
    @values = values.dup
  end

  # mode 0: position
  # mode 1: immediate
  def get(index, mode)
    mode = mode.to_i if mode.is_a?(String)
    (mode == 0) ? @values[index] : index
  end

  def put(index, value)
    @values[index] = value
  end

  def[](index)
    @values[index]
  end
end

def part_1
  tape = Tape.new(input)
  pc = 0
  while true
    instruction = tape[pc]
    opcode = instruction % 100
    mode = sprintf('%03d', instruction / 100)
    # puts "Step ##{pc}: #{mode} (#{opcode})"
    case opcode
    when 1
      # [instr, A, B, A + B]
      in_1 = tape.get(tape[pc+1], mode[2])
      in_2 = tape.get(tape[pc+2], mode[1])
      out =  in_1 + in_2
      tape.put(tape[pc+3], out)
      pc += 4
    when 2
      # [instr, A, B, A * B]
      in_1 = tape.get(tape[pc+1], mode[2])
      in_2 = tape.get(tape[pc+2], mode[1])
      out = in_1 * in_2
      tape.put(tape[pc+3], out)
      pc += 4
    when 3
      # [instr, A]
      puts "Waiting for input: "
      input = gets.chomp.to_i
      tape.put(tape[pc+1], input)
      pc += 2
    when 4
      # [instr, A]]
      puts "OUTPUT: #{tape.get(tape[pc+1], mode[2])}"
      pc += 2
    when 99
      puts "HALT"
      return
    else
      puts "ERROR at #{pc}: #{opcode}"
      return
    end
  end
end

# 7566643
puts part_1