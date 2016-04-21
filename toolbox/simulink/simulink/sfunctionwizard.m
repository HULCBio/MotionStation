function varargout = sfunctionwizard(varargin)
% SFUNCTIONWIZARD controls and manages the display of the S-Function Builder Block.
%
%    To launch the block, copy an S-function block to a
%    model and double click on the block
%
% SFUNCTIONWIZARD(BLOCKHANDLE)  
%     Starts the dialog in the current directory.  
%     BLOCKHANDLE is a handle of an S-function block 
% SFUNCTIONWIZARD(BLOCKHANDLE, 'DELETE') 
%     Closes the S-Function Builder dialog window

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision $  $Date: 2004/04/15 00:49:03 $
%   Ricardo Monteiro  01/26/2001

error(nargchk(1, 4, nargin));

blockHandle = varargin{1};
rtwsimTest = 0;
if nargin > 3
  SfunbuilderAppData = varargin{4};
else
  SfunbuilderAppData = getAppDataName(blockHandle);
end
if nargin == 1
  % Call from Simulink
  Action = 'Create';
  nargout = 0;
else
  Action = varargin{2};
  nargout = 1;
  rtwsimTest = 1;
end
  
  % Process action
  switch (Action)
   case 'Create'
    nargout = 0;
    rtwsimTest = 0;
    %%%%%%%%%%%%%%%%%%
    % Create  Dialog %
    %%%%%%%%%%%%%%%%%%
    if ~usejava('mwt')
      error(['Java is not currently fully enabled on this platform. Please see' ...
             ' Writing S-functions manual for information on how to write S-functions.']);
    end
    
    if isappdata(0, SfunbuilderAppData)
      ad = getappdata(0, SfunbuilderAppData);
      if isfield(ad, 'FrameHandle')
        try
          ad.FrameHandle.show;
        end
        return
      end
    end
    
    mlock
    ad = setup(blockHandle, rtwsimTest,SfunbuilderAppData);
    ad.blockName = getfullname(blockHandle);
    % unlock the library 
    if (strcmp(get_param(bdroot(gcbh),'Name'),'simulink3') | ....
        strcmp(get_param(bdroot(gcbh),'Name'),'simulink'))
      ad.isSimulink3 = 1;
    else
      set_param(bdroot(blockHandle),'Lock','off');
      ad.isSimulink3 = 0;
    end
    setappdata(0, SfunbuilderAppData, ad);
    
    %%%%%%%%%%%%%%%%%%
    % Destroy Dialog %
    %%%%%%%%%%%%%%%%%%
   case 'delete'
    try
      if nargin == 2 &  isfield(getappdata(0),'SfAdsystem') & ~isfield(getappdata(0), SfunbuilderAppData)
        SfunbuilderAppData = 'SfAdsystem';
      end
      ad = getappdata(0, SfunbuilderAppData);
      errorState = lasterr;
      % if the user deletes the same block destroy the wizard window    
      if ~isempty(ad) & strcmp(ad.blockName, getfullname(varargin{1}))
        closeWindow(ad.FrameHandle, ad.HGHandle, SfunbuilderAppData)
      else
        if  nargin >= 3
          varargin{3}.dispose;
        end
      end
      lasterr(errorState);
      return
    end
    %%%%%%%%%%%%%%%%%%
    % Cancel Dialog %
    %%%%%%%%%%%%%%%%%%
   case 'doCancel'
    try
      ad = getappdata(0, SfunbuilderAppData);
      errorState = lasterr;
      % if the user deletes the same block destroy the wizard window    
      if ~isempty(ad) & strcmp(ad.blockName, getfullname(varargin{1}))
        doCancel(0,0,SfunbuilderAppData);
      else
        if  nargin >= 3
          varargin{3}.dispose;
        end
      end
      lasterr(errorState);
      return
    end
    %%%%%%%%%%%%%%%%%%%%%%%%
    % Get Application Data %
    %%%%%%%%%%%%%%%%%%%%%%%%
   case 'GetApplicationData'
    
    if ~usejava('mwt')
      error('Java is not currently fully enabled on this platform');
    end
    ad = setup(blockHandle, rtwsimTest, SfunbuilderAppData);
    ad.blockName = getfullname(blockHandle);
    % unlock the library 
    if (strcmp(get_param(bdroot(gcbh),'Name'),'simulink') | ...
        strcmp(get_param(bdroot(gcbh),'Name'),'simulink3'))
      ad.isSimulink3 = 1;
    else
      set_param(bdroot(blockHandle),'Lock','off');
      ad.isSimulink3 = 0;
    end
    
    varargout{1} = ad;
    if isappdata(0, SfunbuilderAppData)
      rmappdata(0, SfunbuilderAppData)
    end
    
    %%%%%%%%%%%
    % doBuild %
    %%%%%%%%%%%
   case 'doBuild'
    
    doBuild(0, 0, SfunbuilderAppData);

    %%%%%%%%%
    % Build %
    %%%%%%%%%
   case 'Build'
    ad = varargin{3};
    setappdata(0, SfunbuilderAppData, ad)
    doFinish(ad,0,0,SfunbuilderAppData);
    varargout{1} = ad;
    if isappdata(0, SfunbuilderAppData)
      clearIncludePath(ad);
      rmappdata(0, SfunbuilderAppData)
    end
   otherwise
    disp('Invalid input') 
  end
%end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function AppDataName = getAppDataName(blockHandle)
% Creates a unique application data name.
AppDataName = 'SfAd';
try
  if ~isempty(get_param(blockHandle,'SfunBuilderFcnName'))
    AppDataName = [AppDataName get_param(blockHandle,'SfunBuilderFcnName')];
  else
    AppDataName = [AppDataName get_param(blockHandle,'FunctionName')];
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ad = setup(blockHandle,rtwsimTest,SfunbuilderAppData)
% create wizard frame and shove in first panel
if nargin < 4
  SfunType = 0;
end
% create frame
defaultTitle = ['S-Function Builder: ' strrep(getfullname(blockHandle),sprintf('\n'), ' ')];
panel = com.mathworks.toolbox.simulink.sfunbuilder.SFunctionBuilder.CreateSfunctionBuilder(defaultTitle, int32(rtwsimTest), SfunType);
%f = panel.getParent;
panel.setBlockHandle(blockHandle);
panel.setAppDataName(SfunbuilderAppData);
% use a wait cursor
ad.FrameHandle = panel;
ad.FrameHandle.setCursor(java.awt.Cursor.WAIT_CURSOR)

setappdata(0, SfunbuilderAppData, ad);

% initialize app data
ad.DefaultTitle = defaultTitle;
ad.IncPathExists = 0;
if isappdata(0,'SfunctionBuilderIncludePath') 
  ad.IncludeDir = getappdata(0,'SfunctionBuilderIncludePath');
else
  SfunBuilderAddIncludePath = cell(1,3);
  SfunBuilderAddIncludePath{1} = pwd;
  ad.IncludeDir = SfunBuilderAddIncludePath;
  setappdata(0,'SfunctionBuilderIncludePath', ad.IncludeDir);
  ad.IncPathExists = 1;
end
ad.rtwsimTest = rtwsimTest;
ad.PathName = pwd;
ad.Overwritable = '';
ad.compileSuccess = 0;
ad.CreateCompileMexFileFlag = 1;
ad.AlertOnClose = 0;
ad.DiagnosticViewer = '';
if nargin
  ad.inputArgs = blockHandle;
else
  ad.inputArgs = '';
end

% update app data so callbacks can fire
setappdata(0, SfunbuilderAppData, ad);

set(ad.FrameHandle,'Tag',SfunbuilderAppData);
ad.HGHandle = findobj(0,'Tag',SfunbuilderAppData);

setappdata(0, SfunbuilderAppData, ad);

[panel, ad] = updatePanels(panel, ad);

ad.FrameHandle.setCursor(java.awt.Cursor.DEFAULT_CURSOR);


if ~rtwsimTest
  % update frame
 ad.FrameHandle.show;
end
setappdata(0, SfunbuilderAppData, ad);
ad.SfunBuilderPanel.sfName.requestFocus;
ad.SfunBuilderPanel.saveInitFcn;
ad.SfunBuilderPanel.setAlertFlag(boolean(0));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [panel, ad] = updatePanels(panel, ad)

