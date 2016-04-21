function dlgstruct = sigpropddg(h)
% SIGPROPDDG Dynamic dialog for signal properties dialog
  
% Copyright 1990-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $  $Date: 2004/04/19 01:31:57 $

  portH = [];
  if isa(h, 'Simulink.Line')
    portH = h.getSourcePort;
  elseif isa(h, 'Simulink.Port')
    portH = h;
  end

  if isempty(portH)
      txt.Name              = 'This line is a connection line';
      txt.Type              = 'text';
      txt.RowSpan           = [1,1];
      txt.WordWrap          = true;
      spacer.Type           = 'panel';
      spacer.RowSpan        = [2,2];
      dlgstruct.Items       = {txt, spacer};
      dlgstruct.LayoutGrid  = [2, 1];
      dlgstruct.RowStretch  = [0, 1];
      dlgstruct.DialogTitle = 'Connection Line';
      return
  end
  %------------------------------------------------------------------------
  % First Tab
  %------------------------------------------------------------------------
  
  %---------------------------------------
  % first subgroup
  %---------------------------------------
  chkLogSigData.Tag              = 'chkLogSigData';
  chkLogSigData.Type             = 'checkbox';
  chkLogSigData.Name             = 'Log signal data';
  chkLogSigData.ObjectProperty   = 'dataLogging';
  chkLogSigData.Mode             = 1; % immediate mode
  chkLogSigData.DialogRefresh    = true;
  chkLogSigData.ColSpan          = [1 1];

  if convertToBool(portH.dataLogging)
    portH.testPoint = true;
  end
  
  chkTestPoint.Tag               = 'chkTestPoint';
  chkTestPoint.Type              = 'checkbox';
  chkTestPoint.Name              = 'Test point';
  chkTestPoint.ObjectProperty    = 'testPoint';
  chkTestPoint.ColSpan           = [2 2]; 
  chkTestPoint.Enabled           = ~convertToBool(portH.dataLogging);
  chkTestPoint.DialogRefresh     = true;
  chkTestPoint.Mode              = 1; % immediate mode
  
  spacer1.Tag                    = 'spacer1';
  spacer1.Type                   = 'panel';
  spacer1.ColSpan                = [3 3];
  
  pnl1.Tag                       = 'pnl1';
  pnl1.Type                      = 'panel';
  pnl1.LayoutGrid                = [1 3];
  pnl1.Items                     = {chkLogSigData, chkTestPoint, spacer1};
  pnl1.ColStretch                = [0 0 1];
  pnl1.RowSpan                   = [1 1];
 
  %---------------------------------------
  %second subgroup
  %---------------------------------------
  cmbLog.Tag                     = 'cmbLog';
  cmbLog.Type                    = 'combobox';
  cmbLog.ObjectProperty          = 'dataLoggingNameMode'; 
  cmbLog.Values                  = [0 1];
  cmbLog.Entries                 = {'Use signal name', ...
                                    'Custom'};
  cmbLog.Mode                    = 1; % immediate mode
  cmbLog.DialogRefresh           = true;
  cmbLog.ColSpan                 = [1 1];
  %cmbLog.Enabled                 = convertToBool(portH.dataLogging);
  
  txtName.Tag                    = 'txtName';
  txtName.Type                   = 'edit';
  txtName.ObjectProperty         = 'UserSpecifiedLogName';
  txtName.ColSpan                = [2 2];
  txtName.Enabled                = ~(isequal(portH.dataLoggingNameMode, 'SignalName') && ~isequal(portH.Name, ''));
  txtName.Mode                   = 1; %immediate mode
  
  grpLog.Tag                     = 'grpLog';
  grpLog.Type                    = 'group';
  grpLog.Name                    = 'Logging name';
  grpLog.LayoutGrid              = [1 2];
  grpLog.Items                   = {cmbLog, txtName};
  grpLog.RowSpan                 = [2 2];

  %---------------------------------------  
  % third subgroup
  %---------------------------------------
  chkDataPoints.Tag              = 'chkDataPoints';
  chkDataPoints.Type             = 'checkbox';
  chkDataPoints.RowSpan          = [1 1];
  chkDataPoints.ColSpan          = [1 1];
  chkDataPoints.ObjectProperty   = 'DataLoggingLimitDataPoints';
  chkDataPoints.Enabled          = convertToBool(portH.dataLogging);
  chkDataPoints.DialogRefresh    = true;
  chkDataPoints.Mode             = 1;
  
  lblDataPoints.Tag              = 'lblDataPoints';
  lblDataPoints.Type             = 'text';
  lblDataPoints.Name             = 'Limit data points to last: ';
  lblDataPoints.RowSpan          = [1 1];
  lblDataPoints.ColSpan          = [2 2];
  lblDataPoints.Enabled          = convertToBool(portH.dataLogging);
    
  txtDataPoints.Tag              = 'txtDataPoints';
  txtDataPoints.Type             = 'edit';
  txtDataPoints.ObjectProperty   = 'DataLoggingMaxPoints';
  txtDataPoints.RowSpan          = [1 1];
  txtDataPoints.ColSpan          = [3 3];
  txtDataPoints.Enabled          = convertToBool(portH.dataLogging) && convertToBool(portH.DataLoggingLimitDataPoints);
  
  chkDecimation.Tag              = 'chkDecimation';
  chkDecimation.Type             = 'checkbox';
  chkDecimation.ObjectProperty   = 'DataLoggingDecimateData';
  chkDecimation.RowSpan          = [2 2];
  chkDecimation.ColSpan          = [1 1];
  chkDecimation.Enabled          = convertToBool(portH.dataLogging);
  chkDecimation.DialogRefresh    = 1;
  chkDecimation.Mode             = 1;
  
  lblDecimation.Tag              = 'lblDecimation';
  lblDecimation.Type             = 'text';
  lblDecimation.Name             = 'Decimation: ';
  lblDecimation.RowSpan          = [2 2];
  lblDecimation.ColSpan          = [2 2];
  lblDecimation.Enabled          = convertToBool(portH.dataLogging);
  
  txtDecimation.Tag              = 'txtDecimation';
  txtDecimation.Type             = 'edit';
  txtDecimation.ObjectProperty   = 'DataLoggingDecimation';
  txtDecimation.RowSpan          = [2 2];
  txtDecimation.ColSpan          = [3 3];
  txtDecimation.Enabled          = convertToBool(portH.DataLoggingDecimateData) && convertToBool(portH.dataLogging);
  
  grpData.Tag                    = 'grpData';
  grpData.Type                   = 'group';
  grpData.Name                   = 'Data';
  grpData.LayoutGrid             = [2 3];
  grpData.Items                  = {chkDataPoints, lblDataPoints, txtDataPoints, ...
                                    chkDecimation, lblDecimation, txtDecimation};
  grpData.RowSpan                = [3 3];
  
  
  tab1.Tag                       = 'tab1';
  tab1.Name                      = 'Logging and accessibility';
  tab1.Items                     = {pnl1, grpLog, grpData};
  tab1.LayoutGrid                = [3 1];
  tab1.RowStretch                = [0 0 1];
 
  %---------------------------------------------------------------
  % Second Tab
  %---------------------------------------------------------------  
  lblStorageClass.Tag             = 'lblStorageClass';
  lblStorageClass.Type            = 'text';
  lblStorageClass.Name            = 'RTW storage class:';
  lblStorageClass.RowSpan         = [1 1];
  lblStorageClass.ColSpan         = [1 1];
  
  cmbStorageClass.Tag             = 'cmbStorageClass';
  cmbStorageClass.Type            = 'combobox';
  cmbStorageClass.ObjectProperty  = 'RTWStorageClass'; 
  cmbStorageClass.Values          = [0 1 2 3];                      
  cmbStorageClass.Entries         = {'Auto'            ...
                                     'ExportedGlobal'  ...
                                     'ImportedExtern'  ...
                                     'ImportedExternPointer'};
  cmbStorageClass.Mode            = 1; % immediate mode
  cmbStorageClass.DialogRefresh   = true;
  cmbStorageClass.Enabled         = (~isempty(portH.Name) && ~convertToBool(portH.MustResolveToSignalObject));
  cmbStorageClass.RowSpan         = [1 1];
  cmbStorageClass.ColSpan         = [2 2];
  
  spacer2.Tag                     = 'spacer2';
  spacer2.Type                    = 'panel';
  spacer2.RowSpan                 = [1 1];
  spacer2.ColSpan                 = [3 3];
  
  lblTypeQualifier.Tag            = 'lblTypeQualifier';
  lblTypeQualifier.Type           = 'text';
  lblTypeQualifier.Name           = 'RTW storage type qualifier:';
  lblTypeQualifier.RowSpan        = [2 2];
  lblTypeQualifier.ColSpan        = [1 1];
  
  txtTypeQualifier.Tag            = 'txtTypeQualifier';
  txtTypeQualifier.Type           = 'edit';
  txtTypeQualifier.ObjectProperty = 'RTWStorageTypeQualifier';
  txtTypeQualifier.Mode           = 1; % immediate mode
  txtTypeQualifier.Enabled        = ((cmbStorageClass.Enabled) && ...
                                     (~isequal(portH.RTWStorageClass, 'Auto')));
  txtTypeQualifier.RowSpan        = [2 2];
  txtTypeQualifier.ColSpan        = [2 2];
  
  spacer3.Tag                     = 'spacer3';
  spacer3.Type                    = 'panel';
  spacer3.RowSpan                 = [2 2];
  spacer3.ColSpan                 = [3 3];
  
  spacer4.Tag                     = 'spacer4';
  spacer4.Type                    = 'panel';
  spacer4.RowSpan                 = [3 3];
  spacer4.ColSpan                 = [1 3];
  
  tab2.Tag                        = 'tab2';
  tab2.Name                       = 'Real-Time Workshop';
  tab2.Items                      = {lblStorageClass, cmbStorageClass, spacer2 ...
                                     lblTypeQualifier, txtTypeQualifier, spacer3 ...
                                     spacer4};
 
  tab2.LayoutGrid                 = [3 3];
  tab2.ColStretch                 = [0 .1 .9];
  tab2.RowStretch                 = [0 0 1];
  
  %---------------------------------------------------------------
  %Third Tab
  %---------------------------------------------------------------
  lblDescription.Tag              = 'lblDescription';
  lblDescription.Type             = 'text';
  lblDescription.Name             = 'Description:';
  lblDescription.RowSpan          = [1 1];
  
  txtDescription.Tag              = 'txtDescription';
  txtDescription.Type             = 'editarea';
  txtDescription.RowSpan          = [2 2];
  txtDescription.ObjectProperty   = 'Description';
  
  hypLink.Tag                     = 'hypLink';
  hypLink.Type                    = 'hyperlink';
  hypLink.Name                    = 'Document Link';
  hypLink.MatlabMethod            = 'doc';
  hypLink.MatlabArgs              = {portH.documentLink};
  hypLink.RowSpan                 = [3 3];
  
  txtLink.Tag                     = 'txtLink';
  txtLink.Type                    = 'edit';
  txtLink.ObjectProperty          = 'documentLink';
  txtLink.RowSpan                 = [4 4];
 
  tab3.Tag                        = 'tab3';
  tab3.Name                       = 'Documentation';
  tab3.LayoutGrid                 = [4 1];
  tab3.Items                      = {lblDescription ...
                                     txtDescription ...
                                     hypLink ...
                                     txtLink};
 
  %--------------------------------------------------------------
  % better for separate widgets
  %--------------------------------------------------------------
  lblSignalName.Tag               = 'lblSignalName';
  lblSignalName.Name              = 'Signal name:';
  lblSignalName.Type              = 'text';
  lblSignalName.RowSpan           = [1 1];
  lblSignalName.ColSpan           = [1 1];
  
  txtSignalName.Tag               = 'txtSignalName';
  txtSignalName.Type              = 'edit';
  txtSignalName.ObjectProperty    = 'Name';
  txtSignalName.Mode              = 1; % immediate mode
  txtSignalName.DialogRefresh     = true;
  txtSignalName.RowSpan           = [1 1];
  txtSignalName.ColSpan           = [2 2];
  
  lblShowSigProp.Tag              = 'lblShowSigProp';
  lblShowSigProp.Name             = 'Show propagated signals';
  lblShowSigProp.Type             = 'text';
  lblShowSigProp.RowSpan          = [1 1];
  lblShowSigProp.ColSpan          = [3 3];
  lblShowSigProp.Visible          = portH.supportsSignalPropagation;
  
  cmbShowSigProp.Tag              = 'cmbShowSigProp';
  cmbShowSigProp.Type             = 'combobox';
  cmbShowSigProp.ObjectProperty   = 'signalPropagation'; 
  cmbShowSigProp.Values           = [0 1 2];
  cmbShowSigProp.Entries          = {'off', ...
                                    'on',   ...
                                    'all'};
  cmbShowSigProp.RowSpan          = [1 1];
  cmbShowSigProp.ColSpan          = [4 4];
  cmbShowSigProp.Visible          = portH.supportsSignalPropagation;
  
  chkResSigObj.Tag                = 'MustResolveToSignalObject';
  chkResSigObj.Type               = 'checkbox';
  chkResSigObj.Name               = 'Signal name must resolve to Simulink signal object';
  chkResSigObj.ObjectProperty     = 'MustResolveToSignalObject';
  chkResSigObj.Mode               = 1; % immediate mode
  chkResSigObj.DialogRefresh      = true;
  chkResSigObj.Enabled            = ~isempty(portH.Name);
  chkResSigObj.RowSpan            = [2 2];
  chkResSigObj.ColSpan            = [1 4];
  
  tabContainer.Tag                = 'tabContainer';
  tabContainer.Name               = 'MainTab';
  tabContainer.Type               = 'tab';
  tabContainer.Tabs               = {tab1, tab2, tab3};
  tabContainer.RowSpan            = [3 3];
  tabContainer.ColSpan            = [1 4];
  
  %---------------------------------------------------------------
  % Main Dialog
  %---------------------------------------------------------------
  dlgstruct.DialogTag             = 'dlgstruct';
  if isequal(portH.Name, '') 
    dlgstruct.DialogTitle         = 'Signal Properties: (unnamed)';
  else
    dlgstruct.DialogTitle         = ['Signal Properties: ' portH.Name];
  end
  dlgstruct.Items                 = {lblSignalName,  txtSignalName,  ...
                                     chkResSigObj, ...
                                     lblShowSigProp, cmbShowSigProp, ...
                                     tabContainer};
  dlgstruct.LayoutGrid            = [3 4];
  dlgstruct.RowStretch            = [0 0 1];
  dlgstruct.ColStretch            = [0 1 0 0];
  
  if isa(portH, 'handle')
    dlgstruct.Source              = portH;
  end
  
  dlgstruct.DisableDialog         = ~isa(portH, 'handle');
  dlgstruct.HelpMethod            = 'slprophelp';
  dlgstruct.HelpArgs              = {'signal'};
  

  function ret = convertToBool(x)
  if(isa(x, 'logical'))
    ret = x;
  else %it must be a string
    ret = strcmp(x, 'on');
  end
     