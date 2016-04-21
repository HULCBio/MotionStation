function varargout = signalbuilder(blockH, method, varargin)
%SIGNALBUILDER - Command line interface to the Simulink Signal Builder block.
%
%  [TIME, DATA] = SIGNALBUILDER(BLOCK) Returns the X coordinates, TIME, and Y
%  coordinates, DATA, of the Signal Builder block BLOCK.  TIME and DATA take
%  different formats depending on the block configuration:
%
%    Configuration:        TIME/DATA format:                        
%    
%    1 signal, 1 group     Row vector of break points
%
%    >1 signal, 1 group    Column cell vector where each element corresponds to
%                          a separate signal and contains a row vector of breakpoints
%                          
%    1 signal, >1 group    Row cell vector where each element corresponds to a 
%                          separate group and contains a row vector of breakpoints
%                          
%    >1 signal, >1 group   Cell matrix where each element (i,j) corresponds to 
%                          signal i and group j.
%                          
%
%  [TIME, DATA, SIGLABELS] = SIGNALBUILDER(BLOCK) Returns the signal labels,
%  SIGLABELS, in a string or a cell array of strings.
%
%  [TIME, DATA, SIGLABELS, GROUPLABELS] = SIGNALBUILDER(BLOCK) Returns the group
%  labels, GROUPLABELS in a string or a cell array of strings.
%
%  BLOCK = SIGNALBUILDER([],'CREATE', TIME, DATA, SIGLABELS, GROUPLABELS) Create
%  a new Signal Builder block in a new Simulink model using the specified values.  
%  If DATA is a cell array and TIME is a vector the TIME values are duplicated for
%  each element of DATA.  Each vector within TIME and DATA must be the same 
%  length and have at least two elements.  If TIME is a cell array, all elements
%  in a column must have the same initial and final value.  Signal labels, SIGLABELS,
%  and group labels, GROUPLABELS, can be omitted to use default values.  The function
%  returns the path to the new block, BLOCK.
%
%  BLOCK = SIGNALBUILDER(BLOCK,'APPEND', TIME, DATA, SIGLABELS, GROUPLABELS) Append 
%  new groups to the Signal Builder block, BLOCK.  The TIME and DATA arguments must 
%  have the same number of signals as the existing block.
%
%  GET/SET Methods for specific signals and groups
%
%  [TIME,DATA] = SIGNALBUILDER(BLOCK,'GET',SIGNAL,GROUP) Get the time and data values
%  for the specified signal(s) and group(s).  The SIGNAL parameter can be the unique
%  name of a signal, a scalar index of a signal, or an array of signal indices.  The
%  GROUP parameter can be a unique group label, a scalar index, or an array of indices.
%
%  SIGNALBUILDER(BLOCK,'SET',SIGNAL,GROUP,TIME,DATA) Set the time and data values
%  for the specified signal(s) and group(s).  Use empty values of TIME and DATA to 
%  remove groups and signals.

