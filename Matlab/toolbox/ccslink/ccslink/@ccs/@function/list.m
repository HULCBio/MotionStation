function varinfo = list(ff,lvar)
% LIST Returns information on a local variable.
%  LOCVARINFO = LIST(FF,LVAR) returns information about the local variable LVAR.
%  The information returned in LOCVARINFO is in the form of a MATLAB structure.
% 
%  Note: The 'address' field contains the correct address value only if the PC
%  is inside the scope of function FF.
%
%  Note: If LVAR is one of the inputs and if this name is created by FF to
%  replace an unspecified input parameter name (e.g.,'ML_Input1'), LIST will throw 
%  an error saying that LVAR is not a local variable in function FF.
%
%  See also CCSDSP/LIST.

%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.13.4.2 $  $Date: 2004/04/08 20:46:07 $

error(nargchk(2,2,nargin));
varinfo = p_list(ff,lvar);

% [EOF] list.m