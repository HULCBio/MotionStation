function thd=thc2thd(thc,T)
%THC2THD  Converts a continuous time model to discrete time.
%   This function is OBSOLETE. Use C2D instead. See HELP IDMODEL/C2D.
%
%   THD = THC2THD(THC,T)
%
%   THC: The continuous time model, specified in THETA format
%           (See also THETA).
%
%   T: The sampling interval
%   THD: The discrete time model, in THETA format
%
%   Note that the covariance matrix is not translated to discrete time
%   for input-output type models
%
%   See also THD2THC.

%   L. Ljung 10-2-90, 94-08-27
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.6 $ $Date: 2001/04/06 14:21:42 $

if nargin < 2
   disp('Usage: THD = THC2THD(THC,T)')
   return
end
thd = c2d(thc,T);

