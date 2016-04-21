function [ts1timevec, ts2timevec, outprops, outtrans] = timemerge(timeInfo1, timeInfo2, time1, time2)
%TIMEMERGE Common method used by overloaded arithmatic and concatonation 
%
%   Author(s): James G. Owen
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:33:06 $

% TO DO: Consider making into a @timeseries static method

% Convert time units
units = {'years', 'weeks', 'days', 'hours', 'mins', 'secs'};
outunits = units{max(find(strcmp(timeInfo1.Units,units)), ...
        find(strcmp(timeInfo2.Units,units)))}; %smaller units
unitconv1 = tsunitconv(outunits,timeInfo1.Units);
unitconv2 = tsunitconv(outunits,timeInfo2.Units);
ts1timevec = unitconv1*time1;
ts2timevec = unitconv2*time2;

% If time vectors are both absolute then convert them to the output units
% and apply the converted difference between the startdates
ref = '';
delta = 0;
deltaTS = [];
if ~isempty(timeInfo1.Startdate) && ~isempty(timeInfo2.Startdate)        
    delta = tsunitconv(outunits,'days')*(datenum(timeInfo1.Startdate)-datenum(timeInfo2.Startdate));
    if delta>0
        ref = timeInfo2.Startdate;
        ts1timevec = ts1timevec+delta;
        deltaTS = 1;
    else
        ref = timeInfo1.Startdate;
        delta = -delta;
        ts2timevec = ts2timevec+delta;
        deltaTS = 2;
    end
else
    if ~(isempty(timeInfo1.Startdate) || ~isempty(timeInfo2.Startdate))
       warning('Combination of absolute and relative time vectors, dropping absolute reference')
    end
end

% Merge time formats
outformat = '';
if strcmp(timeInfo1.Format,timeInfo2.Format)
    outformat = timeInfo1.Format;
end

outprops = struct('ref',ref,'outformat',outformat,'outunits',outunits);
outtrans = struct('delta',delta,'deltaTS', deltaTS,'scale',{{unitconv1,unitconv2}});