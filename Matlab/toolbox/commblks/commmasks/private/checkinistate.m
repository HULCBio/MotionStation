function eStr = checkinistate(iniState, degree, eStr)
%CHECKINISTATE  Checks for a valid initial states parameter.
%
%   Should be a binary scalar or vector of length = degree. 
%   Is used by the Pseudo-random sequence generator blocks.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/03/07 17:55:34 $

emsg = sprintf(['The initial states parameter must be a scalar or a vector',...
     ' of length equal to the degree of the generator polynomial parameter.']);

% Check the initial state parameter - binary, scalar or vector
if ~( ndims(iniState)==2 & min(size(iniState))==1 )
    eStr.emsg  = emsg;  eStr.ecode = 1; return;
end

if ~( (length(iniState) == degree) | (length(iniState) == 1) )
    eStr.emsg  = emsg;  eStr.ecode = 1; return;
end

if any(iniState~=1 & iniState~=0)
    eStr.emsg  = 'The initial states parameter values must be binary.';
    eStr.ecode = 1; return;
end

% [EOF]
