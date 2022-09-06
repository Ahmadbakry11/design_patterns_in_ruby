# GO4 Definition:
# Convert the interface of a class into another interface clients expect. Adapter lets
# classes work together that couldn't otherwise because of incompatible interfaces.
# ===================================================================================

# Software Adapters
# ------------------
# note: below, I just modified the encrypt method (orginially implemented in Russ Olsen's Book) to 
#       XOR the char_string.ord of each char in the file with the secret key.

class Encrypter
  def initialize(key)
    @key = key
  end

  def encrypt(reader, writer)
    key_index = 0

    while not reader.eof?
      clear_char = reader.getc
      encrypted_char = clear_char.ord ^ @key[key_index].ord
      writer.putc(encrypted_char)
      key_index = (key_index + 1) % @key.size
    end
  end

  def decrypt(reader, writer)
    encrypt(reader, writer)
  end
end

# The above class depends on having 2 open files on that needs to be encrypted and the
# other will be open to write the encrypted version of the file(reader)

encrypter = Encrypter.new('my secret key')

# Perform encryption
reader = File.open('file1.txt')
writer = File.open('file2.txt', 'w')
encrypter.encrypt(reader, writer)

# Perform decryption
enc = File.open('file2.txt')
decoded = File.open('file3.txt', 'w')
encrypter.decrypt(enc, decoded)

# The beauty of the adapter pattern comes when we have a string 
# and that string needs to be encrypted or secured just like the file contents.
# Here, we will have an issue, because we need an object that looks like a File and supports
# the same interface the same as the Ruby IO object.
# so, we need the StringIOAdapter

class StringIOAdapter
  def initialize(string)
    @position = 0
    @string = string
  end

  def eof?
    @position >= @string.length
  end

  def getc
    raise EOFError if @position >= @string.length

    char = @string[@position]
    @position += 1
    char
  end
end

# here, we can use our encrypt instance method of the class Encrypter to
# secure our string like below 

reader = StringIOAdapter.new("a string to be secured")
writer = File.open('file2.txt', 'w')
encrypter.encrypt(reader, writer)

# Russ Olsen's Adapter Pattern definition:
# ------------------------------------------
# An adapter is an object that crosses the chasm between the interface
# that you have and the interface that you need.

# Here the *Client*, our Encrypter instance is expecting a *Target* of an IO object type.
# But under the hood, the client actually has a reference to an *Adapter* StringIOAdapter
# that looks like an IO object but secretly, it reads the characters from s tring, the *Adaptee*.

# ==================================================================================================

One of the most frustrating things is when the interface you want and the interace 
you have almost line up but not quite.

Assuming we have a client that renders a text of a received text object on the screen.

class Renderer
  def render(text_object)
    text = text_object.text 
    size = text_object.size_inches
    color = text_object.color

    # render text
  end
end

Renderer is looking for some sort of objects that look like that:

class TextObject
  attr_accessor :text, :color, :size_inches

  def initialize(text, color, size_inches)
    @text = text
    @color = color
    @size_inches = size_inches
  end
end

But we may find our selves in need to render text o text objects like this:

class BritishTextObject
  attr_accessor :string, :colour, :size_mm

  def initialize(string, colour, size_mm)
    @string = string
    @colour = colour
    @size_mm = size_mm
  end
end

It is better to use the adapter pattern here, because our client (Renderer) is expecting a target
(TextObject) that responds to a certain interface provided by the client.
So, it is better to build our BritishTextObjectAdapter to help the adaptee (BritishTextObject)
to respons to the client interface (Renderer)

class BritishTextObjectAdapter
  def initialize(bto)
    @bto = bto
  end

  def text
    @bto.string
  end

  def color
    @bto.colour 
  end

  def size_inches
    @bto.size_mm / 25.4
  end
end

# ===========================================

The Ruby way:
# -----------------
Ruby has its own way to work around the problem of BritishTextObject we have.
Because in Ruby you can change any class at any time under the condition that you have
the target class loaded.

require 'british_text_object'

class BritishTextObject
  def color 
    colour
  end

  def text
    string
  end

  def size_inches
    size_mm / 25.4
  end
end

The above code loads the BritishTextObject class first, then add the above method to it.
after the require method, the class keyword just repons BritishTextObject class and does not 
create a new one.

# Ruby also has its own way for changing the behaviour of any class instances 

for example assuming we have an instance of BritishTextObject class called bto 
we can do the following 

class << bto 
  def color 
    colour
  end

  def text
    string
  end

  def size_inches
    size_mm / 25.4
  end
end

it turns out that those above methods are uinque to the instance bto and
it is totally independent from the BritishTextObject class .
Ruby calls these methods that are unique to an object "Singleton Methods"

the above also can be represented in different way rather than class << bto 

it can be :
  def bto.color 
    colour
  end

  def bto.text
    string
  end

  def bto.size_inches
    size_mm / 25.4
  end

  Facts about Singleton mthods:
  1- any method defined in the singleton class will override the methods in the regular class.
  singleton class is the first place Ruby looks at when a method called.

  2- The singleton methods also override the methods in any module that happens to be included in
  the class, too.

  3- You can query an object about its singleton methods with the
  singleton_methods method.

  4- Immutable objects—instances of Fixnum, for example—will not cooperate with attempts to add
  singleton methods to them.
