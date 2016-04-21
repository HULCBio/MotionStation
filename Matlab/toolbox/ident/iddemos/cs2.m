echo on
% CASE STUDY # 2 ANALYSING A SIGNAL FROM A TRANSFORMER
%
% In this case study we shall consider the current signal from the
% R-phase when a  400 kV three-phase transformer is energized.
% The measurements were performed by Sydkraft AB in Sweden.

echo off
%   Lennart Ljung
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2001/04/06 14:21:46 $
echo on

load current.mat

% Form the IDDATA object:

i4r = iddata(i4r,[],0.001);  % Second argument empty for no input
% The sampling interval is 1 ms.
% Let's take a look at the  data.

pause, i4r, plot(i4r),pause

% A close up:

pause,plot(i4r(201:250)),pause

% Let us first compute the periodogram:

ge = etfe(i4r);
 
pause,bode(ge),pause

% A smoothed periodogram is obtained by

ges=etfe(i4r,size(i4r,1)/4); 

% A plot with linear frequency scale  is given by

pause, ffplot(ges),grid, pause

% We clearly see the dominant frequency component of 50 Hz, and its harmonics.

% Comparing with the pure periodogram gives:

pause, ffplot(ges,ge),pause

% The standard spectral analysis estimate gives (with the default window 
% size, which is not adjusted to resonant spectra)

gs =  spa(i4r);
 pause,ffplot(gs,ges),pause

% We see that a very large lag window will be required to see all the fine
% resonances of the signal. Standard spectral analysis does not work well.

% Let us instead compute spectra by parametric AR-methods. Models of 2nd
% 4th and 8th order are obtained by

t2=ar(i4r,2); 
t4=ar(i4r,4); 
t8=ar(i4r,8); 
 
% Let us take a look at the spectra:

pause,ffplot(t2,t4,t8,ges),pause

% We see that the parametric spectra are not capable of picking up the
% harmonics. The reason is that the AR-models attach too much attention to
% the higher frequencies, which are difficult to  model. (See Ljung (1999)
% Example 8.5)
% We will have to go to high order models before the harmonics are picked
% up.

% What will a useful order be?

V=arxstruc(i4r(1:301),i4r(302:601),[1:30]'); % Checking all order up to 30
pause,nn=selstruc(V,'log');

% We see a dramatic drop for n=20, so let's pick that order

t20=ar(i4r,20); 
pause,ffplot(ges,t20),pause

% All the harmonics are now picked up, but why has the level dropped?
% The reason is that t20 contains very thin but high peaks. With the
% crude gitter of frequency points in g20 we simply don't see the 
% true levels of the peaks. We can illustrate this as follows:

g20c = idfrd(t20,[551:650]/600*150*2*pi); % A frequency region around
                                             % 150 Hz

pause,ffplot(ges,t20,g20c),pause

% If we are primarily interested in the lower harmonics, and want to
% use lower order models we will have to apply prefiltering of
% the data. We select a fifth order Butterworth filter with cut-off
% frequency at 200 Hz. (This should cover the 50, 100 and 150 Hz modes):

i4rf = idfilt(i4r,5,200/500);% 500 Hz is the Nyquist frequency

t8f=ar(i4rf,8);  

% Let us now compare the spectrum obtained from the filtered data (8th
% order model) with that for unfiltered data (8th order) and with the
% periodogram:

pause,ffplot(t8f,t8, ges),pause

% We see that with the filtered data we pick up the three first peaks in
% the spectrum quite well. 

% We can compute the numerical values of the resonances as follows:
% The roots of a sampled sinusoid of frequency om are located on
% the unit circle at exp(i*om*T), T being the sampling interval. We
% thus proceed as follows:

pause, a = t8f.a % The AR-polynomial
omT=angle(roots(a))'
freqs=omT/0.001/2/pi'  % In Hz
pause

% We thus find the harmonics quite well.  We could also test how well
% the model t8f is capable of predicting the signal, say 50 ms ahead:

pause,compare(i4rf,t8f,50,201:500);pause

% If we were interested in the fourth and fifth harmonics (around
% 200 and 250 Hz) we would proceed as follows:

i4rff=idfilt(i4r,5,[150 300]/500);
t8f=ar(i4rff,8);  
pause,ffplot(ges,t8f),pause

% We thus see that with proper prefiltering, low order parametric models
% can be built that give good descriptions of the signal over desired
% frequency ranges.

% What would the 20th order model give in terms of estimated harmonics:

pause,a = t20.a  % The AR-polynomial
omT=angle(roots(a))'
freqs=omT/0.001/2/pi'  % In Hz
pause

% We see that this model picks  up the harmonics very well.
% This model will also predict as follows:

pause,compare(i4r,t20,50,201:500);pause

% For a complete model of the signal, t20 thus is the natural choice,
% both in terms of finding the harmonics and in prediction capabilities.
% For models in certain frequency ranges we can however do very well
% with lower order models, but we then have to prefilter the data
% accordingly.

pause
echo off

