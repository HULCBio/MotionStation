function result = isunix()
%ISUNIX True for the UNIX version of MATLAB.
%   ISUNIX returns 1 for UNIX versions of MATLAB and 0 otherwise.
%
%   See also COMPUTER, ISPC.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.13.4.2 $  $Date: 2004/03/17 20:05:19 $

%  The only non-Unix platform is the PC
result = ~strncmp(computer,'PC',2);
