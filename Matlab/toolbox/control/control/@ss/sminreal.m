function [sys,xkeep] = sminreal(sys)
%SMINREAL  Compute a structurally minimal realization.
%
%   MSYS = SMINREAL(SYS) eliminates the states of the state-space
%   model SYS that are not connected to any input or output.  The
%   resulting state-space model MSYS is equivalent to SYS and is 
%   structurally minimal, i.e., minimal when all nonzero entries 
%   of SYS.A, SYS.B, SYS.C, and SYS.E are set to 1.
%
%   See also MINREAL.

%   Author(s): P. Gahinet and A.C. Grace
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/04/10 06:00:34 $

error(nargchk(1,1,nargin))

% Loop over each model
for k=1:prod(size(sys.a)),
   na = size(sys.a{k},1);
   [sys.a{k},sys.b{k},sys.c{k},sys.e{k},xkeep] = ...
      smreal(sys.a{k},sys.b{k},sys.c{k},sys.e{k},(1:na)');
end

% Update state names
Nx = size(sys,'order');
if length(Nx)>1 | Nx~=length(xkeep)
   sys.StateName = repmat({''},[max(Nx(:)) 1]);
else
   sys.StateName = sys.StateName(xkeep,1);
end


