function [y,ysd]=idsim(varargin)%data,th,init,inhib)
%IDSIM  Simulates a given dynamic system.
%   OBSOLETE function. Use SIM instead.
%   See HELP IDMODEL/SIM.

 
%   L. Ljung 10-1-86, 9-9-94
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $ $Date: 2004/04/10 23:20:06 $



y=[];ysd=[];
if nargin < 4, inhib = 0;end
if nargin<3,init=[];end
if nargin<2
   disp('Usage: Y = SIM(MODEL,UE)')
   disp('       [Y,YSD] = SIM(MODEL,UE,INIT)')
   return
end

if nargout <= 1;
   y = sim(varargin{:});
else 
   [y,ysd] = sim(varargin{:});
end
 