#Stateful Designed Classes

When designing certain kinds of classes it can be very useful to have a map or chart of all the potential States that might exist for the class.  Not only all the states but also how they are allowed to transition between them.  Quite often just the exercise of thinking up the States and their transitions will help you design the class more thoughtfully.  __Stateful__ gives you mechanic and then reinforces by preventing any invalid state changes.  In addition, __Stateful__ also allows you to have specific implementations by state (ie the doThat (™) method might behave different if your class is "loaded" and not "processing").

# Install

npm install stateful

#Usage

For now, view the example in examples/foo.coffee for a quick glimpse of how to set up a __Stateful__ class.  