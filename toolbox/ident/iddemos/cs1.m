echo on
%CASE STUDY NUMBER 1 : A GLASS TUBE DRAWING FACTORY
%
% In this Case Study we shall study data from a glass tube factory. The
% experiments and the data are discussed in
%
% V. Wertz, G. Bastin and M. Heet: Identification of a glass tube
% drawing bench. Proc. of the 10th IFAC Congress, Vol 10, pp 334-339
% Paper number 14.5-5-2. Munich August 1987.
%
% The the output of the process is the thickness and the diameter of
% the manufactured tube. The inputs are the air-pressure inside the
% tube and the drawing speed.
%
% We shall in this tutorial study the process from the input speed
% to the output thickness.
%
load thispe25.mat
%
% The data ar contained in the variable glass:

pause, glass, pause   % Strike a key to continue


% Split it into two halves, one for
% estimation and one for validation:

echo off
%   Lennart Ljung
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2001/04/06 14:21:45 $
echo on

ze = glass(1001:1500);
zv = glass(1501:2000,:);
pause, plot(ze), pause

% A close-up: 

pause,plot(ze(101:200)),pause

% Let us remove the mean values:

ze = detrend(ze);
zv = detrend(zv);

% The sampling interval of the data is one second. We may
% detect some rather high frequencies in the output. Let us therefore
% first compute the input and output spectra:

sy = spa(ze(:,1,[]));
su = spa(ze(:,[],1));
pause,   bode(sy,su), pause % Strike key to advance plots

% Note that the input has very little relative energy above 1 rad/sec
% while a substantial part of the output's energy comes from fequencies above
% 1 rad/sec. There are thus some high frequency disturbances that may cause
% some problem for the model building.

% We first compute the impulse response, using part of the data:

pause, impulse(ze,'sd',3,'fill'), pause

% We see a quite substantial delay of about 12 samples in the impulse response.

% We also as a preliminary test compute the spectral analysis estimate:

g = spa(ze);
pause, bode(g,'sd',1,'fill'),pause

% We note, among other things, that the high frequency behavior is quite
% uncertain.

% Let us do a quick check if we can pick up good dynamics by just computing
% a fourth order ARX model using the estimation data and simulate that
% model using the validation data. We know that the delay is about 12:
pause  % Press a key to continue

m1 = arx(ze,[4 4 12]);
compare(zv,m1);pause

% A close up:
pause, compare(zv,m1,inf,101:200), pause

%
% There are clear difficulties to deal with the high frequency components
% of the output. That in conjunction with the long delay suggests that we
% decimate the data  by four (i.e. low-pass filter it and pick every fourth
% value):

zd = idresamp(detrend(glass),4);
zde = zd(1:500);
zdv = zd(501:size(zd,'N'));
pause

% Let us find a good structure for the decimated data.

% First compute the impulse response:

pause, impulse(zde,'sd',3,'fill'), pause

% We see that the delay is about 3 samples(which is consistent with what we saw
% above.

% What does the  default model give?

pause, compare(zdv,pem(zde)), pause

% Seems much better that for the undecimated data. Let's go on to find
% a good model structure. First we look for the delay:


V = arxstruc(zde,zdv,struc(2,2,1:30));
nn = selstruc(V,0)

% Then we test several different orders with and around this delay:

V = arxstruc(zde,zdv,struc(1:5,1:5,nn(3)-1:nn(3)+1));

% Make your own choice of orders based on the figure to follow.
% (The "model quality" comments to be made below refer to the default choice)

pause, selstruc(V), pause

% Let's compute and check the model for whatever model you just preferred:

m2 = arx(zde,nn);
 
pause, compare(zdv,m2,inf,21:150);pause

% This seems reasonably good!

% We can also compare the bodeplots of the model m1 and m2:

pause, bode(m1,m2),pause

% We see that the two models agree well up to the Nyquist frequency of
% the slower sampled data.

% Let's test the residuals:

pause, resid(zdv,m2);pause

% This seems OK.

% What does the pole-zero diagram tell us?

pause, zpplot(m2,'sd',3),pause

% Some quite clear indication of pole-zero cancellations!
% This shows that we should be able to do well with lower order
% models. We shall return to that later.


% Let us however also check if we can do better by modeling the noise
% separately in a Box-Jenkins model:

mb=bj(zde,[nn(2) 2 2 nn(1) nn(3)])

% Is this better than the ARX-model in simulation ?
% (press key)
pause, compare(zdv,m2,mb), pause
 
% The Box-Jenkins model is thus capable of describing the validation
% data set somewhat better. How about the Bode plots?

pause, bode(m2,mb),pause

% The models agree quite well, apart from the funny twist in the BJ model.
% This twist, however, seems to have some physical relevance, since we
% get better simulations in the latter case.
% Finally we can compare the FPE:s of the two models:

[fpe(m2) fpe(mb)]

% To summarize: After decimation it is quite possible to build simple models
% that are capable of reproducing the validation set in a good manner.

% We can however do quite well with a much simpler model; a [1 1 3] ARX model:

m3=arx(zde,[1 1 3]);

% Simulation:

pause, compare(zdv,m3,mb), pause 

% 5-step ahead prediction:

pause, compare(zdv,m3,mb,5), pause 

echo off
