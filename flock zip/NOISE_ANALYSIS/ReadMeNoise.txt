          Noise Reduction in the Bird's Position and Orientation Measurements 
                                 11/04/04



Purpose:

The purpose of these computer programs is to determine the optimum Bird measurement rate for
minimizing noise in its position and orientation measurements.




Background:


The Bird's sensor is used to measure the magnetic field transmitted by the Bird's transmitter. 
Unfortunately the sensor cannot discriminate between the transmitted magnetic field and any
other magnetic fields that may be present in the user's environment.  These "other" magnetic
fields cause the Bird's position and orientation measurements to change with time even though
the sensor isn't moving.  Sources of "other" magnetic fields are the power lines in the building,
motors, pumps, elevators, computer displays, power transformers...... anything that uses electrical
power and is located near the Bird and generates signals in the frequency band of 0 to 3 KHz will
result in Bird measurement jitter. If the interfering noise sources do not change their frequency of
operation then these interfering frequencies can be measured and a Bird measurement rate
determined that minimizes the effects of this noise.  The attached computer programs run your
Bird in a mode that measures the interfering noise and determines this best measurement rate.




Hardware/Software Requirements:


1.  An Ascension Bird product that uses an RS232 port to communicate with your host computer. 
These products are: Flock of Birds, MiniBird, Nest of Birds, and Wired MotionStar without the
ethernet interface.

2.  The Bird product must have a Prom Memory software revision number of at least 3.50

3.  The Bird product must have a computer crystal speed of at least 40 MHz.

4.  You must run the Bird's RS232 port at a baud rate of 115K baud.

5.  The RS232 port must be attached to a Bird that is configured either as a Stand Alone or
Master unit with a sensor attached to that unit. 

6.  Your computer that is running the attached programs must use a MicroSoft Windows
operating system.


7.  You must close all windows on your computer so that the attached programs can collect data
from the Bird at maximum speed.

8.  You must be disconnected from any computer network otherwise the program will not run
fast enough to continuously collect data at high speed.

9.  All of the following programs must reside in the same directory on your computer. There are
no drivers to install in the operating system.  The programs are:

a.  RunNoiseCollect.exe
b. RunNoiseCollect.cwc
c. Run NoiseAnalysis.exe
d. RunNoiseAnalysis.cwc
e. NoiseCollect.exe
f. NoiseAnalysis.exe
g. CT_Std.dll
h. CT_Std.inc
i. GfxT_Pro.dll
j. GfxT_Pro.inc





Bird Setup:


1.  Verify that the Bird's dip switches are set for Stand Alone operation at 115K baud by
following the instructions in the Ascension User manual for your Bird product.

2.  Preferably use an RS232 cable with all connector pins present so that the computer program
can reset the Bird as required.

3.  Attach the other end of the RS232 cable to an available COM port on your computer

4.  Turn the Bird's power on. 

5. Position the sensor anywhere in the area where it will be used.

6.  Orientation of the sensor is not important.

7.  Do not put the sensor on the transmitter or on the floor or on any other object that may contain
metal.

8.  Make sure the sensor won't move during measurements.  Place a non-metallic object on the
sensor, if necessary, to make sure the sensor doesn't move.




Running the Program:


There are several different ways to start the programs.  The RunNoiseCollect.exe and
RunNoiseAnalysis.exe programs are front end startups that deal with varying resolution screen
settings to give a large screen on all window's systems.  Alternatively you could just click on
NoiseCollect.exe or NoiseAnalysis.exe to run the programs but you may have a small window if
your screen is being run at high resolution. The NoiseCollect program links directly to
NoiseAnalysis when it is done collecting data.  Similarly if you started up in NoiseCollect,
automatically linked to NoiseAnalysis and then select the option to return, you'll be
automatically linked back to NoiseCollect.  

1.  With your mouse click on the program RunNoiseCollect.exe

2.  The initial copyright screen will turn to a menu screen after a few seconds        

3.  Enter a 0 or just carriage return to select the default Environmental noise analysis to determine
best Bird operating speed

4.  You can carriage return to select the default baud rate of 115,200.  You must select this.

5.  Enter the COM port number of your RS232 port.  The default is COM1

6.  The program will then go out and establish communications with the Bird and display
software revision number, CPU crystal speed, and operating range scaling. If these aren't
displayed in a fast manner then you're Bird is probably flashing an error, you're at the wrong
baud rate, wrong COM port, or your RS232 cable is loose.

7.  Hit any key to continue unless and error condition.  If data errors make sure the sensor isn't on
any metal and that your computer is disconnect from any computer network.

