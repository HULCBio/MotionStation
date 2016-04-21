function resp = addressof(mm)
% ADDRESSOF(MM). Returns the address of MM.
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2003/11/30 23:09:13 $

error(nargchk(1,1,nargin));
resp = mm.address;

% [EOF] addressof.m