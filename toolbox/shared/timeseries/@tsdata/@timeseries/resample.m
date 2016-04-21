function tsout = resample(tsin, timevec)
%RESAMPLE redefines time series objects on a new time vector
%
% TSOUT = RESAMPLE(TSIN,TIMEVEC)
%
% Resamples TSIN on a new time vector defined by TIMEVEC. If the time
% vector is numeric, it is assumed to be specified relative to the 
% @timeseries startdate property in the same units as the time-series
% object, if the time vector is an array of date strings then the absolute
% time vectors are combined. 
%
%   See also MERGE.

%   Authors: James G. Owen
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/11 00:33:52 $
      
if iscell(timevec) || ischar(timevec)
    % Get abs time refenence and convert datastrs to a relative numeric
    % time vector
    try
        ref = datenum(tsin.timeInfo.Startdate);
        t = tsunitconv(tsin.timeInfo.Units, 'days')*(datenum(timevec) - ref);
    catch
        error('timeseries:resample:norel', ...
            'Resampling using datestrs requires that the time-series object with an absolute time vector')
    end
elseif isnumeric(timevec) && length(timevec)>1
    % Numeric time vector
    t = timevec;
elseif isnumeric(timevec) && length(timevec)==1
    % Time interval has been specified
    if timevec<0 
        error('timeseries:resample:interval', ...
            'Time interval has zero or negative length')
    end
    t = tsin.timeInfo.Start:timevec:tsin.timeInfo.End;
else
    error('timeseries:resample:badtime','Invalid time vector')
end

% Interpolate, taking into account the dimension aligned with time
if tsin.dataInfo.GridFirst
    dataout = tsin.dataInfo.Interpolation.interpolate(tsin.time, ...
        tsin.data,t);
else
    thisdata = tsin.data;
    dataout = tsin.dataInfo.Interpolation.interpolate(tsin.time, ...
        thisdata,t,ndims(thisdata));
end

%% Build output time series of whatever class
c = classhandle(tsin);
tsout = eval(sprintf('%s.%s',c.Package.Name,c.Name));
set(tsout.timeInfo,'Units',tsin.timeInfo.Units, ...
    'Startdate',tsin.timeInfo.Startdate);
tsout.dataInfo = tsin.dataInfo.copy;
set(tsout,'Data',dataout,'Time',t,'Name','default');

%% Add bck events
addevent(tsout,tsin.Events);

