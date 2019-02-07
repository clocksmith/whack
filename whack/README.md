# Overview

This is a flutter clone of the popular "whack a gator" arcade game.

Tap the green gators as they come out to whack them. There is no score,
but can you whack them all? Since the actual game only has 1 hammer,
try to do it with only 1 finger!

# Code

## Sequence
The `Sequence` class defines which alligators come out and when they appear. It
is effectively a list of `Event` instances and a duration. Each event has a time and an index.
The time indicates how many milliseconds that the gator is delayed by and the index
specifies which alligator. It is pretty easy to define a custom sequence, or alter the
speed of the original sequence.

The current sequence imitates the actual game with the following 5 waves:

Wave 1 is 5 single gators.
Wave 2 is 5 pairs of gators.
Wave 3 is 4 triples of gators.
Wave 4 is 8 continuous staggered gators followed by 12 faster continuous staggered gators.
* Now I'm angry *
Wave 5 is 30 extremely fast continuous staggered gators.

## Graphics
The graphics are painted with a single `CustomPainter`. In the non 5kb version,
the body and head of the alligator can be easily swapped out with custom drawings
or preloaded images.

## Mechanics
The hit behavior uses a simple `GestureRecognizer` on the render box of the Game.
Each gator's hit box is the body (rectangle) plus the head (circle).

## Sound
The sound is played through the `audioplayers` dart package.
I recorded myself for the one and only sound effect.

# 5kb tricks
The following are things done only because it was a 5kb challenge. If the code were
not subject to these limits, these things would not be done:

* Shortening variable names. For example radius -> r, width -> w, positions -> xs, etc.
* Removing `final` from all final variables.
* There is some math duplicate logic in the hit box and painter. This is because piping shared
variables actually takes up more kb.
* Removing abstract graphics painting.
* No score keeping.
* No start game / end game, app must be killed and re-opened.