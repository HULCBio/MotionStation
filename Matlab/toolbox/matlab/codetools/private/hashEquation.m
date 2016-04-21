function s = hashEquation(a);
% HASHEQUATION  Converts an arbitrary string into one suitable for a filename.
%   HASHEQUATION(A) returns a string usitable for a filename.

% Copyright 1984-2002 The MathWorks, Inc. 
% $Revision: 1.1.6.2 $  $Date: 2003/02/25 07:52:37 $

if isempty(a)
    d = 0;
else
    d = sum(a+(1:length(a))+(1:length(a)).^2);
end

s = sprintf('eq%.0f',d);