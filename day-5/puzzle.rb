require_relative 'input'

# We extend Array because we want to use most of that functionality.
class Tape < Array
  # This is the tidiest way to fetch a value by mode or
  # by reference. Here, 0 --> reference, since that's our "default"
  # (sort of, but it makes the code cleaner if we treat it like it is).
  def[](index, call_by_reference = 0)
    call_by_reference == 0 ? super(index) : index
  end
end

# This is a clean way of storing information about our various commands.
def commands
  @commands = {
    1 => {:word => :add, :inc => 4},
    2 => {:word => :mult, :inc => 4},
    3 => {:word => :in, :inc => 2},
    4 => {:word => :out, :inc => 2},
    5 => {:word => :jnz, :inc => 0},
    6 => {:word => :jz, :inc => 0},
    7 => {:word => :lt, :inc => 4},
    8 => {:word => :eq, :inc => 4},
    99 => {:word => :halt},
  }
end

# We take an arugment to mock the input, so we don't need to manually enter it.
def run(mock_input)
  @tape = Tape.new(input)

  # We don't need this, but it makes the code a bit tidier.
  def t(a, b); @tape[a, b]; end

  # PC = program counter
  pc = 0
  
  # We'll keep looping until we reach a halt. Based on the problem,
  # all well-formed programs will have an explicit halt command.
  while true
    # Gets the instruction, opcode, mode, and keyword for the current step.
    instruction = @tape[pc]
    opcode, mode = [instruction % 100, instruction / 100]
    command = commands[opcode]

    # Quick check to see if we hit an error.
    # We could do this below, but I'd rather make this check explicit here.
    return puts "ERROR at #{pc}: #{opcode}" unless command

    # Shorthand for the arguments and reference flags.
    # I'm okay with this approach, since we have 3 or fewer for all instructions.
    # 
    # Since we always have (at most) 2 inputs and the output is never by
    # reference, we can use r0 and r1 for the flags.
    a0, a1, a2 = [@tape[pc+1], @tape[pc+2], @tape[pc+3]]
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
      when :in then @tape[a0] = mock_input
      when :out then puts "OUTPUT: #{t(a0, r0)}"
      when :jnz then pc = (t(a0, r0) != 0) ? t(a1, r1) : pc + 3
      when :jz then pc = (t(a0, r0) == 0) ? t(a1, r1) : pc + 3
      when :lt then @tape[a2] = (t(a0, r0) < t(a1, r1)) & 1
      when :eq then @tape[a2] = (t(a0, r0) == t(a1, r1)) & 1 
      when :halt then return puts "HALT"
    end
    pc += command[:inc]
  end
end

# 1: 7566643
puts run(1)

# 5: 9265694
puts run(5)
