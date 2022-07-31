Design Patterns ideas boil down to four points:
• Separate out the things that change from those that stay the same.
• Program to an interface, not an implementation.
• Prefer composition over inheritance.
• Delegate, delegate, delegate.

1- Separate out the things that change from those that stay the same.

A key goal of software engineering is to build systems that allow us to contain the
damage. In an ideal system, all changes are local: 
You get there by separating the things that are likely to change from the things
that are likely to stay the same. If you can identify which aspects of your system design
are likely to change, you can isolate those bits from the more stable parts. When
requirements change or a bug fix comes along, you will still have to modify your code,
but perhaps, just perhaps, the changes can be confined to those walled-off, change-
prone areas and the rest of your code can live on in stable peace.

2- Program to an interface, not an implementation.

The idea here is to program to the
most general type you can—not to call a car a car if you can get away with calling it
a vehicle, regardless of whether Car and Vehicle are real classes or abstract interfaces.
And if you can get away with calling your car something more general still, such as a
movable object, so much the better. As we shall see in the pages that follow, Ruby
(a language that lacks interfaces in the built-in syntax sense)2 actually encourages you
to program to your interfaces in the sense of programming to the most general types.

my_car = Car.new
my_car.drive(200)

If we have another types like, plane

# Deal with cars and planes
if is_car
  my_car = Car.new
  my_car.drive(200)
else
  my_plane = AirPlane.new
  my_plane.fly(200)
end

If we have more types like trains, boats, planes, etc, the best solution is:

my_vehicle = get_vehicle
my_vehicle.travel(200)

3- Prefer composition over inheritance.

The trouble is that inheritance comes with some unhappy strings attached.
When you create a subclass of an existing class, you are not really creating two sepa-
rate entities: Instead, you are making two classes that are bound together by a com-
mon implementation core. Inheritance, by its very nature, tends to marry the subclass
to the superclass. Change the behavior of the superclass, and there is an excellent
chance that you have also changed the behavior of the subclass. Further, subclasses
have a unique view into the guts of the superclass. 
Any of the interior workings of
the superclass that are not carefully hidden away are clearly visible to the subclasses.
If our goal is to build systems that are not tightly coupled together, to build systems
where a single change does not ripple through the code like a sonic boom, breaking
the glassware as it goes, then probably we should not rely on inheritance as much
as we do.

Instead of creating classes that inherit most
of their talents from a superclass, we can assemble functionality from the bottom up.
To do so, we equip our objects with references to other objects—namely, objects that
supply the functionality that we need. Because the functionality is encapsulated in

these other objects, we can call on it from whichever class needs that functionality. In
short, we try to avoid saying that an object is a kind of something and instead say that
it has something.

class Vehicle
  # All sorts of vehicle-related code...
  def start_engine
  # Start the engine
  end

  def stop_engine
  # Stop the engine
  end
end

class Car < Vehicle
  def sunday_drive
    start_engine
    # Cruise out into the country and return
    stop_engine
  end
end

Other vehicles also need to start and stop engines, so let’s abstract out the engine
code and put it up in the common Vehicle base class 

What about engineless vehicles like a bicycle or a sailboat, the details of the engine are probably exposed 
to those engineless vehicles.

We can avoid all of these issues by putting the engine code into a class all of its
own—a completely stand-alone class, not a superclass of Car:

class Engine
  # All sorts of engine-related code...
  def start
    # Start the engine
  end

  def stop
    # Stop the engine
  end
end

class Car
  def initialize
    @engine = Engine.new
  end

  def sunday_drive
    @engine.start
    # Cruise out into the country and return...
    @engine.stop
  end
end

(via composition, of course!). As a bonus, by untangling the engine-related code from
Vehicle, we have simplified the Vehicle class.
We have also increased encapsulation. 

Separating out the engine-related code
from Vehicle ensures that a firm wall of interface exists between the car and its
engine. In the original, inheritance-based version, all of the details of the engine
implementation were exposed to all of the methods in Vehicle. In the new version,
the only way a car can do anything to its engine is by working through the public—
and presumably well-thought-out—interface of the Engine class.

We have also opened up the possibility of other kinds of engines. The Engine
class itself could actually be an abstract type and we might have a variety of engines,
all available for use by our car

class Car
  def initialize
    @engine = GasolineEngine.new
  end

  def sunday_drive
    @engine.start
    # Cruise out into the country and return...
    @engine.stop
  end

  def switch_to_diesel
    @engine = DieselEngine.new
  end
end


4- Delegate, delegate, delegate.

Someone calls the start_engine method on our Car. The car object
says, “Not my department,” and hands the whole problem off to the engine.

class Car
  def initialize
    @engine = GasolineEngine.new
  end

  def sunday_drive
    start_engine
    # Cruise out into the country and return...
    stop_engine
  end

  def switch_to_diesel
    @engine = DieselEngine.new
  end

  def start_engine
    @engine.start
  end

  def stop_engine
    @engine.stop
  end
end