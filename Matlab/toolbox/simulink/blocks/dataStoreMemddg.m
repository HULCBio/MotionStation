function dlgStruct = dataStoreMemddg(source, h)
% DATASTOREMEMDDG Dynamic dialog for Data store memory block.
  
%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/11 00:34:19 $

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
dsName.Name             = 'Data store name:';
dsName.Type             = 'edit';
dsName.RowSpan          = [1 1];
dsName.ColSpan          = [1 2];
dsName.ObjectProperty   = 'DataStoreName';
dsName.Tag              = dsName.ObjectProperty;
% required for synchronization --------
dsName.MatlabMethod     = 'slDialogUtil';
dsName.MatlabArgs       = {source,'sync','%dialog','edit','%tag'};

dsRWBlks.Type           = 'textbrowser';
dsRWBlks.Text           = dataStoreRWddg_cb(h.Handle, 'getRWBlksHTML');
dsRWBlks.RowSpan        = [2 2];
dsRWBlks.ColSpan        = [1 2];
dsRWBlks.Tag            = 'dsRWBlks';

dsInitVal.Name          = 'Initial value:';
dsInitVal.Type          = 'edit';
dsInitVal.RowSpan       = [3 3];
dsInitVal.ColSpan       = [1 2];
dsInitVal.ObjectProperty = 'InitialValue';
dsInitVal.Tag           = dsInitVal.ObjectProperty;
% required for synchronization --------
dsInitVal.MatlabMethod  = 'slDialogUtil';
dsInitVal.MatlabArgs    = {source,'sync','%dialog','edit','%tag'};

dsResolveId.Name               = 'Data store name must resolve to Simulink signal object';
dsResolveId.Type               = 'checkbox';
dsResolveId.RowSpan            = [4 4];
dsResolveId.ColSpan            = [1 2];
dsResolveId.DialogRefresh      = 1;
dsResolveId.Enabled            = iscvar(h.DataStoreName);
dsResolveId.ObjectProperty     = 'StateMustResolveToSignalObject';
dsResolveId.Tag                = dsResolveId.ObjectProperty;
% required for synchronization --------
dsResolveId.MatlabMethod       = 'slDialogUtil';
dsResolveId.MatlabArgs         = {source,'sync','%dialog','checkbox','%tag'};

dsRTWStor.Name          = 'RTW storage class:';
dsRTWStor.Type          = 'combobox';
dsRTWStor.Entries       = h.getPropAllowedValues('RTWStateStorageClass')';
dsRTWStor.RowSpan       = [5 5];
dsRTWStor.ColSpan       = [1 1];
dsRTWStor.DialogRefresh = 1;
dsRTWStor.Enabled       = strcmp(h.StateMustResolveToSignalObject, 'off');
dsRTWStor.ObjectProperty = 'RTWStateStorageClass';
dsRTWStor.Tag           = dsRTWStor.ObjectProperty;
% required for synchronization --------
dsRTWStor.MatlabMethod  = 'slDialogUtil';
dsRTWStor.MatlabArgs    = {source,'sync','%dialog','combobox','%tag'};

dsRTWType.Name          = 'RTW type qualifier:';
dsRTWType.Type          = 'edit';
dsRTWType.RowSpan       = [6 6];
dsRTWType.ColSpan       = [1 1];
if ((dsRTWStor.Enabled) && ...
    (~strcmp(h.RTWStateStorageClass,'Auto')))
    dsRTWType.Enabled   = 1;
else
    dsRTWType.Enabled   = 0;
end
dsRTWType.ObjectProperty = 'RTWStateStorageTypeQualifier';
dsRTWType.Tag           = dsRTWType.ObjectProperty;
% required for synchronization --------
dsRTWType.MatlabMethod  = 'slDialogUtil';
dsRTWType.MatlabArgs    = {source,'sync','%dialog','edit','%tag'};

