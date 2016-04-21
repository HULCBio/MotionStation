echo on

%       This demo demonstrates the objects of the System Identification
%       Toolbox.

echo off
%   Lennart Ljung
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.9 $ $Date: 2001/04/06 14:21:45 $
if exist('ss'), cstbflag = 1;else cstbflag = 0; end
echo on

%       1. THE IDDATA OBJECT
%       First create some data:

u = sign(randn(200,2)); % 2 inputs
y = randn(200,1);       % 1 output
ts = 0.1;               % The sampling interval

%       To collect the input and the output in one object do

z = iddata(y,u,ts);

pause   % The data is decribed by just typing its name. Press a key to continue.

z

%       The data is plotted as iddata by the plot command. Press a key to
%       continue and to advance between the subplots.

pause, plot(z), pause

%       To retrieve the outputs and inputs, use

u = z.u;   % or, equivalently u = get(z,'u');
y = z.y;   % or, equivalently y = get(z,'y');

%       To select a portion of the data:

zp = z(48:79);

%       To select the first output and the second input:

zs = z(:,1,2);  % The ':' refers to all the data time points.

pause   % Press a key to continue

%       The subselections can be combined:

plot(z(45:54,1,2)),pause

%       The channels are given default names 'y1', 'u2', etc. This can
%       be changed to any values by

set(z,'InputName',{'Voltage';'Current'},'OutputName','Speed');

%      Equivalently we could write

z.inputn = {'Voltage';'Current'}; % Autofill is used for properties
z.outputn = 'Speed';    % Upper and lower cases are also ignored

%       For bookkeeping and plots, also units can be set:

z.InputUnit = {'Volt';'Ampere'};
z.OutputUnit = 'm/s';

pause, z , pause  % Press any key to continue

%      All current properties are (as for any object) obtained by get:

pause, get(z), pause  % Press a key to continue

%      In addition to the properties discussed so far, we have
%      'Period' which denotes the period of the input if periodic
%      Period = inf means a non-periodic input;

z.Period

pause  % Press a key to continue

%      The intersample behavior of the input may be given as 'zoh'
%      (zero-order-hold, i.e. piecewise constant) or 'foh' (first-
%      order-hold, i.e., piecewise linear). The identification routines
%      use this information to adjust the algorithms.

z.inter

pause % press key to continue

%      You can add channels (both input and output) by "horizontal
%      concatenation", i.e. z = [z1 z2];

z2 = iddata(rand(200,1),ones(200,1),0.1);
z3 = [z,z2];

pause, z3, pause % Press key to display the data

pause, plot(z3), pause % press key to plot data

%      The command IDINPUT generates typical input signals.

u = idinput([30 1 10],'sine'); % 10 periods of 30 samples
u = iddata([],u,1,'Period',30);% Making the input an IDDATA object.

pause, u, pause  % Look at the data

%      SIM applied to an iddata input delivers an iddata output:

m = idpoly([1 -1.5 0.7],[0 1 0.5]);  % This creates a model; see below.
y = sim(m,[u iddata([],randn(300,1))]);  
                               
pause, y , pause  % press a key to continue
                               
z5 = [y u] % The output-input iddata.

%      More about the IDDATA object is found under HELP IDDATA and HELP IDDATADV

pause, % Press akey to continue

%      2. THE IDMODEL OBJECTS

%      All models are delivered as objects. There are a few different objects
%      depending on the type of model used, but this is mostly transparent.

load iddata1

m = armax(z1,[2 2 2 1]);  % This creates an ARMAX model. 

%      To display it just type its name:

pause, m, pause    % Press a key to continue

%      Many of the model properties are directly accessable

m.a    % The A-polynomial
m.nc   % The order of the C-polynomial

%      A list of properties is obtained by get:

pause, get(m), pause  % press a key

%      nf = 0, nd = 0 denote orders of a general linear model, of which
%      the ARMAX model is a special case.
%
%      EstimationInfo contains information about the estimation process:

m.es  % Autofill of properties is used

pause % press a key

%      The Algorithm property contains many properties that affect the
%      estimation algorithm:

pause, m.al  % Press a key

%      All the algorithm properties can be set in the estimation command:
%      (see IDPROPS ALGORITHM for a complete explanation)

m1 = armax(z1,[2 2 2 1],'maxiter',5,'search','LM'); % max 5 iterations, using
       % the Levenberg-Marquard search direction

%      To obtain on-line information about the mimization, use the property
%      'Trace' with possible values 'Off', 'On', and 'Full':

pause, m1 = armax(z1,[2 2 2 1],'Trace','On'); %Press a key

%      The commands to evaluate the model: BODE, STEP, ZPPLOT, COMPARE etc
%      all operare directly on the model, like

compare(z1,m1)

pause   % Press a key

%      Transformations to state-space, transfer function and Zeros and poles are
%      obtained by SSDATA, TFDATA and ZPKDATA:

[num,den]  = tfdata(m1,'v')
       % The 'v' means that num and den are returned
       % as vectors and not as cell arrays. The cell arrays are useful to
       % handle multivariable systems
       
 pause % Press a key
       
       echo off 
       if cstbflag
          disp('      % The objects also connect directly to the Control Systems Toolbox.')
          disp(sprintf('      %% To transform to a TF object in the CSTB: \n \ntfm = tf(m1)'))
          tfm = tf(m1)
       end
       echo on
       
