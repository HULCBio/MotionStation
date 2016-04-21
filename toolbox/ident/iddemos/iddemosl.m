echo on,
%   This demo illstrates how models simulated in simulink can be 
%   identified using the SITB. It also describes how to deal with
%   continuous time systems and delays, as well as the importance of the 
%   intersample behaviour of the input.

pause  % Strike a key to continue

echo off
%   Lennart Ljung
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $ $Date: 2004/04/10 23:16:09 $
if isempty(findstr(matlabpath,'simulink'))
   error('This demo requires SIMULINK')
end
f = figure;

echo on

%   Consider the system decribed by the following SIMULINK scheme.
 
open_system('iddemsl1')
set_param('iddemsl1/Random Number','seed','0')

%   The red part is the system, the blue part is the controller and
%   the reference signal is a swept sinusoid (a chirp signal).
%   The data sampling time is set to 0.5 seconds.

pause  %Strike a key to continue

%   The system can in terms of SITB objects be described by

m0 = idpoly(1,0.1,1,1,[1 0.5],'Ts',0,'InputDelay',1,'NoiseVariance',0.01);

pause   % Strike a key to continue

m0

pause, sim('iddemsl1') % Strike a key to simulate

dat1e = iddata(y,u,0.5); % The IDDATA object

set_param('iddemsl1/Random Number','seed','13')
%   Two different simulations are made, the second one for
%   validation purposes.
sim('iddemsl1') 
dat1v = iddata(y,u,0.5); 

pause, plot(dat1e)   % Strike a key to look at the data

m1 = pem(dat1e);     % A default order model
pause, m1            % Strike a key to look at the model 

pause,             % Check how well the model reproduces the 
                   % validation data

compare(dat1v,m1)

pause,   % Strike a key to look at the non-parametric
% impulse response estimate.

impulse(dat1e,'sd',3);

%   Influences from negative lags are indicated. This is due to the
%   regulator (output feedback). This means that the impulse response
%   estimate cannot be used to determine the time delay.
%   Instead, build several low order ARX-models with different delays
%   and find out the  best fit:

pause  % Strike a key to continue

V = arxstruc(dat1e,dat1v,struc(1:2,1:2,1:10));
nn = selstruc(V,0)

%   The delay is determined to 3 lags. (This is correct: the deadtime of
%   1 second gives two lag-delays, and the ZOH-block another one.)
%   The corresponding ARX-model can also be computed.

pause  % Strike a key to continue

m2 = arx(dat1e,nn)
compare(dat1v,m1,m2);
pause

%   The two models behave similarly in simulation. Let's now try and fine tune
%   orders and delays. Fix the delay to 3, and find a default order state-space
%   model with that delay:

m3 = pem(dat1e,'nk',3);

pause, m3.a  % The A-matrix of the resulting model

%   A third order dynamics is automatically chosen, which together with the
%   2 "extra" delays gives a 5th order state space model.

%   It is always advisable not to blindly reply upon automatic order choices.
%   They are influenced by random errors. A good way is to look at the model's
%   zeros and poles, along with confidence regions:

pause, zpplot(m3,'sd',2) % Confidence region corresponding to 2 standard deviations

pause  % Strike a key to continue

%   Clearly the two poles/zeros at the unit circle seem to cancel, indicating 
%   that a first order dynamics might be sufficient.

m4 = pem(dat1e,1,'nk',3);

compare(dat1v,m4,m3,m1)

%   The compare plot shows that the simple first order model m4 with delay 3
%   gives a very good description of the data. Thus select this model.

pause  % Strike a key to continue.

%   Convert this model to continuous time, and represent it in transfer
%   function form (if you have the CSTB)

mc = d2c(m4);
if exist('lti')
   tf(mc('m')) % 'm' means that only the measured input is considered 
else
   mc('m')
end

%   A good decription of the system has been obtained.

pause   % Strike a key to continue

%   The continuous time model can also be estimated directly, in a canonical
%   state-space form, by the following command:

m5 = pem(dat1e,1,'nk',3,'ts',0,'ss','can');

pause   % Strike a key to continue

if exist('lti')
   tf(m5('m'))
else
   m5('m')
end

pause  % Strike a key to continue

%   To consider the uncertainty of the tranfer functiom parameters,
%   the state-space model can be converted to polynomial form, and
%   displayed with parameter standard deviations by

pause, present(idpoly(m5))

pause % Strike a key to continue

%   The model's step and frequency responses can be compared with
%   the true system m0:

step(m5,m0),pause
bode(m5,m0,'sd',3)

%   The agreements are very good

pause % Strike a key to continue

%   When comparing continuous time models computed from sampled data, it
%   is important to consider the intersample behavviour of the input signal.
%   In the demo so far, the input to the system was piece-wise constant, 
%   due to the Zero-order-Hold (zoh) circuit in the controller. Now remove
%   this circuit, and consider a truly continuous system. The input and output
%   signals are still sampled a 2 Hz, and everything else is the same:

pause, open_system('iddemsl3')

pause % Strike a key to simulate this system
sim('iddemsl3')
dat2e = iddata(y,u,0.5);

pause % Strike a key to continue

%   Discrete time models will still do well on these data, since when they
%   are adjusted to the measurements, they will incorporate the sampling
%   properties, and intersample input behaviour (for the current input.)
%   However, when building continuous time models, knowning the intersample 
%   properties is essential. First build a model just as for the ZOH case:

pause, m6 = pem(dat2e,1,'nk',3,'ts',0,'ss','can'); %Strike a key to estimate
if exist('lti')
   tf(m6('m'))
else
   m6('m')
end

pause, step(m6,m0)  % Compare with true system

%   The agreement is now not so good. We may, however, include in the
%   data object information about the input. As an approximation, let it
%   be described as piecewise linear (First-order-hold, FOH) between the
%   sampling instants. This information is then used by the estimator for
%   proper sampling:

pause % Strike a key to continue

dat2e.Intersample = 'foh';
m7 = pem(dat2e,1,'nk',3,'ts',0,'ss','can');

pause, % Strike a key to continue
if exist('lti')
   tf(m7('m'))
else
   m7('m')
end

pause, step(m7,m0)  % Compare with true system

%   This gives a much better result.

%   End of demo
pause
echo off
bdclose('iddemsl1');
bdclose('iddemsl3');
close(f)





