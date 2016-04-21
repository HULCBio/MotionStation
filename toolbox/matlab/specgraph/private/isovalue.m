function val = isovalue(data)
%ISOVALUE  Isovalue calculator.
%   VAL = ISOVALUE(V) calculates an isovalue from data V using hist
%   function.  Utility function used by ISOSURFACE and ISOCAPS.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/06/17 13:37:43 $


% only use about 10000 samples
r = 1;
len = length(data(:));
if len > 20000
  r = floor(len/10000);
end

[n x] = hist(data(1:r:end),100);

% remove large first max value
pos = find(n==max(n));
pos = pos(1);
q = max(n(1:2));
if pos<=2 & q/(sum(n)/length(n)) > 10
  n = n(3:end); 
  x = x(3:end);
end

% get value of middle bar of non-small values
pos = find(n<max(n)/50);
if length(pos) < 90
  x(pos) = [];
end
val = x(floor(length(x)/2));