% Copyright 2003 The MathWorks, Inc.

    % Put arguments in a canonical form
    if ischar(blockH)
        try,
            objH = get_param(blockH,'Handle');
        catch
            error(['Invalid block, "' blockH '"']);
        end
        blockH = objH;
    end
    
    if nargin<2
        method = 'props';
    else
        method = lower(method);
        if ~ischar(method)
            error('METHOD should be a string.');
        end
    end
    
    if strcmp(method,'get') || strcmp(method,'set')
        if nargin<3
            error(['The ' method ' method requires SIGNAL and GROUP parameters.']);
        else
            signal = varargin{1};
            if ~ischar(signal) && ~isnumeric(signal)
                error('SIGNAL should be a string or numeric.');
            end
        end
    
        if nargin<4
            error(['The ' method ' method requires SIGNAL and GROUP parameters.']);
        else
            group = varargin{2};
            if ~ischar(group) && ~isnumeric(group)
                error('GROUP should be a string or numeric.');
            end
        end
    
        if nargin<5
            time = [];
        else
            time = varargin{3};
            if ~iscell(time) && ~isnumeric(time)
                error('TIME should be a vector or cell array.');
            end
        end
    
        if nargin<6
            data = [];
        else
            data = varargin{4};
            if ~iscell(data) && ~isnumeric(data)
                error('DATA should be a vector or cell array.');
            end
        end
    else
        if nargin<3
            time = [];
        else
            time = varargin{1};
            if ~iscell(time) && ~isnumeric(time)
                error('TIME should be a vector or cell array.');
            end
        end
    
        if nargin<4
            data = [];
        else
            data = varargin{2};
            if ~iscell(data) && ~isnumeric(data)
                error('DATA should be a vector or cell array.');
            end
        end
    
        if nargin<5
            sigLabels = [];
        else
            sigLabels = varargin{3};
            if ~isempty(sigLabels) && ~iscell(sigLabels) && ~ischar(sigLabels)
                error('SIGLABELS should be a string or cell array.');
            end
        end
    
        if nargin<6
            groupLabels = [];
        else
            groupLabels = varargin{4};
            if ~iscell(groupLabels) && ~ischar(groupLabels)
                error('GROUPLABELS should be a string or cell array.');
            end
        end
    end


    switch(method)
    case 'get',
        savedUD = sigbuilder('cmdApi', 'savedData', blockH);
        [signalIdx,goupIdx,msg] = local_resolve_signal_group_index(savedUD, signal, group, 1);
        if ~isempty(msg)
            error(msg);
        end
        if (length(signalIdx)==1 && length(goupIdx)==1)
            time = savedUD.channels(signalIdx).allXData{goupIdx};
            data = savedUD.channels(signalIdx).allYData{goupIdx};
        else
            sigCnt = length(signalIdx);
            grpCnt = length(goupIdx);
            time =cell(sigCnt,grpCnt);
            data =cell(sigCnt,grpCnt);
            for idx = 1:length(signalIdx)
                sigIdx = signalIdx(idx);
                time(idx,:) = savedUD.channels(sigIdx).allXData(goupIdx);
                data(idx,:) = savedUD.channels(sigIdx).allYData(goupIdx);
            end
        end
        varargout{1} = time;
        varargout{2} = data;
        
    case 'set',
        savedUD = sigbuilder('cmdApi', 'savedData', blockH);
        [signalIdx,goupIdx,msg] = local_resolve_signal_group_index(savedUD, signal, group, 0);
        if ~isempty(msg)
            error(msg);
        end
        
        % We may be removing time and data entries
        if isempty(time) && isempty(data)
            if isequal(signalIdx,1:length(savedUD.channels))
                removeGroups = goupIdx;
                sigbuilder('cmdApi', 'removeGroup', blockH, removeGroups);
            elseif isequal(goupIdx,1:length(savedUD.dataSet))
                removeSignals = signalIdx;
                sigbuilder('cmdApi', 'removeSig', blockH, removeSignals);
            else
                error('You can only an entire group or signal');
            end
        end
        
        % Check data consistency
        msg = local_check_time_data_consistency(time,data);
        if ~isempty(msg)
            error(msg)
        end
        
        [time,data,sigLabels,groupLabels] = local_make_canonical(time,data,[],[]);
        newSigCnt = length(signalIdx);
        newGrpCnt = length(goupIdx);
        [dataSigs,dataGrps] = size(data);
        if (newSigCnt ~= dataSigs)
            error(['Data mismatch: ' num2str(newSigCnt) ' signals specified and ' ...
                    num2str(dataSigs) ' rows in data.']);
        end
    
        if (newGrpCnt ~= dataGrps)
            error(['Data mismatch: ' num2str(newGrpCnt) ' groups specified and ' ...
                    num2str(dataGrps) ' columns in data.']);
        end
        sigbuilder('cmdApi', 'set', blockH, signalIdx, goupIdx, time, data);
    
    case 'props',
        savedUD = sigbuilder('cmdApi', 'savedData', blockH);
        chanCnt = length(savedUD.channels);
        groupCnt = length(savedUD.dataSet);
        if (chanCnt==1 && groupCnt==1)
            time = savedUD.channels.allXData{1};
            data = savedUD.channels.allYData{1};
        elseif (chanCnt==1)
            time = savedUD.channels.allXData;
            data = savedUD.channels.allYData;
        else   %if (groupCnt==1)
            time = cell(chanCnt,groupCnt);
            data = cell(chanCnt,groupCnt);
            for i=1:chanCnt
                time(i,:) = savedUD.channels(i).allXData;
                data(i,:) = savedUD.channels(i).allYData;
            end
        end
        
        varargout{1} = time;
        varargout{2} = data;
        
        if nargout>2
            varargout{3} = {savedUD.channels.label};
        end
        
        if nargout>3
            varargout{4} = {savedUD.dataSet.name};
        end
        
    case 'create',
        
        % Check data consistency
        msg = local_check_time_data_consistency(time,data);
        if ~isempty(msg)
            error(msg)
        end
        
        [time,data,sigLabels,groupLabels] = local_make_canonical(time,data,sigLabels,groupLabels);
        blockH = sigbuilder('cmdApi', 'create', time, data, sigLabels, groupLabels);
        varargout{1} = blockH;
        
    case 'append',
        % Check data self consistency
        msg = local_check_time_data_consistency(time,data);
        if ~isempty(msg)
            error(msg)
        end
        
        [time,data,sigLabels,groupLabels] = local_make_canonical(time,data,sigLabels,groupLabels);
        
        % Check consistency with existing block
        [chanCntNow,groupCntNow] = sigbuilder('cmdApi', 'counts', blockH);
        [rows,cols] = size(time);
        
        if (chanCntNow==1)
            if(rows>1 && cols>1)
                error('Existing block has a single channel.  You cannot append more signals.');
            else
                % Make the entries a row cell vector
                newGroupCnt = length(time);
                time = time(:)';
                data = data(:)';
            end
        else
            newGroupCnt = cols;
            if (rows ~= chanCntNow)
                str = num2str(chanCntNow);
                error(['Existing block has ' str ' signals. Data should have ' str ' rows.']);
            end
        end
        
        if isempty(groupLabels)
            for i=1:newGroupCnt 
                groupLabels{i} = ['Group ' num2str(groupCntNow+i)];
            end
        else
            if length(groupLabels) ~= newGroupCnt
                error(['Data has ' num2str(newGroupCnt) ' columns and ' num2str(length(groupLabels)) ' group labels were supplied.']);
            end
        end
        sigbuilder('cmdApi', 'append', blockH, time, data, sigLabels, groupLabels);
        varargout{1} = blockH;
        
    otherwise,
        error(['Unexpected METHOD value: "' method '"']);
    end
    

