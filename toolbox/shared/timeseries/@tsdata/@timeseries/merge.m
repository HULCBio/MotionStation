function [ts1out,ts2out] = merge(ts1,ts2,mergemethod,varargin)
%MERGE merges two time series onto a common time vector
%
%   [TSOUT1, TSOUT2] = MERGE(TS1, TS2, ‘MERGEMETHOD’)
%
%   Combines the time vectors of two time series into a synchronized form
%   using various rules specified by the ‘MERGEMETHOD’ string. The two output
%   time series objects are defined by redistributing the ordinate data of the
%   input time series on the synchronized time vector. The syncronized time
%   vector depends on the ‘MERGEMETHOD’ used as follows:
%
%   'MERGEMETHOD' = Union - Take the union of the time vectors over intersecting
%   intervals. The time vectors of TSOUT1 and TSOUT2 are equal to the union
%   of the time vectors of ts1 and ts2 on the time interval where the two
%   time vectors overlap
%
%   'MERGEMETHOD' = Intersection - Take the intersection of the time
%   vectors. The time vectors of TSOUT1 and TSOUT2 are equal to the
%   intersection of the time vectors of TS1 and TS2.
%
%   'MERGEMETHOD' = Map - Map TS2 to the times of TS1. The time vectors of TSOUT1
%   and TSOUT2 are both equal to the time vector of TS1 where it intersects the
%   interval where the time vectors TS1 and TS2 overlap.
%
%
%   [TSOUT1, TSOUT2] = merge(ts1, ts2, ‘UNIFORM’, INCREMENT)
%
%	Resample both time series so that they are uniformly sampled. The time vectors
%   of TsOut1 and TsOut2 are uniformly sampled with the specified increment
%   on the time interval where the time vectors of ts1 and ts2 overlap. The units
%   of the incrment are assumed to be the smaller time units of the two input time
%   series. 
%
%   Author(s): James G. Owen
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/11 00:33:48 $

%TO DO: Merge quality 

nargchk(3,inf,nargin);
% Extract time
t1 = ts1.time;
t2 = ts2.time;
if isempty(t1) || isempty(t2)
    error('timeseries:merge:noemptytime',...
        'One or more of the time vectors is empty')
end

% Merge time vectors onto a common basis
[ts1timevec, ts2timevec, outprops,outtrans] = ...
    timemerge(ts1.timeInfo, ts2.timeInfo,t1,t2);

% Find overlapping time interval
interval = [max(ts1timevec(1),ts2timevec(1)) min(ts1timevec(end),ts2timevec(end))];
if interval(2)<=interval(1)
    error('timeseries:merge:strictpos', ...
        'Overlapping time interval must have strictly positive length')
end

% Find output time interval
ts1timevec = ts1timevec(ts1timevec>=interval(1) & ts1timevec<=interval(end));
ts2timevec = ts2timevec(ts2timevec>=interval(1) & ts2timevec<=interval(end));

% Merge the time vectors
switch lower(mergemethod)
case 'union'
    tout = union(ts1timevec,ts2timevec);
case 'intersection'
    tout = intersect(ts1timevec,ts2timevec);
    if isempty(tout)
        error('timeseries:merge:emptyset',...
            'There are no intersecting time instants')
    end
case 'uniform'
   if nargin>=3
      tout = interval(1):varargin{1}:interval(end);
   else
      error('timeseries:merge:syntax', ...
          'A sampling interval must be specified for merging on uniform time vectors')
   end
otherwise
      error('timeseries:merge:interpsyntax', ...
          'Invalid merge method specification')
end

% Map the output time interval back into the units and offsets of the input
% time series
if outtrans.deltaTS==1 % deltaTS==1 means the first time series has been shifted 
    tout_ts1 = (tout-outtrans.delta)/outtrans.scale{1};
    tout_ts2 = tout/outtrans.scale{2};
elseif outtrans.deltaTS==2 % deltaTS==1 means the second time series has been shifted 
    tout_ts1 = tout/outtrans.scale{1};
    tout_ts2 = (tout-outtrans.delta)/outtrans.scale{2};
else
    tout_ts1 = tout/outtrans.scale{1};
    tout_ts2 = tout/outtrans.scale{2};
end

data1 = ts1.data;
data2 = ts2.data;
try 
   data1out = localInterp(ts1,t1,data1,tout_ts1);
catch
   if isa(data1,'tsdata.ArrayAdaptor')
       data1out = localInterp(ts1,t1,double(data1),tout_ts1);
   else 
       rethrow(lasterr);
   end
end
try
   data2out = localInterp(ts2,t2,data2,tout_ts2);
catch
   if isa(data2,'tsdata.ArrayAdaptor')
       data2out = localInterp(ts2,t2,double(data2),tout_ts2);
   else 
       rethrow(lasterr);
   end
end

%% Build output time series of whatever class
if classhandle(ts1)==classhandle(ts2)
    c = classhandle(ts1);
    ts1out = eval(sprintf('%s.%s',c.Package.Name,c.Name));
    ts2out = eval(sprintf('%s.%s',c.Package.Name,c.Name));
else
    ts1out = tsdata.timeseries;
    ts2out = tsdata.timeseries;
end

set(ts1out.timeInfo,'Startdate',outprops.ref,'Format', ...
    outprops.outformat,'Units', outprops.outunits)
ts1out.dataInfo = ts1.dataInfo.copy;
set(ts1out,'Data',data1out,'Time',tout,'Name','default');
set(ts2out.timeInfo,'Startdate',outprops.ref,'Format', ...
    outprops.outformat,'Units', outprops.outunits);
ts2out.dataInfo = ts2.dataInfo.copy;
set(ts2out,'Data',data2out,'Time',tout,'Name','default');

%% Add events
addevent(ts1out,ts1.Events);
addevent(ts2out,ts2.Events);

function dataOut = localInterp(ts,t,data,tout)

% Interpolate, taking into account the dimension aligned with time
if ts.dataInfo.GridFirst
    dataOut = ts.dataInfo.Interpolation.interpolate(t, ...
        data,tout);
else
    dataOut = ts.dataInfo.Interpolation.interpolate(t, ...
        data,tout,ndims(data));
end

