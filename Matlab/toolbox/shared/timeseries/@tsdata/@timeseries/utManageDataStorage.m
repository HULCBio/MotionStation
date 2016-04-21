function propout = utManageDataStorage(tsin,eventdata,varname,writeflag)
%UTMANAGEDATASTORAGE

% Author(s): James G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2004/04/11 00:33:56 $

% Find the variable for the specified variable name timeseries varname. Note that
% when this function is called with a varname of Data it refers to the
% ordinate data variable who's name may have changed since creation

% Create an instance of the singleton variable manager
vm = hds.VariableManager;

switch varname
    case 'Data'
    % Find data variable (who's name may have changed from 'Data') as the
    % exterior of the set of variables 'Time' and 'Quality' stored in the Data_
    % property. Cannot use the handles to variables since this method may
    % being called during a load when the previous time and quality handles
    % will have changed
    vars = cell2mat(get(tsin.Data_,{'Variable'}));
    [junk,idx] = setdiff(get(vars,{'Name'}),{'Time';'Quality'});
    if ~isempty(idx)
        var = vars(idx);
    else % If there is no data storage - build one
        newValueArray = tsdata.timeseriesArray('Data');
        newValueArray.Metadata.Interpolation = tsdata.interpolation('zoh');
        tsin.Data_ = [tsin.Data_; newValueArray];
        idx = length(tsin.Data_);
        var = hds.variable('Data');
    end
    
    case 'Time'
        [var,idx] = findvar(tsin,'Time');
        % If there is no data storage for time create it and set the grid
        if isempty(idx)
            newValueArray = tsdata.timeseriesArray('Time');
            tsin.Data_ = [tsin.Data_; newValueArray];
            tsin.setgrid('Time');
            idx = length(tsin.Data_);
            var = hds.variable('Time');
        end
    case 'Quality'
        [var,idx] = findvar(tsin,'Quality');
        % If there is no data storage for quality create it and set the grid
        if isempty(idx)
            newValueArray = tsdata.timeseriesArray('Quality');
            tsin.Data_ = [tsin.Data_; newValueArray];    
            idx = length(tsin.Data_);
        end
end

ValueArray = tsin.Data_(idx); % Find the right ValueArray

% Sync the storage orientation from the metadata object (if
% present) with the @timeseriesArray
if ~isempty(ValueArray.metadata)
    ValueArray.GridFirst = ValueArray.metadata.GridFirst;
end
                
% Extract data *from* specifed data storage
if ~writeflag   
    propout = ValueArray.getArray; 

% Extract data *to* specifed data storage
else
    if strcmp(ValueArray.ReadOnly,'off')
        % Must allow empty values to be written to support specification of an empty quality
        % property
        if ~isempty(eventdata)
            % The error returned from utCheckArraySize when there is a size
            % mismatch is not worded appropriately for time series
            try
                [NewValue,GridSize,SampleSize] = ...
                  utCheckArraySize(tsin,{eventdata},var,ValueArray.GridFirst);
            catch
                try 
                  [NewValue,GridSize,SampleSize] = ...
                       utCheckArraySize(tsin,{eventdata},var, ...
                       ~ValueArray.GridFirst);
                   ValueArray.GridFirst = ~ValueArray.GridFirst;
                   ValueArray.metadata.GridFirst = ValueArray.GridFirst;
                catch 
                   error('timeseries:utManageDataStorage:arraymismatch',...
                     'Size of data array does not match the length of the time series');
                end
            end
            % Store data (may fail if array container is read only)
            ValueArray.SampleSize = SampleSize;
            if ~isempty(ValueArray.SampleSize) && ~isequal(ValueArray.SampleSize,SampleSize)
                warning('Time series data has been re-dimensioned to remain syncronized with the time vector')
            end    
            ValueArray.setArray(ValueArray.utReshape(NewValue,GridSize));
        else
            ValueArray.SampleSize = 0;
            ValueArray.setArray([]);
        end

    else
        error('timeseries:schema:timero', ...
            'The Time property is read only for tscollection members.')
    end

    % Do not store specified data in the timeseries property
    propout = [];

    % Notify data listeners
    tsin.send('datachange',handle.EventData(tsin,'datachange'));
end
