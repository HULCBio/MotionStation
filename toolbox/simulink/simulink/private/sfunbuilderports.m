function varargout = sfunbuilderports(varargin)
% Manage and display the Ports Panel of the S-Function Builder.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.4 $  $Date: 2004/04/15 00:47:37 $

Action = varargin{1};
blockHandle =  varargin{2};
AppDataName = 'SfAd';
try
  AppDataName = [AppDataName get_param(blockHandle,'FunctionName')];
  if length(AppDataName) >= 32
    AppDataName = AppDataName(end-30:end);
  end
end

switch (Action)
 case 'Create'  
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Create Panel and add the listeners %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 iP = varargin{3};
 oP = varargin{4};
 param = varargin{5};    
 AppData = varargin{6};
 import com.mathworks.toolbox.simulink.sfunbuilder.*;
 import java.awt.*;
 import com.mathworks.mwt.*;
 import com.mathworks.mwt.dialog.*;
 import com.mathworks.mwt.window.*;
 
 % get the widgets
 varargout{1} = AppData.SfunBuilderWidgets.fPortsConfigPanel;

 setappdata(0, AppDataName, AppData);
 varargout{2} = AppData; 
 [iP,oP,param] = renamePortInfo(iP,oP,param);
  % Populate Input Ports Panel
  if ~isempty(iP.Name)
      AppData.SfunBuilderWidgets.setInputPortsTableWithFixPt(iP.Name,...
                                                        iP.DataType,...
                                                        iP.Dims,...
                                                        iP.Row,...
                                                        iP.Col,...
                                                        iP.Complexity,...
                                                        iP.Frame,...
                                                        iP.FixPointScalingType,...
                                                        iP.WordLength,...
                                                        iP.IsSigned,...
                                                        iP.FractionLength,...
                                                        iP.Slope,...        
                                                        iP.Bias);               
    
    AppData.SfunBuilderWidgets.setTreeView(iP.Name, 0);
  end
  % Populate Output Ports Panel
  if ~isempty(oP.Name)
     AppData.SfunBuilderWidgets.setOutputPortsTableWithFixPt(oP.Name,...
                                                       oP.DataType,...
                                                       oP.Dims,...
                                                       oP.Row,...
                                                       oP.Col,...
                                                       oP.Complexity,...
                                                       oP.Frame,...
                                                       oP.FixPointScalingType,...
                                                       oP.WordLength,...
                                                       oP.IsSigned,...
                                                       oP.FractionLength,...
                                                       oP.Slope,...        
                                                       oP.Bias);         

     AppData.SfunBuilderWidgets.setTreeView(oP.Name, 1);
  end
  %add Param values to the param cell array

  try
    if ~isempty(param.Name{1})
      AppData.SfunBuilderWidgets.setParametersTable(param.Name, param.DataType, param.Complexity);
      AppData.SfunBuilderWidgets.setTreeView(param.Name, 2);
      pD = setParamsValues(AppData,param);
      AppData.SfunBuilderWidgets.setParametersDeploymentTable(pD.Name, pD.Value,pD.DataType);
    end
  end

 case 'GetPortsInfo'
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Get Ports Panel Info       %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  AppData = varargin{3};
  [inputPortsInfo, outputPortsInfo, parametersInfo,paramsValues] = getPortsInfo(AppData);  
  varargout{1} = inputPortsInfo;
  varargout{2} = outputPortsInfo;
  varargout{3} = parametersInfo;
  varargout{4} = paramsValues;
 otherwise
  disp('Invalid input') 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [fTableD, fTableE] = getDisabledTable

fTableE = com.mathworks.mwt.table.Style;
fTableE.setEditable(1);
fTableE.set('Background', [1 1 1]);
fTableE.set('Foreground', [0 0 0]);
fTableE.setHGridVisible(1);
fTableE.setVGridVisible(1);

