# GO4 definition:
# ==================
# Provide a surrogate or placeholder for another object to control access to it.
# It is also know as Surrogate Pattern

# There are some examples where the need to the proxy pattern gets very clear.

# When we need to provide controlling access to an object or 
# providing a location-independent way of getting at the object or 
# delaying its creation.

# There comes the need to the proxy pattern

# 1- The protection Proxy:
# --------------------------
# Assuming we have a bank account class like below:

class BankAccount
  attr_accessor :balance

  def initialize(starting_balance = 0)
    @balance = starting_balance
  end

  def deposit(amount)
    @balance += amount
  end

  def withdraw(amount)
    @amount -= amount
  end
end

# Now, easily we can have our bank account proxy class
# which will do nothing, but having a reference to te BankAccount class, getting the requests from the client
# and delegating those requests to the BankAccount class.Nothing more.

class BankAccountProxy
  def initialize(account)
    @account = account
  end

  def deposit(amount)
    @account.deposit(amount)There is a method in Ruby called method_missing.
    # When we call a method that is not found in a specific class or an iterface,
    # Ruby will try to search for a method called method_missing in the calling object class
    # and if it does not find it, it will look up in the heirarchy tree untill it finds it
    # or it reaches to the Object which has a default definition for the method_missing.
    # it raises an error: No method error.
    
    # we can rewrite the proxy class as following:
    # I mean, instead if repeating the addition of all the methods defined in the subject class-- 
    # that needs to proxy -- in the proxy class again.We only use the below design
  end

  def withdraw(amount)
    @account.withdraw(amount)
  end
end

# But, if the responsibilty of the proxy is just delegating the requests,
# what is the real accomplishment?.

# Assuming we need to control who gets to the BankAccount operations and who is not allowed.
# # Here comes the role, of the BankAccountProxy.
# It is better to implement the logic of authorization and protection in the proxy.
# This will provide a separation of concerns.The proxt takes care of protection and 
# the BankAccount takes care of the bank account 

require 'etc'

class BankAccountProxy
  def initialize(account, owner_name)
    @account = account
    @owner_name = owner_name
  end

  def deposit(amount)
    check_access
    @account.deposit(amount)
  end

  def withdraw(amount)
    check_access
    @account.withdraw(amount)
  end

  def balance
    check_access
    @account.balance
  end

  private 

  def check_access
    if Etc.getlogin != @owner_name
      raise "Illegal access: #{Etc.getlogin} cannot access account."
    end
  end
end


account = BankAccount.new(5)
pa = BankAccountProxy.new(account, 'ahmad')

pa.deposit(10)

p account.balance     #====> 15

# The previous design has another 3 advatages:

# 1- By implementing the security in a proxy, we make it easy to swap in a differ-
# ent security scheme (just wrap the subject in a difThere is a method in Ruby called method_missing.
# When we call a method that is not found in a specific class or an iterface,
# Ruby will try to search for a method called method_missing in the calling object class
# and if it does not find it, it will look up in the heirarchy tree untill it finds it
# or it reaches to the Object which has a default definition for the method_missing.
# it raises an error: No method error.

# we can rewrite the proxy class as following:
# I mean, instead if repeating the addition of all the methods defined in the subject class-- 
# that needs to proxy -- in the proxy class again.We only use the below designferent proxy) or eliminate the secu-
# rity all together (just drop the proxy)

# 2- By implementing the security in a proxy, we make it easy to swap in a differ-
# ent security scheme (just wrap the subject in a different proxy) or eliminate the secu-
# rity all together (just drop the proxy)

# 3- we can minimize the chance that any important information will 
# inadvertently leak out through our protective shield.

# =======================================================================

# 2- The virtual Proxy:
# --------------------------

# In the last example, when we create the protection proxy, we had to supply the proxy with 
# a real banking account. But in case the we do not want to create the real BankAccount until the user is 
# ready to do something with it, such as making a deposit.We may need to have a virtual proxy.
# It pretends to be a real object, but it does not even have a reference to that real account
# until the client decides to call a method.

