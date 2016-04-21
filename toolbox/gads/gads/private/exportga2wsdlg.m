function exportga2wsdlg(probmodel, optmodel, randchoice)
%EXGAPORT2WSDLG Exports variables to the workspace.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.18.4.2 $  $Date: 2004/03/18 17:59:28 $

title = 'Export To Workspace';

hDialog = dialog('Visible', 'off', 'Name', title, 'WindowStyle', 'normal');

defaultVariableNames = {'gaproblem'; ' '; 'gaoptions'; 'garesults'};
variableNames = createVarNames(defaultVariableNames);

cancelButton = uicontrol(hDialog,'String', 'Cancel',...
                                 'Callback', {@CancelCallback, hDialog});
                             
okButton = uicontrol(hDialog,'String', 'OK', 'Fontweight', 'bold');

checkboxLabels = {'Export problem and options to a MATLAB structure named:'; ...
                  'Include information needed to resume this run';...  
                  'Export options to a MATLAB structure named:';...
                  'Export results to a MATLAB structure named:'};
        
%Retrieve problem
[fitnessFcn,nvars,randstate,randnstate] =  gaguiReadProblem(probmodel);

%Retrieve results
gaResults = getappdata(0,'gads_gatool_results_121677');
if ~isempty(gaResults)
    x = gaResults.x;
    fval = gaResults.fval; 
    output = gaResults.output; 
    exitMessage = output.message; 
    pop = gaResults.population;
    scores = gaResults.scores;
else
    x = []; fval = []; output = [];
    exitMessage = []; pop = []; scores = [];
end
if isempty(x)
    disableFields = true;
else
    disableFields = false;
end

[checkBoxes, editFields] = layoutDialog(hDialog, okButton, cancelButton, ...
                                        checkboxLabels, variableNames, fitnessFcn,nvars,disableFields);

set(okButton, 'Callback', {@OKCallback, hDialog, checkBoxes, editFields, ...
                           optmodel, x, fval, exitMessage, output,fitnessFcn, ...
                           nvars,pop, scores, randstate, randnstate, randchoice});
set(hDialog, 'KeyPressFcn', {@KeyPressCallback, hDialog, checkBoxes, editFields, ...
                           optmodel, x, fval, exitMessage, output,fitnessFcn, ...
                           nvars,pop, scores, randstate, randnstate, randchoice});

%set(hDialog, 'HandleVisibility', 'callback', 'WindowStyle', 'modal');
set(hDialog, 'Visible', 'on');

%----------------------------------------------------------------------------
function modifiedNames = createVarNames(defVariableNames)
    % Preallocating for speed
    modifiedNames = cell(1, length(defVariableNames));
    for i = 1:length(defVariableNames)
        modifiedNames{i} = computename(defVariableNames{i});
    end

%----------------------------------------------------------------------------
function name = computename(nameprefix)

