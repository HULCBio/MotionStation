%msdemo2

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.10.2.3 $

echo on
clc
%     msdemo1 was an introduction to the data
%     types, and some commands for generating system
%     matrices and frequency responses from system matrices,
%     and plotting the results.

%     Let's now consider time responses. First
%     make up a very simple 1 state, 1 input, 1 output
%     system. Recall the syntax for PCK, SYS = PCK(a,b,c,d)
%     Hence   PCK(-4,4,1,0)   will produce a system with
%     Laplace transform 4/(s+4).

pause; % strike any key to continue

sys = pck(-4,4,1,0);

pause; % strike any key to continue
clc

%   now create a STEP INPUT VARYING matrix
%   using STEP_TR. the syntax is
%
%        INPUT = STEP_TR(TIMEDATA,STEPDATA,T_INC,FINALT)
%
%   TIMEDATA is the times at which the step changes occur
%   STEPDATA is the corresponding values of this
%            piecewise-constant signal
%   T_INC is the time increment between values in the
%   FINALT is the last time in the varying matrix INPUT
%
%   as an example, try
%
%         u = step_tr([0 1 2 3],[0 1 -1 -2],0.01,4);
%
pause; % strike any key to continue

%    this will represent a staircase-like time-varying
%    signal. it begins at t=0, with a

pause; % strike any key to continue

u = step_tr([0 1 2 3],[0 1 -1 -2],0.01,4);

pause; % strike any key to continue

%   this represents a varying matrix (note the INF
%   in the lower right corner) There are two data
%   points, the independent variable's values are 0
%   and 0.05, and the value of the matrix at both
%   values is 1.
%

pause; % strike any key to continue
clc

minfo(u)

pause; % strike any key to continue
clc

%    the time response command is called TRSP.
%    Basically, there are two input arguments - the
%    system (a system matrix) and the input function
%    (a varying matrix). The command TRSP assumes
%    that the input function is equal to zero
%    until its independent variable's first value.
%    After that first value, the
%    input function is assumed to be constant between
%    independent variable values. So, to the command
%    TRSP, the varying matrix U created above
%         (recall      U = [1 0 ; 1 0.05 ; 2 inf])
%    represents a unit step input at t=0.

pause; % strike any key to continue
clc

%    Create another varying matrix UTILDE
%    as follows:

pause; % strike any key to continue

utilde = [ 4*ones(50,1) (0:0.05:2.45)' ; 1 2.5 ; 51 inf ];

pause; % strike any key to continue

utilde

pause; % strike any key to continue


%    To the command TRSP, this represents a signal
%    that is zero for t < 0, for t between 0 and 2.5,
%    the signal level is 4, and for t > 2.5, the signal
%    level drops to 1.

pause; % strike any key to continue
clc

minfo(utilde)

pause; % strike any key to continue
clc

%    Now, the actual syntax for TRSP is
%             yout = trsp(sys,u,tfinal,x0)

%    Since the input is assumed to be constant
%    between independent variable values, the
%    system SYS is transformed to a discrete
%    system by a sample-hold, with sampling time
%    defined as the difference between the first
%    and second times in the input signal u. IT IS
%    ASSUMED THAT THE INDEPENDENT VARIABLES IN THE
%    INPUT SIGNAL ARE EVENLY SPACED, AND THIS SPACING
%    DEFINES THE SAMPLING TIME. The
%    third argument, TFINAL, denotes how long the
%    response is computed, and the 4th argument, x0,
%    is the desired initial state at the first time
%    value of the input. If the 4th argument is omitted,
%    then it is assumed to be 0.

pause; % strike any key to continue
clc

%    The first response will be to the step input,
%    with zero initial state (sample time of 0.05
%    seconds), TFINAL = 4 seconds, and zero initial
%    condition.

pause; % strike any key to continue

yout = trsp(sys,u,4);
pause;% strike any key to plot the response
echo off
foobar = figure;
vplot('iv,d',yout)
xlabel('strike any key to continue')
pause;
echo on

pause;  % strike any key to continue
clc

%    Now force SYS with the other input, UTILDE

pause;  % strike any key to continue

yout = trsp(sys,utilde,4);
pause; % strike any key to plot the response
echo off
vplot('iv,d',yout)
xlabel('strike any key to continue')
pause
echo on

pause;  % strike any key to continue
clc

%    create a simple 5 input, 5 output, 5 state
%    system as follows:

pause;  % strike any key to continue

a = diag([-1 -2 -3 -4 -5]);
b = diag([1 2 3 4 5]);
c = eye(5);
sys = pck(a,b,c);

pause;  % strike any key to continue

%   this represents a diagonal transfer function matrix

%      diag[ 1/(s+1)  2/(s+2)  3/(s+3)  4/(s+4)  5/(s+5)]

pause;  % strike any key to continue
clc

%    set up identically zero input for 2 seconds, then
%    a unit step input in each channel

pause;  % strike any key to continue

%   first generate one signal like that
pause;  % strike any key to continue

u = [ [zeros(41,1) [0:0.05:2]'] ; [ones(5,1) [2.05:.05:2.25]' ; 46 inf]];
%u = [ [zeros(41,1) [0:0.05:2]'] ; [ones(5,1) [2.05 ;zeros(4,1)] ; 46 inf]];
%u = [ [0; 2 ] [0;1] ; 2 inf];
pause;  % strike any key to continue
clc

%   now use abv to stack up several of these signals
pause;  % strike any key to continue

twou = abv(u,u);    % twou  is a 2x1 varying matrix
fouru = abv(twou,twou);    % fouru  is a 4x1 varying matrix
input = abv(fouru,u);      % input  is a 5x1 varying matrix

pause;  % strike any key to continue

minfo(input)

pause;  % strike any key to continue
clc
%    set up an initial condition of 1 in each state

xo = ones(5,1);

pause;  % strike any key to continue

%    compute the time response, and plot it

pause;  % strike any key to continue
clc

yout = trsp(sys,input,4,.05,xo);
echo off
vplot('iv,d',yout)

pause % strike any key to conclude the demo
close(foobar);


%