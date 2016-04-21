function realflag = isreal(ze)
% ISREAL Checks if an IDMODEL object contains complex parameters.
%
%   ISREAL(MODEL) returns 1 if all parameters of MODEL are real   
%       and 0 else.

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2001/04/06 14:22:13 $

realflag = isreal(ze.ParameterVector);
