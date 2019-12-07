require_relative('./input')

class SolarSystem
  # Takes a list of planet definitions as inputs and creates the system from it.
  def initialize(planets)
    @system = {}
    planets.each { |planet| add(planet)}
  end
  
  # Adds a planet, updating both the parent and child planets as necessary.
  def add(designation)
    parent, child = designation.split(')')
    parent_node = @system[parent]
    child_node = @system[child]

    # It's possible that we're adding to a parent that doesn't exist yet
    # In that case, insert it with a distance of 0.
    # 
    # If this ends up being appended later, we'll update the distances
    # when it happens.
    # 
    # This also implicitly treats COM as the root
    if !parent_node
      parent_node = Planet.new(parent)
      @system[parent] = parent_node
    end

    # If we're adding a child that doesn't exist, we create it as a child of the parent,
    # which is guaranteed to exist (see above). Otherwise, we rebase the child onto the 
    # parent. This can happen if the child already exists (and, e.g., the parent is the
    # planet being inserted).
    # 
    # This also gives us a nice way to handle the initial insertion.
    if !child_node
      child_node = Planet.new(child, parent_node)
      @system[child] = child_node
      parent_node.add_child(child_node)
    else
      parent_node.add_child(child_node)
      child_node.rebase(parent_node)
    end

    # For logging (and because it's kind of cool)
    # puts "New Planet: #{@system[parent].name} ⊃ #{child} [d=#{@system[child].distance}]"
  end

  # Finds the total of the distances of all planets from the COM,
  # which is also the total number of orbits.
  def total_length
    @system
      .values
      .map { |planet| planet.distance }
      .reduce(&:+)
  end

  def distance_between(source_name, target_name)
    # For simplicity, we're searching for the common ancestor, not the distance to it.
    # We'll figure out the distance later.
    common_ancestor = nil

    # We start at the node named source_name, since that's how we know which "planet"
    # is the starting point. We continue as long as we have a target node.
    # 
    # Keep in mind that we're determining the number of transfers needed for these
    # nodes to share a parent. NOT the distance between the nodes.
    # 
    # Because of this, we actually care about the distance between the parents.
    originating_node = current_node = @system[source_name].parent
    target_node = @system[target_name].parent

    # We continue as long as we have a node. If this is nil, then there's no match,
    # but this should never actually happen.
    while current_node
      distance_from_target = target_node.distance_to_ancestor(current_node.name)

      # If there's a finite distance, then it means that there's a linear relationship between
      # the nodes (that is, the current node is an ancestor of the target). We can break immediately
      # once we find a node that matches this criterion.
      if distance_from_target != Float::INFINITY
        common_ancestor = current_node
        break
      end

      # Otherwise, we're still looking, so move up a node.
      current_node = current_node.parent
    end

    originating_node.distance_to_ancestor(common_ancestor.name) + target_node.distance_to_ancestor(common_ancestor.name)
  end

  class Planet
    attr_reader :distance, :name, :parent
    def initialize(name, parent = nil)
      @children = []
      @name = name
      @distance = parent ? parent.distance + 1 : 0
      @parent = parent
    end

    # We only really need this as a way of supporting the rebase method
    def add_child(child)
      @children.push(child)
    end

    def distance_to_ancestor(ancestor_name)
      distance = 0
      current_node = self
      while current_node && (current_node.name != ancestor_name)
        distance += 1
        current_node = current_node.parent
      end
      
      current_node.nil? ? Float::INFINITY : distance
    end

    # I'm not sure I like this approach. It's a simple way to propoagate changes,
    # but it also means that the insert operation can get really slow.
    # 
    # On the other hand, if we often add leaves and rarely add nodes into the middle
    # of the tree, then this ends up being faster when we need to calculate the 
    # total distance.
    # 
    # We don't actually need to reattach this each time, since it's only the top-most
    # node that changes parents. For simplicity, we just update the distance for each
    # child node.
    def rebase(parent = nil)
      @parent ||= parent
      @distance = @parent.distance + 1
      @children.each { |child| child.rebase }
    end
  end
end

def part_1
  s = SolarSystem.new(input)
  s.total_length
end

def part_2
  s = SolarSystem.new(input)
  s.distance_between("YOU", "SAN")
end

# 145250
puts part_1

# 274
puts part_2