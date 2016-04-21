function [ny,nu] = iosize(L) 
%IOSIZE  I/O size of dynamical systems.
%
%   [NY,NU] = IOSIZE(SYS) returns the number of inputs NU
%   and the number of outputs NY of the system SYS.
%
%   S = IOSIZE(SYS) returns S = [NY NU].
%
%   See also SIZE.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $$
ny = length(L.OutputName);
nu = length(L.InputName);
if nargout==1
   ny = [ny nu];
end