ad = getSfunWizardData(ad);
sfunblkWizData = ad.SfunWizardData;
try
  str = ['val = [[.9  0.75 0.75 1 1 .9 .9 1]'',[1 1 0.75 0.75 .9 .9 1 .9]''];' ...
        'try , sys = get_param(gcb,''SfunBuilderFcnName'');',...
         'if isempty(sys), sys = get_param(gcb,''FunctionName''); end,',...
         'catch, sys = get_param(gcb,''FunctionName''); end'];
  set_param(ad.inputArgs,'MaskInitialization',str);
end
try
  panel.pickPanel(str2num(ad.SfunWizardData.PanelIndex));
catch 
  panel.pickPanel(0);
end

if( ~strcmp(sfunblkWizData.SampleTime, xlate('Inherited')) & ...
    ~strcmp(sfunblkWizData.SampleTime, xlate('Continuous')))
  sfunblkWizData.SampleTimeValue = sfunblkWizData.SampleTime;
  sfunblkWizData.SampleTime = 'Discrete';
else
  sfunblkWizData.SampleTimeValue ='';
end

panel.updateBuildButton(ad.SfunWizardData.SfunName);

panel.setSettingsPanel(ad.SfunWizardData.NumberOfDiscreteStates,...
                       ad.SfunWizardData.DiscreteStatesIC,...
                       ad.SfunWizardData.NumberOfContinuousStates,...
                       ad.SfunWizardData.ContinuousStatesIC,...
                       ad.SfunWizardData.NumberOfParameters,...
                       sfunblkWizData.SampleTime,...
                       sfunblkWizData.SampleTimeValue);

ad.SfunWizardData.ExternalDeclaration = deblank(ad.SfunWizardData.ExternalDeclaration);
ad.SfunWizardData.IncludeHeadersText = deblank(ad.SfunWizardData.IncludeHeadersText);
panel.setLibraryPanel(ad.SfunWizardData.ExternalDeclaration,...
                      ad.SfunWizardData.IncludeHeadersText,...
                      ad.SfunWizardData.LibraryFilesText); 

ad.SfunWizardData.UserCodeText = deblank(ad.SfunWizardData.UserCodeText);
ad.SfunWizardData.UserCodeTextmdlUpdate = deblank(ad.SfunWizardData.UserCodeTextmdlUpdate);
ad.SfunWizardData.UserCodeTextmdlDerivative = deblank(ad.SfunWizardData.UserCodeTextmdlDerivative);
panel.setMethodsPanel(ad.SfunWizardData.UserCodeText,...
                      ad.SfunWizardData.UserCodeTextmdlUpdate,...
                      ad.SfunWizardData.UserCodeTextmdlDerivative,...
                      str2num(ad.SfunWizardData.GenerateTLC),...
                      str2num(ad.SfunWizardData.DirectFeedThrough));

ad.SfunBuilderWidgets = panel.getBuilderPortsPanel;

if isfield( ad.SfunWizardData, 'InputPorts')

  [fPortsConfigPanel, ad] = sfunbuilderports('Create', ad.inputArgs ,...
                                             ad.SfunWizardData.InputPorts ,...
                                             ad.SfunWizardData.OutputPorts,...
                                             ad.SfunWizardData.Parameters,ad);
else
  ad = i_moveFields(ad);
  ad = i_moveParamsFields(ad);
  [fPortsConfigPanel, ad] = sfunbuilderports('Create', ad.inputArgs,...
                                             ad.SfunWizardData.InputPorts,...
                                             ad.SfunWizardData.OutputPorts,...
                                             ad.SfunWizardData.Parameters,ad);
end

ad.SfunBuilderPanel = panel;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ad = doSetParamSFname(ad, SfunbuilderAppData)
% Set the S-function paramter name. This allows the builder to get the
% changes from the C file in case it fail to build.

sfunctionName = ad.SfunBuilderPanel.sfName;
sfunctionName = char(sfunctionName.getText);
sfunctionName = strtok(sfunctionName,'.');
warnState = warning; 
warning on;
if ~isempty(sfunctionName)
  try
    if isvalidmatname(sfunctionName)
      set_param(getfullname(ad.inputArgs),'FunctionName', sfunctionName);   
    else  
      InvalidSFunNameMsg =  sprintf('Invalid S-function file: %s', sfunctionName);
      warning(InvalidSFunNameMsg);
    end
  end
  warning(warnState);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ad = doCancel(obj, evd,SfunbuilderAppData)
% do imports
import java.awt.*;
import com.mathworks.mwt.*;
import com.mathworks.mwt.dialog.*;
import com.mathworks.mwt.window.*;

if nargin == 0, obj = gcbo; end

ad = locGetAppData(nargin, obj,SfunbuilderAppData);
if isempty(ad)
  if strcmp(get(obj,'Type'),'com.mathworks.mwt.MWFrame')
    set(obj,'Visible','off');
  end
  return;
end
if (~ad.isSimulink3)
% Call the allert window
  str = sprintf('There are unsaved changes in the S-Function Builder.\nThese changes can either be discarded or saved to the S-function.');
  replyResults = MWAlert(ad.FrameHandle ,'Warning',str,5); 
  
  switch  get(replyResults,'Reply')
   case 4
    % Dont' Save %
    closeWindow(ad.FrameHandle, ad.HGHandle,SfunbuilderAppData)
    % clear lock on this file 
    munlock
   case 3
    % Save %
    ad.SfunBuilderPanel.donotCompileFlagButton.setSelected(1);
    doSetParamSFname(ad,SfunbuilderAppData);
    % call doFinish 
    doFinish(ad,evd,0,SfunbuilderAppData);
    closeWindow(ad.FrameHandle, ad.HGHandle,SfunbuilderAppData)
    % clear lock on this file 
    munlock
   case 2
    % Do nothing %
    replyResults.dispose;
    return
  end
  replyResults.dispose;
else
  closeWindow(ad.FrameHandle, ad.HGHandle,SfunbuilderAppData)
  % clear lock on this file 
  munlock
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function clearIncludePath(ad)
% Clear the SfunctionBuilderIncludePath
if ad.IncPathExists
  try
    rmappdata(0,'SfunctionBuilderIncludePath');
  end
end 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = doBuild(obj, evd, SfunbuilderAppData)
% do imports
import java.awt.*;
import com.mathworks.mwt.*;
import com.mathworks.mwt.dialog.*;
import com.mathworks.mwt.window.*;

ad = getappdata(0, SfunbuilderAppData);

sfunctionName = ad.SfunBuilderPanel.sfName;
sfunctionName = char(sfunctionName.getText);
sfunctionTLCName = [sfunctionName '.tlc'];
sfunctionName = addextension(sfunctionName);

