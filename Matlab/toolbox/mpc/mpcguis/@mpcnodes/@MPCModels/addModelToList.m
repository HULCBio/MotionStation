function Done = addModelToList(this, Struc, LTImodel)

%  Done = addModelToList(this, Struc, LTImodel)
%
% Adds a model to the list of imported models
%
% "this" is the MPCModels node

%  Author:  Larry Ricker
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.8 $ $Date: 2004/04/10 23:36:38 $

S = this.up;
Done = false;

% Extract the imported model's name and LTI object.
Name=Struc.name;
Model=LTImodel;
% Make sure model meets minimum standards ...
Nin = length(Model.InputName);
Nout = length(Model.OutputName);
Qtitle = 'MPC Question';
if Nin < 1 || Nout < 1
    Message = sprintf(['Model "%s" contains "%i" inputs and "%i"', ...
            ' outputs.  Must have at least one of each.', ...
            '  Aborting model import.'], Name, Nin, Nout);
    uiwait(errordlg(Message, 'MPC error', 'modal'));
    return
end
if ~isreal(LTImodel)
    Message = sprintf(['LTI model "%s" is complex.  It cannot', ...
        ' be imported to the MPC design tool.'], Name);
    uiwait(msgbox(Message,'MPC error','error','modal'));
    Boolean = 0;
    return
end
if length(size(LTImodel)) > 2
    Message = sprintf(['"%s" is an array of LTI Models.  It cannot', ...
        ' be imported to the MPC design tool.'], Name);
    uiwait(msgbox(Message,'MPC error', 'error', 'modal'));
    Boolean = 0;
    return
end
try
    % Convert to state space if possible
    [A, B, C, D] = ssdata(ss(LTImodel));
catch
    Message = sprintf(['"%s" cannot be converted to state space.', ...
        '  It probably contains an improper transfer function.', ...
        '  Import cancelled.'], Name);
    uiwait(msgbox(Message,'MPC error', 'error', 'modal'));
    return
end

% If this is the second model to be loaded, check for compatibility
% with the defined model structure.
if length(this.Models) >= 1
    % Check number of inputs and outputs
    if any([Nin Nout] ~= S.Sizes(6:7))
        Msg = sprintf(['Model "%s" contains %i input(s) and ', ...
            '%i output(s).  Models', ...
            ' imported previously contain %i input(s) and ', ...
            '%i output(s).\n\nIn order to import "%s", ', ...
            'your design must be cleared.  All controllers and ', ...
            'scenarios will be erased.\n\nDo you wish to ', ...
            'clear design "%s"?'], ...
            Name,Nin,Nout,S.Sizes(6:7), Name, S.Label);
        ButtonName = questdlg(Msg,Qtitle,'Yes', 'No', 'No');
        if strcmp(ButtonName,'Yes')
            S.clearTool;
            Done = LocalAddModel(this, Name, Model, S);
        end
        return
    end
    % Check whether or not signal names match.
    Conflict = false;
    for i = 1:Nin
        if ~isempty(Model.InputName{i})
            if ~strcmp(Model.InputName{i}, S.InData{i,1})
                Conflict = true;
            end
        end
    end
    for i = 1:Nout
        if ~isempty(Model.OutputName{i})
            if ~strcmp(Model.OutputName{i}, S.OutData{i,1})
                Conflict = true;
            end
        end
    end
    if Conflict
        Msg = sprintf(['Imported model "%s" contains at least one', ...
            ' InputName or OutputName that conflicts with your', ...
            ' current signal name settings.\n\nConflicting', ...
            ' names in "%s" will be overwritten.'], Name, Name);
        uiwait(warndlg(Msg, 'MPC Warning', 'modal'));
    end
    % Check whether or not I/O groups match
    Conflict = false;
    Msg = ['Imported model "%s" contains at least one', ...
        ' %sGroup that conflicts with your', ...
        ' current signal type settings.\n\nConflicting', ...
        ' types in "%s" will be overwritten.'];
    if iscell(Model.InputGroup)
        InputGroup = Model.InputGroup;
        [ngrp, ncol] = size(Model.InputGroup);
    else
        [InputGroup, ngrp] = localStruct2Cell(Model.InputGroup);
    end
    for i = 1:ngrp
        Type = InputGroup{i,2};
        switch Type
            case {'ManipulatedVariables', 'MV', 'Manipulated', 'Input'};
                Conflict = LocalChkGrp(InputGroup{i,1}, S.iMV);
            case {'MeasuredDisturbances', 'MD', 'Measured'};
                Conflict = LocalChkGrp(InputGroup{i,1}, S.iMD);
            case {'UnmeasuredDisturbances', 'UD', 'Unmeasured'}
                Conflict = LocalChkGrp(InputGroup{i,1}, S.iUD);
            otherwise
                Conflict = true;
        end
        if Conflict
             uiwait(warndlg(sprintf(Msg, Name, 'Input', Name), ...
                 'MPC Warning', 'modal'));            
            break
        end
    end
    Conflict = false;
    if iscell(Model.OutputGroup)
        OutputGroup = Model.OutputGroup;
        [ngrp, ncol] = size(Model.OutputGroup);
    else
        [OutputGroup, ngrp] = localStruct2Cell(Model.OutputGroup);
    end
    for i = 1:ngrp
        Type = OutputGroup{i,2};
        switch Type
            case {'MeasuredOutputs', 'MO', 'Measured', 'Output'};
                Conflict = LocalChkGrp(OutputGroup{i,1}, S.iMO);
            case {'UnmeasuredOutputs', 'UO', 'Unmeasured'};
                Conflict = LocalChkGrp(OutputGroup{i,1}, S.iUO);
            otherwise
                Conflict = true;
        end
        if Conflict
            uiwait(warndlg(sprintf(Msg, Name, 'Output', Name), ...
                'MPC Warning', 'modal'));            
            break
        end
    end
