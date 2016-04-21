%msdemo1

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.11.2.3 $

echo on
clc
%   *************    DATA TYPES    **************
%    A 1-output, 2-input, 2-state linear
%    system is described by the following
%    four matrices

a=[ -.15 .5 ; -.5 -.15]
pause % strike any key to continue
clc
b = [.2 4;-.4 0]
pause % strike any key to continue
c=[5 5]
pause % strike any key to continue
clc
d=[ .1 -.1 ]
pause % strike any key to continue
clc
%    The command
%                PCK
%    will pack this data into a system matrix
%    which we will call SYS

pause % strike any key to continue

sys = pck(a,b,c,d);


%    Simply printing out the MATLAB matrix SYS
%    reveals the extra information embedded in
%    this matrix

pause % strike any key to continue
clc
sys
%    The matrix SYS is 4 by 5, and contains the
%    state space matrices a, b, c, and d. these
%    appear in the upper left, 3 by 4 corner of
%    the matrix, arranged as [a b; c d]. the matrix
%    SYS also has an extra row and column to indicate
%    that it is a system matrix. The -INF in the
%    (4,5) entry indicates system matrix, and the
%    2 in the (1,5) entry indicates 2 STATES.
pause % strike any key to continue
clc
%   The command
%               MINFO,
%   which stands for matrix_information, gives
%   STATE, OUTPUT and INPUT information

pause; % strike any key to continue

minfo(sys)


pause % strike any key to continue
clc
%    the command
%               SPOLES
%    will print the poles of this system

pause; % strike any key to continue

spoles(sys)


pause % strike any key to continue

%    That gives an idea of the SYSTEM MATRIX
%    data type. A VARYING MATRIX can be created
%    by calculating a frequency response or time
%    response of the system - first, a frequency
%    response. Make a frequency vector of 4
%    logarithmically spaced points from 0.1 to 1,
%    using the MATLAB command LOGSPACE

pause; % strike any key to continue

omega = logspace(-1,0,4)


pause; % strike any key to continue
clc

%    The frequency response is computed with
%    the command  FRSP. In particular

%       SYS_G = FRSP(SYS,OMEGA)

%    produces a VARYING matrix SYS_G, that is
%    the frequency response of SYS at the four
%    frequencies of OMEGA.

pause; % strike any key to continue

sys_g = frsp(sys,omega);


pause; % strike any key to continue
clc

%   If we print out the matrix SYS_G as a MATLAB
%   matrix, we can see that the frequency information
%   is embedded there
pause; % strike any key to continue
clc
sys_g
pause; % strike any key to continue
%  SYS_G is a 5 by 3 matrix. the INF in the (5,3) entry
%  implies VARYING matrix. the 4.00 in the (5,2) entry
%  indicates 4 data points are represented, and the first 4
%  entries in the last (3rd) column are the frequencies.
%  the 4 by 2 block in upper left corner are the frequency
%  response matrices (each 1 by 2 - since SYS had 1 output
%  and 2 inputs) stacked upon each other.
pause; % strike any key to continue
clc

%   run the matrix_information command MINFO
%   on SYS_G to see that it is indeed a VARYING
%   matrix.

pause; % strike any key to continue

minfo(sys_g)


pause; % strike any key to continue

%   note that SYS_G is a VARYING MATRIX as
%   expected. it consists of 4 points, and
%   each matrix has 1 row and 2 columns. the
%   command
%           SEE
%   is useful for displaying a varying matrix. it
%   prints out the matrix at each independent
%   variable value (here, interpreted as frequency)

pause; % strike any key to continue

see(sys_g)

pause; % strike any key to continue
clc

%    in this case, the frequencies at which the
%    frequency response has been computed are
%    called the INDEPENDENT VARIABLES of sys_g.
%    the command
%                   SEEIV
%    displays the independent variables of a
%    of a varying matrix without showing all
%    of the varying matrix data.

pause; % strike any key to continue

seeiv(sys_g)


pause; % strike any key to continue
clc

%    VARYING matrices can be plotted versus
%    the independent variable with the command
%    VPLOT, which stands for MATRIX PLOT. VPLOT
%    plots each element of the varying matrix
%    versus the independent variable. In this
%    case, SYS_G has 1 row, and 2 columns, so
%    the command
%               VPLOT('liv,lm',SYS_G')
%    plots a log-magnitude plot (lm means log-magnitude)
%    of the 2 elements, with log axis for the
%    independent variable (liv)

pause; % strike any key to continue
echo off
foobar = figure;
vplot('liv,lm',sys_g)
xlabel('Strike any key to continue')
pause;
echo on
clc

%    VPLOT can also be used to plot Nyquist
%    plots. let's calculate a much finer
%    frequency response, over a larger range,
%    100 points from 0.1 to 10.

pause; % strike any key to continue

omega = logspace(-1,1,100);
sys_g = frsp(sys,omega);

pause; % strike any key to continue
clc
%
%    check the frequencies with  SEEIV(SYS_G).
%    it should be 100 points, from 0.1 to 10.
%
pause; % strike any key to continue

seeiv(sys_g)

pause; % strike any key to continue
clc

%    now plot the 2 Nyquist plots of SYS_G with
%
%                 VPLOT('NYQ',SYS_G)
%
%    the 'NYQ' stands for REAL versus IMAGINARY, and
%    the curves are parametrized by the independent
%    variable

pause; % strike any key to continue
echo off
vplot('nyq',sys_g)
xlabel('Strike any key to continue')
pause;
echo on
clc

%    portions of the varying matrix sys_g can
%    be extracted out using XTRACT

%       XTRACT(SYS_G,0.4,2.1)

%    will extract from SYS_G those points with
%    independent variable (frequency) values
%    between 0.4 and 2.1

pause; % strike any key to continue
clc

some = xtract(sys_g,0.4,2.1);

pause; % strike any key to continue

%   check that only a portion of the original
%   independent variables are in SOME
pause; % strike any key to continue

seeiv(some)

pause; % strike any key to continue

%    generate a Nyquist plot of some using
%        VPLOT('NYQ',SOME)

pause; % strike any key to continue
echo off
vplot('nyq',some)
xlabel('Strike any key to conclude the demo')


%     That is an introduction to generating frequency
%     responses from system matrices, and plotting the
%     results.
%
%

pause % strike any key to conclude the demo

close(foobar);
clc