if (isFileInCurrentDir(sfunctionName) & isempty(ad.Overwritable) & ~ad.rtwsimTest)
  sfunctionName = which(sfunctionName);
  % Handling '\' for PC platforms
  sfunctionName = strrep(sfunctionName,'\','\\');
  str = sprintf(['Overwriting file ' sfunctionName]);
  replyResults = MWAlert(ad.FrameHandle ,'Warning',str,2); 
  ButtonID = get(replyResults,'Reply');
  if (ButtonID == 1)
    ad.Overwritable = 'Yes';
  else
    return
  end
  replyResults.dispose;
else
    % if you get here is beacause the sfunction was created by the wizard 
    % so allow overwriting next time the user press build
    ad.Overwritable = 'Yes';
end

if (isFileInCurrentDir(sfunctionTLCName)  & ~ad.rtwsimTest)
  sfunctionTLCName = strrep(sfunctionTLCName,'\','\\');
  str = sprintf(['Overwriting TLC file ' sfunctionTLCName]);
  replyResults = MWAlert(ad.FrameHandle ,'Warning',str,2); 
  ButtonID = get(replyResults,'Reply');
  if (ButtonID ~= 1)
    return;
  end
  replyResults.dispose;
end

%% Update buttons
ad.SfunBuilderPanel.updateCloseButton('Close');
if ~isempty(ad.DiagnosticViewer)
  try
    ad.DiagnosticViewer.Visible = 0;
  end
end

% call doFinish with four arguments so that we dont close the window
ad = doFinish(ad,evd,0,SfunbuilderAppData);
setappdata(0, SfunbuilderAppData,ad);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ad = locSetAppData(n, ad,SfunbuilderAppData)
% only set app data if this call came from a callback
if n == 3
    setappdata(0, SfunbuilderAppData, ad);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ad = doFinish(ad, evd, flag,SfunbuilderAppData)

sfunctionName = ad.SfunBuilderPanel.sfName;
sfunctionName = char(sfunctionName.getText);
sfunctionName = addextension(sfunctionName);
ad.SfunWizardData.SfunName = strtok(sfunctionName,'.');
cr = sprintf('\n');
if ~isvalidmatname(sfunctionName)
  InvalidSFunNameMsg =  sprintf(['\n Error: Cannot create the S-function file as ''%s''\n',...
                                'because the S-function name is not a valid MATLAB function name.'], sfunctionName);
 ad.SfunBuilderPanel.fCompileStatsTextArea.setText(InvalidSFunNameMsg);
 return;
end
 
[ad, isValid, errorMessage, p] = sfbcheckports(ad);
if(~isValid)
  ad.SfunBuilderPanel.fCompileStatsTextArea.setText(errorMessage);	  
  return
end

% report an error for incorrect settings for ports, states and paramaters
[ad, isValid, errorMessage, d]  = sfbcheckstates(ad);
if(~isValid)
  ad.SfunBuilderPanel.fCompileStatsTextArea.setText(errorMessage);	  
  return
end

% C S-Function
createCompileCSfun(ad, sfunctionName, SfunbuilderAppData,p, d);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  ad = createCompileCSfun(ad, sfunctionName, SfunbuilderAppData, p, d)
% p contains PortInfo
% d contains StatesInfo

CreateWrapperTLC = getSelectedValue(ad.SfunBuilderPanel.generateTLCButton);
directFeed =  getSelectedValue(ad.SfunBuilderPanel.directFeed);
ad.SfunWizardData.DirectFeedThrough = directFeed;

% Parse the libraries section of the s-function builder code
libTextCode = char(ad.SfunBuilderPanel.fIncludeLibraries.getText);
[libFileList, srcFileList, objFileList, ...     
 addIncPaths, addLibPaths, addSrcPaths, ...
 preProcList, preProcUndefList, unrecognizedInfo ] =      ...
    parseLibCodePaneText(libTextCode);

% Save structure to MAT file for use with RTWMAKECFG.M that's generated
% for code generation. This pathway is used for addition include source
% folders, additional include paths
sfBuilderBlockNameMATFile = ['.' filesep 'SFB__' ...
                    char(ad.SfunBuilderPanel.sfName.getText) ...
                    '__SFB.mat'];
SFBInfoStruct.includePath = {addIncPaths{:} addLibPaths{:}};
SFBInfoStruct.sourcePath  = {addSrcPaths{:}};

libAndObjFilesWithFullPath= locateFileInPath({libFileList{:} objFileList{:}},...
                                              {addLibPaths{:} addSrcPaths{:} pwd},...
                                             filesep);
srcFilesSearchPaths = {addSrcPaths{:} './'};
srcFilesWithFullPath = locateFileInPath(srcFileList,srcFilesSearchPaths,filesep);
if ~isempty(libFileList) || ~isempty(objFileList)
  SFBInfoStruct.additionalLibraries = {libAndObjFilesWithFullPath{:}};
end

if exist(sfBuilderBlockNameMATFile)
  delete(sfBuilderBlockNameMATFile);
end
try
eval(['save ' sfBuilderBlockNameMATFile ' ' 'SFBInfoStruct']);
catch
  disp(sprintf('warning: could not create MAT file to store the state in %s for code generation.', ...
               sfBuilderBlockNameMATFile));
end
clear SFBInfoStruct;

currentArgs = get_param(bdroot,'RTWMakeCommand');
preprocUpdatedMakeCmd = UpdatePreProcDefsInMakeCmd(currentArgs,preProcList,preProcUndefList);
set_param(bdroot,'RTWMakeCommand',preprocUpdatedMakeCmd);

panelIndex = num2str(ad.SfunBuilderPanel.getSelectedSfunBuilderPanel);
methodsFlags = char(ad.SfunBuilderPanel.getMethodsFlag);

% Generate a temporary file with all the wizard parameters from the 
% initialization, data properties and libraries panes.
% Note that the 'Library/object/source files' text box in the 'Libraries'
% pane is stored in a single line string separated by the __SFB__ separators
% so that on reloading an existing s-function builder project, the information
% can be reconstructed.
libTextCodeForTempFile = regexprep(libTextCode,sprintf('\n'),'__SFB__');
libTextCodeForTempFile = ['__SFB__' libTextCodeForTempFile];
wizardParamsTempFile = tempname;
generateFileParams(wizardParamsTempFile,p.NumberOfInputs, p.NumberOfOutputs, ...
		  directFeed, p.SampleTime, p.NumberOfParameters,    ...
		  d.NumDStates,d.DStatesIC,d.NumCStates,d.CStatesIC, ...
		  CreateWrapperTLC,libTextCodeForTempFile, panelIndex, ...
                  ad.SfunWizardData.InputPorts,  ...
                  ad.SfunWizardData.OutputPorts, ...
                  ad.SfunWizardData.Parameters, methodsFlags);

if any(isspace(wizardParamsTempFile))
  wizardParamsTempFile = ['"' wizardParamsTempFile '"'];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create a temporary file with the contents of the  mdlOutputs,      %
% mdlUpdates, mdlDerivatives, externDeclarations and include panels  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[mdlOutputTempFile ,mdlOutputTextCode] = CreateTempFile(ad.SfunBuilderPanel, 'tfmdlOutput');
ad.SfunWizardData.UserCodeText =  mdlOutputTextCode;

[mdlUpdateTempFile, mdlUpdateTextCode, ...
 flagDeletemdlUpdate] = CreateTempFile(ad.SfunBuilderPanel, 'tfmdlUpdate');
ad.SfunWizardData.UserCodeTextmdlUpdate =  mdlUpdateTextCode;
if (isempty(mdlUpdateTextCode))
  mdlUpdateTempFile = 'NO_USER_DEFINED_DISCRETE_STATES';
end

[mdlDerivativeTempFile, mdlDerivativeTextCode,...
 flagDeletemdlDerivative] = CreateTempFile(ad.SfunBuilderPanel, 'tfmdlDerivative');
ad.SfunWizardData.UserCodeTextmdlDerivative =  mdlDerivativeTextCode;
if (isempty(mdlDerivativeTextCode))
  mdlDerivativeTempFile = 'NO_USER_DEFINED_CONTINUOS_STATES';
end

[externDeclarationTempFile, externDeclarationTextCode ,...
 flagDeleteexternDeclaration ] = CreateTempFile(ad.SfunBuilderPanel, 'fExternTextArea');
ad.SfunWizardData.ExternalDeclaration =  externDeclarationTextCode;
if (isempty(externDeclarationTextCode))
  externDeclarationTempFile = 'NO_USER_DEFINED_C_CODE';
end

[headersTempFile, headersTextCode,...
 flagDeleteHeader] = CreateTempFile(ad.SfunBuilderPanel, 'fIncludeHeaders');
ad.SfunWizardData.IncludeHeadersText = headersTextCode;
if(isempty(headersTextCode))
  headersTempFile = 'NO_USER_DEFINED_HEADER_CODE';
end

% Wrapper S-function Name
[unused wrapperName] = fileparts(ad.SfunWizardData.SfunName);
wrapperName = [wrapperName '_wrapper.c'];
customSrcAndLibAndObj = [''''                              ...
                    joinCellToStr({                        ...
                        wrapperName,                       ...
                        libAndObjFilesWithFullPath{:}      ...
                        srcFilesWithFullPath{:}} ,''',''') ...
                    ''''];

pathFcnCall = fullfile(matlabroot,'toolbox','simulink','simulink','private');
perlScript = fullfile(matlabroot,'toolbox','simulink','simulink','private','sfunctionwizard.pl');

% use a wait cursor
ad.FrameHandle.setCursor(java.awt.Cursor.WAIT_CURSOR)

s = []; w = [];
mexVerboseText = '';
textDisp = '';

createmessage = generateFormatedMessage(ad,sfunctionName);

if(ad.CreateCompileMexFileFlag)
  ad.SfunBuilderPanel.fCompileStatsTextArea.setText(sprintf('\n\nGenerating %s  ....Please wait',  sfunctionName));
  try
    % Call the perl script
    if ispc
      perlLocation = fullfile(matlabroot, 'sys\perl\win32\bin\perl');
      [s,w] = dos([perlLocation ' ' perlScript ' ' sfunctionName ' ' mdlOutputTempFile ' ' mdlUpdateTempFile ' ' headersTempFile...
		   ' ' externDeclarationTempFile ' ' pathFcnCall ' ' wizardParamsTempFile ' ' mdlDerivativeTempFile ]);
      
    else
      [s,w] = unix(['perl ' perlScript ' ' sfunctionName ' ' mdlOutputTempFile ' ' mdlUpdateTempFile ' ' headersTempFile ...
		    ' ' externDeclarationTempFile ' ' pathFcnCall ' ' wizardParamsTempFile ' ' mdlDerivativeTempFile]);
    end
  catch
    % Avoid hard errors (i.e. UNC Path)
    ErrorMessage = lasterr;
    ad.SfunBuilderPanel.fCompileStatsTextArea.setText(ErrorMessage);
    ad.FrameHandle.setCursor(java.awt.Cursor.DEFAULT_CURSOR);
    return
  end
  % Do not compile and show the appropriate message
  if ((ad.SfunBuilderPanel.donotCompileFlagButton.isSelected) & (~s)) 
     setcompileStatsTextArea(ad,sfunctionName,createmessage,'');
     ad.FrameHandle.validate;
     deleteTempFiles(mdlOutputTempFile);
     deleteTempFiles(wizardParamsTempFile);
     
     if(flagDeletemdlUpdate)
       deleteTempFiles(mdlUpdateTempFile);
      end
     if(flagDeleteHeader);
       deleteTempFiles(headersTempFile);
     end

     if(flagDeleteexternDeclaration)
       deleteTempFiles(externDeclarationTempFile);
     end
	
     if(flagDeletemdlDerivative)
       deleteTempFiles(mdlDerivativeTempFile);
     end

     ad.FrameHandle.setCursor(java.awt.Cursor.DEFAULT_CURSOR);
     return
  elseif(s)
    ad.SfunBuilderPanel.fCompileStatsTextArea.setText(w);
    ad.FrameHandle.setCursor(java.awt.Cursor.DEFAULT_CURSOR);
    return
  end

  % Create mex file
  if(~s)
   ad.SfunBuilderPanel.fCompileStatsTextArea.setText('');
   ad.SfunBuilderPanel.fCompileStatsTextArea.setText(sprintf('\n\nCompiling %s  ....Please wait',  sfunctionName));
   
   try
      [mexVerboseText, errorOccured] = sfbuilder_mexbuild(ad, sfunctionName, customSrcAndLibAndObj, ...
						addIncPaths, preProcList);
   catch
      errorOccured = 1;
      mexVerboseText = sprintf(['\n\n\n\t\tAn unexpected error occurred during compilation. Please' ...
		    ' verify the following:\n' ...
		    '\t\t -The MEX command is configured correctly. Type ''mex -setup'' at \n',...
		    '\t\t  MATLAB command prompt to configure this command.\n',...
		    '\t\t -The S-function settings in the Initialization or Libraries tab were entered incorrectly.\n',...
		    '\t\t  (i.e. use comma separated list for the library/source files)\n',...
		    '\t\t -If S-Function Builder dialog box in an invalid state, please restart\n' ...
	            '\t\t  MATLAB before using this dialog further.']);
    end
    ad.SfunBuilderPanel.fCompileStatsTextArea.setText('');
    if(~errorOccured & ~(ad.SfunBuilderPanel.mexverboseButton.isSelected))
      % there were no compilation errors and verbose mexverboseButton off
      clear strtok(sfunctionName,'.'));
      sfunNameMEX = getFileName(sfunctionName);
      textDisp = sprintf('### S-function %s created successfully',  sfunNameMEX);
      ad = setcompileStatsTextArea(ad,sfunctionName,createmessage,textDisp);
      ad.SfunBuilderPanel.fCompileStatsTextArea.repaint;
      ad.SfunBuilderPanel.fCompileStatsTextArea.requestFocus
      ad.FrameHandle.validate;
      rtwsimTestDiagnostics(ad, textDisp);
      ad.compileSuccess = 1;
    elseif(~errorOccured & (ad.SfunBuilderPanel.mexverboseButton.isSelected))
      % there were no compilation errors and mexverboseButton was on;    
      clear strtok(sfunctionName,'.'));
      sfunNameMEX = getFileName(sfunctionName);
      textDisp = sprintf('### S-function %s created successfully',  sfunNameMEX);
      fullMessage = [createmessage];
      ad = setcompileStatsTextArea(ad,sfunctionName,fullMessage,textDisp);
      ad.FrameHandle.validate;
      ad.SfunBuilderPanel.fCompileStatsTextArea.requestFocus
      rtwsimTestDiagnostics(ad, textDisp);
      ad.compileSuccess = 1;
      ad = callDiagnosticViewer(ad,[fullMessage mexVerboseText],SfunbuilderAppData,'Info');
    elseif(errorOccured & ~(ad.SfunBuilderPanel.mexverboseButton.isSelected))
      % error occured and verbose mexverboseButton off
      ad.SfunBuilderPanel.fCompileStatsTextArea.setText(mexVerboseText)
      ad.SfunBuilderPanel.fCompileStatsTextArea.repaint;
      ad.SfunBuilderPanel.fCompileStatsTextArea.requestFocus
      rtwsimTestDiagnostics(ad, mexVerboseText);
      ad.compileSuccess = 0;
      ad = callDiagnosticViewer(ad,mexVerboseText,SfunbuilderAppData);
    else
      % error occured and verbose mexverboseButton on
      textDisp = sprintf('\nCompile of ''%s'' failed.\n\n',  sfunctionName);
      ad.SfunBuilderPanel.fCompileStatsTextArea.setText([textDisp]);
      rtwsimTestDiagnostics(ad, mexVerboseText);
      ad.compileSuccess = 0;
      ad = callDiagnosticViewer(ad,mexVerboseText,SfunbuilderAppData);
    end
    
  else
    ad.SfunBuilderPanel.fCompileStatsTextArea.setText(w)
    ad.FrameHandle.setCursor(java.awt.Cursor.DEFAULT_CURSOR);
    return
  end
end
% done building the mex file, turn the cursor back
ad.FrameHandle.setCursor(java.awt.Cursor.DEFAULT_CURSOR);

LibSourceTextCode =  ad.SfunBuilderPanel.fIncludeLibraries;
LibSourceTextCode = char(LibSourceTextCode.getText);
ad.SfunWizardData.LibraryFilesText = LibSourceTextCode;

% Remove field to ensure backwards compatibility
wizData = i_removeFieldFromWizData(ad);

ad.AlertOnClose = 1;
ad.SfunBuilderPanel.setAlertFlag(boolean(1));
if(ad.compileSuccess)
  if(ishandle(ad.inputArgs))
    if(~ad.isSimulink3)
      % Set the WizardData, S-function name and S-function parameters
      % Use try and catch to avoid hard errors for set_param
      try
	set_param(getfullname(ad.inputArgs),'FunctionName', sfunctionName(1:end-2));
        ad.SfunBuilderPanel.doSetParameters;
        paramStr = ad.SfunBuilderPanel.getDelimitedParameterString;
        set_param(ad.inputArgs, 'Parameters',char(paramStr));
        
        set_param(bdroot(getfullname(ad.inputArgs)),'Dirty','on');
        setPortLabels(ad.inputArgs, ad.SfunWizardData.InputPorts, ad.SfunWizardData.OutputPorts);
      end
      try
        filesForSFunctionModules = joinCellToStr({srcFileList{:} libFileList{:} objFileList{:}},' ');
        if isempty(filesForSFunctionModules)
          filesForSFunctionModules = ' ';
        end
        filesForSFunctionModules = regexprep(filesForSFunctionModules,...
                                             '\.c(pp)?','','ignorecase');
	set_param(getfullname(ad.inputArgs),'SFunctionModules', ...
                                [sfunctionName(1:end-2),'_wrapper',' ',...
                                 filesForSFunctionModules]);
      end
      try
	set_param(getfullname(ad.inputArgs),'WizardData',wizData);
      end
    else
      % do nothing
    end
  end
  ad.SfunBuilderPanel.setAlertFlag(boolean(0));

  ad.AlertOnClose = 0;
elseif(~ad.isSimulink3)
  % Give the user the inforamation for next time the wizard is called
  try
    set_param(getfullname(ad.inputArgs),'WizardData',wizData);
  end
end

%%%%%%%%%%%%%%%%%%%%%
% Delete temp files %
%%%%%%%%%%%%%%%%%%%%%
deleteTempFiles(mdlOutputTempFile);
deleteTempFiles(wizardParamsTempFile);
if(flagDeletemdlUpdate)
   deleteTempFiles(mdlUpdateTempFile);
end

if(flagDeleteHeader);
  deleteTempFiles(headersTempFile);
end

if(flagDeleteexternDeclaration)
  deleteTempFiles(externDeclarationTempFile);
end
if(flagDeletemdlDerivative)
     deleteTempFiles(mdlDerivativeTempFile);
end

% Clear mex to fix the problems on LINUX
try 
  pause(0.1)
  evalin('base', 'rehash path')
end
% End doBuild

%%%%%%%%%%%%%%%%%%%%%
% Helper functions  %
%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ad = locGetAppData(n, obj, SfunbuilderAppData)
% returns the applcation data
if nargin ~= 0 & n == 1
    ad = obj;
else
    ad = getappdata(0, SfunbuilderAppData);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function closeWindow(frame, h, SfunbuilderAppData)
% Closes the S-function Window

% clear lock on this file
munlock

if ~isempty(frame)
  frame.dispose;
  frame = [];
end
if isappdata(0, SfunbuilderAppData)
  ad = getappdata(0, SfunbuilderAppData);
  ad.SfunBuilderPanel.restoreBlkParams;
  ad.SfunBuilderPanel.SFbuilderTerminate;
  if ~isempty(ad.DiagnosticViewer)
    try
      ad.DiagnosticViewer.Visible = 0;
    end
  end
  clearIncludePath(ad);
  rmappdata(0, SfunbuilderAppData)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Name = addextension(name)
% adds the .mdl extension to the model

hasextension = findstr(name,'.');
if(isempty(hasextension))
  Name = [name '.c'];
else
   Name = name;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function name = getFileName(name)
  name = strtok(name,'.');
  % try this quitely beacuse of Java issues on Linux
  try
    clear(name);
    nameWithPath = which(name);
    p = filesep;
    indexp = findstr(nameWithPath,p);
    name = nameWithPath(1+indexp(end):end);
  end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ad = getSfunWizardData(ad)
% wizardData default values
ad.SfunWizardData.SfunName = '';
ad.SfunWizardData.InputPortWidth = '1';
ad.SfunWizardData.OutputPortWidth = '1';
ad.SfunWizardData.SfunctionParameters = '';
ad.SfunWizardData.NumberOfParameters = '0';
ad.SfunWizardData.DirectFeedThrough = '1';
ad.SfunWizardData.SampleTime = xlate('Inherited');
ad.SfunWizardData.NumberOfDiscreteStates = '0';
ad.SfunWizardData.DiscreteStatesIC = '0';
ad.SfunWizardData.NumberOfContinuousStates = '0';
ad.SfunWizardData.ContinuousStatesIC = '0';
ad.SfunWizardData.ExternalDeclaration = '/* extern double func(double a); */';
ad.SfunWizardData.IncludeHeadersText = '#include <math.h>';
ad.SfunWizardData.LibraryFilesText = '';
empty_space = '                         ';
cr = sprintf('\n');
sampleCodeText = sprintf(['/* This sample sets the output equal to the input' cr ,...
		       '         y0[0] = u0[0];' cr 'For complex signals use: y0[0].re = u0[0].re;',...
                        cr empty_space 'y0[0].im = u0[0].im;',...
                        cr empty_space 'y1[0].re = u1[0].re;',...
                        cr empty_space  'y1[0].im = u1[0].im;*/']);
ad.SfunWizardData.UserCodeText = sampleCodeText;
 sampleCodeText = sprintf(['/*' cr ' * Code example' cr ,...
       ' *   xD[0] = u0[0];' cr '*/ ']);       
ad.SfunWizardData.UserCodeTextmdlUpdate = sampleCodeText;
sampleCodeText = sprintf(['/*' cr ' * Code example' cr ,...
       ' *   dx[0] = xC[0];' cr '*/ ']);  
ad.SfunWizardData.UserCodeTextmdlDerivative = sampleCodeText;
ad.SfunWizardData.GenerateTLC = '1';
ad.SfunWizardData.PanelIndex = '0';
ad.SfunWizardData.InputDataType0 = 'double';
ad.SfunWizardData.OutputDataType0 = 'double';
ad.SfunWizardData.InputSignalType0 = 'real';
ad.SfunWizardData.OutputSignalType0 = 'real';
ad.SfunWizardData.InFrameBased0 = 'off';
ad.SfunWizardData.OutFrameBased0 = 'off';
ad.SfunWizardData.TemplateType = '1';
ad.SfunWizardData.Input0DimsCol = '1';
ad.SfunWizardData.Output0DimsCol = '1';

% if we fail to read the C source file rely on the basic defaults
ad = addDefaultPortsInfo(ad);

mdlWizardData = '';

ad.SfunWizardData.SfunName = get_param(getfullname(ad.inputArgs),'FunctionName');

ad.SfunWizardData.SfunctionParameters = get_param(getfullname(ad.inputArgs),'Parameters');

if(~strcmp(ad.SfunWizardData.SfunName,'system'))
  try
    if ishandle(ad.inputArgs)
      mdlWizardData = get_param(getfullname(ad.inputArgs),'WizardData');
    end
    % If the model contains wizard data use it
    if(~isempty(mdlWizardData))
      mdlWizardData = i_addFields(mdlWizardData);
      ad.SfunWizardData = mdlWizardData;
    end
  end
  % load #defines from sfunction.c
  if (exist([ad.SfunWizardData.SfunName '.c']) == 2 )
    ad = read_sfunction_code(ad);
  end

  % load outputs,updates etc from sfunction_wrapper.c
  if (exist([ad.SfunWizardData.SfunName '_wrapper.c']) == 2)
    ad = read_wrapper_code(ad);
  end
  try
    set_param(ad.inputArgs,'SfunBuilderFcnName', ad.SfunWizardData.SfunName);  
  end
else
  try
    set_param(ad.inputArgs,'SfunBuilderFcnName', ad.SfunWizardData.SfunName);  
  end
  % set the wizard data Sfunction name to empty
  ad.SfunWizardData.SfunName = '';
end

try
  if (~strcmp(get_param(bdroot(ad.inputArgs),'Name'),'simulink3') | ...
      ~strcmp(get_param(bdroot(ad.inputArgs),'Name'),'simulink'))
    % set the default wizard to fire up the DeleteFcn listener
  set_param(getfullname(ad.inputArgs),'WizardData', ad.SfunWizardData);
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ad] = read_sfunction_code(ad)
% Read the wizarddata from the c files 

