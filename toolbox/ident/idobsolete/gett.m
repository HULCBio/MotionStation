function T=gett(th);
%GETT   Gets the sampling interval for a model.
%   OBSOLETE function. Use model property 'Ts' instead: T = TH.ts.
%
%   T = GETT(TH)
%
%   T: The sampling interval
%   TH: The model, defined in the THETA-format (See also THETA.)
%   See also SETT.

%   L. Ljung 10-2-90
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.7 $ $Date: 2001/04/06 14:21:38 $

if nargin < 1
   disp('Usage: T = GETT(TH)')
   return
end
T = pvget(th,'Ts');



