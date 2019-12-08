require_relative('./input')

# Gets the values of the pixel visible in a given location
def first_visible_pixel(layers, index)
  # We just search for the first layer with a non-transparent pixel and return
  # the value of that pixel. If none exists, we return '2' instead.
  layers.find { |layer| layer[index] != '2' }[index] || '2'
end

# Determines the n('1') * n('2') in the row with the lowest number of zeros (n('0'))
def part_1(data, width, height)
  # Convert the raw input string into an array for easier handling.
  layers = data.gsub("\n", '').scan(/.{#{width*height}}/)

  # The acc has the shape [min_number_of_zeros, num_1_in_layer * num_2_in_layer].
  # This way, we can track both values simultaneously without the need for another
  # tracking variable.
  layers.reduce([Float::INFINITY, 0]) do |acc, layer|

    # Get the number of 0s and abort immediately if it's not lower than the
    # current minimum.
    zero_count = layer.count('0')
    next acc unless zero_count < acc[0]
    
    # If it is, then we update the acc with the new digit counts
    acc = [zero_count, layer.count('1') * layer.count('2')]

    # This final [1] is because we only care about the digit counts,
    # not the lowest number of zeros.
  end[1]
end

# Renders the image contained in the data.
def part_2(data, width, height)
  # Process the input data and get the series of layer strings for easier data handling.
  layers = data.gsub("\n", '').scan(/.{#{width*height}}/)

  # For each pixel, find the visible pixel in each layer.
  # Then, split the layer into rows, join the rows with new lines,
  # and replace the characters with more visible characters.
  (0...width*height)
    .reduce('') { |acc, cursor| acc << first_visible_pixel(layers, cursor) }
    .scan(/.{#{width}}/)
    .join("\n")
    .gsub('0', ' ')
    .gsub('1', '#')
end

# 828
puts part_1(input, 25, 6)

# **** *    ***    ** **** 
#    * *    *  *    * *    
#   *  *    ***     * ***  
#  *   *    *  *    * *    
# *    *    *  * *  * *    
# **** **** ***   **  *    
puts part_2(input, 25, 6)