function tsout = mtimes(ts1, ts2)
%MTIMES Overloaded multiplication
%
%   Author(s): James G. Owen
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2004/04/11 00:33:50 $

% Check sizes match
if ~isequal(getGridSize(ts1),getGridSize(ts2))
    error('timeseries:mtimes:badsizes',...
        'Time series have differing lengths')
end

% Check axes alignement
if ts1.DataInfo.GridFirst ~= ts2.DataInfo.GridFirst 
    error('timeseries:mtimes:badalign',...
        'Time vector are not both aligned along the same dimension')
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
    error('timeseries:mtimes:badtimes','Time vectors do not match')
end

% Load the data so its not extracted for each pass of the loop and check
% the dimensions
data1 = ts1.Data;
s1 = hdsGetSize(data1);
data2 = ts2.Data;
s2 = hdsGetSize(data2);
if length(s1)~=length(s2)
    error('timeseries:mtimes:nonconfdim', ...
        'Cannot multiply time series where data has differing dimensions')
end
if length(s1)>3
    error('timeseries:mtimes:non3dimmax', ...
        'Cannot multiply time series with data of dimension > 3')
end

% For mtimes if both input data is 2d then arithmatic can be performed
% directly on the ord data. Otherwise we must step through one sample at
% a time and perform the mtimes on a one sample slice of ord data
if length(s1)==2 && length(s2)==2
    % Only columns of data can be multiplied with mtimes
    if s1(2)~=1 || s2(2)~=1
        msg = ['Cannot multiply data of size ', num2str(s1), ...
            ' by ', num2str(s2)];
        error('timeseries:mtimes:nonconf',msg)        
    end   
    
    % If either ord data is an ArrayAdaptor try to invoke the native 
    % overloaded mtimes, if that fails cast as double and add the old fashioned
    % way
    try
       dataout = data1*data2;
	catch
       try   
           dataout = double(data1)*double(ts2.Data);
       catch
           errstr = sprintf('%s\n%s','mtimes failed for this type of ordinate data object.', ...
                     'Try implementing a double cast method or overloaded addition for this object');
           error('timeseries:mtimes:castfail',errstr)
       end
    end
else % Perform mtimes on each sample for 3d arrays -> slow	
    s = [s1(1:2) s2(3)]; % Output array size 
    % Check conformability
    if s1(3)~=s2(2)
        msg = ['Sample sizes of ', num2str(s1(2:end)) , ' and ',...
            num2str(s2(2:end)), ' are not conformable'];
        error('timeseries:mtimes:nonconfdim', msg)
    end
	try  
       dataout = hdsNewArray(data1,s); 
       for k=1:s(1)
          r = [{k} repmat({':'},[1 length(s(2:end))])];
          dataout = hdsSetSlice(dataout,r,feval('mtimes',hdsReshapeArray(hdsGetSlice(data1,r),[1 s1(2:end)]), ...
              hdsReshapeArray(hdsGetSlice(data2,r),[1 s2(2:end)])));
       end
	catch
       % Try casting to double in case ordinate data type does not support
       % mtimes arithmatic 
       dataout = hdsNewArray(1,[s1(1:2) s2(3)]); 
       try
           data1 = double(data1);
           data2 = double(data2);
           for k=1:s(1)
               r = [{k} repmat({':'},[1 length(s(2:end))])];
               dataout = hdsSetSlice(dataout,r,feval('mtimes',hdsReshapeArray(hdsGetSlice(data1,r),s1(2:end)), ...
                  hdsReshapeArray(hdsGetSlice(data2,r),s2(2:end))));  
           end
       catch
           errstr = sprintf('%s\n%s','mtimes failed for this type of ordinate data object.', ...
                     'Try implementing a double cast method or overloaded addition for this object');
           error('timeseries:mtimes:badcast',errstr)
       end

	end
end    

% Build output time series. If both time series are subclasses 
% try to make the output the same classs
if classhandle(ts1) == classhandle(ts2)
    c = classhandle(ts1);
    tsout = eval(sprintf('%s.%s',c.Package.Name,c.Name));
    set(tsout,'Data', dataout,'Time',ts1timevec)
else
    tsout = tsdata.timeseries;
    initialize(tsout,dataout,ts1timevec);
end

set(tsout,'Name',['Mtimes_' ts1.Name '_' ts2.Name]);
set(tsout.timeInfo,'Startdate',outprops.ref,'Units', ...
    outprops.outunits,'Format',outprops.outformat);

% Quality arithmatic - merge quality info and combine quality codes
if ~isempty(ts1.qualityInfo) && ~isempty(ts2.qualityInfo)
    tsout.qualityInfo = merge(ts1.qualityInfo,ts2.qualityInfo);
end
if ~isempty(get(get(tsout,'qualityInfo'),'Code')) && ~isempty(ts1.quality) && ~isempty(ts2.quality)
    tsout.quality = min(ts1.quality,ts2.quality);
end

% Merge ordinate metadata
tsout.dataInfo = mtimes(ts1.dataInfo,ts2.dataInfo);

% Merge events
addevent(tsout,horzcat(ts1.Events,ts2.Events));

