function zd=detrend(z,o,brp)
%DETREND Removes trends from data sets.
%   ZD = DETREND(Z)    or   ZD = DETREND(Z,O,BREAKPOINTS)
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
%
%   See also IDFILT.

%   L. Ljung 7-8-87
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2004/04/10 23:15:45 $

if nargin < 2, o = 0; end	% Default is mean removal, unlike DETREND
y = z.OutputData;
ny = size(y{1},2);
u = z.InputData;
zd = z;
if strcmp(lower(z.Domain),'frequency')
    if o>0
        error('Only means can be removed for frequency domain data.')
    end
    fr = z.SamplingInstants;
    for kexp = 1:length(fr)
        fr0 = find(fr{kexp}==0);
        if isempty(fr0)
            warning(['No frequency = 0 found in data. Detrending without effect.'])
        end
        y{kexp}(fr0,:)=zeros(1,ny);
        u{kexp}(fr0,:)=zeros(1,ny);
    end
    zd.InputData = u;
    zd.OutputData = y;
    return
end
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
