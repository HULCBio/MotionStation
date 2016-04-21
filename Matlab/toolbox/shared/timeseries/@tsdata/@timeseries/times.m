function tsout = times(ts1, ts2)
%TIMES Overloaded multiplication 
%
%   Author(s): James G. Owen
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2004/04/11 00:33:55 $

% Check sizes match
if ~isequal(getGridSize(ts1),getGridSize(ts2))
    error('Time series have differing lengths')
end

% Merge time vectors onto a common basis
[ts1timevec, ts2timevec, outprops] = ...
    timemerge(ts1.timeInfo, ts2.timeInfo,ts1.time,ts2.time);

% Relative time vectors - remove initial values
if isempty(outprops.ref) 
    ts1timevec = ts1timevec-ts1timevec(1);
    ts2timevec = ts2timevec-ts2timevec(1);
end

% Check that the time vectors match
intervalLen = ((ts1timevec(end)-ts1timevec(1))/length(ts1timevec));
if norm(ts1timevec-ts2timevec)/intervalLen>1e-6
    error('Time vectors do not match')
end

% Merge the time alignment
[data1,data2,s1,s2] = tsAlignSizes(ts1.Data, ...
    ts1.DataInfo.GridFirst,ts2.Data,ts2.DataInfo.GridFirst);
if ~isequal(s1,s2)
    error('timeseries:plus:sizemis','Size of the data arrays are mismatching')
end

% If either ord data is an ArrayAdaptor try to invoke the native 
% overloaded plus, if that fails cast as double and add the old fashioned
% way
try
   dataout = data1.*data2;  
catch
   try 
       dataout = double(data1).*double(data2);  
   catch
       errstr = sprintf('%s\n%s','Times failed for this type of ordinate data object.', ...
                 'Try implementing a double cast method or overloaded addition for this object');
       error('timeseries:plus:badcast',errstr)
   end
end
    
% Build output time series. If both time series are subclasses 
% try to make the output the same classs
if classhandle(ts1) == classhandle(ts2)
    c = classhandle(ts1);
    tsout = eval(sprintf('%s.%s',c.Package.Name,c.Name));
    tsout.dataInfo = times(ts1.dataInfo,ts2.dataInfo);
    set(tsout,'Data', dataout,'Time',ts1timevec)
else
    tsout = tsdata.timeseries;
    tsout.dataInfo = times(ts1.dataInfo,ts2.dataInfo);
    initialize(tsout,dataout,ts1timevec);
end
set(tsout.timeInfo,'Startdate',outprops.ref,'Units', ...
    outprops.outunits,'Format',outprops.outformat);

% Quality arithmatic - merge quality info and combine quality codes
if ~isempty(ts1.qualityInfo) && ~isempty(ts2.qualityInfo)
    tsout.qualityInfo = merge(ts1.qualityInfo,ts2.qualityInfo);
end
if ~isempty(get(get(tsout,'qualityInfo'),'Code')) && ~isempty(ts1.quality) && ~isempty(ts2.quality)
    tsout.quality = min(ts1.quality,ts2.quality);
end

set(tsout,'Name',['Times_' ts1.Name '_' ts2.Name]);

% Merge events
addevent(tsout,horzcat(ts1.Events,ts2.Events));
