## Assignment Overview
This project implements an auto-vector interrupt-driven 24-hour digital clock using the Easy68K simulator. The clock is displayed on a bank of eight 7-segment displays and shows time in the format HH-MM-SS. The clock operates through a combination of an interrupt-driven service routine, a polling loop, and global memory locations for hours, minutes, and seconds. The clock can be reset back to 00-00-00 by generating a level 7 interupt through the hardware window. The clock may vary based on computer speed.

## How to use 
To run the clock open the hardware window of easy68k and set it to generate an auto-vectored interupt every 16 milliseconds (1/60) of a second. Each interupt will decrement a counter set to 60 and after it reaches 0 this indicates 1 second has passed and the polling loop will write the new time into the 7 segment display. Reset the clock by clicking the level 7 auto vectored interupt button at any time. You may slow down or speed up the clock based on the ms rate selected.

## View of the hardware window
<img width="314" alt="image" src="https://github.com/user-attachments/assets/60eb4495-7d5f-4409-8a65-4baa9a1797d1" /> 
