echo on,
%   This case study concerns data collected from a laboratory scale
%   "hairdryer". (Feedback's Process Trainer PT326; See also page
%   525 in Ljung, 1999). The process works as follows: Air is fanned
%   through a tube and heated at the inlet. The air temperature is
%   measured by a thermocouple at the outlet. The input (u) is the
%   power over the heating device, which is just a mesh of resistor
%   wires. The output is the outlet air temperature (or rather the
%   voltage from the thermocouple).

echo off
%   Lennart Ljung
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2001/04/06 14:21:44 $
echo on

%       First load the data:

pause % Press a key to continue

load dryer2

%       Vector y2, the output, now contains 1000 measurements of
%       temperature in the outlet airstream.  Vector u2 contains 1000
%       input data points, consisting of the voltage applied to the
%       heater. The input was generated as a binary random sequence
%       that switches from one level to the other with probability 0.2.
%       The sampling interval is 0.08 seconds.
%       
%       First set up the data set as an IDDATA object:

dry = iddata(y2,u2,0.08);

pause % Press a key to continue

%       To get information about the data, just type the name:

dry 

pause % Press a key to continue

%       For better bookkeeping, give names to input and outputs:

dry.InputName = 'Power';
dry.OutputName = 'Temperature';

%       Select the 300 first values for building a model:

ze = dry(1:300); 

%       Plot the interval from sample 200 to 300:
 
pause,  plot(ze(200:300)), pause  % Press any key for plot.

%       Remove the constant levels and make the data zero-mean:

ze = dtrend(ze);

%       Let us first estimate the impulse response of the system
%       by correlation analysis to get some idea of time constants
%       and the like:

pause, impulse(ze,'sd',3); pause % Press a key for plot

%       The dash-dotted lines mark a 99% confidence interval. We thus see that
%       there is a time delay (dead-time) of 3 samples before the
%       output responds to the input. Adding 'fill' as an extra argument
%       gives an alterante display:

pause, impulse(ze,'sd',3,'fill'), pause

%       The simplest way to get started is to build a state-space model
%       where the order is automatically determined, using a prediction
%       error method:
%
pause,  m1 = pem(ze); %Press any key to continue.

%       Let's take a look at the model:

pause, m1     % Press any key to see model.

pause    % Press any key to continue.

%       To retrieve the properties of this model we could, e.g., find the
%       A-matrix of the state space representation by

A = m1.a

%       etc. Check IDDEMO #4 for more information about the model objects.
%       Type get(m1) to find out which properties can be retrieved.

pause   % Press any key to continue.

%       How good is this model? One way to find out is to simulate it
%       and compare the model output with measured output. We then
%       select a portion of the original data that was not used to build
%       the model, viz from sample 800 to 900:

zv = dry(800:900);
zv = dtrend(zv);
compare(zv,m1);pause

%       The agreement is quite good. 
%       The Bode plot of the model is obtained by

pause, bode(m1) % Press any key to continue

%       An alternative is to consider the Nyquist plot, and mark
%       uncertainty regions at certain frequencies with ellipses,
%       corresponding to 3 (say) standard deviations:

pause, nyquist(m1,3) % press a key to continue

%       We can also compare the step response of the model with
%       one that is directly computed from data in a non-parametric way:

pause, step(m1,ze) % Press any key to continue

%       To study a model with prescribed structure, we
%       compute a difference equation model with two poles,
%       one zero, and three delays:

m2 = arx(ze,[2 2 3]);
 
%       Let's take a look at the model:

pause, m2    % Press any key to see model.

pause    % Press any key to continue.
%       To compare its performance on validation data with m1
%       we do

compare(zv,m1,m2);pause

%       The agreement is quite good. Compute the poles and zeros of
%       the models:

pause, zpplot(m1,m2), pause    % Press any key for plot.

%       The uncertainties of the poles and zeros can also be plotted

pause, zpplot(m1,m2,3), pause % '3' denotes the number of standard deviations

%       Now display the frequency functions of the models:

pause, bode(m1,m2), pause    % Press any key for Bode plot.

%       We can compare these frequncy functions with what is obtained
%       by a non-parametric spectral analysis method:

gs = spa(ze);

%       Press a key for a comparison with the transfer function from the
%       parametric models.

pause, bode(m1,m2,gs), pause

%       The frequency responses from the three models/methods almost
%       coincide. This indicates that this reponse is reliable.
%
%       We can also study a Nyquist plot, with the uncertainy regions marked
%       at certain frequencies:

pause, nyquist(m1,m2,gs,3)

echo off
set(gcf,'NextPlot','replace');
