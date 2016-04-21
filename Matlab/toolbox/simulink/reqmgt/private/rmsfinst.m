function result = rmsfinst
%RMSFINST Stateflow installed?
%   BOOL = RMSFINST detects where or not Stateflow has been
%   installed.  Returns: success = 1 if installed, 0 if not installed.
% 

%  Author(s): M. Greenstein, 02/22/99
%  Copyright 1998-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $   $Date: 2004/04/15 00:36:42 $

% dboissy: Check if Stateflow is mex file on path
result = exist('sf') == 3;

