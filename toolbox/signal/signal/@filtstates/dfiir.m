%DFIIR   Direct-form IIR filter states.
%   H = FILTSTATES.DFIIR constructs a default direct-form IIR filter states
%   object.
%
%   H = FILTSTATES.DFIIR(NUMSTATES,DENSTATES) constructs an object and sets
%   its 'Numerator' and 'Denominator' properties to NUMSTATES and DENSTATES
%   respectively.  
%
%   Notice that the Filter Design Toolbox, along with the Fixed-Point
%   Toolbox, enables single precision floating-point and fixed-point
%   support for the Numerator and Denominator states.
%
%   Example #1, construct the default object
%   h = filtstates.dfiir
%
%   Example #2, construct an object with Numerator and Denominator states
%   as vectors of zeros.
%   h = filtstates.dfiir(zeros(4,1),zeros(4,1));
%
%   See also FILTSTATES/DOUBLE, DFILT.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/01/25 23:08:20 $

% [EOF]
