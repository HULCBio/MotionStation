function zd=dtrend(z,o,brp)
%DTREND Removes trends from data sets.
%   ZD = DTREND(Z)    or   ZD = DTREND(Z,O,BREAKPOINTS)
%
%   Z is the data set to be detrended, organized with the data records as
%   column vectors. ZD is returned as the detrended data.
%
%   If O = 0 (the default case) the sample means are removed from each of
%   the columns.
%
%   If O = 1, linear trends are removed. A continuous, piecewise linear
%   trend is adjusted to each of the data records, and then removed. The
%   interior breakpoints for the linear trend segments are contained in
%   the row vector BREAKPOINTS. The default value is that there are no
%   interior breakpoints, so that one single straight line is removed from
%   each of the data records.
%
%   This function is obsolete.  Please use DETREND instead.
%
%   See also DETREND, IDFILT.

%   L. Ljung 7-8-87
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2001/04/06 14:22:01 $

if nargin < 2, o = 0; end	% Default is mean removal, unlike DETREND
y = z.OutputData;
ny = size(y{1},2);
u = z.InputData;
yd = cell(size(y));
ud = cell(size(u));
for kexp = 1:length(y)
z1 = [y{kexp} u{kexp}];
if nargin < 3
  z1 = detrend(z1,o);
else
  z1 = detrend(z1,o,brp);
end
yd{kexp} = z1(:,1:ny);
ud{kexp} = z1(:,ny+1:end);
end
zd = pvset(z,'OutputData',yd,'InputData',ud);