function [time,data,sigLabels,groupLabels] = local_make_canonical(time,data,sigLabels,groupLabels)
    if ~isempty(sigLabels) && ~iscell(sigLabels)
        sigLabels = {sigLabels};
    end
    
    if ~isempty(groupLabels) && ~iscell(groupLabels)
        groupLabels = {groupLabels};
    end
    

    if ~iscell(time)
        time = {time};
    end
    
    if ~iscell(data)
        data = {data};
    end
    
    if isequal(size(time),size(data))
        return;
    end
    
    [rowCnt,colCnt] = size(data);
    if length(time)==1
        timeElm = time;
        time = cell(rowCnt,colCnt);
        for i=1:rowCnt
            for j=1:colCnt
                time(i,j) = timeElm;
            end
        end
     else
        timeOrig = time;
        time = cell(rowCnt,colCnt);
        for i=1:rowCnt
            for j=1:colCnt
                time(i,j) = timeOrig(j);
            end
        end
     end
        
    

function msg = local_check_time_data_consistency(time,data)

    % First make sure the arguments are consistent
    if iscell(data)
        [sigCnt,grpCnt] = size(data);
        if iscell(time)
            if isequal(size(time),size(data))
                for i=1:sigCnt
                    for j=1:grpCnt
                        msg = local_check_time_data_pair(time{i,j},data{i,j});
                        if ~isempty(msg)
                            msg = [sprintf('TIME{%d,%d}, DATA{%d,%d} argument inconsistency: ',i,j,i,j) msg];
                            return;
                        end
                    end
                end
            elseif length(time)==grpCnt
                for i=1:sigCnt
                    for j=1:grpCnt
                        msg = local_check_time_data_pair(time{j},data{i,j});
                        if ~isempty(msg)
                            msg = [sprintf('TIME{%d}, DATA{%d,%d} argument inconsistency: ',j,i,j) msg];
                            return;
                        end
                    end
                end
            elseif length(time)==1
                for i=1:sigCnt
                    for j=1:grpCnt
                        msg = local_check_time_data_pair(time{1},data{i,j});
                        if ~isempty(msg)
                            msg = [sprintf('TIME, DATA{%d,%d} argument inconsistency: ',i,j) msg];
                            return;
                        end
                    end
                end
            else
                msg = ['Size mismatch.  TIME should be a scalar cell array, a vector with the same length' char(10) ...
                       'as the column count in DATA or a cell array with the same dimensions as DATA'];
            end

        else
            for i=1:sigCnt
                for j=1:grpCnt
                    msg = local_check_time_data_pair(time,data{i,j});
                    if ~isempty(msg)
                        msg = [sprintf('TIME, DATA{%d,%d} argument inconsistency: ',i,j) msg];
                        return;
                    end
                end
            end
        end
    else
        if iscell(time)
            msg = 'TIME must be a vector when DATA is a vector';
            return
        end
        msg = local_check_time_data_pair(time,data);
    end

    
