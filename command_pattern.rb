# Assuming that we are building a GUI framework that has so many buttons for example doing so many 
# function.And we have our Button class like below:

class Button
  # tens of lines related to the 
  # styling and so on

  def on_push_button
    # do something 
  end
end

# * our button class will be instantiated and thousands of instances of the same button will be created.
#   And each will have a specific task to do according to the business.

# * One dummy solution is to use inheritance and create a button for each task like below:

class SaveButton < Button 
  def on_push_button
    # save document
  end
end

class NewDocumentButton < Button
  def on_push_button
    # create new document
  end
end

# This solution is dummy, because we may need hundreds of diffrent buttons.

# -------------------------------------------------------------------------

# An easier way to do that:
# ==========================

# We need to remember one the most important principles mentioned before:

# "Separate out the things that change from those that stay the same."

# we want to bundle up the code to handle
# the button push or menu selection in its own object—an object that does nothing but
# wait to be executed and, when executed, goes out and performs an application-specific
# task.

# These packages of action are the commands of the command pattern.

# To apply the Command pattern to our button example, we simply store a com-
# mand object with each button.

class Button
  attr_accessor :command 

  def initialize(command)
    @command = command 
  end

  def on_push_button
    @command.excute if @command
  end
end

class SaveCommand 
  def excute
    # save the document
  end
end

save_button = Button.new(SaveCommand.new)

# The connection between the button and the command is a runtime connection, so the button needs to have a
# reference to the command.And, we can change the command on the fly and change the bahavior or function
# consequently.

# ----------------------------------------------------

# code blocks as commands.
# ==========================

# It is clear now that commands are only wrappers around some code that has onw thing to do 
# and the only reason for its existence is to run code at the right time.
# This is the difinition of code block.

class Button
  attr_accessor :command 

  def initialize(&block)
    @command = block 
  end

  def on_push_button
    @command.call if @command
  end
end

new_button = Button.new do
  # save the document
end 

# If the command is just a simple code that is waiting to run upon request, then it is better
# to use the Proc objects and if the command excutes some complex code that changes so many states for
# example, then it is better use the command pattern.
# ---------------------------------------------------------

# Commands That Record
# =========================
# Command pattern can be useful in keeping track of what you have already done.

# Assuming that we are building an installtion program that installs soe code to your device.
# This installation program may have some tasks like, creating new files, copying them or even deleting some files.
# And they need to tell the user about what is the current running procrss or comand or even what has been done.
# It is better here to have our command interface class with a description about the command.

class Command 
  attr_reader :description

  def initialize(description)
    @description = description
  end

  def excute 
  end
end

def NewFileCommand < Command
  def initialize(path, contents)
    super("Make a new file ate the path: #{path}")
    @path = path 
    @content = content
  end

  def excute
    f = File.open(@path, "w")
    f.write(@content)
    f.close
  end
end

def DeleteFileCommand < Command
  def initialize(path)
    super("Deleteing file at path: #{path}")
    @path = path
  end

  def excute
    File.delete(@path)
  end
end

def CopyFileCommand < Command
  def initialize(source, target)
    super("Copying File from #{source} to #{target}")
    @source = source
    @target = target
  end

  def excute
    FileUtils.copy(@source, @target)   #File Utility methods.
  end
end

# Here we are interested in tracking what we are doing during , before or even after the software installation.
# We need to wrap all the previous command in an interface that looks like a command and has 
# sub commands underneath.It looks like we a composite of command.

class CompositeCommand < Command 
  def initialize
    @commands = []
  end

  def add_command(command)
    @commands << command
  end

  def description
    description = ''
    @commands.each { |c| description += c.description }
    description
  end

  def excute
    @commands.each {|c| c.excute }
  end
end

cmds = CompositeCommand.new 
cmds.add_command(NewFileCommand.new(file.txt, "Hello World"))
cmds.add_command(CopyFileCommand.new(file.txt, file2.txt))
cmds.add_command(DeleteFileCommand.new(file.txt))
cmds.excute

# Here we can get the description of all the installation process by:

puts cmds.description

# Also, we can get the description at any moment of the installation process, 
# by asking each excute command to print its description.

# --------------------------------------------------------

# Getting Things Done with Commands

# Undoing changes done by human or even software is a necissity nowadays.
# Undoing changes for example can be found in so many applications like the text editors for example.
# All database transaction can be rolled back.This is a sort of undoing.
# Undoing some change can be done by keeping track of the state of the object in the context 
# of change before and after the change.This can be a tedious and dummy operation in case of file having thousands of lines.

# We can use the command pattern to simply represent the undo operation, since it is simply a command and 
# it is the reverse operation of the excution of a command.
# so, for each command having excute method, we cam implement the unexcute method too.
# In the case of software installation example, we can implement like so:

def NewFileCommand < Command
  def initialize(path, contents)
    super("Make a new file ate the path: #{path}")
    @path = path 
    @content = content
  end

  def excute
    f = File.open(@path, "w")
    f.write(@content)
    f.close
  end

  def unexcute
    File.delete(@path)
  end
end

# To make the undo of the delete file command, we need to keep the contents of file 
# before delete in a separate or temp directory.For simplicity, we will take the copy 
# in memory.

def DeleteFileCommand < Command
  def initialize(path)
    super("Deleteing file at path: #{path}")
    @path = path
  end

  def excute
    @conetent = File.open(@path)
    File.delete(@path)
  end

  def unexcute
    f = File.open(@path, "w")
    f.write(@content) if @content 
    f.close
  end
end

def CopyFileCommand < Command
  def initialize(source, target)
    super("Copying File from #{source} to #{target}")
    @source = source
    @target = target
  end

  def excute
    @target_exist? = File.exist?(@target) #if exists, copy file to it, else, create one and copy
    FileUtils.copy(@source, @target)   #File Utility methods.
  end

  def unexcute
    if @target_exist?
      File.open(@target, 'w') { |f| f.truncate(0) }
    else
      File.delete(@target)
    end
  end
end

# also unexcute can be implemented in the composite command like below:

class CompositeCommand < Command 
  def initialize
    @commands = []
  end

  def add_command(command)
    @commands << command
  end

  def description
    description = ''
    @commands.each { |c| description += c.description }
    description
  end

  def excute
    @commands.each {|c| c.excute }
  end

  def unexcute
    @commands.reverse.each { |c| c.unexcute }
  end
end

# "The key thing about the Command pattern is that it separates the thought from
# the deed. When you use this pattern, you are no longer simply saying, “Do this”;
# instead, you are saying, “Remember how to do this,” and, sometime later, “Do that
# thing that I told you to remember.” "
# ----------------------------------------------------------------------------------------

# Command Pattern in the wild:
# =============================

# 1- Active Record Migrations:
# ==============================

# ActiveRecord comes equipped with a classic example of an undo-able Command
# pattern implementation in the form of its migration facility.

# The beauty of migrations lies in the fact that you can step your database schema 
# forward or backward in time by either doing (up-ing?) or undoing (down-ing?) the migrations.

class CreateBookTable < ActiveRecord::Migration
  def self.up             #Command excute
    create_table :books do |t|
      t.column :title, :string
      t.column :author, :string
    end
  end

  def self.down    #Command unexcute
    drop_table :books
  end
end


Pending:
We need to read about Madeleine and Marshal and how they use the command pattern.





