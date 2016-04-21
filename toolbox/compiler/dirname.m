function dir = dirname(func)
% DIRNAME Return the name of the directory containing the function.
%         If the function is a built-in, return the empty string.

% Copyright 2003 The MathWorks, Inc.

dir = fileparts(which(func));