s = []; w = [];
perlScript = fullfile(matlabroot,'toolbox','simulink','simulink','private','read_sfunwiz.pl');
perlLocation = fullfile(matlabroot, 'sys\perl\win32\bin\perl');
sfunctionName = [ad.SfunWizardData.SfunName '.c'];
if (exist(sfunctionName) == 2)
  sfunctionName = which(sfunctionName);
  clear(sfunctionName);

  % read the version number
  ad.Version = '';
  if any(isspace(sfunctionName))
    sfunctionName = ['"' sfunctionName '"'];
  end

  perlScriptVersion = fullfile(matlabroot,'toolbox','simulink','simulink','private','get_sfbuilder_version.pl');
  try
    if ispc
      perlLocation = fullfile(matlabroot, 'sys\perl\win32\bin\perl');
      [status,sfbVersion] = dos([perlLocation ' '  perlScriptVersion ' '  sfunctionName]);
      eval(sfbVersion);
    else
      [status,sfbVersion] = unix(['perl ' perlScriptVersion ' '  sfunctionName]);
      eval(sfbVersion);
    end
  catch
    ErrorMessage = lasterr;
    disp(ErrorMessage);
  end  
 %- 
 %
 switch(ad.Version)
  case '1.0'
   try
     if ispc
       perlLocation = fullfile(matlabroot, 'sys\perl\win32\bin\perl');
       [s,w] = dos([perlLocation ' '  perlScript ' '  sfunctionName ' '  ad.Version]);
     else
       [s,w] = unix(['perl ' perlScript ' '  sfunctionName ' ' ad.Version]);
     end
   catch
     ErrorMessage = lasterr;
     disp(ErrorMessage);
   end
  case '2.0'
   try
     if ispc
       perlLocation = fullfile(matlabroot, 'sys\perl\win32\bin\perl');
      [s,w] = dos([perlLocation ' '  perlScript ' '  sfunctionName ' '  ad.Version]);
    else
      [s,w] = unix(['perl ' perlScript ' '  sfunctionName ' ' ad.Version]);
    end
  catch
     ErrorMessage = lasterr;
     disp(ErrorMessage);
   end
  case '3.0'
   try
     if ispc
       perlLocation = fullfile(matlabroot, 'sys\perl\win32\bin\perl');
      [s,w] = dos([perlLocation ' '  perlScript ' '  sfunctionName ' '  ad.Version]);
    else
      [s,w] = unix(['perl ' perlScript ' '  sfunctionName ' ' ad.Version]);
    end
  catch
     ErrorMessage = lasterr;
     disp(ErrorMessage);
  end
  otherwise
   disp(sprintf('Invalid S-function Builder version found in: %s Using default parameters',sfunctionName));
 end
