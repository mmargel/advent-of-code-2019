require_relative('./input')

def generate_layers(data, width, height)
  layers = []
  cursor = 0
  layer_size = width * height

  # Continue until we run out of data.
  # We assume the data is well-formed.
  loop do
    # Get the next layer substrings.
    # We do this by using `scan` to break it up into layer-sized substrings
    layer = data[cursor, layer_size].scan(/.{#{width}}/)
    break if layer.empty?

    # Append the layer and progress the cursor
    layers << layer
    cursor += layer_size
  end

  # Return the layers
  layers
end

# Finds the count of a given digit in a layer.
# Since it's an array of strings, we just join them and count the values.
def count_digit(layer, digit)
  layer.join.count(digit.to_s)
  # We could also do this, but there's no real benefit:
  # layer.map { |row| row.count(digit.to_s) }.reduce(:+)
end

# Gets the values of the pixel visible in a given location
def first_visible_pixel(layers, row, column)
  # We just search for the first layer with a non-black pixel and return
  # the value of that pixel. If none exists, we return '2' instead.
  layers.find { |layer| layer[row][column] != '2' }[row][column] || '2'
end

# Determines the n('1') * n('2') in the row with the lowest number of zeros (n('0'))
def part_1(data, width, height)
  # Convert the raw input string into a 2-D array for easier handling.
  layers = generate_layers(data.gsub("\n", ''), width, height)

  # The acc has the shape [min_number_of_zeros, num_1_in_layer * num_2_in_layer].
  # This way, we can track both values simultaneously without the need for another
  # tracking variable.
  layers.reduce([Float::INFINITY, 0]) do |acc, layer|

    # Get the number of 0s and abort immediately if it's not lower than the
    # current minimum.
    zero_count = count_digit(layer, 0)
    next acc unless zero_count < acc[0]
    
    # If it is, then we update the acc with the new digit counts
    acc = [zero_count, count_digit(layer, 1) * count_digit(layer, 2)]

    # This final [1] is because we only care about the digit counts,
    # not the lowest number of zeros.
  end[1]
end

# Renders the image contained in the data.
def part_2(data, width, height)
  # Convert the raw input string into a 2-D array for easier handling.
  layers = generate_layers(data.gsub("\n", ''), width, height)

  # We use this array to store the image data
  rendered_image = []

  # Then, starting at (0,0), we iterate over the image and determine what's
  # rendered for each pixel.
  (0...height).each do |row|
    # We render this one row at a time. Since we're rendering this as ascii,
    # we can just store each row as a string.
    #
    # For each pixel in the row, get the rendered pixel and add it to
    # the array.
    image_row = (0...width)
      .map { |column| first_visible_pixel(layers, row, column)}
      .join

    # Once the row is done, append it to the image.
    rendered_image << image_row
  end

  # Join the 
  rendered_image
    .join("\n")
    .gsub('0', ' ')
    .gsub('1', '*')
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
