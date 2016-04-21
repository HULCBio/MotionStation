function DefineStructureTables(S, Model,InData,OutData)

% Fill in structure tables using defaults as needed.

%	Author:  Larry Ricker
%	Copyright 1986-2003 The MathWorks, Inc. 
%	$Revision: 1.1.8.4 $  $Date: 2003/12/04 01:35:52 $

NumIn = length(Model.InputName);
NumOut = length(Model.OutputName);
S.Sizes(1, 6:7) = [NumIn, NumOut];

[InNames, InTypes] = setInputCharacteristics(S, Model);
[OutNames, OutTypes] = setOutputCharacteristics(S, Model);

if nargin < 3
    InData = cell(NumIn, 5);
    for i = 1:NumIn
        InData(i,:) = {InNames{i}, InTypes{i}, '', '', '0.0'};
    end
    OutData = cell(NumOut, 5);
    for i = 1:NumOut
        OutData(i,:) = {OutNames{i}, OutTypes{i}, '', '', '0.0'};
    end
end

% Need to hide, make change, then make visible in order for changes to
% appear.
setJavaLogical(S.InUDD.Table, 'setVisible', 0);
setJavaLogical(S.OutUDD.Table, 'setVisible', 0);
S.InUDD.setCellData(InData);
S.OutUDD.setCellData(OutData);
setJavaLogical(S.InUDD.Table, 'setVisible', 1);
setJavaLogical(S.OutUDD.Table, 'setVisible', 1);

% Initialize InData & OutData properties
S.InData = InData;
S.OutData = OutData;

% --------------------------------------------------------------------

function [InNames, InTypes] = setInputCharacteristics(S, Model)

% Set input characteristics based on information in Model.  If not set
% there, use default setting.

iMD = [];
iUD = [];
NumIn = S.Sizes(6);
InTypes = cell(1,NumIn);
InTypes(1,:) = {'Manipulated'};
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
        case {'MeasuredDisturbances', 'MD', 'Measured'};
            iMD = [iMD, InputGroup{i,1}];
        case {'UnmeasuredDisturbances', 'UD', 'Unmeasured'};
            iUD = [iUD, InputGroup{i,1}];
        otherwise
            Msg = sprintf(['Imported model contains an unrecognized ', ...
                'InputGroup "%s".  Inputs in "%s" will be classified', ...
                ' as manipulated variables.'], Type, Type);
            uiwait(warndlg(Msg, 'MPC Warning', 'modal'));
    end
end
if ~isempty(iMD)
    InTypes(1,iMD) = {'Meas. disturb.'};
end
if ~isempty(iUD)
    InTypes(1,iUD) = {'Unmeas. disturb.'};
end

S.iMV = [];
S.iMD = [];
S.iUD = [];
for i = 1:NumIn
    % Input signal names
    if length(Model.InputName{i}) > 0 
        InNames{i} = Model.InputName{i};
    else 
        InNames{i} = sprintf('In%i',i); 
    end
    % Pass through types again.  This approach avoids assigning a
    % signal to more than one type.
    Type = InTypes{i};
    switch Type
        case 'Unmeas. disturb.'
            S.iUD = [S.iUD, i];
        case 'Meas. disturb.'
            S.iMD = [S.iMD, i];
        otherwise
            S.iMV = [S.iMV, i];
    end
end
if length(S.iMV) <= 0
    S.iMV = [1:NumIn];
    InTypes(1,:) = {'Manipulated'};
    S.iMD = [];
    S.iUD = [];
    Message = ['Plant model must contain at least one manipulated ', ...
            'variable.  Your model did not contain any, so all input ', ...
            'signal types have been set to manipulated.  Please make ', ...
            'appropriate assignments in the "Input signal properties" table.'];
    uiwait(warndlg(Message,'MPC Warning', 'modal'));
end

S.Sizes(1,1:3) = [length(S.iMV), length(S.iMD), length(S.iUD)];

% --------------------------------------------------------------------

function [OutNames, OutTypes] = setOutputCharacteristics(S, Model)

% Set output characteristics based on information in Model.  If not set
% there, use default setting.

iUO = [];
NumOut = S.Sizes(7);
OutTypes = cell(1,NumOut);
OutTypes(1,:) = {'Measured'};
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
        case {'UnmeasuredOutputs', 'UO', 'Unmeasured'};
            iUO = [iUO, OutputGroup{i,1}];
        otherwise
            Msg = sprintf(['Imported model contains an unrecognized ', ...
                'OutputGroup "%s".  Outputs in "%s" will be classified', ...
                ' as measured outputs.'], Type, Type);
            uiwait(warndlg(Msg, 'MPC Warning', 'modal'));
    end
end
if ~isempty(iUO)
    OutTypes(1,iUO) = {'Unmeasured'};
end

S.iMO = [];
S.iUO = [];
for i = 1:NumOut
    % Output signal names
    if length(Model.OutputName{i}) > 0 
        OutNames{i} = Model.OutputName{i};
    else 
        OutNames{i} = sprintf('Out%i',i); 
    end
    % Pass through types again.  This approach avoids assigning a
    % signal to more than one type.
    Type = OutTypes{i};
    switch Type
        case 'Unmeasured'
            S.iUO = [S.iUO, i];
        otherwise
            S.iMO = [S.iMO, i];
    end
end
if length(S.iMO) <= 0
    S.iMO = [1:NumOut];
    OutTypes(1,:) = {'Measured'};
    S.iUO = [];
    Message = ['Plant model must contain at least one measured ', ...
            'output.  Your model did not contain any, so all output ', ...
            'signal types have been set to measured.  Please make ', ...
            'appropriate assignments in the "Output signal properties" table.'];
    waitfor(warndlg(Message,'MPC Warning', 'modal'));
end
S.Sizes(1,4:5) = [length(S.iMO), length(S.iUO)];

% ========================================================================

function [CellGroup, ngrp] = localStruct2Cell(StructGroup)

Fields = fieldnames(StructGroup);
ngrp = length(Fields);
CellGroup = cell(ngrp,2);
for i = 1:ngrp
    CellGroup{i,2} = Fields{i};
    CellGroup{i,1} = getfield(StructGroup,Fields{i});
end
