%   [num,den] = ltitf(sys)
%
%   For SISO systems, returns the numerator and denominator of
%   the transfer function  given a state-space realization SYS
%
%   Input:
%     SYS        state-space realization of the system in
%                packed form
%   Output:
%     NUM,DEN    numerator and denominator of the transfer
%                function  (vectors of the polynomial
%                coefficients)
%
%
%   See also  LTISYS, LTISS, SINFO, SSUB.

%  Author: P. Gahinet  6/94
%  Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function [num,den] = ltitf(sys)

[a,b,c,d,e]=ltiss(sys);

if sum(size(d))~=2, error('SYS is not a SISO system'); end

if norm(e-eye(size(e)),1)==0,
   [num,den]=ss2tf(a,b,c,d);
else
   if rcond(e) < 100*mach_eps,
      error('Singular descriptor system (E nearly singular)')
   else
      [num,den]=ss2tf(e\a,e\b,c,d);
   end
end
