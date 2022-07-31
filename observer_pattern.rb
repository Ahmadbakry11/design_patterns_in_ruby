# The observer pattern defines a one to many dependency between objects, so that 
# when one object changes its state, all its depndents are notified and updated
# automatically.

# EX:1
# Assuming that we have an employee and many other objects or services need 
# to know about the salary change of the employee.Let's say TaxMan and Payroll

class Subject
  attr_accessor :observers

  def initialize
    @observers = []
  end

  def add_observer(observer)
    @observers << observer 
  end

  def remove_observer(observer)
    @observers.delete(observer)
  end

  def notify_observers
    @observers.each do |o|
      o.update(self)
    end
  end
end

# Observable or Subject based on GO4
class Employee < Subject
  attr_accessor :name, :title
  attr_reader :salary

  def initialize(name, title, salary)
    super()
    @name = name 
    @title = title
    @salary = salary
  end

  def salary=(new_salary)
    @salary = new_salary
    notify_observers
  end
end

# Observer
class Payroll
  def update(changed_employee)
    puts "#{changed_employee.name} has got a salary change and now it's #{changed_employee.salary}"
  end
end

# Observer
class TaxMan
  def update(citizen)
    puts "Send an update for the tax collected from #{citizen.name} by #{citizen.slary}"
  end
end

# There is a little bit flaw or a mistake in the prev. approach
# Ruby allows any class 
# to have only one super class.So if we needed our employee class to inherit
# or get information from other classes, that will be impossible
# And this is on the flaws of (inheritance) making our class tightly coupled to another class.
# The sloution lies in using module subject and include it in any class that needs
# to be observed

module Subject
  attr_accessor :observers

  def initialize
    @observers = []
  end

  def add_observer(observer)
    @observers << observer 
  end

  def remove_observer(observer)
    @observers.delete(observer)
  end

  def notify_observers
    @observers.each do |o|
      o.update(self)
    end
  end
end

class Employee 
  include Subject
end

# and voila

# Ruby comes with a ready baked Observable module for implementing
# the observer pattern 

require 'observe'

class Employee < Subject
  include Observable

  attr_accessor :name, :title
  attr_reader :salary

  def initialize(name, title, salary)
    super()
    @name = name 
    @title = title
    @salary = salary
  end

  def salary=(new_salary)
    @salary = new_salary
    changed                       # here we must call changed to notify observers
    notify_observers(self)        # it returns a boolean if changed or not
  end
end

# Variations on the Observer Pattern
# Variations always lie in the interface between the observer and the subject.
# Here the interface is the simple update method, which has one argument, the subject itself.
# There are 2 variations here according to the GO4.

# 1- Pull method:
#    Like above, you pass the subject and the observer is reponsible for pulling what it needs.
# 2- Push method:
#    You pass the subject plus the changes themselves like below:

   observer.update(self, :salary_changed, old_salary, new_salary)

  # adv: The observer will not have to work hard to keep track of what is going on.
  # disadv: Observers sometimes will receive data they do not need, in case there are not
  #          interested in the sent changes.aAnd the solution for that, is to implement different 
  #          update methods for different events.

           observer.update_salary(self, old_salary, new_salary)

           observer.update_title(self, old_title, new_title)

# Using and abusing the observer pattern
  # 1- Most of the problems asociated by using the observer pattern are related to the timing and frequency
  #   of the update the the subject spew to the observers.
  #   Getting the subject object updated, does not mean at all that there is a change.
  #   The solution for that is to only notify the observers if there is only a change.


    def salary=(new_salary)
      old_salary = @salary 
      @salary = new_salary
      notify_observers unless @salary == old_salary
    end
  
    # 2- Another potential problem lies in the consistency of the subject as it informs its
    #    observers of changes.
    #   Assuming we have an employee who gets updates to his title or gets promoted for ex.

      def title=(new_title)
        old_title = @title
        @title = new_title
        notify_observers unless @title == old_title
      end

      fred = Employee.new('Fred', 'Crane Operator', 3000)
      fred.salary = 10000
      # Here all of the observers, get notified with the new salary and the old title
      # Fred is the highest paid crane operator in the world.
      fred.title = 'Vice president'

      # The solution for that, is by notifying observers only if the the changes are complete
      # and do not make the observer notification associated with the an attribute change 
      
      def changes_complete
        notify_observers
      end

      fred = Employee.new('Fred', 'Crane Operator', 3000)
      fred.salary = 10000
      fred.title = 'Vice president'
      fred.changes_complete
      
# The whole pattern implementation:

module Subject
  attr_accessor :observers

  def initialize
    @observers = []
  end

  def add_observer(observer)
    @observers << observer 
  end

  def remove_observer(observer)
    @observers.delete(observer)
  end

  def notify_observers
    @observers.each do |o|
      o.update(self)
    end
  end
end



class Employee
  include Subject

  attr_accessor :name, :changed?
  attr_reader :salary, :title

  def initialize(name, title, salary)
    super()
    @name = name 
    @title = title
    @salary = salary
    @changed? = false
  end

  def salary=(new_salary)
    old_salary = @salary
    @salary = new_salary
    @changed == true unless @salary == old_salary
  end

  def title=(new_title)
    old_title = @title
    @title = new_title
    @changed == true unless @title == old_title
  end

  def changes_complete
    notify_observers if changed?
  end
end

# Observer
class Payroll
  def update(changed_employee)
    puts "#{changed_employee.name} has got a salary change and now it's #{changed_employee.salary}"
  end
end

# Observer
class TaxMan
  def update(citizen)
    puts "Send an update for the tax collected from #{citizen.name} by #{citizen.salary}"
  end
end

fred = Employee.new('Fred', 'Crane Operator', 3000)
fred.salary = 10000
fred.title = 'Vice president'
fred.changes_complete




      


