function [y,t] = utGetLogData(LogObject)
% Extracts and formats time and ordinate data.

%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:46:55 $
%   Copyright 1986-2004 The MathWorks, Inc.
t = LogObject.Time;
y = LogObject.Data;
% Format y as NSxNCH array
% REVISIT: Look at GridFirst (g198640)
ns = length(t);
if ns==size(y,3)
   y = permute(y,[3 1 2]);
end
s = size(y);
y = reshape(y,[ns prod(s(2:end))]);
