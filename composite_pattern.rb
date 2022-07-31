# Sometimes we want a complex object to look and act exactly like
# the components we use to build it.

# Sometimes you have an application that has a hierarchical or tree implementation and you 
# need to treat the parent at any point of the tree and the leafs uniformally in terms of the 
# interface they implement without having a difference between them.

# Sometimes we want a complex object to look and act exactly like
# the components we use to build it.

# suppose, we need to design an app that tracks the used time to make a cake for some startup.
# This app has some complex tasks, which in turn are composed of some smaller tasks, that may also composed 
# of other sub tasks and so on.
# For example the make cake task may be composed of Make Batter, Fill Pan, Bake, Frost tasks.

# In terms of the main target of that design, which is claculating the time consumed.Each of the above is considered a task,
# regardless, whether this is a complex or a simple task.

# This is what the GOF4 know as "the sum acts like one of the parts".

# Here, we need to impelement or use the composite pattern.
# According to the GOF4, to use the composite pattern we need three moving parts.

# Part1: you need a common interface or base class for all of your objects. The GoF call this base
# class or interface the component. 

# Part2: you need one or more leaf classes—that is, the simple, indivisible building
# blocks of the process. In our cake example, the leaf tasks were the simple jobs, such as
# measuring flour or adding eggs.
# In the organization example, the individual workers are the leaves.

# Part3: we need at least one higher-level class, which the GoF call the composite
# class. The composite is a component, but it is also a higher-level object that is built
# from subcomponents. In the baking example, the composites are the complex tasks
# such as making the batter or manufacturing the whole cake—that is, the tasks that are made up of subtasks.
# For organizations, the composite objects are the departments
# and divisions.


# Lets write some code to implement the cake factory creation process using the composite pattern.

# 1-Start by implementing the component base class.Since all of steps mentioned above to make the cake are 
#   simply Task.So, let's call the component Task

  class Task
    attr_reader :name
    def initialize(name)
      @name = name
    end

    def get_time_required
      0.0
    end
  end

# 2- Implement Leaf classes

  class AddDryIngredientsTask < Task
    def initialize
      super('Add dry ingredients')
    end

    def get_time_required
      1.0
    end
  end
  def get_time_required
    0.0
  end
    def get_time_required
      3.0
    end
  end

  class AddLiquidsTask < Task
    def initialize
      super('Add the liquids to the mix')
    end

    def get_time_required
      2.0
    end
  end

