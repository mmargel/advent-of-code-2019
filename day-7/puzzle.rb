require_relative 'input'

class Computer
  def initialize(tape)
    @tape = tape.dup
    @pc = 0
  end

  def has_run?
    @has_run ||= false
  end

  # This is a clean way of storing information about our various commands.
  def commands
    @@commands ||= {
      1 => {:word => :add, :inc => 4},
      2 => {:word => :mult, :inc => 4},
      3 => {:word => :in, :inc => 2},
      4 => {:word => :out, :inc => 2},
      5 => {:word => :jnz, :inc => 0},
      6 => {:word => :jz, :inc => 0},
      7 => {:word => :lt, :inc => 4},
      8 => {:word => :eq, :inc => 4},
      99 => {:word => :halt},
    }.freeze
  end

  def t(index, mode)
    mode == 0 ? @tape[index] : index
  end
  
  # We take an arugment to mock the input, so we don't need to manually enter it.
  def run(mock_input_tape = [])
    @mock_input_tape = mock_input_tape
    @mock_input_index = 0
    @has_run = true
    
    # We'll keep looping until we reach a halt. Based on the problem,
    # all well-formed programs will have an explicit halt command.
    while true
      # Gets the instruction, opcode, mode, and keyword for the current step.
      instruction = @tape[@pc]
      opcode, mode = [instruction % 100, instruction / 100]
      command = commands[opcode]

      # Quick check to see if we hit an error.
      # We could do this below, but I'd rather make this check explicit here.
      unless command
        puts "ERROR at #{@pc}: #{opcode}"
        return {halted: true}
      end

      # Shorthand for the arguments and reference flags.
      # I'm okay with this approach, since we have 3 or fewer for all instructions.
      # 
      # Since we always have (at most) 2 inputs and the output is never by
      # reference, we can use r0 and r1 for the flags.
      a0, a1, a2 = [@tape[@pc+1], @tape[@pc+2], @tape[@pc+3]]
      r0, r1 = [mode & 1, mode & 2]
      
      # Each command maps to a symbol (listed above).
      # For each command, we use our custom tape[] method, which lets us
      # easily specify whether it's by reference or by value.
      # 
      # To make by-reference checks easier, we use bit masks to check the mode.
      #   e.g. if input 2 is by reference, it would by X1X which maps to N!=0
      #   since X1X & 010 (2) == 010 != 0
      case command[:word]
        when :add then @tape[a2] = t(a0, r0) + t(a1, r1)
        when :mult then @tape[a2] = t(a0, r0) * t(a1, r1)
        when :in then @tape[a0] = get_next_mock_input || (puts "INPUT: "; gets.chomp.to_i)
        when :out 
          # We need to increment this here since we return below
          @pc += command[:inc]
          return {value: t(a0, r0)}
        when :jnz then @pc = (t(a0, r0) != 0) ? t(a1, r1) : (@pc + 3)
        when :jz then @pc = (t(a0, r0) == 0) ? t(a1, r1) : (@pc + 3)
        when :lt then @tape[a2] = (t(a0, r0) < t(a1, r1)) ? 1 : 0
        when :eq then @tape[a2] = (t(a0, r0) == t(a1, r1)) ? 1 : 0
        when :halt then return {halted: true}
      end
      @pc += command[:inc]
    end
  end

  def get_next_mock_input
    @mock_input_index += 1
    @mock_input_tape[@mock_input_index-1]
  end

end

def run_and_carry(code, num_iterations, phase_settings, initial_value)
  halted = false
  computer_number = 0
  iteration_count = 0
  output = initial_value
  first_run = true

  # This lets each machine have its own state.
  computers = Array.new(phase_settings.length).map { |_| Computer.new(code) }

  # TODO: Replace with (0..iteration_count).each for cleaner code
  while (iteration_count += 1) <= num_iterations && !halted
    puts "computer_number: #{computer_number}"
    computer = computers[computer_number]
    inputs = computer.has_run? ? [output] : [phase_settings[computer_number], output]
    puts "inputs: #{inputs}"
    result = computer.run(inputs)

    output = result[:value] if result[:value]
    halted = result[:halted]

    puts "result: #{result}"
    # gets

    if (output.nil? || halted)
      puts "HALTED: result: #{output}"
      # gets
    end

    # Move to the next iteration
    computer_number = (computer_number + 1) % computers.length
  end
  output
end

def part_1
  [0,1,2,3,4].permutation.reduce(0) do |acc, permutation|
    output = run_and_carry(input, permutation.length, permutation, 0)
    [acc, output].max
  end
end

def part_2
  [5,6,7,8,9].permutation.reduce(0) do |acc, permutation|
    output = run_and_carry(input, Float::INFINITY, permutation, 0)
    [acc, output].max
  end
end


# 21760
puts part_1

# 69816958
puts part_2