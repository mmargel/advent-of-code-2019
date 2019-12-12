require_relative('input')
require 'set'

def count_visible_asteroids(chart, x0, y0)
  asteroids = Set.new
  (0...chart.length).each do |y|
    (0...chart[0].length).each do |x|
      next if y == y0 && x == x0
      next unless chart[y][x] == '#'

      dx = x0 - x
      dy = y0 - y
      if (dy == 0)
        asteroids.add([dx > 0 ? 1 : -1, nil])
      elsif (dx == 0)
        asteroids.add([nil, dy > 0 ? 1 : -1])
      else
        gcd = dx.gcd(dy)
        slope = [dy, dx].map { |x| x / gcd }
        puts "#{x0}, #{y0} --> #{x}, #{y} (#{slope})"
        asteroids.add(slope)
      end
    end
  end

  puts "asteroids: #{asteroids}"
  asteroids.size
end

def part_1
  chart = input
  max_asteroids = 0
  best_coords = nil
  (0...chart[0].length).each do |x|
    (0...chart.length).each do |y|
      next unless chart[y][x] == '#'
      visible_asteroids = count_visible_asteroids(chart, x, y)
      puts "visible_asteroids: #{visible_asteroids}"
      if visible_asteroids > max_asteroids
        max_asteroids = visible_asteroids
        best_coords = [x, y]
      end
    end
  end

  puts "#{max_asteroids} @ #{best_coords}"
end

# 296
part_1