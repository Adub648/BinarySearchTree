# frozen_string_literal: true

require_relative 'node'

class Tree
  attr_accessor :root

  def initialize(arr)
    @root = build_tree(arr)
    @length = arr.length
  end

  # create balanced binary search tree
  def build_tree(arr)
    arr = sort(arr)
    arr = arr.uniq
    make_tree(arr)
  end

  # create nodes for tree through recursion
  def make_tree(arr, start_point = 0, end_point = arr.length)
    return nil if start_point > end_point

    middle_point = (start_point + end_point).div(2)
    node = Node.new(arr[middle_point])

    node.left = make_tree(arr, start_point, middle_point - 1)
    node.right = make_tree(arr, middle_point + 1, end_point)

    node.left = nil if !node.left.nil? && node.left.data.nil?
    node.right = nil if !node.right.nil? && node.right.data.nil?
    node
  end

  # sort using merge sort
  def sort(arr)
    return arr if arr.length <= 1

    middle = (arr.length / 2).round
    left = arr.slice(0, middle)
    right = arr.slice(middle, arr.length)

    merge(sort(left), sort(right))
  end

  def merge(left, right)
    arr = []
    i = 0
    j = 0

    while left.length.positive? && right.length.positive?
      if left[0] < right[0]
        arr.push(left.shift)
      else
        arr.push(right.shift)
      end
    end

    while i < left.length
      arr.push(left[i])
      i += 1
    end

    while j < right.length
      arr.push(right[j])
      j += 1
    end
    arr
  end

  # insert value through recursion
  def insert(data, root = @root)
    if root.data == data
      return root
    elsif root.data < data
      root.right = if root.right.nil?
                     Node.new(data)
                   else
                     insert(data, root.right)
                   end
    else
      root.left = if root.left.nil?
                    Node.new(data)
                  else
                    insert(data, root.left)
                  end
    end

    root
  end

  # delete value
  def delete(root = @root, value)
    return false if @root.nil?

    value = find(value)
    return false if value.nil?

    find_parent(value)
    p @parent_value
    # if leaf value simply delete links
    if value.left.nil? && value.right.nil?
      if value == @root
        @root = nil
        return
      end

      if @parent_value.left == value
        @parent_value.left = nil
      else
        @parent_value.right = nil
      end
    # if one right child change link to skip it
    elsif value.left.nil?
      if value == @root
        @root = root.right
        return
      end

      if @parent_value.left == value
        @parent_value.left = value.right
      else
        @parent_value.right = value.right
      end
    # if one left child change link to skip it
    elsif value.right.nil?
      if value == @root
        @root = root.left
        return
      end

      if @parent_value.left == value
        @parent_value.left = value.left
      else
        @parent_value.right = value.left
      end
    # if two children replace depending on where it is located in tree
    else
      # # we find the lowest value that is in the right subtree of the BST, as it is the point that is going to keep the tree balanced
      # find minimum value in right subtree
      new_val = minimum_value(value.right)
      # if there is right subtree, link to parent of minimmum value
      unless new_val.right.nil?
        find_parent(new_val)
        @parent_value.left == new_val.right
      end
      # replace value
      value.data = new_val.data
      find_parent(new_val)
      # delete old value
      if @parent_value.left == new_val
        @parent_value.left = nil
      else
        @parent_value.right = nil
      end
      nil
    end
  end

  # find minimum value of subtree through iteration
  def minimum_value(value)
    minimum_value = value
    until value.left.nil?
      minimum_value = value.left.data
      value = value.left
    end
    minimum_value
  end

  # find value using binary search
  def find(root = @root, value)
    return root if root.nil? || root.data == value

    if root.data < value
      find(root.right, value)
    else
      find(root.left, value)
    end
  end

  # find parent of value through recursion
  def find_parent(root = @root, value)
    arr = []
    return if root.nil?

    if root.left == value
      arr.append(root)
    elsif root.right == value
      arr.append(root)
    else
      find_parent(root.left, value)
      find_parent(root.right, value)
    end
    @parent_value = arr[0] unless arr.empty?
  end

  # display array with level order traversal
  def level_order(root = @root)
    return if root.nil?

    queue = []
    arr = []
    queue.append(root)
    until queue.empty?
      current = queue[0]
      arr.append(current.data) if current.data
      queue.shift
      queue.append(current.left) unless current.left.nil?
      queue.append(current.right) unless current.right.nil?
    end
    arr
  end

  # display array with inorder traversal
  def inorder(root = @root, arr = [])
    return if root.nil?

    inorder(root.left, arr)
    arr.append(root.data) if root.data
    inorder(root.right, arr)

    arr
  end

  # display array with preorder traversal
  def preorder(root = @root, arr = [])
    return if root.nil?

    arr.append(root.data) if root.data
    preorder(root.left, arr)
    preorder(root.right, arr)

    arr
  end

  # display array with postorder traversal
  def postorder(root = @root, arr = [])
    return if root.nil?

    postorder(root.left, arr)
    postorder(root.right, arr)
    arr.append(root.data) if root.data

    arr
  end

  # find height of node
  def height(value)
    value = find(value)
    arr = level_order(value)
    last_value = arr[-1]
    # find distance between node and lowest node
    height = find_with_height(value, last_value)
    puts "The height of value #{last_value} is #{height}"
  end

  # find depth of node
  def depth(value)
    depth = find_with_height(@root, value)
    puts "Depth of #{value} is #{depth}"
  end

  # find height of node from specified parent node (either a parent or root) using recursion
  def find_with_height(root, last_value, i = 1)
    return i if root.nil? || root.data == last_value

    i += 1
    if root.data < last_value
      find_with_height(root.right, last_value, i)
    else
      find_with_height(root.left, last_value, i)
    end
  end

  # check if tree is balanced through level oder traversal and comparison
  def balanced?(node = @root, boolean_check = [])
    return if node.nil?

    queue = []
    queue.append(node)
    until queue.empty?
      current = queue[0]
      if current.data
        # find height of left node
        if !node.left.nil?
          left_arr = level_order(node.left)
          left_last_value = left_arr[-1]
          left_height = find_with_height(node.left, left_last_value)
        else
          left_height = 0
        end
        # find height of right node
        if !node.right.nil?
          right_arr = level_order(node.right)
          right_last_value = right_arr[-1]
          right_height = find_with_height(node.right, right_last_value)
        else
          right_height = 0
        end
        # if nodes are uneven
        boolean_check.append('false') if left_height - right_height > 1 || right_height - left_height > 1
      end
      queue.shift
      queue.append(current.left) unless current.left.nil?
      queue.append(current.right) unless current.right.nil?
    end
    # check if nodes below are balanced
    balanced?(node.left, boolean_check)
    balanced?(node.right, boolean_check)
    boolean_check.each do |i|
      return false if i == 'false'
    end
    true
  end

  # re-balance tree by making new tree
  def rebalance(root = @root)
    arr = level_order(root)
    @root = build_tree(arr)
  end

  # print through recursion
  def pretty_print(node = @root, prefix = '', is_left = true)
    pretty_print(node.right, "#{prefix}#{is_left ? '│   ' : '    '}", false) if node.right
    puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.data}"
    pretty_print(node.left, "#{prefix}#{is_left ? '    ' : '│   '}", true) if node.left
  end
end

tree = Tree.new(Array.new(15) { rand(1..100) })
tree.pretty_print
puts 'Is the tree balanced?'
p tree.balanced?
puts 'Print tree in level order, preorder, postorder and inorder'
tree.level_order
p tree.preorder
p tree.postorder
p tree.inorder
puts 'Insert numbers into tree and print'
tree.insert(123)
tree.insert(2345)
tree.insert(348)
tree.pretty_print
puts 'Check if tree is balanced and rebalance and print'
p tree.balanced?
tree.rebalance
tree.pretty_print
puts 'Check if tree is balanced'
p tree.balanced?
puts 'Print tree in level order, preorder, postorder and inorder'
tree.level_order
p tree.preorder
p tree.postorder
p tree.inorder
