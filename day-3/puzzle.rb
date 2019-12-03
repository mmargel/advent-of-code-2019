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
end

def is_closer?(a, b)
  # puts "is_closer?: #{a}, #{b}, #{a[0].abs + a[1].abs < b[0].abs + b[1].abs}"
  a[0].abs + a[1].abs < b[0].abs + b[1].abs
end

def part_1
  wires = input.dup
  # wires = sample.dup
  travel_grid = {[0,0] => 0}
  closest_overlap = [Float::INFINITY, Float::INFINITY]

  wires.each_with_index do |steps, wire_number|
    # puts '---'
    current_spot = [0,0]  
    steps.each do |step|
      delta, num_steps = get_step_path(step)
      (1..num_steps).each do |_|
        current_spot[0] += delta[0]
        current_spot[1] += delta[1]
        current_spot_slug = current_spot.join(';')

        if wire_number == 0
          travel_grid[current_spot_slug] = 1
          # puts "travel_grid[current_spot_slug]: #{travel_grid[current_spot_slug]}"
        else
          puts current_spot.inspect if travel_grid[current_spot_slug]
          # puts "travel_grid[current_spot_slug]: #{current_spot_slug} --> #{travel_grid[current_spot_slug]}"
          if travel_grid[current_spot_slug] && is_closer?(current_spot, closest_overlap)
            # puts "closest_overlap: #{closest_overlap}"
            # puts "current_spot: #{current_spot}"
            closest_overlap = current_spot.dup
          end
        end
      end
    end
  end
# puts '==='
  puts closest_overlap.inspect
  closest_overlap[0].abs + closest_overlap[1].abs
end


puts part_1