end


try
  if (~s)
    w = strrep(w,'"','');
    eval(w)
    ad.SfunWizardData.DiscreteStatesIC  =  strrep(ad.SfunWizardData.DiscreteStatesIC,'[','');
    ad.SfunWizardData.DiscreteStatesIC  =  strrep(ad.SfunWizardData.DiscreteStatesIC,']','');
    ad.SfunWizardData.ContinuousStatesIC =  strrep(ad.SfunWizardData.ContinuousStatesIC,']','');
    ad.SfunWizardData.ContinuousStatesIC = strrep(ad.SfunWizardData.ContinuousStatesIC,'[','');
    if ~isempty(strmatch('__SFB__',ad.SfunWizardData.LibraryFilesText))
    ad.SfunWizardData.LibraryFilesText = strrep(ad.SfunWizardData.LibraryFilesText,'__SFB__',sprintf('\n'));
    else
      % For backwards compatibility
      ad.SfunWizardData.LibraryFilesText = strrep(ad.SfunWizardData.LibraryFilesText, ' ',sprintf('\n'));
    end
    if(strcmp(ad.Version,'1.0'))
      ad.SfunWizardData.InputPortWidth = strrep(ad.SfunWizardData.InputPortWidth, 'DYNAMICALLY_SIZED','-1');
      ad.SfunWizardData.OutputPortWidth = strrep(ad.SfunWizardData.OutputPortWidth, 'DYNAMICALLY_SIZED','-1');
    end
    if strcmp(ad.SfunWizardData.SampleTime, 'INHERITED_SAMPLE_TIME');
      ad.SfunWizardData.SampleTime = xlate('Inherited');
    elseif strcmp(ad.SfunWizardData.SampleTime, '0');
      ad.SfunWizardData.SampleTime = xlate('Continuous');
    end    
    if (~strcmp(ad.SfunWizardData.GenerateTLC, '0') & (~strcmp(ad.SfunWizardData.GenerateTLC, '1'))) 
      ad.SfunWizardData.GenerateTLC = '0';
    end
  else
    disp(w);
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ad] = read_wrapper_code(ad, mdlWizardData)