# 3- Now, let's discuss how the composite task can be implemented.

  class MakeBatterTask < Task

    def initialize
      super('Make the Batter')
      @sub_tasks = []
      add_sub_task(AddDryIngredientsTask.new)
      add_sub_task(MixTask.new)
      add_sub_task(AddLiquidsTask.new)
    end

    def add_sub_task(task)
      @sub_tasks << task 
    end

    def remove_sub_task(task)
      @sub_tasks.delete(task)
    end

    def get_time_required
      # @sub_tasks.map(&:get_time_required).inject { |time, n| time + n }  using inject
      total = 0.0
      @sub_tasks.each { |task| total += task.get_time_required }
      total
    end 
  end

  # We note that how the composite task implements the get_time_required method by collecting
  # data from its children
  # And because, we will have other composite tasks, we can refactor our code and add those detils
  # to a base composite class.

  class CompositeTask < Task
    def initialize(name)
      super(name)
      @sub_tasks = []
    end

    def add_sub_task(task)
      @sub_tasks << task 
    end

    def remove_sub_task(task)
      @sub_tasks.delete(task)
    end

    def get_time_required
      # @sub_tasks.map(&:get_time_required).inject { |time, n| time + n }  using inject
      total_time = 0.0
      @sub_tasks.each { |task| total_time += task.get_time_required }
      total_time
    end 
  end
  
  class MakeBatterTask < CompositeTask
    def initialize
      super('Make the Batter')
      add_sub_task(AddDryIngredientsTask.new)
      add_sub_task(MixTask.new)
      add_sub_task(AddLiquidsTask.new)
    end
  end

  # The key point to keep in mind about composite objects is that the tree may be
  # arbitrarily deep.For example, the MakeBatterTask goes down one level, but we may have other tasks that can
  # go deeper more.We may have a MakeCakeTask that can be as following.

  class MakeCakeTask < CompositeTask
    def initialize
      super('Make the Cake')
      add_sub_task(MakeBatterTask.new)
      add_sub_task( FillPanTask.new )
      add_sub_task(AddLiquidsTask.new)
      add_sub_task( BakeTask.new )
      add_sub_task( FrostTask.new )
      add_sub_task( LickSpoonTask.new )
    end
  end

  # Any one of the subtasks of MakeCakeTask might be a composite.Like the MakeBatterTask

  # There is something that is inconvenient about the composite pattern.
  # We began by saying that the goal of the Composite pattern is to make the leaf
  # objects more or less indistinguishable from the composite objects.
  # We say “more or less” here because there is one unavoidable difference between a composite and a leaf.
  # The composite has to manage its children, which probably means that it needs to have 
  #   * a method to get at the children 
  #   * and possibly methods to add and remove child objects.
  # The leaf classes, of course, really do not have any children to manage; that is the nature
  # of leafyness.

  # Also, we can note that there is a clear violation to the ISP(Interfcae Segregation Principle) which states that
  # states that no code should be forced to depend on methods it does not use.[1] 
  # ISP splits interfaces that are very large into smaller and more specific ones 
  # so that clients will only have to know about the methods that are of interest to them.

  # And here, we can clearly note that the child classes are depending on methods like add_sub_task and
  # remove_sub_task from the interface they implement (Task), although those classes do not have children or remove and
  # can not add children.And this the clear violation to the ISP.

  # The solution for how you can handle this decision is mostly a matter of taste: Make the leaf
  # and composite classes different, or burden the leaf classes with embarrassing methods
  # that they do not know how to handle. My own instinct is to leave the methods off of
  # the leaf classes. Leaf objects cannot handle child objects, and we may as well admit it.

  # We can have another solution for such inconvenient difference.Which is avoiding mutation.
  # We can consider the data structure that represents the whole tree, an immutable data structure.
  # So, here we can implement a feature for converting the leaf to a composite by generating a new copy of the data 
  # and keeping the orginal data with leaf(an immutable that can not be a composite)

  # The Composite pattern is a strictly top-down affair.
  # Because each composite object holds references to its subcomponents but the child components 
  # do not know a thing about their parents, it is easy to traverse the tree from the
  # root to the leaves but hard to go the other way.

  # The solution: it is easy to add a parent reference to each participant in the composite so that we
  # can climb back up to the top of the tree. 

  class Task
    attr_accessor :name, :parent 

    def initialize(name)
      @name = name 
      @parent = nil
    end

    def get_time_required
      0.0
    end
  end

  class CompositeTask < Task
    def initialize(name)
      super(name)
      @sub_tasks = []
    end

    def add_sub_task(task)
      @sub_tasks << task
      task.parent = self 
    end

    def remove_sub_task(task)
      @sub_tasks.delete(task)
      task.parent = nil
    end

    def get_time_required
      # @sub_tasks.map(&:get_time_required).inject { |time, n| time + n }  using inject
      total_time = 0.0
      @sub_tasks.each { |task| total_time += task.get_time_required }
      total_time
    end 
  end

  # and so, we can trace all the composite component up to its ultimate parent.

  while task
    puts("task: #{task}")
    task = task.parent
  end

  # The most popular error while using the composite pattern, is assuming that the tree is only one level deep.
  # And all the childs of any composite are only leaves.
  # And this is a mistake.

  # Assuming we need to get the length of all the leaf components in the tree(number of leaf components in the tree).
  # We will need recursion to correctly implement that.

  class Task
    # Lots of code omitted...

    def total_number_basic_tasks
      1
    end
  end

  class CompositeTask < Task
    # Lots of code omitted...
    
    def total_number_basic_tasks
      total = 0
      @sub_tasks.each {|task| total += task.total_number_basic_tasks}
      total
    end
  end
# ===========
# Sprucing up the composite pattern with operators.

# As we saw above, the composite is a component and at the same time, it is a collection of components.
# So, it will be more readable if we dealt with our composite as a ruby collection.

# like :

composite = CompositeTask.new 
composite << MixTask.new 

# we need to define our operator << like below

def <<(task)
  @sub_tasks << task 
end

# also, we can do something like, 
# puts composite[i].get_time_required  ==> like below 

def [](index)
  @sub_tasks[index]
end

# And also, we can do something like, 
# composite[1] = MixTask.new

def [](index, new_value)
  @sub_tasks[index] = new_value
end

