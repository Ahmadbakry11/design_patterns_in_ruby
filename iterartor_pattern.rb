# In case we have some object that is internally composed of other objects and we may need to sequence 
# through all of the sub-objects without needing to know any of the details of how the aggregate object is storing them.

# Here we may need the Iterator pattern, a technique that allows an
# aggregate object to provide the outside world with a way to access its collection of sub-objects. 

# The GoF tell us that the Iterator pattern will do the following:
#   "Provide a way to access the elements of an aggregate object sequentially without
#   exposing its underlying representation"

# In other words, an Iterator provides the outside world with a sort of movable
# pointer into the objects stored inside an otherwise opaque aggregate object.

# 1- External Iterator:
# ------------------------

# It is called External because the iterator is a separate object from the aggregate. 

# We can build our own version of a Java external iterator.

class ArrayIterator
  def initialize(array)
    @array = array 
    @index = 0
  end

  def has_next?
    @index < @array.length
  end

  def item
    @array[@index]
  end

  def next_item
    value = @array[@index]
    @index += 1 
    value
  end
end

# Here is how we might use our new iterator.

array = ['red', 'green', 'blue']
i = ArrayIterator.new(array)

while i.has_next?
  puts("item: #{i.next_item}")
end

# With just a few lines of code, our ArrayIterator gives us just about everything
# we need to iterate over any Ruby array. As a free bonus, Ruby’s flexible dynamic typ-
# ing allows ArrayIterator to work on any aggregate class that has a length method and
# can be indexed by an integer. String is just such a class, and our ArrayIterator
# will work fine with strings:

i = ArrayIterator.new('abc')

while i.has_next?
  puts("item: #{i.next_item}")    #this will return the strring as a number(charcter code).
end

while i.has_next?
  puts("item: #{i.next_item.chr}")
end


# Although, that was so effecient, but external iterators are rarely used in ruby.
# Ruby has something better to solve such problem(iteration) and it is built on top of code block and the 
# Proc object.

# 2- Internal Iterators 
# -----------------------

# it is called internal iterators, because all of the iterating action
# occurs inside the aggregate object, the code block-based iterators are called internal
# iterators.

# Building internal iterator in ruby is verty easy using code blocks

def for_each_element(array)
  i = 0
  while i < array.length
    yield(array[i]) if block_given?
    i += 1 
  end 
end

for_each_element(array) { |element| puts element }

# The Array class sports with its own iterator called each 

array.each {|element| puts("The element is #{element}")}

# ----------------------

# Enumerable
# -----------------
# If you do find yourself creating an aggregate class and equipping it with an internal
# iterator, you should probably consider including the Enumerable mixin module in
# your class.

# There are 2 conditions to do so:

# 1- you need only make sure that your internal iterator method is named "each"
# 2- the individual elements that you are going to iterate over have a reasonable implementation of 
# the (spaceship operator) <=> comparison operator.

# We need to mention also here that mixing the Enumerable module will supply
# you with a all the goodness methods included in the Enumerable module.
# Here is an example for that.

class Account
  attr_accessor :name, :balance

  def initialize(name, balance)
    @name = name 
    @balance = balance 
  end

  def <=>(other)
    balance <=> other.balance
  end
end

class Portofolio
  include Enumerable

  attr_accessor :accounts 

  def initialize
    @accounts = []
  end

  def each(&block)
    @accounts.each(&block)
  end

  def add_account(account)
    @accounts << account
  end
end

# By simply mixing the Enumerable module into Portfolio and defining an
# each method, we have equipped Portfolio with all kinds of Enumerable goodness.
# For example, we can now find out whether any of the accounts in our portfolio has a
# balance of at least $2,000:

my_portfolio.any? {|account| account.balance > 2000}

# We can also find out whether all of our accounts contain at least $10:

my_portfolio.all? {|account| account.balance > = 10}
# ========================================================

# Using and Abusing the Iterator Pattern
# ----------------------------------------

# Unfortunately, none of the iterators that we have built in this chapter so far react
# particularly well to change. Recall that our external ArrayIterator worked by hold-
# ing on to the index of the current item. Deleting elements from the array that we have
# not seen yet is not a problem, but making modifications to the beginning of the array
# will wreak havoc with the indexing.

# We can make our ArrayIterator resistant to changes to the underlying array by
# simply making a copy of the array in the iterator constructor:

class ChangeResistantArrayIterator
  def initialize(array)
    @array = Array.new(array)
    @index = 0
  end

# Internal iterators have exactly the same concurrent modification problems as
# external iterators. For example, it is probably a very bad idea to do the following:

array=['red', 'green', 'blue', 'purple']
array.each do | color |
  puts(color)
  if color == 'green'
    array.delete(color)
  end
end

# This will print:

# red
# green
# purple

# Internal iterators can also defend against the crime of modifying while iterating
# by working on a separate copy of the aggregate, just as we did in our
# ChangeResistantArrayIterator class. This might look something like the following
# code:

def change_resistant_for_each_element(array)
  copy = Array.new(array)
  i = 0
  
  while i < copy.length
    yield(copy[i])
    i += 1
  end
end