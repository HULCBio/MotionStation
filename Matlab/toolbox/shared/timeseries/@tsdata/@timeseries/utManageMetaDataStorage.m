function propout = utManageMetaDataStorage(tsin,eventdata,varname, writeflag)
%UTMANAGEMETADATASTORAGE

% Author(s): James G. Owen
% Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2003/12/22 00:55:14 $

% Create an instance of the singleton variable manager
vm = hds.VariableManager;

% Find the variable for the specified variable name timeseries varname. Note that
% when this function is called with a varname of Data it refers to the
% ordinate data variable who's name may have changed since creation
switch varname
    case 'Data'
    % Find data variable (who's name may have changed from 'Data') as the
    % exterior of the set of variables 'Time' and 'Quality' stored in the Data_
    % property. Cannot use the handles to variables since this method may
    % being called during a load when the previous time and quality handles
    % will have changed
    vars = cell2mat(get(tsin.Data_,{'Variable'}));
    [junk,idx] = setdiff(get(vars,{'Name'}),{'Time';'Quality'});
    var = vars(idx);
    case {'Time','Quality'}
        [var,idx] = findvar(tsin,varname);
end
if isempty(var)
    propout = []; % No data storage
    return
end

ValueArray = tsin.Data_(idx); % Find the right ValueArray

% Write to specified metadata storage
if writeflag
    % Write new value into specified data record

    
    if strcmp(ValueArray.ReadOnly,'off')
        % If this is new @timemetadata need to sync its properties
        % with stored time vector
        if isa(ValueArray.metadata,'tsdata.abstracttimemetadata')
           tvec = ValueArray.getArray; 
        end
    else
        error('The TimeInfo property is read only for tscollection members.')
    end

    ValueArray.metadata = eventdata;
    
    % Do not store at timeseries level
    propout = [];
else
    % Read metadata
    propout = ValueArray.metadata; % Find the right ValueArray
end
