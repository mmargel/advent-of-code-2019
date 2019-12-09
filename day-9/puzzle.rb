require_relative 'input'

class Computer
  def initialize(tape)
    @tape = tape.dup
    @mem_offset = 0
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
      5 => {:word => :jnz, :inc => 3},
      6 => {:word => :jz, :inc => 3},
      7 => {:word => :lt, :inc => 4},
      8 => {:word => :eq, :inc => 4},
      9 => {:word => :mem, :inc => 2},
      99 => {:word => :halt, :inc => 0},
    }.freeze
  end

  # Easy way to reference the tape, given a mode (0 = reference, 1 = value)
  def r(index, mode)
    # If the returned value is outside of memory (and positive, but this isn't enforced),
    # then return 0 instead.
    case mode
      when 0 then @tape[index] || 0
      when 1 then index
      when 2 then @tape[index + @mem_offset] || 0
    end
  end

  def w(index, value, mode)
    # We default the mode to 0, since it's often implicitly set to 0 (so it's passed
    # in as nil)
    mode ||= 0

    case mode
      when 0 then @tape[index] = value
      when 2 then @tape[index + @mem_offset] = value  
    end
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
      a0, a1, a2 = @tape[@pc+1..@pc+command[:inc]]
      r0, r1, r2 = mode.to_s.reverse.split('').map(&:to_i)
      # We increment this so so that commands that require a return (`out`) 
      # can still advance the pointer. It also makes jnz and jz tidier
      @pc += command[:inc]

      # Each command maps to a symbol (listed above).
      # For each command, we use our custom tape[] method, which lets us
      # easily specify whether it's by reference or by value.
      # 
      # To make by-reference checks easier, we use bit masks to check the mode.
      #   e.g. if input 2 is by reference, it would by X1X which maps to N!=0
      #   since X1X & 010 (2) == 010 != 0
      # puts "command: #{command}, #{instruction} args:(#{a0}, #{a1}, #{a2}) modes:(#{r0}, #{r1}, #{r2}) | #{mode}"
      case command[:word]
        when :add then w(a2, r(a0, r0) + r(a1, r1), r2)
        when :mult then w(a2, r(a0, r0) * r(a1, r1), r2)
        when :in then w(a0, get_next_mock_input || (puts "INPUT: "; gets.chomp.to_i), r0)
        when :out then puts "OUTPUT: #{r(a0, r0)}"
        when :jnz then @pc = r(a1, r1) if r(a0, r0) != 0
        when :jz then @pc = r(a1, r1) if r(a0, r0) == 0
        when :lt then w(a2, (r(a0, r0) < r(a1, r1)) ? 1 : 0, r2)
        when :eq then w(a2, (r(a0, r0) == r(a1, r1)) ? 1 : 0, r2)
        when :mem then @mem_offset += r(a0, r0)
        when :halt then return puts "HALT"
      end
    end
  end

  # Get the next value from the mock input ticker and advance that pointer.
  # This pointer will be reset on each new run (since each run has its)
  # own inputs
  def get_next_mock_input
    @mock_input_index += 1
    @mock_input_tape[@mock_input_index-1]
  end
end

def part_1
  Computer.new(input).run([1])
  # Computer.new(sample_1).run
  # Computer.new(sample_2).run
  # Computer.new(sample_3).run
end

# 2932210790
part_1
