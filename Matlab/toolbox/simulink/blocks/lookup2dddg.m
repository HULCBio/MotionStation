function dlgStruct = lookup2dddg(source, h)
% LOOKUP2DDDG
%   Default DDG schema for 2-D Lookup block parameter dialog.
%

% Copyright 2004 The MathWorks, Inc.

% Top group is the block description
descTxt.Name            = h.BlockDescription;
descTxt.Type            = 'text';
descTxt.WordWrap        = true;

descGrp.Name            = h.BlockType;
descGrp.Type            = 'group';
descGrp.Items           = {descTxt};
descGrp.RowSpan         = [1 1];
descGrp.ColSpan         = [1 1];

% Bottom group is the block parameters
rowValues.Name           = 'Row index input values:';
rowValues.Type           = 'edit';
rowValues.RowSpan        = [1 1];
rowValues.ColSpan        = [1 4];
rowValues.ObjectProperty = 'RowIndex';
rowValues.Tag            = rowValues.ObjectProperty;
% required for synchronization --------
rowValues.MatlabMethod   = 'slDDGUtil';
rowValues.MatlabArgs     = {source,'sync','%dialog','edit','%tag', '%value'};

colValues.Name           = 'Column index of input values:';
colValues.Type           = 'edit';
colValues.RowSpan        = [2 2];
colValues.ColSpan        = [1 4];
colValues.ObjectProperty = 'ColumnIndex';
colValues.Tag            = colValues.ObjectProperty;
% required for synchronization --------
colValues.MatlabMethod   = 'slDDGUtil';
colValues.MatlabArgs     = {source,'sync','%dialog','edit','%tag', '%value'};

inputValuesEdit.Name       = 'Edit...';
inputValuesEdit.Type       = 'pushbutton';
inputValuesEdit.RowSpan    = [2 2];
inputValuesEdit.ColSpan    = [5 5];
inputValuesEdit.MatlabMethod = 'luteditorddg_cb';
inputValuesEdit.MatlabArgs = {'%dialog',h};

outputValues.Name        = 'Vector of output values:';
outputValues.Type        = 'edit';
outputValues.RowSpan     = [3 3];
outputValues.ColSpan     = [1 4];
outputValues.ObjectProperty = 'OutputValues';
outputValues.Tag         = outputValues.ObjectProperty;
% required for synchronization --------
outputValues.MatlabMethod = 'slDDGUtil';
outputValues.MatlabArgs  = {source,'sync','%dialog','edit','%tag', '%value'};

lookup_popup.Name           = 'Look-up method:';
lookup_popup.Type           = 'combobox';
lookup_popup.Entries        = h.getPropAllowedValues('LookUpMeth')';
lookup_popup.RowSpan        = [4 4];
lookup_popup.ColSpan        = [1 5];
lookup_popup.DialogRefresh  = 1;
lookup_popup.Editable       = 0;
lookup_popup.ObjectProperty = 'LookUpMeth';
lookup_popup.Tag            = lookup_popup.ObjectProperty;
% required for synchronization --------
lookup_popup.MatlabMethod   = 'slDDGUtil';
lookup_popup.MatlabArgs     = {source,'sync','%dialog','combobox','%tag', '%value'};

ts.Name             = 'Sample time (-1 for inherited):';
ts.Type             = 'edit';
ts.ObjectProperty   = 'SampleTime';
ts.Tag              = ts.ObjectProperty;
ts.RowSpan          = [5 5];
ts.ColSpan          = [1 5];
% required for synchronization --------
ts.MatlabMethod     = 'slDDGUtil';
ts.MatlabArgs       = {source,'sync','%dialog','edit','%tag', '%value'};

spacer.Name    = '';
spacer.Type    = 'text';
spacer.RowSpan = [6 6];
spacer.ColSpan = [1 5];

mainTab.Name       = 'Main';
mainTab.Items      = {rowValues,colValues,inputValuesEdit,outputValues,lookup_popup,ts,spacer};
mainTab.LayoutGrid = [6 5];
mainTab.ColStretch = [1 1 1 1 0];
mainTab.RowStretch = [0 0 0 0 0 1];

