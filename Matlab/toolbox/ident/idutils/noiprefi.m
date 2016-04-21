function str = noiprefi(ev)
%NOIPREFI  Sets the prefix for noise channels
%  STR = NOIPREFI(EV)
%   EV = 'e' gives the prefix for non-normalized noise
%   EV = 'v' for normalized noise

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2001/04/06 14:21:56 $

if nargin == 0
   ev = 'e';
end

str = [ev,'@'];


