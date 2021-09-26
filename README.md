# Snake Boxer Collection

A series of games based on the marginally popular [Snake Boxer](http://www.hrwiki.org/wiki/Snake_Boxer) series in Homestar Runner.

### Snake Boxer 1

![Snake Boxer 1](https://github.com/daniel-tran/snake-boxer-collection/raw/main/SnakeBoxer1.gif)

```
Defend the deli against the Snake Mafia,
using nothing but your fists and your
wits (or what's left anyway)!
   They'll stop at nothing until the
deli is reduced to nothing but rubble!
```

### Snake Boxer 2: The Biting of Boxer Joe

![Snake Boxer 2](https://github.com/daniel-tran/snake-boxer-collection/raw/main/SnakeBoxer2.gif)

```
Survive against the onslaught of snakes
and collect food items, whilst
avoiding avoiding bombs and arrows.
   Score big and be remembered as a
legendary snake boxing hero of old!
```

### Snake Boxer 3: Solving Problems Through Diplomacy

![Snake Boxer 3](https://github.com/daniel-tran/snake-boxer-collection/raw/main/SnakeBoxer3.gif)

```
Punch snakes and earn diplomacy!
   Climb the political ranks and
participate in arbitrary global
activities!
   Do you have what it takes to become
the best diplomat in Free Country, USA?
```

### Snake Boxer 4: Lady Snake Parade

![Snake Boxer 4](https://github.com/daniel-tran/snake-boxer-collection/raw/main/SnakeBoxer4.gif)

```
Escape from the Lady Snake Parade
... in space!
   Try to outrun the inevitable by
playing various minigames!
```

### Snake Boxer 5

![Snake Boxer 5](https://github.com/daniel-tran/snake-boxer-collection/raw/main/SnakeBoxer5.gif)

[From page 1 of the "Snake Boxer 5" video game manual](http://www.hrwiki.org/wiki/Snake_Boxer_5):
```
After failing to lead the Lady Snake
Parade into space, Boxer Joe returns
to his roots as a New York deli owner.
   It isn't long, however, before the
local Snake Mafia learns of his
return and forces him back into
the ring!
   How long can you last against
wave after wave of deadly snakes,
and can you unlock Boxer Joe's
deadly secret before it's too late?
```

### Snake Boxer 6: Now The Snakes Have Fists Too

![Snake Boxer 6](https://github.com/daniel-tran/snake-boxer-collection/raw/main/SnakeBoxer6.gif)

```
Choose your fighter and defeat
opponents across the world!
   Or test your skills in a 1-on-1
knockout match!
   Who is that mysterious fighter
waiting for you in Denmark?
```

## Available Platforms

These games should be playable on any platform where [Processing](https://processing.org/download) can be installed.

## FAQ

### Why use Processing?

A couple of reasons made Processing an appealing tool to use for building these games with, at least initally:

- Processing is built on top of Java, so it should be fairly portable between different operating systems.
- Easy to build for both the PC and mobile devices using the same code base.
- The ability to port the code base into a proper Java game engine is always possible, since the sketches can be compiled into Java code.

### No sound effects?

At the moment, there's [a known problem](https://github.com/processing/processing-sound/issues/70) in the Processing Sound library that does not enable sound to be played from sketches on certain Android versions. Adding sound effects may be revisited once that issue is resolved in a way that supports sketches on both Android and PC.

### Can I play the Forbidden Mode in "Snake Boxer 5"?

From experience with playing "Snake Boxer 5" in "Strong Bad's Cool Game for Attractive People", the Forbidden Mode makes the game substantially easier. Furthermore, there wasn't any downside in playing in Forbidden Mode, so this makes playing in the normal mode superfluous (at least in terms of achieving the maximum awesomeness score) once the secret code is known for the Forbidden Mode.

For those reasons, "Snake Boxer 5" in this version does not include a Forbidden Mode.

### Where can I find technical documentation on the games?

You can find that sort of information on [the repository wiki](https://github.com/daniel-tran/snake-boxer-collection/wiki).
