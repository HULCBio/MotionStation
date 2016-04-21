%FIRTYPE  Determine the type of a linear phase FIR filter.
%   T = FIRTYPE(Hd) determines the type (1 through 4) of a Discrete-Time
%   FIR filter object Hd.  The filter must be real and have linear phase.
%
%   Type 1 through 4 are defined as follows:
%      
%     - Type 1: Even order symmetric coefficients.
%     - Type 2: Odd order symmetric coefficients.
%     - Type 3: Even order antisymmetric coefficients.
%     - Type 4: Odd order antisymmetric coefficients.
%
%   If Hd has multiple sections, all sections must be real FIR filters with
%   linear phase.  For this case, T is a cell array containing the type
%   of each section.
%
%   See also DFILT.

% Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/13 00:00:03 $

% Help for the filter's FIRTYPE method.

% [EOF]