inputSameDT.Name           = 'Require all inputs to have same data type';
inputSameDT.Type           = 'checkbox';
inputSameDT.RowSpan        = [1 1];
inputSameDT.ColSpan        = [1 1];
inputSameDT.ObjectProperty = 'InputSameDT';
inputSameDT.Tag            = inputSameDT.ObjectProperty;
inputSameDT.DialogRefresh  = 1;
% required for synchronization --------
inputSameDT.MatlabMethod   = 'slDDGUtil';
inputSameDT.MatlabArgs     = {source,'sync','%dialog','checkbox','%tag', '%value'};

dtMode.Name           = 'Output data type mode:';
dtMode.Type           = 'combobox';
dtMode.Entries        = h.getPropAllowedValues('OutDataTypeMode')';
dtMode.RowSpan        = [2 2];
dtMode.ColSpan        = [1 1];
dtMode.DialogRefresh  = 1;
dtMode.Editable       = 0;
dtMode.ObjectProperty = 'OutDataTypeMode';
dtMode.Tag            = dtMode.ObjectProperty;
% required for synchronization --------
dtMode.MatlabMethod   = 'slDDGUtil';
dtMode.MatlabArgs     = {source,'sync','%dialog','combobox','%tag', '%value'};

dtOut.Name           = 'Output data type (e.g. sfix(16), uint(8), float(''single'')):';
dtOut.NameLocation   = 2;
dtOut.Type           = 'edit';
dtOut.RowSpan        = [3 3];
dtOut.ColSpan        = [1 1];
dtOut.ObjectProperty = 'OutDataType';
dtOut.Tag            = dtOut.ObjectProperty;
% required for synchronization --------
dtOut.MatlabMethod   = 'slDDGUtil';
dtOut.MatlabArgs     = {source,'sync','%dialog','edit','%tag', '%value'};

dtOutScal.Name           = 'Output scaling value (Slope, e.g. 2^-9 or [Slope Bias], e.g. [1.25 3]):';
dtOutScal.NameLocation   = 2;
dtOutScal.Type           = 'edit';
dtOutScal.RowSpan        = [4 4];
dtOutScal.ColSpan        = [1 1];
dtOutScal.ObjectProperty = 'OutScaling';
dtOutScal.Tag            = dtOutScal.ObjectProperty;
% required for synchronization --------
dtOutScal.MatlabMethod   = 'slDDGUtil';
dtOutScal.MatlabArgs     = {source,'sync','%dialog','edit','%tag', '%value'};

lockOutScale.Name           = 'Lock output scaling against changes by the autoscaling tool';
lockOutScale.Type           = 'checkbox';
lockOutScale.RowSpan        = [5 5];
lockOutScale.ColSpan        = [1 1];
lockOutScale.ObjectProperty = 'LockScale';
lockOutScale.Tag            = lockOutScale.ObjectProperty;
lockOutScale.DialogRefresh  = 1;
% required for synchronization --------
lockOutScale.MatlabMethod   = 'slDDGUtil';
lockOutScale.MatlabArgs     = {source,'sync','%dialog','checkbox','%tag', '%value'};

if strcmp(h.OutDataTypeMode,'Specify via dialog')
  dtOut.Visible     = 1;
  dtOutScal.Visible = 1;
  lockOutScale.Visible = 1;
else
  dtOut.Visible     = 0;
  dtOutScal.Visible = 0;
  lockOutScale.Visible = 0;
end

round.Name           = 'Round integer calculations toward:';
round.Type           = 'combobox';
round.Entries        = h.getPropAllowedValues('RndMeth')';
round.RowSpan        = [6 6];
round.ColSpan        = [1 1];
round.Editable       = 0;
% round.Mode         = 1;
round.DialogRefresh  = 1;
round.ObjectProperty = 'RndMeth';
round.Tag            = round.ObjectProperty;
% required for synchronization --------
round.MatlabMethod = 'slDDGUtil';
round.MatlabArgs   = {source,'sync','%dialog','combobox','%tag', '%value'};

saturate.Name           = 'Saturate on integer overflow';
saturate.Type           = 'checkbox';
saturate.RowSpan        = [7 7];
saturate.ColSpan        = [1 1];
saturate.ObjectProperty = 'SaturateOnIntegerOverflow';
saturate.Tag            = saturate.ObjectProperty;
% required for synchronization --------
saturate.MatlabMethod   = 'slDDGUtil';
saturate.MatlabArgs     = {source,'sync','%dialog','checkbox','%tag', '%value'};

