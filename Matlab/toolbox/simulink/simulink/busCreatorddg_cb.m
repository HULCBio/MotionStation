function varargout = busCreatorddg_cb(dlg, action, varargin)

% Copyright 2003-2004 The MathWorks, Inc.

if ~isempty(dlg)
    src = dlg.getDialogSource;
    h   = src.getBlock;
end

switch action
    case 'getNumIn'
        blkH   = varargin{1};
        inputs = varargin{2};
        numIn  = getNumIn(get_param(blkH, 'BusStruct'), inputs);
        varargout{1} = num2str(numIn);

    case 'getTreeItems'
        blkH   = varargin{1};
        inputs = varargin{2};
        % get base tree items and refactor to fit user's UI choices
        [items handles] = getTreeItems(get_param(blkH, 'BusStruct'));
        if isa(get_param(blkH,'Object'),'Simulink.BusCreator')
            items = refactor(get_param(blkH,'Object'), items, inputs, true);
        end
        varargout{1} = items;
        varargout{2} = handles;

    case 'getListEntries'
        blkH   = varargin{1};
        inputs = varargin{2};
        % get base list entries and refactor to fit user's UI choices
        entries = getListEntries(get_param(blkH, 'BusStruct'));
        entries = refactor(get_param(blkH,'Object'), entries, inputs, false);
        varargout{1} = entries;
        varargout{2} = cellarr2str(entries);

    case 'doInherit'
        doInherit(dlg, 'bcInherit', true);

    case 'doInputs'
        inputs = varargin{1};
        doInputs(dlg, 'bcNumIn', inputs);
        
    case 'doListSelection'
        tag    = varargin{1};
        doListSelection(dlg, tag);
        
    case 'doTreeSelection'
        tag = varargin{1};
        doTreeSelection(dlg, tag);

    case {'doFind', 'hilite'}
        doFind(dlg);
        
    case 'doBusObjEdit'
        buseditor('Create',dlg.getWidgetValue('BusObject'));
        
    case 'doUp'
        if isa(h,'Simulink.BusCreator')
            tag = 'bcSignalsList';
        else
            tag = 'bcOutputsList';
        end
        doSwap(dlg, -1, tag);
        
    case 'doDown'
        if isa(h,'Simulink.BusCreator')
            tag = 'bcSignalsList';
        else
            tag = 'bcOutputsList';
        end
        doSwap(dlg, +1, tag);
        
    case 'doRefresh'
        if isa(h,'Simulink.BusCreator')
            dlg.refresh;            
            doInherit(dlg, 'bcInherit', false);
        elseif isa(h,'Simulink.BusSelector')
            entries = validateSelections(clean(dlg.getUserData('bcOutputsList')), h.InputSignals);
            entriesStr = strrep(strrep(cellarr2str(entries),'''',''),':','.');
            src.state.OutputSignals = entriesStr;
            dlg.setUserData('bcOutputsList',entries);
            dlg.refresh;
        elseif isa(h,'Simulink.BusAssignment')
            entries = validateSelections(clean(dlg.getUserData('bcOutputsList')), h.InputSignals);
            entriesStr = strrep(strrep(cellarr2str(entries),'''',''),':','.');
            src.state.AssignedSignals = entriesStr;
            dlg.setUserData('bcOutputsList',entries);
            dlg.refresh;
        end
    
    case 'doRename'
        inputs = varargin{1};
        doRename(dlg, inputs);

    case 'doPreApply'
        if isa(h,'Simulink.BusCreator')
            busCreatorddg_cb(dlg,'doRename',src.state.Inputs);
            customNames = dlg.getWidgetValue('bcInherit');
            if customNames & ~isempty(str2num(src.state.Inputs))
                src.state.Inputs = cellarr2str(dlg.getUserData('bcSignalsList'));
            elseif ~customNames & isempty(str2num(src.state.Inputs))
                src.state.Inputs = num2str(length(str2cellarr(src.state.Inputs)));
            end
            dlg.setWidgetValue('Inputs',src.state.Inputs);
        elseif isa(h,'Simulink.BusSelector')
            dlg.setWidgetValue('OutputSignals',clean(src.state.OutputSignals));
        elseif isa(h,'Simulink.BusAssignment')
            dlg.setWidgetValue('AssignedSignals',clean(src.state.AssignedSignals));
        end
        [varargout{2} varargout{1}] = src.preApplyCallback(dlg); %[msg noErr]
        busCreatorddg_cb(dlg, 'doRefresh');

    case 'doClose'
        busCreatorddg_cb(dlg, 'unhilite');
        
    case 'doSelect'
        name = regexprep(dlg.getWidgetValue('bcInputsTree'), {'([^/]|//+)++/','//'}, {'$1.','/'});
        if isa(h,'Simulink.BusSelector')
          src.state.OutputSignals = [src.state.OutputSignals ',' strrep(cellarr2str(name),'''','')];
          entries = strread(src.state.OutputSignals,'%s','delimiter',',')';
        else
          src.state.AssignedSignals = [src.state.AssignedSignals ',' name];
          entries = strread(src.state.AssignedSignals,'%s','delimiter',',')';
        end
        dlg.setUserData('bcOutputsList',entries);
        busCreatorddg_cb(dlg,'doRefresh');
        
    case 'doRemove'
        ind     = dlg.getWidgetValue('bcOutputsList') + 1;
        entries = dlg.getUserData('bcOutputsList');
        num     = length(entries);
        if ~isempty(ind) & ~isempty(entries) & num>1
            entries(ind) = [];
            entriesStr   = strrep(strrep(cellarr2str(entries),'''',''),':','.');
            src.state.OutputSignals = entriesStr;
            dlg.setUserData('bcOutputsList',entries);
            busCreatorddg_cb(dlg,'doRefresh');
            if isempty(dlg.getWidgetValue('bcOutputsList')) | ind == num
                dlg.setWidgetValue('bcOutputsList', num-2);
            end
        end

    case 'unhilite'
        if isa(h,'Simulink.BusCreator')
            blockHandles = dlg.getUserData('bcSignalsTree');
        else
            blockHandles = dlg.getUserData('bcInputsTree');
        end
        hiliting = char(get_param(blockHandles,'HiliteAncestors'));
        ind = strmatch('find',hiliting);
        if ~isempty(ind)
            hilite_system(blockHandles(ind), 'none');
        end
        
    case 'validate'
        blkH    = varargin{1};
        entries = varargin{2};
        blk     = get_param(blkH, 'Object');
        varargout{1} = validateSelections(clean(entries), blk.InputSignals);

    otherwise
        warning('DDG:SLDialogSource',['Unknown action in ' mfilename]);
end


% Callback functions ------------------------------------------------------
% getNumIn: return how many input signals
function numIn = getNumIn(s, inputs);
numIn = str2num(inputs);
if isempty(numIn)
    numIn = length(findstr(inputs,','))+1;
end

% getTreeItems: return a formatted representation of input signals for a
% tree widget and the handles of all blocks associated with this block
function [items, handles] = getTreeItems(s)
items   = {};
handles = [];
for i = 1:length(s)
    if isempty(s(i).signals)
        items   = [items {s(i).name}];
        handles = unique([handles s(i).src]);
    else
        [itms hdls] = getTreeItems(s(i).signals);
        items   = [items {s(i).name, itms}];
        handles = unique([handles s(i).src hdls]);
    end
end

% getListEntries: return a formatted representation of input signals for a
% listbox widget (ie: cell array of signal names)
function entries = getListEntries(s)
entries = {};
if length(s) > 0
    entries = {s(:).name};
end

% doInherit: callback function
function doInherit(dlg, tag, refresh)
if refresh
    dlg.refresh
end
if (dlg.getWidgetValue(tag) == 0)   % Inherit bus signal names...
    dlg.setEnabled('bcRename',0);
    dlg.setVisible('bcUp',0);
    dlg.setVisible('bcDown',0);
    dlg.setVisible('bcRefresh',1);
    dlg.setVisible('bcSignalsList',0);
    dlg.setVisible('bcSignalsTree',1);
else                                % Require input signal names match...
    dlg.setEnabled('bcRename',1);
    dlg.setVisible('bcUp',1);
    dlg.setVisible('bcDown',1);
    dlg.setVisible('bcRefresh',0);
    dlg.setVisible('bcSignalsList',1);
    dlg.setVisible('bcSignalsTree',0);
end

% doInputs: callback function
function doInputs(dlg, tag, inputs)
h   = dlg.getDialogSource.getBlock;
num = str2num(dlg.getWidgetValue(tag));
customNames = dlg.getWidgetValue('bcInherit');
if ~isempty(num) & isfinite(num) & num > 0 & num ~= num2str(length(h.BusStruct))
    % un-hilite_system
    busCreatorddg_cb(dlg, 'unhilite');

    % get signals list
    if ~isempty(str2num(inputs))
        signalNames = {dlg.getDialogSource.getBlock.BusStruct(:).name};
    else
        signalNames = str2cellarr(inputs);
    end

    % update signals
    newSignals = signalNames;
    currentNum = length(signalNames);
    if currentNum < num
        for i = 1 : num-currentNum
            newSignals = [newSignals {['signal', num2str(currentNum+i)]}];
        end
    elseif currentNum > num
        newSignals(num+1:end) = [];
    end

    % update state & refresh
    if customNames
        dlg.getDialogSource.state.Inputs = cellarr2str(newSignals);
    else
        dlg.getDialogSource.state.Inputs = num2str(length(newSignals));
    end
    dlg.setUserData('bcSignalsList', newSignals);
    busCreatorddg_cb(dlg, 'doRefresh');
end

% doListSelection: callback function
function doListSelection(dlg, tag)
busCreatorddg_cb(dlg, 'unhilite');
ind     = dlg.getWidgetValue(tag) + 1;
entries = dlg.getUserData(tag);
if isempty(ind)
    dlg.setEnabled('bcUp',0);
    dlg.setEnabled('bcDown',0);
elseif ind == 1
    dlg.setEnabled('bcUp',0);
    dlg.setEnabled('bcDown',1);
elseif ind == length(entries)
    dlg.setEnabled('bcUp',1);
    dlg.setEnabled('bcDown',0);
else
    dlg.setEnabled('bcUp',1);
    dlg.setEnabled('bcDown',1);
end

% doTreeSelection: callback function
function doTreeSelection(dlg, tag)
busCreatorddg_cb(dlg, 'unhilite');
if isempty(dlg.getWidgetValue(tag))
    dlg.setEnabled('bcFind',0);
    dlg.setEnabled('bcSelect',0);
else
    dlg.setEnabled('bcFind',1);
    dlg.setEnabled('bcSelect',1);
end

% doFind: callback function
function doFind(dlg)
blkH   = dlg.getDialogSource.getBlock.Handle;
sig    = {};
sigSrc = [];
% un-hilite
busCreatorddg_cb(dlg, 'unhilite');
% figure out which block we are trying to find
if dlg.isVisible('bcSignalsTree')
    sig = {regexprep(dlg.getWidgetValue('bcSignalsTree'), {'([^/]|//+)++/','//'}, {'$1.','/'})};    
elseif dlg.isVisible('bcInputsTree')
    sig = regexprep(dlg.getWidgetValue('bcInputsTree'), {'([^/]|//+)++/','//'}, {'$1.','/'});   
elseif ~isempty(dlg.getWidgetValue('bcSignalsList'))
    listCell = dlg.getUserData('bcSignalsList');
    sig = listCell(dlg.getWidgetValue('bcSignalsList')+1);
end
if ~isempty(sig)
    for i = 1:length(sig)
        sigSrc = findbussrc(get_param(blkH,'BusStruct'), sig{i});
        if ~isempty(sigSrc) 
        if sigSrc ~= blkH
            found = ~strcmp(get_param(sigSrc,'HiliteAncestors'),'find');
            if found
                hilite_system(sigSrc, 'find');
            end
        end
    end
    end
end

% doSwap: callback function for doUp & doDown
function doSwap(dlg, inc, tag)
ind     = dlg.getWidgetValue(tag) + 1;
entries = dlg.getUserData(tag);
if isempty(ind) | length(ind)>1 return; end
newInd  = ind + inc;
if newInd < 1 | newInd > length(entries) return; end
temp    = entries(newInd);
entries(newInd) = entries(ind);
entries(ind) = temp;
dlg.setUserData(tag, entries);
if isa(dlg.getDialogSource.getBlock,'Simulink.BusCreator')
    dlg.getDialogSource.state.Inputs = cellarr2str(entries);
elseif isa(dlg.getDialogSource.getBlock,'Simulink.BusSelector')
    dlg.getDialogSource.state.OutputSignals = strrep(strrep(cellarr2str(entries),'''',''),':','.');
elseif isa(dlg.getDialogSource.getBlock,'Simulink.BusAssignment')
    dlg.getDialogSource.state.AssignedSignals = strrep(strrep(cellarr2str(entries),'''',''),':','.');
end
dlg.setWidgetValue(tag, []);        % deselect combobox
dlg.setWidgetValue(tag, newInd-1);  % move selection with value
busCreatorddg_cb(dlg,'doRefresh');
doListSelection(dlg, tag);

% doRename: callback function
function doRename(dlg,inputs)
newName = dlg.getWidgetValue('bcRename');
ind     = dlg.getWidgetValue('bcSignalsList');
if ~isempty(newName) & ~isempty(ind)
    if ~isempty(str2num(inputs))
        nameList = {dlg.getDialogSource.getBlock.BusStruct(:).name};
    else
        nameList = str2cellarr(inputs);
    end
    
    nameList{ind+1} = newName;
    dlg.getDialogSource.state.Inputs = cellarr2str(nameList);
    dlg.setUserData('bcSignalsList', nameList);
    busCreatorddg_cb(dlg,'doRefresh');
end


% Utility methods ---------------------------------------------------------
% refactor: merge true signal inputs with user's UI choices
function signals = refactor(h, signals, inputs, isTree)
% if there are no ui choices to merge with, return
if isempty(inputs) return; end
% identify if we are dealing with inherited names or custom names
num = str2num(inputs);
if isempty(num)         % custom names
    num   = length(findstr(inputs,','))+1;
    isStr = true;
else                    % inherited names
    isStr = false;
end
% preliminary process of the list view to see if we can return early
if ~isTree & isStr
        signals = str2cellarr(inputs);
        return;
end
% process the list & tree view of signals
if isfinite(num) & num > 0 & num ~= num2str(length(h.BusStruct))
    if isStr & ~isTree
        signalNames = str2cellarr(inputs);
    else
        signalNames = {h.BusStruct(:).name};
    end
    
    % update items based on intermediate inputs string
    currentNum = length({h.BusStruct(:).name});
    if currentNum < num
        for i = 1 : num-currentNum
            signals = [signals {['signal', num2str(currentNum+i)]}];
        end
    elseif currentNum > num
        count = 1;
        for i=1:length(signals)
            if ischar(signals{i})
                count = count + 1;
            end
            if count > num+1
                signals{i} = [];
            end
        end
    end
end

% cellarr2str: convert cell array of signal names to Bus Creator formatted
% string representation
function str = cellarr2str(signalArray)
if isempty(signalArray)
    str = '';
else
    str = [];
    sep = '';
    for i = 1:length(signalArray)
        sig   = deblankall(signalArray{i});
        valid = strrep(strrep(sig,'.','_'),',','_');
        if (~valid)
            %
            % Take care of invalid chars: '.' and ';'
            % This is consistent with the code in mux.c
            %
            strrep(sig, '.', ':');
            strrep(sig, ',', ';');
        end

        str = [str sep '''' sig ''''];
        sep = ',';
    end
end

% str2cellarr: convert Bus Creator formatted string to cell array of signal
% names
function cellarr = str2cellarr(signalStr)
cellarr = strrep(strread(signalStr,'%s','delimiter',','),'''','')';

% validateSelections: if a signal in the 'Selected signals' listbox is not
% valid, let the user know
function modArray = validateSelections(inArray, data)
modArray = inArray;
if iscell(data)
    for i = 1:length(inArray)
        delimArray = DelimitString(inArray{i}, '.');
        currData = data;
        preStr   = '';

        for k = 1:length(delimArray)
            currName = delimArray{k};
            found = 0;
            
            for j = 1:length(currData)
                if iscell(currData{j})
                    compareName = currData{j}{1};
                else
                    compareName = currData{j};
                end
            
                if strcmp(currName, compareName)
                    found = 1;
                    if iscell(currData{j})
                        currData = currData{j}{2};
                    end
                    break;
                end
            end

            if (found==0)
                preStr = '??? ';
                break;
            end
        end
        modArray{i} = [preStr inArray{i}];
    end
end

function array = DelimitString(str, sep)
array = {};
idx = find(str == sep);
if ~isempty(idx)
  idx = [0 idx length(str)+1];
  for i = 1:length(idx)-1
    % we have that many signals
    array{i} = str(idx(i)+1:idx(i+1)-1);
  end
else
  array{1} = str;
end

function modArray = clean(inArray)
modArray = strrep(inArray, '??? ', '');