if (evalin('base',['exist(''', nameprefix,''', ''var'');']) == 0)
    name = nameprefix;
    return
end

% get all names that start with prefix in workspace
workvars = evalin('base', ['char(who(''',nameprefix,'*''))']);
% trim off prefix name
workvars = workvars(:,length(nameprefix)+1:end); 

if ~isempty(workvars)
    % remove all names with suffixes that are "non-numeric"
    lessthanzero = workvars < '0';
    morethannine = workvars > '9';
    notblank = (workvars ~= ' ');
    notnumrows = any((notblank & (lessthanzero | morethannine)),2);
    workvars(notnumrows,:) = [];
end

% find the "next one"
if isempty(workvars)
    name = [nameprefix, '1'];
else
    nextone = max(str2num(workvars)) + 1;
    if isempty(nextone)
        name = [nameprefix, '1'];
    else
        name = [nameprefix, num2str(nextone)];
    end
end

%----------------------------------------------------------------------------
function OKCallback(obj, eventdata, dialog, cb, e, model, x, fval, exitMessage,output, ...
    fitnessFcn,nvars,pop, scores, randstate, randnstate, randchoice)

    CB_PROBLEM = 1;
    CB_RESTART = 2;
    CB_OPTION = 3;
    CB_RESULTS = 4;
    
    varnames = [];
    
     % we care only about items that are checked
     for i = 1:length(e)
         if get(cb{i}, 'Value') == 1 && i~=CB_RESTART
            varnames{end + 1} = get(e{i}, 'String');
         end
     end
    
     if isempty(varnames)
         errordlg('You must select an item to export', ...
                  'Export to Workspace');
         return;
     end
    
    %check for invalid and empty variable names
    badnames = [];
    numbadentries = 0;
    emptystrmsg = '';
    badnamemsg = '';
    for i = 1:length(varnames)
        if strcmp('', varnames{i})
            numbadentries = numbadentries + 1;
            emptystrmsg = sprintf('%s\n', ...
                'An empty string is not a valid choice for a variable name.');
        elseif ~isvarname(varnames{i})
            badnames{end + 1} = varnames{i};
            numbadentries = numbadentries + 1;
        end
    end
    badnames = unique(badnames);
   
    if ~isempty(badnames)
        if (length(badnames) == 1)
            badnamemsg = ['"' badnames{1} '"' ...
                      ' is not a valid MATLAB variable name.'];
        elseif (length(badnames) == 2)
            badnamemsg = ['"' badnames{1} '" and "' badnames{2} ...
                      '" are not valid MATLAB variable names.'];
        else 
            badnamemsg = [sprintf('"%s", ', badnames{1:end-2}),...
                      '"' badnames{end-1} ...
                      '" and "' badnames{end} ...
                      '" are not valid MATLAB variable names.', ];
        end
    end
    
    if numbadentries > 0 
        dialogname = 'Invalid variable names';
        if numbadentries == 1
            dialogname = 'Invalid variable name';
        end
        errordlg([emptystrmsg badnamemsg], dialogname);    
        return; 
    end
    
    %check for names already in the workspace
    dupnames = [];
    for i = 1:length(varnames)
        if evalin('base',['exist(''',varnames{i},''', ''var'');'])
            dupnames{end + 1} = varnames{i};
        end
    end
    dupnames = unique(dupnames);
 
    if ~isempty(dupnames) 
        dialogname = 'Duplicate variable names';
        if (length(dupnames) == 1)
            queststr = ['"' dupnames{1} '"'...
                        ' already exists. Do you want to overwrite it?'];
            dialogname = 'Duplicate variable name';
        elseif (length(dupnames) == 2)
            queststr = ['"' dupnames{1} '" and "' dupnames{2} ...
                        '" already exist. Do you want to overwrite them?'];
        else
            queststr = [sprintf('"%s" , ', dupnames{1:end-2}), ...
                        '"' dupnames{end-1} '" and "' dupnames{end} ...
                        '" already exist. Do you want to overwrite them?'];
        end
        buttonName = questdlg(queststr, dialogname, 'Yes', 'No', 'Yes');
        if ~strcmp(buttonName, 'Yes') 
            return;
        end 
    end

    %Check for variable names repeated in the dialog edit fields
    [uniqueArray ignore uniqueIndex] = unique(varnames);
    if length(varnames) == length(uniqueArray)
        if get(cb{CB_PROBLEM}, 'Value') == 1  
            tempstruct = struct;
            tempstruct.fitnessfcn=fitnessFcn;
            tempstruct.nvars=nvars;
            if randchoice
                tempstruct.randstate = randstate;
                tempstruct.randnstate = randnstate;
            end
            options = gaguiReadHashTable(model);
  
            if get(cb{CB_RESTART}, 'Value') == 1 
                options.InitialPopulation=pop;
                options.InitialScores=scores;    
            end 
            %remove special gui outputfcn which is the first in the list
            if ~isempty(options.OutputFcns) 
                temp = options.OutputFcns{1};
                temp = temp{1};
                if strcmp(func2str(temp), 'gatooloutput')
                    options.OutputFcns(1) = [];
                end
            end
            if isempty(options.OutputFcns)
                options.OutputFcns = [];
            end
            tempstruct.options=options;
            assignin('base', get(e{CB_PROBLEM}, 'String'), tempstruct);
        end
        if get(cb{CB_OPTION}, 'Value') == 1  
            options = gaguiReadHashTable(model);
                
            %remove special gui outputfcn which is the first in the list
            if ~isempty(options.OutputFcns) 
                temp = options.OutputFcns{1};
                temp = temp{1};
                if strcmp(func2str(temp), 'gatooloutput')
                    options.OutputFcns(1) = [];
                end
            end
            if isempty(options.OutputFcns)
                options.OutputFcns = [];
            end
            
            assignin('base', get(e{CB_OPTION}, 'String'), options);
        end
        if get(cb{CB_RESULTS}, 'Value') == 1  % export solution 
            tempstruct = struct;
            tempstruct.x = x;
            tempstruct.fval = fval;
            tempstruct.exitmessage = exitMessage;
            tempstruct.output = output;
            assignin('base', get(e{CB_RESULTS}, 'String'), tempstruct); 
        end
        if length(varnames) == 1
            msg = sprintf('The variable ''%s'' has been created in the current workspace.', varnames{1});
        elseif length(varnames) == 2 
            msg = sprintf('The variables ''%s'' and ''%s'' have been created in the current workspace.', varnames{1}, varnames{2});
        elseif length(varnames) == 3
            msg = sprintf('The variables ''%s'', ''%s'' and ''%s'' have been created in the current workspace.', varnames{1}, varnames{2}, varnames{3});
        else  %shouldn't get here
            msg='';
        end
        disp(msg);
        delete(dialog);
    else
        errordlg('Names must be unique', 'Invalid Names');
    end
 
%----------------------------------------------------------------------------
function CancelCallback(obj, eventdata, dialog)
    delete(dialog);
   
%----------------------------------------------------------------------------
function KeyPressCallback(obj, eventdata, dialog, cb, e, model, x, fval, ...
        exitMessage, output, fitnessFcn,nvars,pop, scores, randstate, ...
        randnstate, randchoice)
    asciiVal = get(dialog, 'CurrentCharacter');
    if ~isempty(asciiVal)
        % space bar or return is the "same" as OK
        if (asciiVal==32 || asciiVal==13)   
            OKCallback(obj, eventdata, dialog, cb, e, model, x, fval, ...
               exitMessage, output, fitnessFcn, nvars, pop, scores, randstate, ...
               randnstate, randchoice);
        elseif (asciiVal == 27) % escape is the "same" as Cancel
            delete(dialog);
        end
    end
   
%----------------------------------------------------------------------------
function [cb, e] = layoutDialog(hDlg, okBut, cancelBut, checkboxLabels, ...
                                variableNames,fitnessFcn,nvars, disableFields)
    
    EXTENT_WIDTH_INDEX = 3;  % width is the third argument of extent
    
    POS_X_INDEX      = 1;
    POS_Y_INDEX      = 2;
    POS_WIDTH_INDEX  = 3;
    POS_HEIGHT_INDEX = 4;
    
    CONTROL_SPACING  = 5;
    EDIT_WIDTH       = 90;
    CHECK_BOX_WIDTH  = 20;
    DEFAULT_INDENT   = 20;
    
    CB_PROBLEM = 1;
    CB_RESTART = 2;
    CB_OPTION = 3;
    CB_RESULTS = 4;
    
    okPos = get(okBut, 'Position');
    cancelPos = get(cancelBut, 'Position');
    longestCBExtent = 0;
    ypos = okPos(POS_HEIGHT_INDEX) + okPos(POS_Y_INDEX)+ 2*CONTROL_SPACING;
    cb = cell(4, 1);
    e = cell(4, 1);
    for i = 4:-1:1
        cb{i} = uicontrol(hDlg, 'Style', 'checkbox', 'String', ...
                          checkboxLabels{i});
        check_pos = get(cb{i}, 'Position');
        check_pos(POS_Y_INDEX) = ypos;
        extent = get(cb{i}, 'Extent');
        width = extent(EXTENT_WIDTH_INDEX);
        check_pos(POS_WIDTH_INDEX) = width + CHECK_BOX_WIDTH;  
        set(cb{i}, 'Position', check_pos);
        if i==CB_RESTART %indent 2nd line a little and don't add a edit field;
            check_pos(POS_X_INDEX) = check_pos(POS_X_INDEX) + CHECK_BOX_WIDTH;
            set(cb{i}, 'Position', check_pos);
        else
            e{i} = uicontrol(hDlg, 'Style', 'edit', 'String', variableNames{i}, ...
                                   'BackgroundColor', 'white', ...
                                   'HorizontalAlignment', 'left');
            edit_pos = get(e{i}, 'Position');
            edit_pos(POS_Y_INDEX) = ypos;
            edit_pos(POS_WIDTH_INDEX) = EDIT_WIDTH;
            % cursor doesn't seem to appear in default edit height
            edit_pos(POS_HEIGHT_INDEX) = edit_pos(POS_HEIGHT_INDEX) + 1;
            set(e{i}, 'Position', edit_pos);
        end
        ypos = ypos + CONTROL_SPACING + edit_pos(POS_HEIGHT_INDEX);
        if width > longestCBExtent
            longestCBExtent = width;
        end
        
        if isempty(fitnessFcn) || isempty(nvars) 
            set(cb{CB_PROBLEM}, 'Enable', 'off');
            set(e{CB_PROBLEM}, 'Enable', 'off');
            set(e{CB_PROBLEM}, 'Backgroundcolor', [0.831373 0.815686 0.784314]);
        end

        if disableFields
            set(cb{CB_RESTART}, 'Enable', 'off');
            set(cb{CB_RESULTS}, 'Enable', 'off');
            set(e{CB_RESTART}, 'Enable', 'off');
            set(e{CB_RESTART}, 'Backgroundcolor', [0.831373 0.815686 0.784314]);
            set(e{CB_RESULTS}, 'Enable', 'off');
            set(e{CB_RESULTS}, 'Backgroundcolor', [0.831373 0.815686 0.784314]);
            if strcmp(get(cb{CB_PROBLEM}, 'Enable'), 'off')  % only options is enabled - check it
                set(cb{CB_OPTION}, 'Value', 1);
            end
        end
    end

    % Position edit boxes
    edit_x_pos = check_pos(POS_X_INDEX) + longestCBExtent + CONTROL_SPACING ...
                           + CHECK_BOX_WIDTH;
    for i = 1:4
        edit_pos = get(e{i}, 'Position');
        edit_pos(POS_X_INDEX) = edit_x_pos;
        set(e{i}, 'Position', edit_pos);
    end
    h_pos = get(hDlg, 'Position');
    
    h_pos(POS_WIDTH_INDEX) = max(edit_x_pos + edit_pos(POS_WIDTH_INDEX) + ...
                                 CHECK_BOX_WIDTH, okPos(POS_WIDTH_INDEX) + ...
                                 cancelPos(POS_WIDTH_INDEX) + ...
                                 CONTROL_SPACING + (2 * DEFAULT_INDENT));
    h_pos(POS_HEIGHT_INDEX) = ypos;
    set(hDlg, 'Position', h_pos);
    
    % Make sure it is on-screen
    oldu = get(0,'Units');
    set(0,'Units','pixels');
    screenSize = get(0,'ScreenSize');
    set(0,'Units',oldu);
    outerPos = get(hDlg,'OuterPosition');
    if outerPos(1)+outerPos(3) > screenSize(3)
        outerPos(1) = screenSize(3) - outerPos(3);
    end
    if outerPos(2)+outerPos(4) > screenSize(4)
        outerPos(2) = screenSize(4) - outerPos(4);
    end
    set(hDlg, 'OuterPosition', outerPos);
    
    x_ok = (h_pos(POS_WIDTH_INDEX))/2 -  (okPos(POS_WIDTH_INDEX) + ... 
            CONTROL_SPACING + cancelPos(POS_WIDTH_INDEX))/2;
    okPos(POS_X_INDEX) = x_ok;
    set(okBut, 'Position', okPos);
    cancelPos(POS_X_INDEX) = okPos(POS_X_INDEX) + okPos(POS_WIDTH_INDEX) + ...
                                   CONTROL_SPACING;
    set(cancelBut, 'Position', cancelPos);

    % Reorder the children so that tabbing makes sense
    children = get(hDlg, 'children');
    children = flipud(children);
    set(hDlg, 'children', children);
