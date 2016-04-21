function zerst = idnonzer(inp)
%IDNONZER Returns subset of input vector that are valid handles.
%   INP:   A vector of candidate handles
%   ZERST: Vector of valid handles

%   L. Ljung 4-4-94
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2001/04/06 14:22:35 $

inp = inp(:);
inp = inp(inp>0);
zerst = inp(ishandle(inp));