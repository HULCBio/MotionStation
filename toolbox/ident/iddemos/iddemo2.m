echo on

%   In this example we compare several different methods of
%   identification.

echo off
%   Lennart Ljung
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.9 $ $Date: 2001/04/06 14:21:44 $
echo on

%       We start by forming some simulated data.  Here are the
%       numerator and denominator coefficients of the transfer
%       function model of a system:

B = [0 1 0.5];
A = [1 -1.5 0.7];

%       These can be put into the model object used by
%       the toolbox:

m0 = idpoly(A,B,[1 -1 0.2]);

%       The third argument, [1 -1 0.2], gives a characterization
%       of the disturbances that act on the system.

pause   % Press any key to continue.


%       Now we generate an input signal U, a disturbance signal E,
%       and simulate the response of the model to these inputs:

u = idinput(350,'rbs'); % A random binary signal of length 350
u = iddata([],u);
e = iddata([],randn(350,1)); % White Gaussian noise with unit variance
y = sim(m0,[u e]) % Both u and y are now IDDATA objects

%       Collect the input/output data as an IDDATA data object: 

z = [y,u];

pause, z  % Press any key to get information about the data.

%       Plot first 100 values of the input U and the output Y.

pause, plot(z(1:100)), pause  % Press any key for plot.

%       Now that we have corrupted, simulated data, we can estimate models
%       and make comparisons.  Let's start with spectral analysis.  We
%       invoke SPA which returns a spectral analysis estimate of
%       the frequency function and the noise spectrum:

GS = spa(z);

pause, bode(GS), pause   % Press any key for plot.

pause, bode(GS,'sd',3,'fill') % Showing the uncertainty (3 standard deviations)

%       We start with a default model (state-space model computed
%       by a prediction error method:

m = pem(z);

pause, m, pause   % Press any key to present results.

%       Now use the Least Squares method to find an ARX-model with
%       two poles, one zero, and a single delay on the input:

a2 = arx(z,[2 2 1]);

pause, a2, pause   % Press any key to present results.


%       Now use the instrumental variable method (IV4) to find a model
%       with two poles, one zero, and a single delay on the input:

i2 = iv4(z,[2 2 1]);


pause, i2, pause     % Press any key to present results.

%       Show Bode plots comparing the Spectral Analysis
%       estimate with the ARX and IV4 estimates:

pause, bode(GS,m,a2,i2), pause  % Press any key for plots.

%       To set the line markers use

pause, bode(GS,'b',m,'m',a2,'g',i2,'k'), pause  % Press any key for plots.


%       Calculate and plot residuals for the model obtained by IV4:

resid(z,i2);  %Plots the result of residual analyssi
pause, resid(z,i2,'fr') % presents the result in the frequncy domain.
e = resid(z,i2); pause % Just computes the residuals
plot(e(:,1,[])), % e(:,1,[]) selects all samples, output #1 and no inputs
title('Residuals, IV4 method'), pause


%       Now compute second order ARMAX model:

am2 = armax(z,[2 2 2 1]);

pause   % Press any key to continue.

%       Now compute second order BOX-JENKINS model:

bj2 = bj(z,[2 2 2 2 1]);

%       Compare the frequency functions with those obtained by the
%       PEM method and the spectral analysis method:

pause   % Press any key for plots.

bode(am2,bj2,m,GS), pause

%       % To compare the noise spectra:

bode(am2('noise'),bj2('n'),m('n'),GS('n')), pause,

%       Plot residuals for the ARMAX and BOX-JENKINS models

resid(z,am2); pause
resid(z,bj2); pause

%       Compare the BJ model with the ARMAX model and with the 
%       default PEM model:

compare(z,bj2,am2,m); pause

%       Now we'll compute the poles and zeros of the ARMAX and
%       BOX-JENKINS models

pause, zpplot(am2,bj2), pause, % Press a key for plot

% Clearly, AM2 and BJ2 both give good residuals and simulated outputs.
% They are also in good mutual agreement. Let's check which has the
% smaller AIC (Akaike's  AIC-criterion):

[aic(am2), aic(bj2)]
pause   % Press any key to continue.

%       Since we generated the data, we enjoy the luxury of comparing
%       the model to the true system:

 
pause   % Press any key for plots of comparisons.

bode(m0,am2), pause
%       % The responses practically coincide
bode(m0('noise'),am2('noise')), pause
zpplot(m0,am2), pause
echo off
set(gcf,'NextPlot','replace');