fTableD = com.mathworks.mwt.table.Style;
fTableD.setEditable(0);
c = java.awt.Color(.755, .755 ,.755);
c.lightGray;
fTableD.setBackground(c);
fTableD.setHGridVisible(1);
fTableD.setVGridVisible(1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [inPortsInfo, outPortsInfo,parametersInfo, paramsValues] = getPortsInfo(appData);

inCellRows  = appData.SfunBuilderWidgets.getNumberofInputs;
outCellRows = appData.SfunBuilderWidgets.getNumberofOutputs;
paramsCellRows = appData.SfunBuilderWidgets.getNumberofParams;
nParams = paramsCellRows;

 outPortsInfo.Name{1} ='ALLOW_ZERO_PORTS';
 outPortsInfo.DataType{1} ='0';
 outPortsInfo.Dims{1}  ='0';
 outPortsInfo.Row{1} ='0';
 outPortsInfo.Complexity{1} ='0';
 outPortsInfo.Frame{1} ='0';
 outPortsInfo.Col{1} = '0';
 outPortsInfo.IsSigned{1} = '1';
 outPortsInfo.WordLength{1} = '8';
 outPortsInfo.FixPointScalingType{1} = '0';
 outPortsInfo.FractionLength{1} = '3';
 outPortsInfo.Slope{1} = '2^-3';
 outPortsInfo.Bias{1} = '0';

 for k = 1:outCellRows
   outPortsInfo.Name{k}       = appData.SfunBuilderWidgets.fJOutputPortList.getValueAt(k-1,0);
   outPortsInfo.DataType{k}   = char(appData.SfunBuilderWidgets.getOutputPortDataType(k-1));
   outPortsInfo.Dims{k}       = appData.SfunBuilderWidgets.fJOutputPortList.getValueAt(k-1,1);
   outPortsInfo.Row{k}        = appData.SfunBuilderWidgets.fJOutputPortList.getValueAt(k-1,2);
   outPortsInfo.Complexity{k} = appData.SfunBuilderWidgets.fJOutputPortList.getValueAt(k-1,4);
   outPortsInfo.Frame{k}      = appData.SfunBuilderWidgets.fJOutputPortList.getValueAt(k-1,5);
    
   if strcmp(char(outPortsInfo.Dims{k}),'1-D')
     outPortsInfo.Col{k}        = '1';
   else     
     outPortsInfo.Col{k}    = appData.SfunBuilderWidgets.fJOutputPortList.getValueAt(k-1,3);
     if isempty(outPortsInfo.Col{k})
       outPortsInfo.Col{k} = '1';
     end
    end
    
    outPortsInfo.Dims{k} = char(outPortsInfo.Dims{k});
    if ~ischar(outPortsInfo.Col{k})
      outPortsInfo.Col{k} = '';
    end
     
    if strcmp(char(outPortsInfo.DataType{k}),'fixpt')
      outPortsInfo = configueFixPtAttributes(appData, outPortsInfo, k,1);
    else
      outPortsInfo.IsSigned{k} = '1';
      outPortsInfo.WordLength{k} = '8';
      outPortsInfo.FixPointScalingType{k} = '1';
      outPortsInfo.FractionLength{k} = '3';
      outPortsInfo.Slope{k} = '0.125';
      outPortsInfo.Bias{k} = '0';
    end
 end

 inPortsInfo.Name{1} ='ALLOW_ZERO_PORTS';
 inPortsInfo.DataType{1} ='0';
 inPortsInfo.Dims{1}  ='0';
 inPortsInfo.Row{1} ='0';
 inPortsInfo.Complexity{1} ='0';
 inPortsInfo.Frame{1} ='0';
 inPortsInfo.Col{1} = '0';
 inPortsInfo.IsSigned{1} = '1';
 inPortsInfo.WordLength{1} = '8';
 inPortsInfo.FixPointScalingType{1} = '0';
 inPortsInfo.FractionLength{1} = '3';
 inPortsInfo.Slope{1} = '2^-3';
 inPortsInfo.Bias{1} = '0';

 for k = 1:inCellRows
   inPortsInfo.Name{k} = appData.SfunBuilderWidgets.fJInputPortList.getValueAt(k-1,0);
   inPortsInfo.DataType{k}   = char(appData.SfunBuilderWidgets.getInputPortDataType(k-1));
   inPortsInfo.Dims{k}       = appData.SfunBuilderWidgets.fJInputPortList.getValueAt(k-1,1);
   inPortsInfo.Row{k}        = appData.SfunBuilderWidgets.fJInputPortList.getValueAt(k-1,2);
   inPortsInfo.Complexity{k} = appData.SfunBuilderWidgets.fJInputPortList.getValueAt(k-1,4);
   inPortsInfo.Frame{k}      = appData.SfunBuilderWidgets.fJInputPortList.getValueAt(k-1,5);   
   
   if strcmp(char(inPortsInfo.Dims{k}),'1-D')
     inPortsInfo.Col{k}        = '1';
   else     
     inPortsInfo.Col{k}    = appData.SfunBuilderWidgets.fJInputPortList.getValueAt(k-1,3);
     if isempty(inPortsInfo.Col{k})
       inPortsInfo.Col{k} = '';
     end
   end

  if strcmp(char(inPortsInfo.DataType{k}),'fixpt')
    inPortsInfo = configueFixPtAttributes(appData, inPortsInfo, k,0);
  else
    inPortsInfo.IsSigned{k} = '0';
    inPortsInfo.WordLength{k} = '8';
    inPortsInfo.FixPointScalingType{k} = '1';
    inPortsInfo.FractionLength{k} = '9';
    inPortsInfo.Slope{k} = '0.125';
    inPortsInfo.Bias{k} = '0';
  end
 end
  parametersInfo.Name = {''};
  parametersInfo.DataType = {''};
  parametersInfo.Complexity = {''};
 for k = 1:paramsCellRows
   parametersInfo.Name{k}       = appData.SfunBuilderWidgets.fJParametersList.getValueAt(k-1,0);
   parametersInfo.DataType{k}   = appData.SfunBuilderWidgets.fJParametersList.getValueAt(k-1,1);
   parametersInfo.Complexity{k} = appData.SfunBuilderWidgets.fJParametersList.getValueAt(k-1,2);
 end
 
 paramsValues = '';
 for k = 1:nParams
   paramsValues =  [paramsValues ','  appData.SfunBuilderWidgets.fJParametersDeploymentList.getValueAt(k-1,2)];
 end
 if ~isempty(paramsValues)
   paramsValues(1) = '';
 end
 
 [inPortsInfo, outPortsInfo,parametersInfo] = i_renamePortDataTypes(inPortsInfo,outPortsInfo,parametersInfo);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [iP, oP, params] = i_renamePortDataTypes(iP,oP,params)
% maps the UI datatype with the source data type

if ~strcmp(iP.Row{1},'0')
 for i = 1:length(iP.Name)

   inDataType = iP.DataType{i};
   switch inDataType
    case 'double'  
     iP.DataType{i} = 'real_T';
    case 'single'
     iP.DataType{i} = 'real32_T';
    case 'boolean'
     iP.DataType{i} = 'boolean_T';  
    case 'fixpt'
     %
    otherwise
     iP.DataType{i} = [inDataType '_T'];
   end
   
   Complexity = iP.Complexity{i};
   switch Complexity
    case 'real'
     iP.Complexity{i} = 'COMPLEX_NO';
    case 'complex'
     if(~strcmp(iP.DataType{i},'boolean_T'))
       iP.DataType{i}  = ['c' iP.DataType{i}];
       iP.Complexity{i} = 'COMPLEX_YES';
     else
       iP.Complexity{i} = 'COMPLEX_NO';
     end
    otherwise
     iP.Complexity{i} = 'COMPLEX_INHERITED';
   end

   InFrameBased = iP.Frame{i};
   switch InFrameBased
    case 'off'
     iP.Frame{i} = 'FRAME_NO';
    case 'on'
     iP.Frame{i} = 'FRAME_YES';
    case 'auto'
     iP.Frame{i} = 'FRAME_INHERITED';  
    otherwise
     iP.Frame{i} = 'FRAME_NO';
   end
 end
end
 % Outputs
 for i = 1:length(oP.Name)
    outDataType = oP.DataType{i};
   switch outDataType
    case 'double'  
     oP.DataType{i} = 'real_T';
    case 'single'
     oP.DataType{i} = 'real32_T';
    case 'boolean'
     oP.DataType{i} = 'boolean_T';  
    case 'fixpt'
     %
    otherwise
     oP.DataType{i} = [outDataType '_T'];
   end
   
   Complexity  = oP.Complexity{i};
   switch Complexity
    case 'real'
     oP.Complexity{i} = 'COMPLEX_NO';
    case 'complex'
     if(~strcmp(oP.DataType{i},'boolean_T'))
       oP.DataType{i} =  ['c'  oP.DataType{i}];
       oP.Complexity{i} = 'COMPLEX_YES';
     else
       oP.Complexity{i}= 'COMPLEX_NO';
     end
    otherwise
     oP.Complexity{i}= 'COMPLEX_INHERITED';
   end

   OutFrameBased = oP.Frame{i};
   switch OutFrameBased
    case 'off'
     oP.Frame{i}= 'FRAME_NO';
    case 'on'
     oP.Frame{i} = 'FRAME_YES';
    case 'auto'
     oP.Frame{i}= 'FRAME_INHERITED';
    otherwise
     oP.Frame{i} = 'FRAME_NO';
   end
end

 %Parameters
 if ~isempty(params.Name{1})
   for i = 1:length(params.Name)
     paramsDataType = params.DataType{i};
     switch paramsDataType
      case 'double'  
       params.DataType{i} = 'real_T';
      case 'single'
       params.DataType{i} = 'real32_T';
      case 'boolean'
       params.DataType{i} = 'boolean_T';  
      otherwise
       params.DataType{i} = [paramsDataType '_T'];
     end
   
     Complexity  = params.Complexity{i};
     switch Complexity
      case 'real'
       params.Complexity{i} = 'COMPLEX_NO';
      case 'complex'
       if(~strcmp(params.DataType{i},'boolean_T'))
         params.DataType{i} =  ['c'  params.DataType{i}];
         params.Complexity{i} = 'COMPLEX_YES';
       else
         params.Complexity{i}= 'COMPLEX_NO';
       end
      otherwise
       params.Complexity{i}= 'COMPLEX_INHERITED';
     end
   end
 end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  param = setParamsValues(AppData,param);

if ~isempty(param.Name{1})
  for k = 1:length(param.Name)
    param.Value{k} = '';
  end
end

blkParams = get_param(AppData.inputArgs,'Parameters');
p = AppData.SfunWizardData.Parameters;
if ~isempty(param.Name{1})
  param.Value = strread(blkParams,'%s','delimiter',',');
  for j =1:length(param.Name)
    if strcmp(param.Complexity{j},'complex')
      param.DataType{j} = [param.DataType{j} '(complex)'];
    end
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [iP,oP,param] = renamePortInfo(iP,oP,param)

 for i = 1:length(iP.Name)  
   iP.Row{i} = strrep(iP.Row{i}, 'DYNAMICALLY_SIZED','-1');
   if (strcmp(iP.DataType{i},'real32_T') | ... 
       strcmp(iP.DataType{i},'creal32_T'))
     iP.DataType{i}  = ...
         strrep(iP.DataType{i},'real32_T','single');
     iP.DataType{i}  =  strrep(iP.DataType{i},'c','');
   else
     iP.DataType{i}  =strrep(iP.DataType{i},'real_T','double');
     iP.DataType{i}  = ...
        strrep(iP.DataType{i},'_T','');
     iP.DataType{i}  =  strrep(iP.DataType{i},'c','');
   end   
   
   if strcmp(iP.Dims{i},'1-D')
     iP.Col{i}        = '';
   end
   
   if( ~isfield(iP,'IsSigned') || (length(iP.IsSigned) < length(iP.Name)) )
        iP.IsSigned{i} = '1';
        iP.WordLength{i} = '12';
        iP.FixPointScalingType{i}= '1';
        iP.FractionLength{i} ='3';
        iP.Slope{i}  ='2^-9';
        iP.Bias{i} ='0';
   end   
 end
 for i = 1:length(oP.Name) 
   oP.Row{i} = strrep(oP.Row{i}, 'DYNAMICALLY_SIZED','-1');
   if (strcmp(oP.DataType{i},'real32_T') | ...
       strcmp(oP.DataType{i},'creal32_T'))
     oP.DataType{i}  = ...
         strrep(oP.DataType{i},'real32_T','single');
     oP.DataType{i}  = ...
         strrep(oP.DataType{i},'c','');      
   else
     oP.DataType{i} = ...
        strrep(oP.DataType{i},'real_T','double');
     oP.DataType{i} = ...
         strrep(oP.DataType{i},'_T','');
     oP.DataType{i}  = ...
         strrep(oP.DataType{i},'c','');      
   end    
   
   if strcmp(oP.Dims{i},'1-D')
     oP.Col{i}        = '';
   end
   
   if( ~isfield(oP,'IsSigned') || (length(oP.IsSigned) < length(oP.Name)) )
     oP.IsSigned{i}            = '1';
     oP.WordLength{i}          = '12';
     oP.FixPointScalingType{i} = '1';
     oP.FractionLength{i}      = '3';
     oP.Slope{i}               = '2^-9';
     oP.Bias{i}                = '0';
   end   
 end
  
 for i = 1:length(param.Name) 
   if (strcmp(param.DataType{i},'real32_T') | ...
       strcmp(param.DataType{i},'creal32_T'))
     param.DataType{i}  = ...
         strrep(param.DataType{i},'real32_T','single');
     param.DataType{i}  = ...
         strrep(param.DataType{i},'c','');      
   else
     param.DataType{i} = ...
        strrep(param.DataType{i},'real_T','double');
     param.DataType{i} = ...
         strrep(param.DataType{i},'_T','');
     param.DataType{i}  = ...
         strrep(param.DataType{i},'c','');      
   end     
 end
  
 iP.Complexity = strrep(iP.Complexity,'COMPLEX_YES','complex');
 iP.Complexity = strrep(iP.Complexity,'COMPLEX_NO','real');
 oP.Complexity = strrep(oP.Complexity,'COMPLEX_YES','complex');
 oP.Complexity = strrep(oP.Complexity,'COMPLEX_NO','real');
 param.Complexity = strrep(param.Complexity,'COMPLEX_YES','complex');
 param.Complexity = strrep(param.Complexity,'COMPLEX_NO','real');
 
 iP.Frame = ...
     strrep(iP.Frame,'FRAME_NO','off');
 iP.Frame = ...
    strrep(iP.Frame,'FRAME_YES','on');
 iP.Frame = ...
     strrep(iP.Frame,'FRAME_INHERITED','auto');
 oP.Frame = ...
     strrep(oP.Frame,'FRAME_NO','off');
 oP.Frame = ...
     strrep(oP.Frame,'FRAME_YES','on');
 oP.Frame = ...
     strrep(oP.Frame,'FRAME_INHERITED','auto');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function [Slope] = getSlope(Str)
Slope =  sprintf('%0.5g', 2^-3);

try
  Slope = eval(Str);
  Slope = sprintf('%0.5g', Slope(1));
catch
  disp('Invalid Slope');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function portsInfo = configueFixPtAttributes(appData, portsInfo,k,port_mode);
% FxPtAtt = java.lang.String[]:
% 
%    'Binary point scaling'   /* Scaling */
%    '8'                      /* Wordlenght */
%    'true'                   /* Signed */
%    '30'                     /* Fraction length */
%    '2^-3'                   /* Bias  */
%    '0'                      /* Slope */
if(port_mode == 0)
  FxPtAtt = appData.SfunBuilderWidgets.getInputPortFixedPointAttributes(k-1);
else
  FxPtAtt = appData.SfunBuilderWidgets.getOutputPortFixedPointAttributes(k-1);
end
 
 if(strcmp( char(FxPtAtt(3)),'true'))
   portsInfo.IsSigned{k}       = '1';
 else
   portsInfo.IsSigned{k}       = '0';
 end
 portsInfo.WordLength{k}     = char(FxPtAtt(2));
 portsInfo.FractionLength{k} = char(FxPtAtt(4));
 portsInfo.FixPointScalingType{k} =  char(FxPtAtt(1));
 portsInfo.FractionLength{k} = char(FxPtAtt(4));
 portsInfo.Slope{k}          = getSlope(char(FxPtAtt(5)));
 portsInfo.Bias{k}           = char(FxPtAtt(6));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% EOF sfunbuilderports.m %