end
Done = LocalAddModel(this, Name, Model, S);
if Done
    % Warn if D is non-zero for MVs
    LocalCheckD(this, S, D, Name);
end

% ========================================================================

function LocalCheckD(this, S, D, Name)

MVList = '';
for i = 1:size(D,2)
    if any(D(:,i))
        % D column contains non-zero.  If an MV, add to list of bad inputs.
        if any(S.iMV == i)
            if ~isempty(MVList)
                MVList = [MVList, ', '];
            end
            MVList = [MVList, S.InData{i,1}];
        end
    end
end
if ~isempty(MVList)
    Message = sprintf(['"%s" has direct input/output feedthrough', ...
        ' for the following manipulated variable input(s):', ...
        '\n\n%s\n\n', ...
        'Controller calculations will fail unless you change ', ...
        'the signal type(s) to measured disturbance or ', ...
        'unmeasured disturbance.'], ...
        Name, MVList);
    uiwait(msgbox(Message,'MPC Warning', 'warn', 'modal'));
end


% ========================================================================

function Done = LocalAddModel(this, Name, Model, S)

Replacing = false;
Done = this.addModel(Name, Model, 0);
if ~Done
    % A model with this name already exists.  Ask if the user
    % wants to replace it.
    Question = sprintf(['Model "%s" has already been loaded.', ...
            '  Do you want to replace it?'],Name);
    ButtonName=questdlg(Question, 'MPC Question', 'No');
    if strcmp(ButtonName, 'Yes')
        Done = this.addModel(Name, Model, 1);
        Replacing = true;
    else
        Done = false;
    end
end
if Done
    S.ModelImported = 1;
    if isempty(this.Dialog)
        % Force creation of MPCModels dialog panel
        this.getDialogInterface(S.TreeManager);
    end
    this.RefreshModelList;
    if length(this.Models) == 1 && ~Replacing
        DefineStructureTables(S, Model);
    end
end

% ========================================================================

function [CellGroup, ngrp] = localStruct2Cell(StructGroup)

Fields = fieldnames(StructGroup);
ngrp = length(Fields);
CellGroup = cell(ngrp,2);
for i = 1:ngrp
    CellGroup{i,2} = Fields{i};
    CellGroup{i,1} = getfield(StructGroup,Fields{i});
end

% ========================================================================

function Conflict = LocalChkGrp(Grp1, Grp2)

Grp1 = Grp1(:);
Grp2 = Grp2(:);
Conflict = false;
if length(Grp1) ~= length(Grp2)
    Conflict = true;
elseif ~isempty(Grp1)
    if any(Grp1 ~= Grp2)
        Conflict = true;
    end
end
