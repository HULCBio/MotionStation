function tsout = vertcat(ts1,ts2,varargin)
%VERTCAT  Vertical concatenation of time series objects.
%
%   TS = VERTCAT(TS1,TS2,...) vertical concatenation performs
%
%         TS = [TS1 ; TS2 ; ...]
% 
%   This operation amounts to appending the time series in 
%   the temporal direction. The time vecors must not overlap and
%   the size of the ordinate data sets must agree in all but the 
%   first dimension  
%
%   See also HORZCAT.
%
%   Author(s): James G. Owen
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/11 00:33:58 $

% Process argument pairwise
tsout = localConcat(ts1,ts2);
for k=1:nargin-2
    tsout = localConcat(tsout,varargin{k});
end


function tsout = localConcat(ts1,ts2)

% Merge time vectors onto a common basis
[ts1timevec, ts2timevec, outprops] = ...
    timemerge(ts1.timeInfo, ts2.timeInfo,ts1.time,ts2.time);

% Concatonate time and ord data
if ts1timevec(end)>=ts2timevec(1)
    error('timeseries:vertcat:nooverlap',...
        'Time intervals are overlapping or not in order')
end

time = vertcat(ts1timevec,ts2timevec);

% Merge the time alignment
[data1,data2,s1,s2] = tsAlignSizes(ts1.Data, ...
    ts1.DataInfo.GridFirst,ts2.Data,ts2.DataInfo.GridFirst);

% Build the output data array
if ~isequal(s1(2:end),s2(2:end))
    error('timeseries:vertcat:errdim',...
        'Ordinate data has mismatching dimensions')
end
if ~ts1.DataInfo.GridFirst && ~ts1.DataInfo.GridFirst
    dataout = hdsNewArray(ts1.Data,[s1(1:end-1) s1(end)+s2(end)]); 
    r1 = [repmat({':'},[1 length(s1)-1]) {1:s1(end)}];
    r2 = [repmat({':'},[1 length(s1)-1]) {(s1(end)+1):(s2(end)+s1(end))}]; 
else    
    r1 = [{1:s1(1)} repmat({':'},[1 length(s1)-1])];
    r2 = [{(s1(1)+1):(s2(1)+s1(1))} repmat({':'},[1 length(s1)-1])];
    dataout = hdsNewArray(ts1.Data,[s1(1)+s2(1) s1(2:end)]);
end

% Slice each block into the empty array
dataout = hdsSetSlice(dataout,r1,data1);
dataout = hdsSetSlice(dataout,r2,data2);    

% Build output time series. If both time series are subclasses 
% try to make the output the same classs
if classhandle(ts1) == classhandle(ts2)
    c = classhandle(ts1);
    tsout = eval(sprintf('%s.%s',c.Package.Name,c.Name));   
    set(tsout,'dataInfo',cat(ts1.dataInfo,ts2.dataInfo),'Name','default')
    set(tsout,'Data', dataout,'Time',time)
else
    tsout = tsdata.timeseries;
    tsout.dataInfo = cat(ts1.dataInfo,ts2.dataInfo);
    initialize(tsout,dataout,time);
end
set(tsout.timeInfo,'Startdate',outprops.ref,'Units',outprops.outunits, ...
    'Format',outprops.outformat);


% Quality arithmatic - merge quality info and combine quality codes
if ~isempty(ts1.qualityInfo) && ~isempty(ts2.qualityInfo)
    tsout.qualityInfo = merge(ts1.qualityInfo,ts2.qualityInfo);
end
if ~isempty(tsout.qualityInfo) && ~isempty(ts1.quality) && ~isempty(ts2.quality)
    tsout.quality = [ts1.quality;ts2.quality];
end

% Event concat
tsout.Events = horzcat(ts1.Events,ts2.Events);
