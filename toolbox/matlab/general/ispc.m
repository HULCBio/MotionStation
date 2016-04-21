function result = ispc
%ISPC True for the PC (Windows) version of MATLAB.
%   ISPC returns 1 for PC (Windows) versions of MATLAB and 0 otherwise.
%
%   See also COMPUTER, ISUNIX.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.4.4.1 $  $Date: 2004/03/17 20:05:17 $

result = strncmp(computer,'PC',2);
