%FIRTYPE  Determine the type of a linear phase FIR filter.
%   T = FIRTYPE(Hm) determines the type (1 through 4) of the multirate
%   filter object Hm.  The filter must be real and have linear phase.
%
%   Type 1 through 4 are defined as follows:
%      
%     - Type 1: Even order symmetric coefficients.
%     - Type 2: Odd order symmetric coefficients.
%     - Type 3: Even order antisymmetric coefficients.
%     - Type 4: Odd order antisymmetric coefficients.
%
%   If Hm has multiple sections, all sections must be real FIR filters with
%   linear phase.  For this case, T is a cell array containing the type
%   of each section.
%
%   Example: Determine the type of the default interpolator for L=4.
%   L = 4;
%   Hm = mfilt.firinterp(L);
%   firtype(Hm)
%
%   See also MFILT/ISLINPHASE.

% Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:24:51 $

% Help for the filter's FIRTYPE method.

% [EOF]
