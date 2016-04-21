%ISDEPLOYED tests if the code is running in deployed mode or MATLAB mode
%   X = ISDEPLOYED returns true when the function is being run in deployed 
%   mode and false if it is being run within MATLAB environment.
%   
%   This function will return false when executed within MATLAB.
%   When this function is used in an application compiled with MATLAB 
%   Compiler, it will return true.
%
%   See also MCC

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/23 19:09:46 $