function [signalIdx,goupIdx,msg] = local_resolve_signal_group_index(savedUD, signal, group, checkBounds)
    signalIdx = [];
    goupIdx = [];
    msg = '';
    
    sigCnt = length(savedUD.channels);
    if isempty(signal)
        signalIdx = 1:sigCnt;
    elseif ischar(signal)
        allNames = {savedUD.channels.label};
        signalIdx = find(strcmp(signal,allNames));
        if isempty(signalIdx)
            msg = ['Signal "' signal '" does not exist'];
            return;
        end
        if length(signalIdx)>1
            msg = ['Signal "' signal '" is not unique'];
            return;
        end
    else
        if islogical(signal)
            signalIdx = find(signal);
        else
            signalIdx = signal;
        end
        if any(signalIdx<1)
            msg = 'Invalid signal index';
        end
        if checkBounds && any(signalIdx>sigCnt)
            msg = 'Invalid signal index';
        end
    end
    
    grpCnt = length(savedUD.dataSet);
    if isempty(group)
        goupIdx = 1:grpCnt;
    elseif ischar(group)
        allNames = {savedUD.dataSet.name};
        goupIdx = find(strcmp(group,allNames));
        if isempty(goupIdx)
            msg = ['Group "' group '" does not exist'];
            return;
        end
        if length(goupIdx)>1
            msg = ['Group "' group '" is not unique'];
            return;
        end
    else
        if islogical(group)
            goupIdx = find(group);
        else
            goupIdx = group;
        end
        if any(goupIdx<1)
            msg = 'Invalid group index';
        end
        if checkBounds && any(goupIdx>grpCnt)
            msg = 'Invalid group index';
        end
    end
    
    
function msg = local_check_time_data_pair(time,data)

    msg = '';
    if length(time) ~= length(data)
        msg = sprintf('Size mismatch, %d elements in time and %d elements in data.', ...
                        length(time), length(data));
        return;
    end
    
    if any(diff(time)<0)
        msg = sprintf('Time must monotonically increase.');
        return;
    end
    
    if ~isreal(time)
        msg = sprintf('Time must be real valued.');
    end

    if ~isreal(data)
        msg = sprintf('Data must be real valued.');
    end

    