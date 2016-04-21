function initialize(varargin)
%INTIIALIZE Utility method to build time series objects
%
%   Author(s): James G. Owen
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2004/04/11 00:33:47 $

nargchk(nargin,2,5);
this = varargin{1};
varargin = varargin(2:end);
datasrc = [];
timesrc = [];
time = [];
data = [];
 
% If first argument is empty create an empty time series
if isempty(varargin{1}) || min(hdsGetSize(varargin{1}))<1
    varargin{1} = '';
end
            
% Parse inputs
switch nargin
    case 2 %timeseries(data) or timeseries(name)
        if isa(varargin{1},'char')
            name = varargin{1};
        else    
            time = localBuildTime(varargin{1});
            [data, datasrc] = localParseData(varargin{1});
            name = 'default';
        end    
    case 3 % timeseries(data, 'name') or timeseries(data, time)
        if isa(varargin{2},'char') || isempty(varargin{2}) % 2nd arg is a name or empty
            name = varargin{2};
            if isempty(name)
                name = 'default';
            end
            time = localBuildTime(varargin{1});
        % Second argument is time
        % Time vector, cell array, time src or char array    
        elseif isnumeric(varargin{2}) || iscell(varargin{2}) || (ischar(varargin{2}) && ...
                min(size(varargin{2}))>1) || isa(varargin{2},'hds.ArrayContainer')
            name = 'default';
            % Process time vector
            if isa(varargin{2},'hds.ArrayContainer')
                timesrc = varargin{2};
            else
                time = varargin{2};
                if ischar(time)
                    time = cellstr(time);
                end
            end
        else
            error('timeseries:initialize:notime',...
 'The second argument must represent the time vector or the time series name')
        end
        % Process data vector
        [data, datasrc] = localParseData(varargin{1});
    case 4 % timeseries(data, time, 'name')
        [data, datasrc] = localParseData(varargin{1});
        if isempty(varargin{2}) % No time vector, build default
            time = localBuildTime(varargin{1});
        elseif isa(varargin{2},'hds.ArrayContainer')
            timesrc = varargin{2};
        elseif isnumeric(varargin{2}) || iscell(varargin{2})
            time = varargin{2};
        elseif ischar(varargin{2})
            time = {varargin{2}};
        else
            error('Invalid time vector')
        end
        name = varargin{3};    
end

% % Add and initialize value arrays 
% this.Data_ = [tsdata.timeseriesArray('Data');
%               tsdata.timeseriesArray('Time');
%               tsdata.timeseriesArray('Quality')];
%           
% % Add default interpolation
% this.dataInfo.Interpolation = tsdata.interpolation('zoh');
% 
% % Time is the grid
% setgrid(this,'Time');

if ~isempty(time) % Validate time vector
    if isnumeric(time)
       time = tsChkTime(time);
    end
    s = hdsGetSize(data);
 
    % Sort time and data vectors. Note this cannot be done if either vector
    % is derived from a data source because the action of sorting would
    % cause time and data to be out of synch
    if ~isempty(datasrc) && ((isnumeric(time) && ~issorted(time)) || ...
            (iscell(time) && issorted(datenum(time)))) 
        error('timeseries:initialize:unsorted',...
            'Unsorted time vectors cannot be used when ordinate data is defined by a data source')
    elseif ~isempty(datasrc) && isnumeric(time)
        I = tssorttime(time);
    elseif isnumeric(time) && isnumeric(data)
        I = tssorttime(time,data);
    else
        I = (1:length(time))';
    end
    
    if ~isempty(datasrc) && length(I)<length(time)
        error('timeseries:initialize:unsorted',...
           'Duplicate times are not allowed when ordinate data is defined by a data source')
    elseif length(I)<1
        error('timeseries:initialize:nosingleton',...
           'Time vectors must have non-empty time vectors')
    end
    
    % Assign the time vector
    if iscell(time)
        this.setAbsTime(time(I));	
        this.Time = tsChkTime(this.Time);
    else
        this.Time = time(I);
    end
elseif ~isempty(timesrc)
    setdatasrc(this,timesrc,'Time');
end
    

% Assign and sort data if both time and data are not derived from a data
% src
if ~isempty(data) && ~isempty(time) 
    s = hdsGetSize(data);
    % If only the last dimension is aligned with time then assign the 
    % GridFirst properties to refelect this
    if s(1)~=length(time) && s(end)==length(time)
         this.Data_(1).Metadata.GridFirst = false;
         this.Data_(1).GridFirst = false; 
         this.Data = hdsReshapeArray(hdsGetSlice(data, ...
             [repmat({':'},[1 length(s)-1]) {I}]), ...
             [s(1:end-1) length(I)]);
    elseif s(1)==length(time)
        this.Data = hdsReshapeArray(hdsGetSlice(data,[{I} repmat({':'}, ...
            [1 length(s)-1])]),[length(I) s(2:end)]);
    else
        error('timeseries:intialize:mismatch',...
            'Mismatch between the size of the time and data vectors')
    end
elseif ~isempty(datasrc)
    setdatasrc(this,datasrc,'Data');
end

% Assign the name
this.Name = name;

function time = localBuildTime(data)

% Construct a default time vector from numerical ordinate data or a data
% src

if isa(data,'hds.ArrayContainer')
    try
       s = data.size;
    catch
       error('This syntax is invalid for data sources that so not support getsize')
    end
    if s(1)>1
        time = (0:(s(1)-1))';
    else
        time = (0:(s(end)-1))';
    end
elseif isnumeric(data) || isa(data,'tsdata.ArrayAdaptor')
    s = hdsGetSize(data);
    if s(1)>1
        time = (0:(s(1)-1))';
    else
        time = (0:(s(end)-1))';
    end
else
    error('timeseries:initialize:indata',...
        'Invalid data type')
end


function [data, datasrc] = localParseData(datainvec)

data = [];
datasrc = [];
if isa(datainvec,'hds.ArrayContainer')
    datasrc = datainvec;
elseif (isnumeric(datainvec) && ~isempty(datainvec)) ...
        || isa(datainvec,'tsdata.ArrayAdaptor')
    data = datainvec;
else
    error('timeseries:initialize:nodata',...
        'The first argument must represent the ordinate data')
end