class VirtualAccountProxy
  def initialize(starting_balance = 0)
    @starting_balance = starting_balance
  end

  def deposite(amount)
    subject.deposit(amount)
  end

  def withdraw(amount)
    subject.withdraw(amount)
  end

  def subject
    @subject ||= BankAccount.new(@starting_balance)
  end
end

# The only drawback of that design is that the VirtualAccountProxy creates a bank account.
# It tangles with the BankAccount and violates the separation of concern principle.

We can solve that issue using the Ruby blocks

class VirtualAccountProxy
  def initialize(&block)
    @block = block
  end

  def deposite(amount)
    subject.deposit(amount)
  end

  def withdraw(amount)
    subject.withdraw(amount)
  end

  def subject
    @subject ||= block.call
  end
end

account = VirtualAccountProxy.new { BankAccount.new(100) }

# the virtual proxy provides us with a good
# separation of concerns: The real BankAccount object deals with deposits and with-
# drawals, while the VirtualAccountProxy deals with the issue of when to create the
# BankAccount instance.

# =========================================================================================
# Get the advantage of Ruby and build proxies better.
# ---------------------------------------------------

# There is a method in Ruby called method_missing.
# When we call a method that is not found in a specific class or an iterface,
# Ruby will try to search for a method called method_missing in the calling object class
# and if it does not find it, it will look up in the heirarchy tree untill it finds it
# or it reaches to the Object which has a default definition for the method_missing.
# it raises an error: No method error.

# we can rewrite the proxy class as following:
# I mean, instead if repeating the addition of all the methods defined in the subject class-- 
# that needs to proxy -- in the proxy class again.We only use the below design

class AccountProxy
  def initialize(real_account)
    @account = real_account
  end

  def method_missing(name, *args)
    @account.send(name, *args)
  end
end

ap = AccountProxy.new(BankAccount.new(10))
ap.deposite(10)     #====> will delegate that method to real account object.

# We an rewrite our protection proxy as following:

require 'etc'

class BankAccountProxy
  def initialize(real_account, owner_name)
    @subject = real_account
    @owner_name = owner_name
  end

  def method_missing(name, *args)
    check_access
    @subject.send(name, *args)
  end

  private

  def check_access
    if Etc.getlogin != @owner_name
      raise "Illegal access: #{Etc.getlogin} cannot access account."
    end
  end
end

# and rewrite the VirtualAccountProxy to be:

class VirtualAccountProxy
  def initialize(&block)
    @block = block
  end

  def method_missing(name, *args)
    @subject.send(name, *args)
  end

  def subject
    @subject ||= block.call
  end
end

# The real awesomeness behind the above design is not because it is only 18 lines or less of code 
# But, because it work as a proxy regardless the subject whether it is a bank account or a string.

# for example we can use the BankAccountProxy to protecct a string instead of a bank account.

bap = BankAccountProxy.new('I can go higher', 'ahmed')
bap.length  #15

# And we can use the VirtualAccountProxy with array instead of bank account nreation block 

array = VirtualProxy.new { Array.new }

array << 'Hello'
array << 'proxies'

# Proxy Pattern in the wild:
# ============================
# The most popular use for the proxy pattern in ruby happens to be in the form of remote
# proxy applications.Apart from the SOAP client, there is also the drb package
# or the Distributed Ruby package that allows ruby distributed applications to be 
# bound or connected together using the TCP/IP network.

# Let's use the distributed ruby in the sever client mode.

# Let's build a service that is located on a server and that service needs to be shared.

# server code:

require 'drb/drb'

URI = 'druby://localhost:8787'

class TimeServer
  def get_current_time
    Time.now
  end
end

SERVER_OBJECT = TimeServer.new
DRb.start_service(URI, SERVER_OBJECT)
DRb.thread.join

# Run the previous script from one terminal

# client code 

require 'drb/drb'

SERVER_URI = 'druby://localhost:8787'
DRb.start_service

time_server = DRbObject.new_with_uri(SERVER_URI)

puts time_server.get_current_time

# Run the client script from another terminal or another machine 
# on the same network and you will get the current time.
