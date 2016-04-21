echo off
%   IDDEMO MULTIVARIABLE SYSTEMS shows how to deal with data with several
%   input and output channels

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.5 $ $Date: 2001/04/06 14:21:46 $
 
clf
help iddemo9
echo on
pause % Strike any key to continue.

% We start by looking at the data set SteamEng.

load SteamEng

% This data set is collected froma laboratory scale steam engine. It has
% the inputs 
% * Pressure of the steam (actually compressed air) after the control valve.
% * Magnitization voltage over the generator connected to the output axis.
% The outputs are
% * Generated voltage in the generator
% * The rotational speed of the generator (Frequency of the generated AV voltage)
% The sampling interval was 50 ms.

pause

% First collect the measured channels into an IDDATA object:

steam = iddata([GenVolt,Speed],[Pressure,MagVolt],0.05);

steam.InputName  = {'Pressure';'MagVolt'};
steam.OutputName = {'GenVolt';'Speed'};
 
 pause, plot(steam), pause  % Strike any key to continue.
 
% A first step to get a feel for the dynamics is to look at the
% step responses between the different channels:

ms = step(steam);
pause, step(ms), pause % Strike any key to continue

% To look at the significance of the repsonses, the impulse plot
% can be used instead, with confidence regions correponding to
% 3 standard deviations:

pause, impulse(ms,'sd',3), pause % Strike any key to continue


% Apparently the response from MagVolt to Speed is not very significant
% (Compare the y-scales!)
% and the influence from MagVolt to GenVolt has not much dynamics, just a
% delay.

% A quick first test is also to look a a default state-space prediction
% error model. Use only the first half of the data for estimation:

mp = pem(steam(1:250));

% The model is as follows

pause, mp, pause  % Strike a key

% Compare with the step responses estimated directly from data:

pause,step(ms,'b',mp,'r',3), pause % Blue for direct estimate, red for mp

% The agreement is striking, except for MagVolt to Speed, which anyway is
% insignificant.

% To test the quality of the state-space model, simulate it on the part
% of data that was not used for estimation and compare the outputs:

pause, compare(steam(251:450),mp), pause % Strike a key

% Similarly, comparisons of the frequency response of mp with a spectral
% analysis estimate gives.

msp = spa(steam);

pause, bode(msp,'b',mp,'r'), pause  % Strike a key

% This data set quickly gave good models. Otherwise you often have to try
% out submodels for certain channels, to see significant influences
% The toolbox objects give full support to the necessary bookkeeping in
% such work. The InputNames and OutputNames are central for this.

% The step responses indicate that MagVolt primarily influences GenVolt while
% Pressure primarily affects Speed. Build two simple SISO model for this:

m1 = armax(steam(1:250,'Speed','Pressure'),[2 2 2 1]);
m2 = armax(steam(1:250,1,2),[2 2 2 1]); %Both names and numbers can be used

% Compare these models with the MIMO model mp:

pause, compare(steam(251:450),m1,m2,mp), pause % Strike a key

pause, nyquist(m1,m2,mp,'sd',3), pause % Nyquist plots with uncertainty regions

% The SISO models do a good job to reproduce their respective outputs.

% The rule-of-thumb is that the model fitting becomes harder when you add more
% outputs (more to explain!) and simpler when you add more inputs. To to a good
% job on the output 'GenVolt', both inputs could be used.

m3 = armax(steam(1:250,'GenVolt',:),'na',4,'nb',[4 4],'nc',2,'nk',[1 1]);
m4 = pem(steam(1:250,'GenVolt',:));

pause, compare(steam(251:450),mp,m3,m4,m2), pause % Strike a key

% About 10 % improvement was possible by including the input Pressure,
% compared to m2 that uses just MagVolt as input.

pause %strike a key

% If desired, he two SISO models m1 and m2 can be put together as one 'Diagonal' 
% model by first creating a zero dummy model:

mdum = idss(zeros(2,2),zeros(2,2),zeros(2,2),zeros(2,2));
set(mdum,'InputName',get(steam,'InputName'),'OutputName',get(steam,'OutputName'));
mdum.ts = 0.05;
 
m12 = [idss(m1),mdum('Speed','MagVolt')];    % Adding Inputs. 
                                             % From both inputs to Speed
m22 = [mdum('GenVolt','Pressure'),idss(m2)]; % Adding Inputs. 
                                             % From both inputs to GenVolt

mm = [m12;m22]; % Adding the outputs to a 2-by-2 model.

pause, compare(steam(251:450),mp,mm), pause

 %  End of demo
echo off