wrapper_sfunctionName = [ad.SfunWizardData.SfunName '_wrapper.c'];
pathFcnCall = strrep(which(mfilename), [mfilename '.p'],'');
perlScript = fullfile(matlabroot,'toolbox','simulink','simulink','private','read_sfunwiz_wrapper.pl');

if (exist(wrapper_sfunctionName) == 2)
  wrapper_sfunctionName = which(wrapper_sfunctionName);
  clear(wrapper_sfunctionName);
  if any(isspace(wrapper_sfunctionName))
    wrapper_sfunctionName = ['"' wrapper_sfunctionName '"'];
  end
  firstStr{1} = 'SFUNWIZ_wrapper_Outputs_Changes_BEGIN';
  lastStr{1}  = 'SFUNWIZ_wrapper_Outputs_Changes_END';
  firstStr{2} = 'SFUNWIZ_wrapper_Update_Changes_BEGIN';
  lastStr{2}  = 'SFUNWIZ_wrapper_Update_Changes_END';
  firstStr{3} = 'SFUNWIZ_wrapper_Derivatives_Changes_BEGIN';
  lastStr{3}  = 'SFUNWIZ_wrapper_Derivatives_Changes_END';
  firstStr{4} = 'SFUNWIZ_wrapper_includes_Changes_BEGIN';
  lastStr{4}  = 'SFUNWIZ_wrapper_includes_Changes_END';
  firstStr{5} = 'SFUNWIZ_wrapper_externs_Changes_BEGIN';
  lastStr{5}  = 'SFUNWIZ_wrapper_externs_Changes_END';
  try 
    for k = 1: length(firstStr)
      if ispc
	perlLocation = fullfile(matlabroot, 'sys\perl\win32\bin\perl');
	[s,w{k}] = dos([perlLocation ' '  perlScript ' '  wrapper_sfunctionName ' ' firstStr{k} ' ' lastStr{k}]);
	
      else
	[s,w{k}] = unix(['perl ' perlScript ' '  wrapper_sfunctionName ' ' firstStr{k} ' ' lastStr{k}]);
      end
    end
  catch
    ErrorMessage = lasterr;
    disp(ErrorMessage);
  end  
  if (~s)
    ad.SfunWizardData.UserCodeText = w{1};
    ad.SfunWizardData.UserCodeTextmdlUpdate = w{2};
    ad.SfunWizardData.UserCodeTextmdlDerivative = w{3};
    ad.SfunWizardData.IncludeHeadersText = w{4};
    ad.SfunWizardData.ExternalDeclaration = w{5};
  else
    disp(w);
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = isFileInCurrentDir(fileName)
% Returns 1 if file is in the current dir
presentDir = pwd;
out = 0;
fileNamefullPath = [presentDir filesep fileName];
if (exist(fileNamefullPath) == 2)
  out = 1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function valid = isvalidmatname(c)