spacer.Name    = '';
spacer.Type    = 'text';
spacer.RowSpan = [8 8];
spacer.ColSpan = [1 1];

lutd_tm.Type             = 'edit';
lutd_tm.ObjectProperty   = 'LUTDesignTableMode';
lutd_tm.Tag              = lutd_tm.ObjectProperty;
lutd_tm.Visible          = 0;
lutd_tm.RowSpan          = [9 9];
lutd_tm.ColSpan          = [1 1];

lutd_ds.Type             = 'edit';
lutd_ds.ObjectProperty   = 'LUTDesignDataSource';
lutd_ds.Tag              = lutd_ds.ObjectProperty;
lutd_ds.Visible          = 0;
lutd_ds.RowSpan          = [9 9];
lutd_ds.ColSpan          = [1 1];

lutd_fn.Type             = 'edit';
lutd_fn.ObjectProperty   = 'LUTDesignFunctionName';
lutd_fn.Tag              = lutd_fn.ObjectProperty;
lutd_fn.Visible          = 0;
lutd_fn.RowSpan          = [9 9];
lutd_fn.ColSpan          = [1 1];

lutd_useBP.Type             = 'checkbox';
lutd_useBP.ObjectProperty   = 'LUTDesignUseExistingBP';
lutd_useBP.Tag              = lutd_useBP.ObjectProperty;
lutd_useBP.Visible          = 0;
lutd_useBP.RowSpan          = [9 9];
lutd_useBP.ColSpan          = [1 1];

lutd_rel.Type             = 'edit';
lutd_rel.ObjectProperty   = 'LUTDesignRelError';
lutd_rel.Tag              = lutd_rel.ObjectProperty;
lutd_rel.Visible          = 0;
lutd_rel.RowSpan          = [9 9];
lutd_rel.ColSpan          = [1 1];

lutd_abs.Type             = 'edit';
lutd_abs.ObjectProperty   = 'LUTDesignAbsError';
lutd_abs.Tag              = lutd_abs.ObjectProperty;
lutd_abs.Visible          = 0;
lutd_abs.RowSpan          = [9 9];
lutd_abs.ColSpan          = [1 1];

dataTab.Name            = 'Data Types';
dataTab.Items           = {inputSameDT, dtMode,dtOut,dtOutScal,lockOutScale,round,saturate, ...
                          spacer, lutd_tm, lutd_ds, lutd_fn, lutd_useBP, lutd_rel, lutd_abs};
dataTab.LayoutGrid      = [9 1];
dataTab.RowStretch      = [0 0 0 0 0 0 0 1 0];

paramGrp.Name           = 'Parameters';
paramGrp.Type           = 'tab';
paramGrp.Tabs           = {mainTab, dataTab};
paramGrp.RowSpan        = [2 2];
paramGrp.ColSpan        = [1 1];
paramGrp.Source         = h;

%-----------------------------------------------------------------------
% Assemble main dialog struct
%-----------------------------------------------------------------------
dlgStruct.DialogTitle   = ['Block Parameters: ' strrep(h.Name, sprintf('\n'), ' ')];
dlgStruct.Items         = {descGrp, paramGrp};
dlgStruct.LayoutGrid    = [2 1];
dlgStruct.RowStretch    = [0 1];
dlgStruct.HelpMethod    = 'slhelp';
dlgStruct.HelpArgs      = {h.Handle};
% Required for simulink/block sync ----
dlgStruct.PreApplyMethod = 'preApplyCallback';
dlgStruct.PreApplyArgs   = {'%dialog'};
dlgStruct.PreApplyArgsDT = {'handle'};
% Required for deregistration ---------
dlgStruct.CloseMethod       = 'closeCallback';
dlgStruct.CloseMethodArgs   = {'%dialog'};
dlgStruct.CloseMethodArgsDT = {'handle'};

[isLib, isLocked] = source.isLibraryBlock(h);
if isLocked || source.isHierarchySimulating
  dlgStruct.DisableDialog = 1;
else
  dlgStruct.DisableDialog = 0;
end
