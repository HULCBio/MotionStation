function errorCount = create_truth_table(fcnId, ignoreErrors, checkErrorOnly)
%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.6 $  $Date: 2004/04/15 00:56:29 $
if (nargin < 2)
    ignoreErrors = 0;
end

if (nargin < 3)
    checkErrorOnly = 0;
end

chartId = sf('get',fcnId,'state.chart');
machineId = sf('get',chartId,'chart.machine');
chartDirty = sf('get',chartId,'chart.dirty');
machineDirty = sf('get',machineId,'machine.dirty');
modelH = sf('get',machineId,'machine.simulinkModel');
modelDirty = get_param(modelH,'dirty');
chartIced = sf('get',chartId,'chart.iced');
% ted the editor. fixes 144039
sf('LoseFocusFcn', chartId);
if(~checkErrorOnly)
    % fixes rendering problems when the chart is not open
    % G146300
    if(~sf('get',chartId,'.visible'))
        sf('Open',chartId);
    end
    if(chartIced)
        sf('set',chartId,'chart.iced',0);
    end
    viewObj = sf('get',chartId,'chart.viewObj');
    if(~isempty(sf('find',viewObj,'state.truthTable.isTruthTable',1)))
        % we are viewing a truth-table. get out to avoid rendering problems
        sf('UpView',chartId);
    end
end

% We need to capture all the salient properties of this view
% so that we can restore them later.
% Otherwise, bad rendering problems will happen.

previousViewObj = sf('get',chartId,'chart.viewObj');
previousZoom = sf('get',chartId,'chart.zoom');
previousViewLimits = sf('get',chartId,'chart.viewLimits');

errorCount = 0;
construct_tt_error('reset');
try,
    if(~checkErrorOnly)
        sf('DrawLater',chartId);
    end
    try_create_truth_table(fcnId, checkErrorOnly);
catch,
    if(~checkErrorOnly)
        sf('DrawNow',chartId,fcnId);
    end
    construct_tt_error('add',fcnId,lasterr,0); % this means we hit an unexpected error
end

if(~checkErrorOnly)
    % Now we restore the previous viewobject, zoom and limits
    sf('Open',previousViewObj);
    sf('set',chartId,'chart.zoom',previousZoom);
    sf('set',chartId,'chart.viewLimits',previousViewLimits);
    sf('DrawNow',chartId,fcnId);
    if(chartIced)
        sf('set',chartId,'chart.iced',1);
    end
    %restore dirty flag on the chart and machine
end
if(machineDirty==0)
    sf('set',machineId,'machine.dirty',0);
end    
if(chartDirty==0)
    sf('set',chartId,'chart.dirty',0);
end
set_param(modelH,'dirty',modelDirty);
    
if(ignoreErrors)
    errorCount = construct_tt_error('get');