8.  Sensor set up instructions are then displayed.  Hit any key to continue.

9. Hit any key to start collecting noise data from the Bird.  It takes about 10 seconds to collect the
data..

10.  When prompted hit any key to continue after the data is collected

11. You'll get a message that the Bird is rebooting.  If you only have an RS232 cable with 3 pins
then the Bird won't reboot.  Buts its not critical here unless you come back and want to run other
features of this program to verify the noise reduction.

12.  Enter a 0 or just carriage return to select the default Analyze the noise for best measurement
rate.

13.  Enter a 0 or carriage return to select Fast Analysis

14.  Carriage return to select the default data file of SENSORnoise.dat that contains the Bird
noise data collected above.

15.  Important.  You must know what the frequency of the power lines are in your country.  In the
United States its 60 Hz.  In many parts of the rest of the world its 50 Hz.  If you don't know, find
it out because this program will give wrong noise information if its not correctly selected.  The
Bird itself assumes you're a 60 Hz power user.  If you're a 50 Hz user then you must use the
Change Value Filter Line Frequency command to configure your Bird correctly before you
operate it with the optimum measurement rate recommended by this program.
Enter a 0 to select 60 Hz power, or 1 for 50 Hz power.

16.  The program then displays a WAIT sign for about 15 seconds, longer or shorter depending
on the speed of your computer while it determines the best measurement rates.

17. Before it displays the measurement rate list it asks if you want to save the list to a file.

18.  The program then displays a list of a few hundred measurement rates verses noise figure
ordered from the best measurement rate with the lowest noise figure to the worst measurement
rate at the bottom of the screen.  These are for Bird measurement rates in the range of 80 to 140
measurements per second.  If you want another range of measurement rates you'll have to exit
with a key hit of Q and select the Engineering Menu and work your way through the menu items.

 A scroll bar will have appeared on the right side of the screen.  Use your mouse to scroll to the
top of the screen.  The first Bird measurement rate listed will give you the best noise
performance.  There are probably several rates with similar small noise figures.  All of these rates
will give you similar performance.  You have a trade-off to do.  If you want good dynamic
performance in addition to low noise then pick the highest Bird measurement rates in the list.  If
you want better conductive metal distortion rejection then you'll want to select a lower Bird
measurement rate. As the noise figure increases, so will your Bird noise.  

A scroll bar may not appear in some Windows operating systems depending on how the system is
configured.  If this is the case you'll either need to rerun the case and select the option that saves
the list to a file or hit the P key to plot the data and read the measurement rate to use from the
lowest point on the plot.

19.  You can get a visual picture of the measurement rate verses noise by hitting the P key for a
plot of the data.  Or you can hit Q to return to the previous menu.  Once you have a plot on the
screen you can print the plot by hitting the P key or hit the S key to save a bitmap image of the
plot to a file.  When you hit the P key to print the plot a  printer window will open for you to
select the printer and graph orientation on the paper.

20.  To put this information into your Bird you'll need to send the selected Bird measurement
rate with the Change Value Bird Measurement Rate Parameter 7 command.  Don't forget to also
set the line frequency if you have 50 Hz power using the Change Value Filter Line frequency
Parameter 20 command.  You'll need to send these commands every time you power up your
Bird or reset it since it has no non-volatile memory.

21.  You can check these values out in your Bird by selecting the menu item "Return to the
BirdNoiseCollect program for running the Bird" or, when you're out of the program click on the
program RunBirdNoiseCollect.exe

22.  In the BirdNoiseCollect program at the first screen menu select Bird Operation (1)

23.  Then select the baud rate and com port which should be the same as when you collected the
noise data.

24.  Select Standalone system (0)

25. Select do echo/ok test ? No(0)

26.  The system then reads from the Bird some system info and prints it on the screen.  Hit
carriage return.

27.  Select running std bird (0)

28.  To see the Bird's position and angles enter 4
     for noise statistics enter 1
            To print the statistics on the screen enter 1
            If you want a number of samples other than 2000, enter the number
            It will take a while for the first statistics to appear.
            To stop the printing of statistics hit any key.  It will take a while to respond when it
             finishes the next statistics print out

29.   To change the Birds measurement rate to the best value determined by the noise collection
routine, select menu item 15 - change value.  Then select item 7 to change the measurement rate. 
Then enter the measurement rate, for example, 122.64. With a carriage return

30.  To see how this improves the noise statistics repeat starting at step 28 above.

31.  To change the power line frequency from the default 60 Hz to 50 Hz
select the change value menu 15, then select item 20, the filter line frequency, then enter 50 for
50 Hz power and carriage return.  