% returns 1 of it's a valid name and 0 otherwize
valid = 1;
inValidChars = ['~';'!';'@';'#';'$';'%';'^';'&';'*';'(';')';'-';'+';,...
		'|';'='; '\';'{';'}';'[';']';'<';'>';'?';'/';'.'];

if(ischar(c))
  isFirstDigitaNum = isempty(double(str2num(c(1))));
  if(~isFirstDigitaNum);
    if ~(strcmp(c(1),'i') | (strcmp(c(1),'j')))
      valid = 0;
    return;
    end
  end  
  indx =  findstr(c,'.');
  if(indx)
    c =  c(1:indx(end)-1);
  end
  for i = 1 : length(inValidChars)
    if findstr(inValidChars(i),c);
      valid = 0;
    end
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = getSelectedValue(in)

if(in.isSelected == logical(0))
  out = '0';
else
  out = '1';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = getLogicValue(in)

in = get(in,'State');
if(strcmp(in,'off'))
  out = '0';
else
  out = '1';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function [tempFileName, tf, delFlag] = CreateTempFile(ad, adField)
% Create a temporary file with 
tempFileName = '';
tf = '';
switch adField
 case {'tfmdlOutput','tfmdlUpdate','tfmdlDerivative'}
   tf = ad.getUserCode(adField);
 otherwise
  tf = getfield(ad,adField);
  tf = tf.getText;
end

%tf = getfield(ad,adField);
%tf = char(tf.getText);
tf = char(tf);
if isempty(tf)
  tf = ' ';
end
% Call MATLAB's tempname to generate a temporary file
if (~isempty(tf))
  delFlag = 1;
  tempFileName =  tempname;
  fid = fopen(tempFileName,'w');
  fprintf(fid,'%s',tf);
  fclose(fid);
else
  delFlag = 0;
end

% Add double quote to a file name to avoid problems with files that has
% spaces in its path
  if any(isspace(tempFileName))
    tempFileName = ['"' tempFileName '"'];
  end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function [SampleTime, ad] = setSampleTime(SampleTime,ad)
import com.mathworks.toolbox.simulink.sfunbuilder.*;

status = get(ad.SfunBuilderWidgets.fSampleTimeDiscreteValue, 'Enabled');

if strcmp(status,'on')
 SampleTime = ad.SfunBuilderWidgets.fSampleTimeDiscreteValue;
 SampleTime = char(SampleTime.getText);
end
ad.SfunWizardData.SampleTime = SampleTime;

SampleTime =  strrep(SampleTime,']',''); 
SampleTime =  strrep(SampleTime,'[','');
warnMsg =  sprintf(['Warning: You have specified an invalid sample time.\n\tSetting' ...
		    ' the S-function sample time to be inherited']);
warnMsg1 =  sprintf(['Warning: Sample Time was not specified.\n\tSetting' ...
		    ' the S-function sample time to be inherited']);

try
  if (str2num(SampleTime) >= 0);
    return
  elseif (findstr(SampleTime,...
          char(SfunBuilderResourceBundle.getString('settings.SamplingMode.Inherited'))))
    SampleTime = 'INHERITED_SAMPLE_TIME';
   return
  elseif (findstr(SampleTime,...
                  char(SfunBuilderResourceBundle.getString('settings.SamplingMode.Continuous'))))
    SampleTime = '0';
    return
  elseif (findstr(SampleTime,'UserDefined'));
    SampleTime = 'INHERITED_SAMPLE_TIME';
    disp(warnMsg1);
    return
  elseif isempty(str2num(SampleTime))
    SampleTime = 'INHERITED_SAMPLE_TIME';
    disp(warnMsg1);
    return
  elseif ~(isempty(str2num(SampleTime)))
    if (str2num(SampleTime) == -1)
      SampleTime = 'INHERITED_SAMPLE_TIME';
    else (str2num(SampleTime) <= -1);
      disp(warnMsg);
      SampleTime = 'INHERITED_SAMPLE_TIME';
    end
  end
catch
  disp(warnMsg);
  SampleTime = 'INHERITED_SAMPLE_TIME';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function [createmessage, ad ] = generateFormatedMessage(ad,sfunctionName);
% Build the strings without carriage return so that we can trigger the hyperlink callbacks
textWidth = 500;
wrapperFile = [strtok(sfunctionName,'.') '_wrapper.c'];
str1 =  sprintf('### ''%s'' created successfully', sfunctionName);
str2=   sprintf('### ''%s'' created successfully', wrapperFile);

space =  blanks(textWidth);
space1 = blanks(textWidth - length(str1));
space2 = blanks(textWidth - length(str2));

if(str2num(getSelectedValue(ad.SfunBuilderPanel.generateTLCButton)))
  sfunctionNameTLC = strrep(sfunctionName,'.c','.tlc');
  str3 =  sprintf('### ''%s'' created successfully', sfunctionNameTLC);
  space3 = blanks(textWidth - length(str3));
  createmessage = [space str1 space1 str2 space2 str3 space3];
else
  createmessage = [space str1 space1 str2 space2];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function  ad =  setcompileStatsTextArea(ad,sfunctionName,createmessage,textDisp);
textWidth = 500;
createmessage = [createmessage textDisp];
dv = DAStudio.DiagnosticViewer('dummy');
msg = DAStudio.DiagnosticMsg;
msg.type = 'info';
msg.sourceFullName = 'S-function Builder';
msg.sourceName = 'S-function Builder';
msg.component = 'S-function Builder';

c = msg.Contents;
c.details = createmessage;
c.Details = msg.findhtmllinks(c.Details);
import com.mathworks.toolbox.dastudio.diagView.*;
try
  % (xxx) remove it 
ad.SfunBuilderPanel.fCompileStatsTextArea.setAutoWrap(1)
ad.SfunBuilderPanel.fCompileStatsTextArea.setSize(textWidth,300)
ad.SfunBuilderPanel.fCompileStatsTextArea.setText('');
ad.SfunBuilderPanel.fCompileStatsTextArea.setText(c.Details);
catch
  ad.SfunBuilderPanel.fCompileStatsTextArea.setText(createmessage);
end


c.summary = c.details;
c.Type = 'info';

dv.addDiagnosticMsg(msg);
dv.javaEngaged = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function  ad = callDiagnosticViewer(ad, errorText,SfunbuilderAppData,TypeStr)

if nargin == 3
  TypeStr = 'error';
end
dv = DAStudio.DiagnosticViewer('S-function Builder');

msg = DAStudio.DiagnosticMsg;
msg.type = TypeStr;
msg.sourceFullName = getfullname(ad.inputArgs);
msg.sourceName =  get_param(ad.inputArgs,'Name');
msg.component = 'S-function Builder';

% Here populate the first messsage's contents
c = msg.Contents;
c.Type = 'Build';
c.details = errorText;
c.summary = c.details;
dv.addDiagnosticMsg(msg);

% here make the diagnostic viewer visible
dv.javaEngaged = 1;
dv.Visible = 1;
ad.DiagnosticViewer = dv;
setappdata(0, SfunbuilderAppData, ad);                                                

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function deleteTempFiles(name)
% remove double quotes
name = strrep(name,'"','');
delete(name);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function makeCmdStr = UpdatePreProcDefsInMakeCmd(currentMakeCmdStr,preProcList,preProcUndefList);

makeCmdStr = currentMakeCmdStr;

if ~isempty(preProcList)
  preprocListStr = '';
  for idx = 1:length(preProcList)
    if isempty(preProcList{idx}) continue, end
    if isempty(regexp(currentMakeCmdStr,preProcList{idx}))
      preprocListStr = [preprocListStr ' -D' preProcList{idx} ' '];
    end
  end
  if ~isempty(preprocListStr)
    makeCmdStr = [makeCmdStr ' OPTS="' preprocListStr '"'];
  end
end

if ~isempty(preProcUndefList)
  for idx = 1:length(preProcUndefList)
    if isempty(preProcUndefList{idx}) continue, end
    makeCmdStr = regexprep(makeCmdStr,['-D' preProcUndefList{idx}],'');
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function generateFileParams(fileName,NumberOfInputs, NumberOfOutputs,directFeed, ...
                           SampleTime, NumberOfParameters, NumDStates,DStatesIC,...
                           NumCStates,CStatesIC,CreateWrapperTLC, LibList, ...
                           PanelIndex, iP,oP,paramsList, methodsFlags)

n1 = ['NumOfCStates=' NumCStates];
n2 = ['CStatesIC=' CStatesIC];
n3 = ['NumOfDStates=' NumDStates];
n4 = ['DStatesIC=' DStatesIC];
n5 = ['NumberOfParameters=' NumberOfParameters];
n6 = ['SampleTime=' SampleTime];
n7 = ['CreateWrapperTLC=' CreateWrapperTLC];
n8 =['directFeed=' directFeed];
n9 =['LibList=' LibList];
n10 =['PanelIndex=' PanelIndex];
iP.Row{1} = NumberOfInputs;
oP.Row{1} =  NumberOfOutputs;
fidExtern = fopen(fileName,'w');
fprintf(fidExtern,'%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n', n1,...
        n2, n3, n4, n5, n6, n7, n8, n9, n10); 

 if strcmp(iP.Name{1}, 'ALLOW_ZERO_PORTS')
   fprintf(fidExtern,'%s\n', ['NumberOfInputPorts= 0']);
 else
   fprintf(fidExtern,'%s\n', ['NumberOfInputPorts=' num2str(length(iP.Name))]);
 end
 if strcmp(oP.Name{1}, 'ALLOW_ZERO_PORTS')
   fprintf(fidExtern,'%s\n', ['NumberOfOutputPorts= 0']);
 else
  fprintf(fidExtern,'%s\n', ['NumberOfOutputPorts=' num2str(length(oP.Name))]);
 end

 fprintf(fidExtern,'%s\n', ['GenerateStartFunction= ' methodsFlags(1)]);
 fprintf(fidExtern,'%s\n', ['GenerateTerminateFunction= ' methodsFlags(2)]);
 
 for i = 1:length(iP.Name)
   fprintf(fidExtern,'%s\n', ['InPort' num2str(i) '{']);
   fprintf(fidExtern,'%s\n', ['inPortName' num2str(i) '=' iP.Name{i}]);
   fprintf(fidExtern,'%s\n', ['inDataType' num2str(i) '=' iP.DataType{i}]);
   fprintf(fidExtern,'%s\n', ['inDims' num2str(i) '=' iP.Dims{i}]);
   fprintf(fidExtern,'%s\n', ['inRow' num2str(i) '=' iP.Row{i}]);
   fprintf(fidExtern,'%s\n', ['inCol' num2str(i) '=' iP.Col{i}]);
   fprintf(fidExtern,'%s\n', ['inComplexity' num2str(i) '='  iP.Complexity{i}]);
   fprintf(fidExtern,'%s\n', ['inFrameBased' num2str(i) '=' iP.Frame{i}]);
   fprintf(fidExtern,'%s\n', ['inIsSigned' num2str(i) '=' iP.IsSigned{i}]);
   fprintf(fidExtern,'%s\n', ['inWordLength' num2str(i) '=' iP.WordLength{i}]);
   fprintf(fidExtern,'%s\n', ['inFractionLength' num2str(i) '=' iP.FractionLength{i}]);
   fprintf(fidExtern,'%s\n', ['inFixPointScalingType' num2str(i) '=' iP.FixPointScalingType{i}]);
   fprintf(fidExtern,'%s\n', ['inSlope' num2str(i) '=' iP.Slope{i}]);
   fprintf(fidExtern,'%s\n', ['inBias' num2str(i) '=' iP.Bias{i}]);  
   fprintf(fidExtern,'%s\n', '}');
 end

 for i = 1:length(oP.Name)
   fprintf(fidExtern,'%s\n', ['OutPort' num2str(i) '{']);
   fprintf(fidExtern,'%s\n', ['outPortName' num2str(i) '=' oP.Name{i}]);
   fprintf(fidExtern,'%s\n', ['outDataType' num2str(i) '=' oP.DataType{i}]);
   fprintf(fidExtern,'%s\n', ['outDims' num2str(i) '=' oP.Dims{i}]);
   fprintf(fidExtern,'%s\n', ['outRow'  num2str(i) '=' oP.Row{i}]);
   fprintf(fidExtern,'%s\n', ['outCol'  num2str(i) '=' oP.Col{i}]);
   fprintf(fidExtern,'%s\n', ['outComplexity'  num2str(i) '=' oP.Complexity{i}]);
   fprintf(fidExtern,'%s\n', ['outFrameBased'  num2str(i) '=' oP.Frame{i}]);
   fprintf(fidExtern,'%s\n', ['outIsSigned' num2str(i) '=' oP.IsSigned{i}]);
   fprintf(fidExtern,'%s\n', ['outWordLength' num2str(i) '=' oP.WordLength{i}]);
   fprintf(fidExtern,'%s\n', ['outFractionLength' num2str(i) '=' oP.FractionLength{i}]);
   fprintf(fidExtern,'%s\n', ['outFixPointScalingType' num2str(i) '=' oP.FixPointScalingType{i}]);
   fprintf(fidExtern,'%s\n', ['outSlope' num2str(i) '=' oP.Slope{i}]);
   fprintf(fidExtern,'%s\n', ['outBias' num2str(i) '=' oP.Bias{i}]);      
   fprintf(fidExtern,'%s\n', '}');
 end

 for i = 1:length(paramsList.Name)
   fprintf(fidExtern,'%s\n', ['Parameter' num2str(i) '{']);
   fprintf(fidExtern,'%s\n', ['parameterName' num2str(i) '=' paramsList.Name{i}]);
   fprintf(fidExtern,'%s\n', ['parameterDataType' num2str(i) '=' paramsList.DataType{i}]);
   fprintf(fidExtern,'%s\n', ['parameterComplexity'  num2str(i) '=' paramsList.Complexity{i}]);
   fprintf(fidExtern,'%s\n', '}');
 end

fclose(fidExtern);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setPortLabels(blkHandle,iP,oP)

defaultMaskString = sprintf(['plot(val(:,1),val(:,2))' '\n' 'disp(sys)']);
inportString = '';
if ~strcmp(iP.Name{1}, 'ALLOW_ZERO_PORTS')
  for k=1:length(iP.Name)
    portName = iP.Name{k};
    inportString = sprintf([inportString '\n' 'port_label(''input'',' num2str(k) ',' '''' portName ''')']);       
  end
end
defaultMaskString = [defaultMaskString inportString];

outportString = '';
if ~strcmp(oP.Name{1}, 'ALLOW_ZERO_PORTS')
  for k=1:length(oP.Name)
    portName = oP.Name{k};
    outportString = sprintf([outportString '\n' 'port_label(''output'',' num2str(k) ',' '''' portName ''')']);       
  end
end
defaultMaskString = [defaultMaskString outportString];

set_param(blkHandle,'MaskDisplay',defaultMaskString);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function S = i_addFields(S) 
% add fields for SfunBuilder V2

if(~isfield(S,'InputDataType0'))
  S = setfield(S,'InputDataType0','double');
  S = setfield(S,'OutputDataType0','double');
  S = setfield(S,'InputSignalType0','real');
  S = setfield(S,'OutputSignalType0','real');
  S = setfield(S,'InFrameBased0','off');
  S = setfield(S,'OutFrameBased0','off');
  S = setfield(S,'TemplateType','1');
end
if(~isfield(S,'Parameters'))
  S.Parameters.Name = {''};
  S.Parameters.DataType = {''};
  S.Parameters.Complexity = {''};
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ad = i_moveFields(ad) 
% move fields for SfunBuilder V2

ad.SfunWizardData.InputPorts.Name = {'u'};
ad.SfunWizardData.InputPorts.Dims = {'1-D'};
ad.SfunWizardData.InputPorts.Row = {ad.SfunWizardData.InputPortWidth};
ad.SfunWizardData.InputPorts.Col = {''};
ad.SfunWizardData.InputPorts.DataType = {ad.SfunWizardData.InputDataType0};
ad.SfunWizardData.InputPorts.Frame = {ad.SfunWizardData.InFrameBased0};
ad.SfunWizardData.InputPorts.Complexity  ={ ad.SfunWizardData.InputSignalType0};


ad.SfunWizardData.OutputPorts.Name = {'y'};
ad.SfunWizardData.OutputPorts.Dims = {'1-D'};
ad.SfunWizardData.OutputPorts.Row = {ad.SfunWizardData.OutputPortWidth};
ad.SfunWizardData.OutputPorts.Col = {''};
ad.SfunWizardData.OutputPorts.DataType = {ad.SfunWizardData.OutputDataType0};
ad.SfunWizardData.OutputPorts.Frame = {ad.SfunWizardData.OutFrameBased0};
ad.SfunWizardData.OutputPorts.Complexity = {ad.SfunWizardData.OutputSignalType0};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ad = i_moveParamsFields(ad) 
% move fields for SfunBuilder V2
if str2num(ad.SfunWizardData.NumberOfParameters) == 0
  ad.SfunWizardData.Parameters.Name = {''};
  ad.SfunWizardData.Parameters.DataType = {''};
  ad.SfunWizardData.Parameters.Complexity = {''};
else
  n = 0; 
  for k= 1:str2num(ad.SfunWizardData.NumberOfParameters)
    ad.SfunWizardData.Parameters.Name{k} = ['param' num2str(n)]; 
    ad.SfunWizardData.Parameters.DataType{k} = 'real_T';
    ad.SfunWizardData.Parameters.Complexity{k}  = 'real';
    n = n + 1;
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ad = addDefaultPortsInfo(ad)
% Adds dafault port info in case we fail to load the data 
% from the C source file
ad.SfunWizardData.InputPorts.Name = {'u0'};
ad.SfunWizardData.InputPorts.Row = {'1'};
ad.SfunWizardData.InputPorts.DataType = {'real_T'};
ad.SfunWizardData.InputPorts.Col = {''};
ad.SfunWizardData.InputPorts.Complexity = {'real'};
ad.SfunWizardData.InputPorts.Frame = {'off'};
ad.SfunWizardData.InputPorts.Dims = {'1-D'};

ad.SfunWizardData.OutputPorts.Name = {'y0'};
ad.SfunWizardData.OutputPorts.Row = {'1'};
ad.SfunWizardData.OutputPorts.DataType = {'real_T'};
ad.SfunWizardData.OutputPorts.Col = {''};
ad.SfunWizardData.OutputPorts.Complexity = {'real'};
ad.SfunWizardData.OutputPorts.Frame = {'off'};
ad.SfunWizardData.OutputPorts.Dims = {'1-D'};

ad.SfunWizardData.Parameters.Name = {''};
ad.SfunWizardData.Parameters.DataType = {''};
ad.SfunWizardData.Parameters.Complexity = {''};
ad.Version = '';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function wizData = i_removeFieldFromWizData(ad)
% remove fields from SfunBuilder 2.0
wizData = ad.SfunWizardData;
try
wizData = rmfield(wizData, {'InputDataType0','OutputDataType0','InputSignalType0','Input0DimsCol', 'Output0DimsCol',...
                            'OutputSignalType0','InFrameBased0','OutFrameBased0','TemplateType'});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rtwsimTestDiagnostics(ad, textDisp)
if ad.rtwsimTest
  disp(textDisp);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
