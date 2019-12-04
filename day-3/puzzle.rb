require_relative 'input'

def get_step_path(step)
  step_size = step[1..-1]
  step_dir = case step[0]
    when 'U' then [0, 1]
    when 'D' then [0, -1]
    when 'L' then [-1, 0]
    when 'R' then [1, 0]
  end

  return step_dir, step_size.to_i

  # return case step[0]
  #   when 'U' then [0, 1]
  #   when 'D' then [0, -1]
  #   when 'L' then [-1, 0]
  #   when 'R' then [1, 0]
  # end, step[1..-1].to_i
end

# Because doing all of these oeprations manually is annoying
class Tuple < Array
  def initialize(*args)
    super(args)
  end

  def to_taxi_distance
    self.map(&:abs).reduce(:+)
  end

  def+ (other)
    Tuple.new(self.first + other.first, self.last + other.last)
  end

  def to_h
    @slug ||= self.join(';')
  end
end

def run(distance_type)
  wires = input.dup
  
  # There's this weird thing that we can do here, which lets us store both the
  # number of wires passing through a spot and the length to a tile in the same
  # place. Basically, since we know that wires don't self-intersect, we can treat
  # and truthy value here as "visited" for wire 2.
  #
  # As a result, we can just store the distance here and if wire 2 sees that
  # there's any truthy value, we know that this has been visited. If it's been
  # visited, we can then check the distance based on whichever metric we
  # care about.
  #
  # Since we don't count the intersection at the origin, we're just going
  # to leave it out of this chart.
  distance_chart = {}
  shortest_distance = Float::INFINITY

  # We have multiple wires, so we just do this in a loop with the index.
  # In theory, we could also separate this into 2 totally separate method
  # calls, but I'm not convinced that it's worth it
  wires.each_with_index do |wire_steps, wire_number|
    # We reset these values whenever we change wires
    current_tile = Tuple.new(0,0)
    wire_length = 0

    # Now we iterate through each instruction in that specific wire, updating the
    # distance_chart as we go
    wire_steps.each do |step|
      delta, num_steps = get_step_path(step)
      # We don't care about the index of this loop, just the
      # number of iterations
      (1..num_steps).each do
        # We can do this because we made our current spot a Tuple instead of an Array
        current_tile += delta

        # We can use the current spot as a hash key, due to how we wrote its to_h method
        current_tile_distance = distance_chart[current_tile]

        # We increment this here because we need to uncoil the wire before we lay it down.
        # This way, we're including the wire needed to get to the current tile in our
        # calculations.
        wire_length += 1

        # If we're on the first wire, just update the value to something truthy.
        # Here, we use the wire length so we can find the shortest path more easily.
        if wire_number == 0
          distance_chart[current_tile] = wire_length
        # If we're on the second wire, and the spot has been visited, then try to update
        # the corresponding distance metric
        elsif current_tile_distance
          # There might be a slightly tidier way of doing this by passing in a comparator
          # delegate, but that's probably going to create more headaches than it solves.
          shortest_distance = distance_type == :taxicab ?
            [current_tile.to_taxi_distance, shortest_distance].min :
            [current_tile_distance + wire_length, shortest_distance].min
        end
      end
    end
  end

  shortest_distance
end

# [431, -434]
# 865
puts run(:taxicab)

# 35038
puts run(:wire_length)