else
    % long jump
    construct_tt_error('add',fcnId,'Errors occurred during truthtable parsing',1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function try_create_truth_table(fcnId, checkErrorOnly)

switch(lower(computer))
case {'sgi','sgi64'}
    str = 'Stateflow Truthtables feature is not supported on SGI platform. You can edit/save/load models containing Truthtables but not simulate them.';
    local_error(fcnId, 'Parse', str, 1);
end    

rt = sfroot;
fcnObject = rt.find('-isa','Stateflow.TruthTable','-and','Id',fcnId);

predicateMatrix =  sf('get',fcnId,'state.truthTable.predicateArray');
actionMatrix =  sf('get',fcnId,'state.truthTable.actionArray');

if isempty(actionMatrix)
    % G182707: make empty action table to empty 0x2 cell array
    % A double empty action table "[]" makes "regexprep" complain in preprocess
    actionMatrix = cell(0,2);
end

skipGenDiagram = 0;
if isempty(predicateMatrix) | size(predicateMatrix, 1) <= 1 | size(predicateMatrix, 2) <= 2
    % G141792: Right after creation the tables are empty
    % For empty predicate table, proceed with warning and clean up all
    % content. The truth table acts like an empty graphical function.
    warnMsg = sprintf('Condition Table contains no conditions or decisions.');
    local_warn(fcnId, 'Parse', warnMsg);
    skipGenDiagram = 1;
else
    initialize_table(fcnId, predicateMatrix, actionMatrix);
    error_check_truth_table(fcnId);
end

% Early return if there have been earlier errors, or the function is called
% to check error only
if(construct_tt_error('get') > 0 || checkErrorOnly)
    return;
end
    
clean_up_content(fcnObject);
if ~skipGenDiagram
    gen_truth_table_diagram(fcnObject);
end
sf('RebuildHierarchy',fcnId);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function clean_up_content(fcnObject)

sf('RebuildHierarchy',fcnObject.Id);

fcnContents = fcnObject.find;
for i=1:length(fcnContents)
    if(ishandle(fcnContents(i)) & fcnContents(i)~=fcnObject)
        skipDeletion = 0;
        if(strcmp(get(classhandle(fcnContents(i)), 'Name'), 'Data'))
            skipDeletion = ~sf('get',fcnContents(i).Id,'data.autogen.isAutoCreated');
        end
        if ~skipDeletion
            delete(fcnContents(i));
        end        
    end
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function initialize_table(fcnId, predicateMatrix, actionMatrix)

% Predicate table formating
global gIdxPredDesp gIdxPredLabel gIdxPredCode;

gIdxPredDesp = 1; % The index of column which holds predicate description in predicate table
gIdxPredLabel = 2; % The index of column which holds predicate label in predicate table
gIdxPredCode = 3; % The index of column which holds predicate code in predicate table

% Action table formating
global gIdxActDesp gIdxActLabel gIdxActCode;

gIdxActDesp = 1; % The index of column which holds action description in action table
gIdxActLabel = 2; % The index of column which holds action label in action table
gIdxActCode = 3; % The index of column which holds action code in action table

% Draw diagram setting
global gTTJuncRadius gTTFontSize;

gTTJuncRadius = 5; % Radius for truthtable diagram junction radius
gTTFontSize = 12; % Font size used in diagram

% Table pieces
global gTId gPredHeader gPredBody gPredAction gActions gInitActIdx gFinalActIdx;

% Diagnostics setting
global gDiagError gDiagWarning gDiagIgnore;

gDiagError = 0;
gDiagWarning = 1;
gDiagIgnore = 2;

% truth table id
gTId = fcnId;
gInitActIdx = 0;
gFinalActIdx = 0;

[gPredHeader predBody predAction gActions] = preprocess_truth_table(predicateMatrix, actionMatrix);

% create action string to index mapping
import java.util.Hashtable;
mapActionIndex = Hashtable;
for i = 1:size(gActions, 1)
    mapActionIndex.put(int2str(i), i);
    actLabel = gActions{i, gIdxActLabel};

    if ~isempty(actLabel)
        ov = mapActionIndex.put(actLabel, i);
        if ~isempty(ov)
            %errorMsg = ['Action Table, action ' int2str(ov) ' & action ' int2str(i) ': Duplicate action label ''' actLabel '''.'];
            errorMsg = sprintf('Action Table, actions %d and %d: Duplicate action label ''%s''.', ov, i, actLabel);
            local_error(gTId, 'Parse', errorMsg, 0);
        end

        if strcmp(lower(actLabel), 'init')
            gInitActIdx = i;
        end
        
        if strcmp(lower(actLabel), 'final')
            gFinalActIdx = i;
        end
    end
end

% convert predBody true/false string value to 1/0
[m n] = size(predBody);
gPredBody = zeros(m, n);
for row = 1:m
    for col = 1:n
        switch lower(predBody{row, col})
            case {'t','y','1','true','yes'}
                gPredBody(row, col) = 1;
            case {'f','n','0','false','no'}
                gPredBody(row, col) = 0;
            case '-'
                gPredBody(row, col) = -1;
            case ''
                %errorMsg = ['Condition Table, column D' int2str(col) ' row ' int2str(row) ': T/F/- cells cannot be empty'];
                errorMsg = sprintf('Condition Table, column D%d, row %d: T/F/- cells cannot be empty.', col, row);
                local_error(gTId, 'Parse', errorMsg, 0);
                gPredBody(row, col) = 0; % dummy set for multiple error detection
            otherwise
                %errorMsg = ['Condition Table, column D' int2str(col) ' row ' int2str(row) ': Unknown boolean string ''' predBody{row, col} '''.'];
                errorMsg = sprintf('Condition Table, column D%d, row %d: Invalid boolean string ''%s''.', col, row, predBody{row, col});
                local_error(gTId, 'Parse', errorMsg, 0);
                gPredBody(row, col) = 0; % dummy set for multiple error detection
        end
    end
end
% cache actions for each decision column
n = length(predAction);
gPredAction = cell(n, 1);
for i = 1:n
     actions = sf('SplitStringIntoCells', predAction{i}, ';,', 0);
     for j = 1:length(actions)
         idx = mapActionIndex.get(actions{j});
         if ~isempty(idx)
             gPredAction{i} = [gPredAction{i} idx];
         else
             %errorMsg = ['Condition Table, column D' int2str(i) ': Action ''' actions{j} ''' is not defined in Action Table.'];
             errorMsg = sprintf('Condition Table, column D%d: Action ''%s'' is not defined in Action Table.', i, actions{j});
             local_error(gTId, 'Parse', errorMsg, 0);
             % leave gPredAction{i} empty instead of aliasing.
         end
     end
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varNames = gen_temp_bool_vars(fcnObject)

global gIdxPredDesp gIdxPredLabel gIdxPredCode gPredHeader gTId;

numP = size(gPredHeader, 1);

varNames = cell(numP, 1);
for i = 1:numP
    varName = gPredHeader{i, gIdxPredLabel};
    
    if isempty(varName)
        varName = ['c' int2str(i)];
    end
    
    varNames{i} = varName;

    tmpData = Stateflow.Data(fcnObject);
    tmpData.Name = varName;
    tmpData.DataType = 'boolean';
    tmpData.Props.InitialValue = '0';
    tmpData.Scope = 'TEMPORARY_DATA';
    tmpData.Description = gPredHeader{i, gIdxPredDesp};
    
    autogenMap = create_autogen_map('p','r',i);
    sf('set', tmpData.Id, ...
       'data.autogen.isAutoCreated', 1, ...
       'data.autogen.source', gTId, ...
       'data.autogen.mapping', autogenMap);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function labelStr = construct_predicate_eval_transition_label_string(boolVarNames, index)

global gIdxPredDesp gIdxPredLabel gIdxPredCode gPredHeader;

predDesp = gPredHeader{index, gIdxPredDesp};
predLabel = gPredHeader{index, gIdxPredLabel};
predCode = gPredHeader{index, gIdxPredCode};

if(isempty(predLabel))
    predLabel = int2str(index);
else
    predLabel = ['''',predLabel,''''];
end

labelStr = ['$ $' 10 '/* Condition ' predLabel ];
if ~isempty(predDesp)
    % insert predicate description as comments
    predDesp(strfind(predDesp, 10)) = ' '; % 10 is newline
    predDesp(strfind(predDesp, 13)) = ' '; % 13 is return
    labelStr = [labelStr ': ' predDesp];
end

labelStr = [labelStr ' */' 10];

% Extract out //, % style comments from predicate code
predCode = [predCode 10];
[s t] = regexp(predCode, '(//|%)[^\n]*\n');
for i = 1:length(s)
    labelStr = [labelStr predCode(s(i):t(i))];
end
predCode = regexprep(predCode, '(//|%)[^\n]*\n', char(10));
predCode = regexprep(predCode, '^\s*(.*?)\s*$', '$1');

% -------- trim off beginning and ending "[" "]" for backward compatibility
% YREN: should move to pre_process_truth_table later
if predCode(1) == '[' && predCode(end) == ']'
    predCode = predCode(2:end-1);
end
% ---------------------------------------------------------------------

labelStr = [labelStr boolVarNames{index} ' = (' predCode ');'];
    
if isempty(strfind(labelStr, 10))
    labelStr = ['{ ' labelStr ' }'];
else
    labelStr = ['{' 10 labelStr 10 '}'];
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function labelStr = construct_condition_transition_label_string(boolVarNames, index)

global gIdxPredDesp gIdxPredLabel gIdxPredCode gPredBody;

m = size(gPredBody, 1);

labelStr = '[';
for k = 1:m
    boolVal = gPredBody(k, index);
    if boolVal > 0
        labelStr = [labelStr boolVarNames{k} '&&'];
    elseif boolVal == 0
        labelStr = [labelStr '!' boolVarNames{k} '&&'];
    else
        continue; % dont care
    end
end

if strcmp(labelStr, '[')
    % all don't care column.
    labelStr = '/* Default */';
else
    %labelStr = ['/* D' int2str(index) ' */   ' labelStr(1:end-2) ']'];
    %labelStr = [labelStr(1:end-2) ']'];
    labelStr = [labelStr(1:end-2) ']   /* D' int2str(index) ' */'];
end
    
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function labelStr = construct_action_transition_label_string(actionIdx)

global gIdxActDesp gIdxActLabel gIdxActCode gActions;

actionDesp = gActions{actionIdx, gIdxActDesp};
actionCode = gActions{actionIdx, gIdxActCode};
actionLabel = gActions{actionIdx, gIdxActLabel};
if(isempty(actionLabel))
    actionLabel = int2str(actionIdx);
else
    actionLabel = ['''' actionLabel ''''];
end
labelStr = ['$ $' 10 '/* Action ' actionLabel ];
if ~isempty(actionDesp)
    % insert action description as comments
    actionDesp(strfind(actionDesp, 10)) = ' '; % flatten newline
    actionDesp(strfind(actionDesp, 13)) = ' '; % flatten return
    labelStr = [labelStr ': ' actionDesp];
end

labelStr = [labelStr ' */' 10 actionCode];

if isempty(strfind(labelStr, 10))
    labelStr = ['{ ' labelStr ' }'];
else
    labelStr = ['{' 10 labelStr 10 '}'];
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function gen_truth_table_diagram(containerObj)

global gIdxPredDesp gIdxPredLabel gIdxPredCode gPredHeader gPredBody gPredAction gTId gInitActIdx gFinalActIdx;
global gTTJuncRadius gTTFontSize;

boolVarNames = gen_temp_bool_vars(containerObj);

[numP numT] = size(gPredBody);

segmentMargin = 30; % margin between two action transitions
x = 20; y = 25; % The start point

% the default transition
[t j] = add_trans_to_junc(containerObj, [x y], 6, [x y+segmentMargin], 12, gTId, []);

% the INIT transition
if gInitActIdx > 0
    labelStr = construct_action_transition_label_string(gInitActIdx);
    autogenMap = create_autogen_map('a','r',gInitActIdx);
    [t j] = append_vertical_transition_to_junction(containerObj, j, labelStr, gTId, autogenMap);
end

% adding transitions to calculate predicates
for i = 1:numP
    labelStr = construct_predicate_eval_transition_label_string(boolVarNames, i);
    autogenMap = create_autogen_map('p','r',i);
    [t j] = append_vertical_transition_to_junction(containerObj, j, labelStr, gTId, autogenMap);
end

% now append action transitions for each action column in predicate table
%avoidCollisionPos = j.Position.Center + [0 segmentMargin];

% Following two values are used for finalization
endJuncs = cell(numT,1);
rightBound = 0;

% Wheather the last column is default column (all dont care)
defaultLastCol = (sum(gPredBody(:,numT)) == -numP); 

for i = 1:numT
    % Adding the connective transition
    %[t j] = add_trans_to_junc(containerObj, j, 6, avoidCollisionPos, 12, containerObj.Id, []);
    
    condStr = construct_condition_transition_label_string(boolVarNames, i);
    autogenMap = create_autogen_map('p','c',i);
    [t jn maxVBound] = append_horizontal_transition_to_junction(containerObj, j, condStr, gTId, autogenMap);
    
    actions = gPredAction{i};
    for k = 1:length(actions)
        actionStr = construct_action_transition_label_string(actions(k));
        autogenMap = create_autogen_map('a','r',actions(k));
        [t jn vBound] = append_horizontal_transition_to_junction(containerObj, jn, actionStr, gTId, autogenMap);
        
        if vBound > maxVBound
            maxVBound = vBound;
        end
    end
    
    endJuncs{i} = jn;
    if jn.Position.Center(1) > rightBound
        rightBound = jn.Position.Center(1);
    end
    
    % Adding the connective transition
    if i < numT | ~defaultLastCol
        avoidCollisionPos = j.Position.Center;
        avoidCollisionPos(2) = vBound + segmentMargin;
        [t j] = add_trans_to_junc(containerObj, j, 6, avoidCollisionPos, 12, gTId, []);
    else
        j = jn;
    end
end

% the ending transition and junction
%add_trans_to_junc(containerObj, j, 6, j.Position.Center + [0 segmentMargin], 12, containerObj.Id, []);

% the FINAL transition
if gFinalActIdx > 0
    % Stretch out all end junctions to the same y location, and connect them
    for i = 1:length(endJuncs)
        endJuncs{i}.Position.Center(1) = rightBound;
        if i > 1
            connect_juncs_by_trans(containerObj, endJuncs{i-1}, 6, endJuncs{i}, 12, gTId, []);
        end
    end
    
    if ~defaultLastCol
        % Create the connective junction, and make the connections
        jc = Stateflow.Junction(containerObj);
        jc.Position.Center = [rightBound j.Position.Center(2)];
        jc.Position.Radius = gTTJuncRadius;
        connect_juncs_by_trans(containerObj, endJuncs{end}, 6, jc, 12, gTId, []);
        connect_juncs_by_trans(containerObj, jc, 9, j, 3, gTId, []);
    end
    
    % Create the finalization junction
    labelStr = construct_action_transition_label_string(gFinalActIdx);
    autogenMap = create_autogen_map('a','r',gFinalActIdx);
    [t j] = append_vertical_transition_to_junction(containerObj, j, labelStr, gTId, autogenMap);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [T, J] = append_vertical_transition_to_junction(containerObj, sourceJunc, labelString, autogenSourceId, autogenMap)

global gTTJuncRadius gTTFontSize;

factor = 1.86; % factor to adjust transition length based on fontsize and number of lines in label string.
marginTransLabel = 10; % the margin between transition line and label string.

% Determine number of lines by searching the newline character 10
numLines = length(strfind(labelString, 10)) + 1;

transLength = numLines * gTTFontSize * factor;

x = sourceJunc.Position.Center(1);
y = sourceJunc.Position.Center(2);

dstJuncPos = [x y + transLength];
[T J] = add_trans_to_junc(containerObj, sourceJunc, 6, dstJuncPos, 12, autogenSourceId, autogenMap);

T.LabelString = labelString;
labelPos = T.LabelPosition;
T.LabelPosition = [x+marginTransLabel y+(transLength-labelPos(4))/2 labelPos(3:4)];

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [T, J, verticalBound] = append_horizontal_transition_to_junction(containerObj, sourceJunc, labelString, autogenSourceId, autogenMap)

global gTTJuncRadius gTTFontSize;

hFactor = 0.68; % factor to adjust horizontal transition length by length of label string and font size
vFactor = 1.68;

% Get the maximum line length by number of characters
newLinePos = [0 find(labelString == 10 | labelString == 13) length(labelString)+1];
maxLineLen = 0;
for i = 2:length(newLinePos)
    thisLineLen = newLinePos(i) - newLinePos(i-1);
    if thisLineLen > maxLineLen
        maxLineLen = thisLineLen;
    end
end

% Determine number of lines by searching the newline character 10
numLines = length(strfind(labelString, 10)) + 1;

transLength = maxLineLen * gTTFontSize * hFactor;

x = sourceJunc.Position.Center(1);
y = sourceJunc.Position.Center(2);
dstJuncPos = [x + transLength y];

[T J] = add_trans_to_junc(containerObj, sourceJunc, 3, dstJuncPos, 9, containerObj.Id, autogenMap);

T.LabelString = labelString;
labelPos = T.LabelPosition;
leftMargin = (transLength - labelPos(3)) / 2;
marginTransLabel = 3;

% Put label string under transition
T.LabelPosition = [x+leftMargin y+marginTransLabel labelPos(3:4)];
verticalBound = y + marginTransLabel + numLines*gTTFontSize*vFactor;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function T = connect_juncs_by_trans(containerObj, sJ, sOc, dJ, dOc, autogenSourceId, autogenMap)

T = Stateflow.Transition(containerObj);
T.Source = sJ;
T.SourceOClock = sOc;
T.Destination = dJ;
T.DestinationOClock = dOc;
T.DrawStyle = 'smart';
sf('set', T.Id, 'transition.autogen.isAutoCreated', 1);
sf('set', T.Id, 'transition.autogen.source', autogenSourceId);
sf('set', T.Id, 'transition.autogen.mapping', autogenMap);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [T, J] = add_trans_to_junc(containerObj, s, sOc, dPos, dOc, autogenSourceId, autogenMap)
% containerObj: containerObj to put in new trans and junc
% s: source, if not handle -> T is default trans with sourceEndPoint = s
% sOc: sourceOClock
% dPos: new junc (destination of new trans) position.
% dOc: destinationOClock
% T,J: return handles of newly added trans and junc

global gTTJuncRadius gTTFontSize;

J = Stateflow.Junction(containerObj);
J.Position.Center = dPos;
J.Position.Radius = gTTJuncRadius;

T = Stateflow.Transition(containerObj);
T.Destination = J;
T.DestinationOClock = dOc;

sf('set', T.Id, 'transition.autogen.isAutoCreated', 1);
sf('set', T.Id, 'transition.autogen.source', autogenSourceId);
sf('set', T.Id, 'transition.autogen.mapping', autogenMap);
sf('set', J.Id, 'junction.autogen.isAutoCreated', 1);
sf('set', J.Id, 'junction.autogen.source', autogenSourceId);
sf('set', J.Id, 'junction.autogen.mapping', autogenMap);

if ishandle(s)
    T.Source = s;
else
    T.SourceEndPoint = s;
end
T.SourceOClock = sOc;
T.DrawStyle = 'smart';

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function error_check_truth_table(fcnId)

global gIdxActDesp gIdxActLabel gIdxActCode gActions gInitActIdx gFinalActIdx;
global gIdxPredDesp gIdxPredLabel gIdxPredCode gPredHeader gPredBody gPredAction gTId;
global gDiagError gDiagWarning gDiagIgnore;

% ------------------- check action table -----------------------
[m n] = size(gActions);

% "check for vacant action code"
% for r = 1:m
%     if isempty(gActions{r, gIdxActCode})
%         warnMsg = ['Action Table, action ' int2str(r) ': Empty action string.'];
%         local_warn(gTId, 'Parse', warnMsg);
%     end
% end

% "Detect duplicate action labels" is done in "initialize_table"

% "Detect unreferred actions (by condition table)"
unreferredAct = setdiff([1:m], [gPredAction{:} gInitActIdx gFinalActIdx]);
if ~isempty(unreferredAct)
    %warnMsg = ['Action Table, action (' int2str(unreferredAct) '): Unreferred actions by Condition Table.'];
    warnMsg = sprintf('Action Table, actions (%s): Unreferred actions by Condition Table.', int2str(unreferredAct));
    local_warn(gTId, 'Parse', warnMsg);
end

% ------------------- check condition table ----------------------
[m n] = size(gPredBody);

% "check for duplicate predicate label, or other data collisions"
import java.util.Hashtable;
hashUserPredLabel = Hashtable;
hashAutoPredLabel = Hashtable;
ttUserCreatedData = sf('find',sf('DataOf',gTId),'data.autogen.isAutoCreated',0);
for i = 1:m
    if isempty(gPredHeader{i, gIdxPredLabel})
        autoPredLabel = ['c' int2str(i)]; % must be consistent with gen_temp_bool_vars()
        hashAutoPredLabel.put(autoPredLabel, i);
        existingData = sf('find',ttUserCreatedData,'data.name',autoPredLabel);
        if ~isempty(existingData)
            % Auto created condition label collides with user defined data
            errorMsg = sprintf('Condition Table, autocreated label ''%s'' for condition %d collides with a user created data #%d',...
                               autoPredLabel,i,existingData(1));
            local_error(gTId, 'Parse', errorMsg, 0);
        end
    end
end
for i = 1:m
    predLabel = gPredHeader{i, gIdxPredLabel};
    if ~isempty(predLabel)
        ov = hashUserPredLabel.put(predLabel, i);
        if ~isempty(ov)
            % Duplicate user defined condition labels
            errorMsg = sprintf('Condition Table, conditions %d and %d: Duplicate condition label ''%s''.', ov, i, predLabel);
            local_error(gTId, 'Parse', errorMsg, 0);
        end
        av = hashAutoPredLabel.get(predLabel);
        if ~isempty(av)
            % Collision of user defined condition label with autocreated condition label
            errorMsg = sprintf('Condition Table, user label ''%s'' in condition %d collides with an autocreated label for condition %d',...
                               predLabel,i,av);
            local_error(gTId, 'Parse', errorMsg, 0);
        end
        existingData = sf('find',ttUserCreatedData,'data.name',predLabel);
        if ~isempty(existingData)
            % User condition label collides with user defined data
            errorMsg = sprintf('Condition Table, user label ''%s'' in condition %d collides with a user created data #%d',...
                               predLabel,i,existingData(1));
            local_error(gTId, 'Parse', errorMsg, 0);
        end
    end
end

% "check for vacant predicate/condition code"
for r = 1:m
    if isempty(gPredHeader{r, gIdxPredCode})
        %errorMsg = ['Condition Table, row ' int2str(r) ': Empty condition string.'];
        errorMsg = sprintf('Condition Table, condition %d: Empty condition string.', r);
        local_error(gTId, 'Parse', errorMsg, 0);
    end
end

% "check for true/false string value" is done in "initialize_table"

% "all dont care column, if exists, should always be the last column"
if(m>1)
	% multiple predicates
	tmp = sum(gPredBody);
else
	% single predicate
	tmp = gPredBody;
end
nonEndingDontCareCols = find(tmp(1:n-1) == -m);
if ~isempty(nonEndingDontCareCols)
    %errorMsg = ['Condition Table, column (' int2str(nonEndingDontCareCols) '): All ''dont care'' default column must be the last column.'];
    errorMsg = sprintf('Condition Table, columns D(%s): Default decision column (containing all ''don''t cares'') must be the last column.', int2str(nonEndingDontCareCols));
    local_error(gTId, 'Parse', errorMsg, 0);
end

% "Check for undefined action in predicate table, action row" is done in initialize_table

% "Check for vacant action for a decision column in conditon table"
for i = 1:n
    if isempty(gPredAction{i})
        %errorMsg = ['Condition Table, column ' int2str(i) ': No action specified.'];
        errorMsg = sprintf('Condition Table, column D%d: No action is specified.', i);
        local_error(gTId, 'Parse', errorMsg, 0);
    end
end

% "Check for the use of reserved INIT FINAL actions in condition table"
useInitCols = []; useFinalCols = [];
for i = 1:n
    if ~isempty(find(gPredAction{i} == gInitActIdx))
        useInitCols = [useInitCols i];
    end
    if ~isempty(find(gPredAction{i} == gFinalActIdx))
        useFinalCols = [useFinalCols i];
    end
end
if ~isempty(useInitCols)
    %warnMsg = ['Condition Table, column (' int2str(useInitCols) '): Action ''INIT'' is reserved for truth table initialization. It should not be explicitly referred.'];
    warnMsg = sprintf('Condition Table, columns D(%s): Action ''INIT'' is reserved for truth table initialization. It should not be explicitly referred.', int2str(useInitCols));
    local_warn(gTId, 'Parse', warnMsg);
end
if ~isempty(useFinalCols)
    %warnMsg = ['Condition Table, column (' int2str(useFinalCols) '): Action ''FINAL'' is reserved for truth table finalization. It should not be explicitly referred.'];
    warnMsg = sprintf('Condition Table, columns D(%s): Action ''FINAL'' is reserved for truth table finalization. It should not be explicitly referred.', int2str(useFinalCols));
    local_warn(gTId, 'Parse', warnMsg);
end

% Early return if there have been earlier errors
if(construct_tt_error('get')>0)
    return;
end


% "Check for truth table under, over specification"
overSpecDiagnostic = sf('get',fcnId,'state.truthTable.diagnostic.overSpecification');
underSpecDiagnostic = sf('get',fcnId,'state.truthTable.diagnostic.underSpecification');
%%%WISH the magic number is 20 above which we ignore over/under checks
    
if(overSpecDiagnostic~=gDiagIgnore | underSpecDiagnostic~=gDiagIgnore)
    % do the computation only if atleast one of the settings 
    % is set to error or warn
    magicNumber = 20;
    if(m<=magicNumber)
        mySpecCheck = exist('my_tt_check_specification');
        if mySpecCheck == 2 || mySpecCheck == 3
            % User specified diagnostice function
            [over under] = my_tt_check_specification(gPredBody);
        else
            % Default diagnostic function
            [over under] = tt_check_specification(gPredBody);
        end
    else
        msg = sprintf('Truthtable contains more than %d conditions. Skipping (over/under)specification checks as it may take a long time',magicNumber);
        local_warn(gTId, 'Parse', msg ,gDiagWarning);
        over = [];
        under = [];
    end
end
if(overSpecDiagnostic==gDiagIgnore)
    % prevent
    over = [];
end
if(underSpecDiagnostic==gDiagIgnore)
    under = [];
end

numCaseReport = 23; % number of over or under cases to report

if ~isempty(over)
    %warnMsg = ['Over specification found in Condition Table:' 10];
    warnMsg = sprintf('Overspecification found in Condition Table:\n');
    for i = 1:min(length(over), numCaseReport)
        %warnMsg = [warnMsg 'Column ' int2str(double(over{i}(1))) ' is overspecified by columns (' int2str(double(over{i}(2:end))), ') ' 10];
        warnMsg = sprintf('%sColumn D%d is overspecified by columns D(%s)\n', warnMsg, double(over{i}(1)), int2str(double(over{i}(2:end))));
    end
    if length(over) > numCaseReport
        %warnMsg = [warnMsg '... (' int2str(length(over) - numCaseReport) ' more)'];
        warnMsg = sprintf('%s... (%d more)', warnMsg, length(over) - numCaseReport);
    end
    local_warn(gTId, 'Parse', warnMsg,overSpecDiagnostic);
end

if ~isempty(under)
    underCount = length(under);

    % Considering the long time for quine_mcclusky on large set
    complexityBound = 1024;
    
    underStr = quine_mcclusky(dec2bin(under(1:min(underCount, complexityBound)), m), 0);
    
    tailing = [];
    if underCount > complexityBound || size(underStr, 1) > numCaseReport
        midPos = ceil(m / 2);
        tailStr = sprintf(' ... more');
        tailing = [char(32*ones(midPos-1, length(tailStr))); tailStr; char(32*ones(m-midPos, length(tailStr)))];
    end
    
    underStr = underStr(1:min(size(underStr, 1), numCaseReport), :);
    underStr(find(underStr == '1')) = 'T';
    underStr(find(underStr == '0')) = 'F';
    underStr = char(regexprep(cellstr(rot90(underStr)), '([\w-])', '$1   '));
    underStr = [underStr tailing];

    %warnMsg = ['Under specification found in Condition Table for following missing cases:' 10];
    warnMsg = sprintf('Underspecification found in Condition Table for following missing cases:\n');
    for i = 1:size(underStr, 1)
        %warnMsg = [warnMsg underStr(i, :) 10];
        warnMsg = sprintf('%s%s\n', warnMsg, underStr(i, :));
    end

    local_warn(gTId, 'Parse', warnMsg,underSpecDiagnostic);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function local_error(fcnId, buildType, errorMsg, throwFlag)

construct_tt_error('add',fcnId,['(Truth Table) ' errorMsg],throwFlag);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function local_warn(fcnId, buildType, warnMsg,diagnosticType)

global gDiagError gDiagWarning gDiagIgnore;

if(nargin<4)
    diagnosticType = gDiagWarning;
end
if(diagnosticType==gDiagWarning)
    construct_warning(fcnId, buildType, ['(Truth Table) ' warnMsg]);
elseif(diagnosticType==gDiagError)
    construct_tt_error('add',fcnId,['(Truth Table) ' warnMsg],0);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function autogenMap = create_autogen_map(tableType,rowCol,index)

autogenMap.table = tableType;
autogenMap.rowcol = rowCol;
autogenMap.index = index;
