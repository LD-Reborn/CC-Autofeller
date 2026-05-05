# CC-Autofeller
Computercraft turtle autofelling program

features:
- automatic felling: yes
- automatic refuel: yes
- automatic item drop-off: yes
- sapling replanting: no
- recover from reload: no
- gps: no
- networked / coordinated activation or navigation: no

## Physical setup
Place your turtle in front of an array of trees. Usually I do 2 rows of saplings at a length of about 20.

It should look like this from above:
```
# #
# #
# #
# #
# #
# #
# #
# #
# #
# #
T
C
```
- `#` = saplings
- `T` = turtle
- `C` = chest

Please make sure that
- the turtle faces the sapling
- the turtle is placed in front of the left-most tree (as seen above).

## Software setup
To install CC-Autofeller, enter this command in your turtle's CLI:
```
wget https://raw.githubusercontent.com/LD-Reborn/CC-Autofeller/refs/heads/main/feller.lua
```
Now the autofeller is available using the command `feller`.

## Usage
```
fell [depth] [width] [height]
Example: fell 20 2 12
    depth:  How long the area is (blocks)
    width:  How wide the area is (blocks)
    height: How high to fell (blocks)
```

## FAQ
### Can I place the saplings the other way around?
Yes. It would be slower because the turtle will have to turn around a lot more, but it would work.

Like this, as seen from above:
```
# # # # # # # # # #
# # # # # # # # # #
T
C
```
- `#` = saplings
- `T` = turtle
- `C` = chest

### Can I place the turtle in the middle or the right side?
No. The turtle only mines stuff that is in front of it and to the right. Everything left of it is not touched.

As seen from above - this does not work:
```
# # # # # # # # # #
# # # # # # # # # #
        T
        C
```
nor this:
```
# # # # # # # # # #
# # # # # # # # # #
                  T
                  C
```
- `#` = saplings
- `T` = turtle
- `C` = chest
### Can I use multiple turtles for a single area?
This would operate fine if both turtles are run using `feller 10 1 12`:
```
# #
# #
# #
# #
# #
# #
# #
# #
# #
# #
T T
C C
```

- `#` = saplings
- `T` = turtle
- `C` = chest
