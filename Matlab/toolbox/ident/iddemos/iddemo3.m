echo on

%   This case study illustrates various possibilities to estimate a
%   reasonable model structure.
%
%   It is based on the same "hairdyer" data as demo # 2.
%   The process consists of air being fanned through a tube. The air
%   is heated at the inlet of the tube, and the input is the voltage
%   applied to the heater. The output is the temperature at the outlet
%   of the tube.

echo off
%   Lennart Ljung
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $  $Date: 2004/04/10 23:16:07 $
echo on

%       First, load the data. It is in the IDDATA data format.

load dry2

%       Form a data set for estimation of the first half, and a reference
%       set for validation purposes of the second half:

ze = dry2(1:500); 
zr = dry2(501:1000); 

%       Detrend each of the sets:

ze = dtrend(ze); zr = dtrend(zr);

%       Take a look at the data:

pause, plot(ze(200:350)), pause    % Press any key to continue

%       Let us first try and determine the time delay from input to output.
%       There are several ways to do this:
%
%       1) Estimate the impulse reponse by a non-parmetric method (IMPULSE)
%       2) Use the state-space model estimator N4SID with a number of
%          different orders and find the delay of the 'best' one.
%       3) Use ARXSTRUC to estimate many models of the ARX-type and see
%          which gives the best fit.
%
%       First IMPULSE. The dash-dotted lines show confidence intervals
%       corresponding to 3 standard deviations:

pause, impulse(ze,'sd',3) % Press a key to continue

%       A clear indication that the impulse response "takes off" (leaves
%       the unceratinty region) after 3 samples.
%
%       Now state-space models of several orders. Hit return to select
%       the default best order in the plot to follow.

pause,  m = n4sid(ze,1:15); % All orders between 1 and 15. 

%       What's the delay of this best model?

pause, impulse(m,'sd',3)

%       Another clear indication of a delay of 3.

pause  % press a key

%
%       We shall now work with ARX models of the following kind:

% y(t) + a1*y(t-1) + ... + ana*y(t-na) = b1*u(t-nk) + ... + bnb*u(t-nb-nk+1)

%       To determine the time delay (nk), we select a second order model
%       (na=nb=2), and try out every time delay
%       between 1 and 10. The loss function for the different models
%       are computed using the validation data set:

V = arxstruc(ze,zr,struc(2,2,1:10));

%       We now select that delay that gives the best fit for the
%       validation data:

[nn,Vm] = selstruc(V,0); % nn is given as [na nb nk]

%       The chosen structure was
nn
pause % Press any key to continue.

%       We can also check how the fit depends on the delay. The logarithms
%       of a quadratic loss function are given as the first row, while
%       the indexes na, nb and nk are given as a column below the correspon-
%       ding loss function.

pause % Press any key to continue.

Vm
%       The choice of three delays is thus rather clear. Now test the
%       orders. In the ARX-structure we check the fit for all 100
%       combinations of up to 10 b-parameters and up to 10 a-parameters, 
%       all with delay 3:

V = arxstruc(ze,zr,struc(1:10,1:10,3));

pause % Press any key to continue.

%       The best fit for the validation data set is obtained for

nn = selstruc(V,0)

pause % Press any key to continue.

%       It may be advisable to check yourself how much the fit is
%       improved for the higher order models. The following plot
%       shows the fit as a function of the number of parameters used.
%       (Note that several different model structures use the same
%       number of parameters.) You will then be asked to enter the
%       number of parameters you think gives a sufficiently good fit.
%       The routine then selects that structure with this many parameters
%       that gives the best fit.

pause, nns = selstruc(V)      % Press a key to continue.

%       The best fit is thus obtained for nn = [4 4 3], while we
%       see that the improved fit compared to nn = [2 2 3] is rather
%       marginal.

pause % Press any key to continue.

%       Let's compute the fourth order model:

th4 = arx(ze,[4 4 3]);

%       We now check the pole-zero configuration for the fourth order
%       model. We also include confidence regions for the poles and zeros
%       corresponding to 3 standard deviations.

pause, zpplot(th4,3), pause      % Press any key to for plot.

%       It is thus quite clear that the two complex conjugated pole-zero
%       pairs are likely to cancel, so that a second order model would be
%       adequate. We thus compute

th2 = arx(ze,[2 2 3]);

%       We can test how well this model is capable of reproducing the
%       validation data set. To compare the simulated output from the two
%       models with the actual output (plotting the mid 200 data points)
%       we invoke (press key for plot)

pause,compare(zr(150:350),th2,th4);pause


%       We can also check the residuals ("leftovers") of this model,
%       i.e., what is left unexplained by the model.

pause % Press any key to continue.

e = resid(ze,th2); pause

plot(e(:,1,[])), title('The residuals'),pause

%       We see that the residual are quite small compared to the signal
%       level of the output, that they are reasonably (although not
%       perfectly) well uncorrelated with the input and between themselves.
%       We can thus be (provisionally) satisfied with the model th2.

%       To find a good state space model, one we know that the delay is 3
%       we proceed as follows:

pause, ms = n4sid(ze,[1:15],'nk',3);

%       The default order is 3, that is in good agreement with our earlier findings.
%       Finally, we compare how the state space model ms and the ARX model th2
%       compare in reproducing the measured output of the validation data:

pause, compare(zr,ms,th2)

%       The models are practically identical.

pause % Press any key to return to main menu.
echo off
set(gcf,'NextPlot','replace');
