echo on
%   In this demo we shall demonstrate how to use several the SITB to
%   estimate parameters in user-defined model structures. We shall investigate
%   data produced by a (simulated) dc-motor. We first load the data:

echo off
%   Lennart Ljung
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.9 $ $Date: 2001/04/06 14:21:45 $
echo on

load dcmdata

%       The matrix y contains the two outputs: y1 is the angular position of
%       the motor shaft and y2 is the angular velocity. There are 400 data
%       points and the sampling interval is 0.1 seconds. The input is
%       contained in the vector u. It is the input voltage to the motor.
%       Press a key for plots of the input-output data.

z = iddata(y,u,0.1); % The IDDATA object
z.InputName = 'Voltage';
z.OutputName = {'Angle';'AngVel'};

pause,plot(z),pause

%       We shall build a model of the dc-motor. The dynamics of the motor is
%       well known. If we choose x1 as the angular position and x2 as the
%       angular velocity it is easy to set up a state-space model of the
%       following character neglecting disturbances:
%       (see Example 4.1 in Ljung(1999):

%           | 0     1  |      | 0   |
%  d/dt x = |          | x  + |     | u
%           | 0   -th1 |      | th2 |
%
%
%          | 1  0 |
%     y =  |      | x
%          | 0  1 |
%
%
%       The parameter th1 is here the inverse time-constant of the motor and
%       th2 is such that th2/th1 is the static gain from input to the angular
%       velocity. (See Ljung(1987) for how th1 and th2 relate to the physical
%       parameters of the motor.)
%       We shall estimate these two parameters from the observed data. Strike
%       a key to continue.

pause

%       1. FREE PARAMETERS
%
%       We first have to define the structure in terms of the general
%       description
%
%       d/dt x = A x + B u + K e
%
%       y   = C x + D u + e
%
%       Strike a key to continue.

pause

%
%       Any parameter to be estimated is entered as NaN (Not a Number).
%       Thus we have the structure matrices
As = [0 1; 0 NaN];
Bs = [0; NaN];
Cs = [1 0; 0 1];
Ds = [0; 0];
Ks = [0 0;0 0];
X0s = [0;0];   %X0 is the initial value of the state vector; it could also be
             %entered as parameters to be identified.
             
%       We shall produce an initial guess for the parameters marked with
%       NaN above. Let us guess  that the time constant is one second 
%       and that the static gain is 0.28. This gives:

A = [0 1; 0 -1];
B = [0; 0.28];
C = eye(2);
D = zeros(2,1);

%       The nominal model is now defined by

ms = idss(A,B,C,D);pause     % Strike a key to continue

%       To define the "structure", i.e., which parameters to estimate:

setstruc(ms,As,Bs,Cs,Ds,Ks,X0s); 
set(ms,'Ts',0)  % This defines the model to be continuous (Sampling interval 0) 

pause, ms, pause % To examine the nominal = initial model, press a key


%       The prediction error (maximum likelihood) estimate of the parameters
%       is now computed by (Press a key to continue)

pause, dcmodel = pem(z,ms,'trace','on');

 
pause, dcmodel, pause % Press a key to display the model
 
%       The estimated values of the parameters are quite close to those used
%       when the data were simulated (-4 and 1).

%       To evaluate the model's quality we can simulate the model with the
%       actual input by and compare it with the actual output.
%       Strike a key to continue.

pause, compare(z,dcmodel); pause

%       We can now, for example plot zeros and poles and their uncer-
%       tainty regions. We will draw the regions corresponding to 10 standard
%       deviations, since the model is quite accurate. Note that the pole at
%       the origin is absolutely certain, since it is part of the model
%       structure; the integrator from angular velocity to position.
%       Strike a key to continue.

pause, zpplot(dcmodel,10), pause

%       Now, we may make various modifications. The 1,2-element of the A-matrix
%       (fixed to 1) tells us that x2 is the derivative of x1. Suppose that
%       the snesors are not calibrated, so that there my be an unknown 
%       propertionality constant. To include the estimation of such a constant
%       we just "let loose" A(1,2): and reestimate

dcmodel2 = dcmodel;
pause, dcmodel2.As(1,2) = NaN;
dcmodel2 = pem(z,dcmodel2,'trace','on'); 

%       The resulting model is

pause, dcmodel2, pause

%       We find that the estimated A(1,2) is close to 1.
%       To compare the two model we use

pause, compare(z,dcmodel,dcmodel2), pause

%       2. COUPLED PARAMETERS
%
%       Suppose that we accurately know the static gain of the dc-motor (from
%       input voltage to angular velocity, e.g. from a previous step-response
%       experiment. If the static gain is G, and the time constant of the
%       motor is t, then the state-space model becomes
%
%            |0     1|    |  0  |
%  d/dt x =  |       |x + |     | u
%            |0  -1/t|    | G/t |
%
%            |1   0|
%     y   =  |     | x
%            |0   1|
%

pause % Press a key to continue

%       With G known, there is a dependence between the entries in the
%       different matrices. In order to describe that, the earlier used way
%       with "NaN" will not be sufficient. We thus have to write an m-file
%       which produces the A,B,C,D,K and X0 matrices as outputs, for each
%       given parameter vector as input. It also takes auxiliary arguments as
%       inputs, so that the user can change certain things in the model
%       structure, without having to edit the m-file. In this case we let the
%       known static gain G be entered as such an argument. The m-file that
%       has been written has the name 'motor'. Press a key for a listing.

pause, type motor

pause % Press a key to continue.

%       We now create a IDGREY model object corresponding to this model
%       structure: The assumed time constant will be

par_guess = 1;

%       We also give the value 0.25 to the auxiliary variable G (gain)
%       and sampling interval

aux = 0.25;

dcmm = idgrey('motor',par_guess,'cd',aux,0);

pause   % Press a key to continue

%       The time constant is now estimated by

dcmm = pem(z,dcmm,'trace','on');

%       We have thus now estimated the time constant of the motor directly.
%       Its value is in good agreement with the previous estimate.
%       Strike a key to continue.

pause, dcmm,  pause

%       With this model we can now proceed to test various aspects as before.
%       The syntax of all the commands is identical to the previous case.
%       For example, we can compare the idgrey model with the other
%       state-space model:

compare(z,dcmm,dcmodel)

%       They are clearly very close.


%       3. MULTIVARIATE ARX-MODELS.
%
%       The state-space part of the toolbox also handles multivariate (several
%       outputs) ARX models. By a multivariate ARX-model we mean the
%       following: Strike a key to continue.

pause

%       A(q) y(t) = B(q) u(t) + e(t)
%
%       Here A(q) is a ny | ny matrix whose entries are polynomials in the
%       delay operator 1/q. The k-l element is denoted by a_kl(q):
%
%                          -1                   -nakl
%       a_kl(q) = 1 + a-1 q    + .... + a-nakl q
%
%       It is thus a polynomial in 1/q of degree nakl.

%       Similarly B(q) is a ny | nu matrix, whose kj-element is

%                      -nkkj         -nkkj-1                 -nkkj-nbkj
%       b_kj(q) = b-0 q      +  b-1 q        + ... + b-nbkj q

%       There is thus a delay of nkkj from input number j to output number k

%       The most common way to create those would be to use the ARX-command.
%       The orders are specified as
%       nn = [na nb nk]
%       with na being a ny | ny matrix whose kj-entry is nakj; nb and nk are
%       defined similarly.  Strike a key to continue.

pause

%       Let's test some ARX-models on the dc-data. First we could simply build
%       a general second order model:


dcarx1 = arx(z,'na',[2,2;2,2],'nb',[2;2],'nk',[1;1]);

pause, dcarx1 % press a key to examine the result

%       The result, dcarx1, is stored as an IDARX model, and all previous
%       commands apply. We could for example explicitly determine the
%       ARX-polynomials by

pause, dcarx1.A % Press a key to continue

pause, dcarx1.B % Press a key to continue


%       We could also test a structure, where we know that y1 is obtained by
%       filtering y2 through a first order filter. (The angle is the integral
%       of the angular velocity). We could then also postulate a first order
%       dynamics from input to output number 2:

na = [1 1; 0 1];
nb = [0 ; 1];
nk = [1 ; 1];

dcarx2 = arx(z,[na nb nk]);

pause, dcarx2 %       Strike a key to continue

pause

%       To compare the different models obtained we use

compare(z,dcmodel,dcmm,dcarx2)
pause

%       Finally, we could compare the bodeplots obtained from the input to
%       output one for the different models by

 
pause,bode(dcmodel,'r',dcmm,'b',dcarx2,'g'),pause

%       The two first models are in more or less exact agreement. The
%       arx-models are not so good, due to the bias caused by the non-white
%       equation error noise. (We had white measurement noise in the
%       simulations).
pause
echo off
set(gcf,'NextPlot','replace');