ds1D.Name               = 'Interpret vector parameters as 1-D';
ds1D.Type               = 'checkbox';
ds1D.RowSpan            = [7 7];
ds1D.ColSpan            = [1 2];
ds1D.ObjectProperty     = 'VectorParams1D';
ds1D.Tag                = ds1D.ObjectProperty;
% required for synchronization --------
ds1D.MatlabMethod       = 'slDialogUtil';
ds1D.MatlabArgs         = {source,'sync','%dialog','checkbox','%tag'};

mainTab.Name            = 'Main';
mainTab.Items           = {dsName,dsRWBlks,dsInitVal,...
                           dsResolveId,dsRTWStor,dsRTWType,ds1D};
mainTab.LayoutGrid      = [7 2];
mainTab.RowStretch      = [0 1 0 0 0 0 0];

dsDataType.Name         = 'Data type:';
dsDataType.Type         = 'combobox';
dsDataType.Entries      = h.getPropAllowedValues('DataType')';
dsDataType.RowSpan      = [1 1];
dsDataType.ColSpan      = [1 1];
dsDataType.DialogRefresh = 1;
dsDataType.ObjectProperty = 'DataType';
dsDataType.Tag          = dsDataType.ObjectProperty;
% required for synchronization --------
dsDataType.MatlabMethod = 'slDialogUtil';
dsDataType.MatlabArgs   = {source,'sync','%dialog','combobox','%tag'};

dsOutData.Name          = 'Output data type (e.g. sfix(16), uint(8), float(''single'')):';
dsOutData.NameLocation  = 2;
dsOutData.Type          = 'edit';
dsOutData.RowSpan       = [2 2];
dsOutData.ColSpan       = [1 1];
dsOutData.ObjectProperty = 'OutDataType';
dsOutData.Tag           = dsOutData.ObjectProperty;
% required for synchronization --------
dsOutData.MatlabMethod  = 'slDialogUtil';
dsOutData.MatlabArgs    = {source,'sync','%dialog','edit','%tag'};

dsOutScal.Name          = 'Output scaling value (Slope, e.g. 2^-9 or [Slope Bias], e.g. [1.25 3]):';
dsOutScal.NameLocation  = 2;
dsOutScal.Type          = 'edit';
dsOutScal.RowSpan       = [3 3];
dsOutScal.ColSpan       = [1 1];
dsOutScal.ObjectProperty = 'OutScaling';
dsOutScal.Tag           = dsOutScal.ObjectProperty;
% required for synchronization --------
dsOutScal.MatlabMethod  = 'slDialogUtil';
dsOutScal.MatlabArgs    = {source,'sync','%dialog','edit','%tag'};

if strcmp(h.DataType,'Specify via dialog')
    dsOutData.Visible   = 1;
    dsOutScal.Visible   = 1;
else
    dsOutData.Visible   = 0;
    dsOutScal.Visible   = 0;
end

dsSigType.Name          = 'Signal type:';
dsSigType.Type          = 'combobox';
dsSigType.Entries       = h.getPropAllowedValues('SignalType')';
dsSigType.RowSpan       = [4 4];
dsSigType.ColSpan       = [1 1];
dsSigType.ObjectProperty = 'SignalType';
dsSigType.Tag           = dsSigType.ObjectProperty;
% required for synchronization --------
dsSigType.MatlabMethod  = 'slDialogUtil';
dsSigType.MatlabArgs    = {source,'sync','%dialog','combobox','%tag'};

spacer.Name             = '';
spacer.Type             = 'text';
spacer.RowSpan          = [5 5];
spacer.ColSpan          = [1 2];

dataTab.Name            = 'Data Types';
dataTab.Items           = {dsDataType,dsOutData,dsOutScal,dsSigType, spacer};
dataTab.LayoutGrid      = [5 1];
dataTab.RowStretch      = [0 0 0 0 1];

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
dlgStruct.CloseCallback = 'dataStoreRWddg_cb';
dlgStruct.CloseArgs     = {h.Handle, 'unhilite'};
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
