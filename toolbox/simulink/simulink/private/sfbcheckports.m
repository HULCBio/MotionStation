function  [ad, isValid, errorMessage, p, iP, oP] = sfbcheckports(ad);

% Copyright 2003 The MathWorks, Inc.

isValid = 1;
errorMessage = '';
cr = sprintf('\n');

[iP, oP, paramsList,paramsValues] = sfunbuilderports('GetPortsInfo', ad.inputArgs, ad);

NumberOfInputs = iP.Row{1};
ad.SfunWizardData.InputPortWidth = NumberOfInputs;
NumberOfInputs =  strrep(NumberOfInputs,']',''); 
NumberOfInputs =  strrep(NumberOfInputs,'[',''); 

NumberOfOutputs = oP.Row{1};
ad.SfunWizardData.OutputPortWidth = NumberOfOutputs;
NumberOfOutputs =  strrep(NumberOfOutputs,']',''); 
NumberOfOutputs =  strrep(NumberOfOutputs,'[',''); 

if isempty(paramsList.Name{1})
  NumberOfParameters = '0';
else
  NumberOfParameters = num2str(length(paramsList.Name));
end

SampleTime = ad.SfunBuilderWidgets.fSampleTime;
SampleTime = char(SampleTime.getSelectedItem);
[SampleTime, ad] =  setSampleTime(SampleTime,ad);

if ~isValidParams(NumberOfParameters)
  errorMessage = sprintf(['Error: invalid setting for the S-function parameters: %s',...
		    NumberOfParameters]);
  isValid = 0;
end  


if ~strcmp(iP.Row{1},'0')
  [isvalid , strmessage] = checkPortNames(iP,'input');
  if ~isvalid
    errorMessage = horzcat(errorMessage, cr, strmessage);
    isValid = 0;
  end  
end

if ~strcmp(oP.Row{1},'0')
  [isvalid , strmessage] = checkPortNames(oP,'output');
  if ~isvalid
    errorMessage = horzcat(errorMessage, cr, strmessage);
    isValid = 0;
  end  
end

if ~isempty(paramsList.Name{1})
  [isvalid , strmessage] = checkParamNames(paramsList,'parameter');
  if ~isvalid
    errorMessage = horzcat(errorMessage, cr, strmessage);
    isValid = 0;
  end  
end

if ~strcmp(iP.Row{1},'0')
  [iP, isvalid , strmessage] = checkPortDims(iP,'input');
  if ~isvalid
    errorMessage = horzcat(errorMessage, cr, strmessage);
    isValid = 0;
  end  
end

if ~strcmp(oP.Row{1},'0')
  [oP, isvalid , strmessage] = checkPortDims(oP,'output');
  if ~isvalid
    errorMessage = horzcat(errorMessage, cr, strmessage);
    isValid = 0;
  end  
end

ad.SfunBuilderWidgets.fSfunParamsValue.setText(NumberOfParameters);
ad.SfunBuilderWidgets.fSfunParamsValue.repaint;
ad.SfunWizardData.NumberOfParameters = NumberOfParameters;

p.NumberOfInputs     = NumberOfInputs;
p.NumberOfOutputs    = NumberOfOutputs;
p.NumberOfParameters = NumberOfParameters;
p.SampleTime         = SampleTime; 

% Set default for ports
if (str2num(p.NumberOfInputs) == -1 ) 
     p.NumberOfInputs = 'DYNAMICALLY_SIZED';
end
if (str2num(p.NumberOfOutputs) == -1 ) 
     p.NumberOfOutputs = 'DYNAMICALLY_SIZED';
end

ad.SfunWizardData.InputPorts = iP;
ad.SfunWizardData.OutputPorts = oP;
ad.SfunWizardData.Parameters = paramsList;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = isValidParams(in)

if isempty(in)
   out = 0;
   return
else
  if findstr(in,'.')
    out = 0;
  else
    out = (all(abs(in) >= abs('0'),1) & all(abs(in) <= abs('9')));
    out = out(1);
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function [isvalid, strmessage] = checkPortNames(portStruct, portIOString)
isvalid = 1;
strmessage = '';
for k=1:length(portStruct.Name)
  try
    if (~isvalidmatname(portStruct.Name{k}) | isempty(portStruct.Name{k}))
      strmessage = sprintf('\n ERROR: Invalid %s port name: %s', portIOString, portStruct.Name{k});
      isvalid = 0;
      return
    end
  catch
    isvalid = 0;
    strmessage = sprintf('\n ERROR: Invalid name specified for %s port: %d', portIOString, k);
    return
  end
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
function [isvalid, strmessage] = checkParamNames(portStruct, portIOString)
isvalid = 1;
strmessage = '';
for k=1:length(portStruct.Name)
  try
    if ~isvalidmatname(portStruct.Name{k})
      strmessage = sprintf(['\n ERROR: Invalid ' portIOString  ' name: ' portStruct.Name{k}]);
      isvalid = 0;
      return
    end
  catch
    isvalid = 0;
    strmessage = sprintf('\n ERROR: Invalid name specified for %s: %d', portIOString, k);
    return
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function [portStruct, isvalid , strmessage] = checkPortDims(portStruct, portIOString)
isvalid = 1;
strmessage = '';
for k=1:length(portStruct.Name)

  % Check Row settings
  Dims = portStruct.Row{k};
  try
    n = length(eval(Dims));      
    if(n > 1)
      isvalid = 0;
      strmessage = sprintf('\n ERROR: Invalid setting for the %s port dimensions ''%s'' : %s', portIOString,  portStruct.Name{k}, Dims); 
     return
    end
  catch
    isvalid = 0;
    strmessage = sprintf('\n ERROR: Invalid setting for the %s port dimensions ''%s'' : %s', portIOString,  portStruct.Name{k}, Dims); 
    return
  end

  if (Dims(1) == '[')
    Dims = strrep(Dims,'[','');     
  end
  if (Dims(end) == ']')
    Dims = strrep(Dims,']','');     
    end
    if k==1
      if ~loc_isdigit(Dims)
        strmessage = sprintf('\n ERROR: Invalid setting for the %s port dimensions ''%s'' : %s', portIOString,  portStruct.Name{k}, Dims); 
        isvalid = 0;
        return
      end
    else
      if ~loc_isdigit(Dims,1)
        strmessage = sprintf('\n ERROR: Invalid setting for the %s port dimensions ''%s'' : %s', portIOString,  portStruct.Name{k}, Dims); 
        isvalid = 0;
        return
      end
  end
  portStruct.Row{k} = Dims;

  % Check Col Settings
  Dims = portStruct.Col{k};
  try
    n = length(eval(Dims));      
    if(n > 1)
      isvalid = 0;
      strmessage = sprintf('\n ERROR: Invalid setting for the %s port dimensions ''%s'' : %s', portIOString,  portStruct.Name{k}, Dims); 
     return
    end
  catch
    isvalid = 0;
    strmessage =sprintf('\n ERROR: Invalid setting for the %s port dimensions ''%s'' : %s', portIOString,  portStruct.Name{k}, Dims); 
    return
  end

  if (Dims(1) == '[')
    Dims = strrep(Dims,'[','');     
  end
  if (Dims(end) == ']')
    Dims = strrep(Dims,']','');     
  end
    if k==1
      if ~loc_isdigit(Dims)
        strmessage = sprintf('\n ERROR: Invalid setting for the %s port dimensions ''%s'' : %s', portIOString,  portStruct.Name{k}, Dims); 
        isvalid = 0;
        return
      end
    else
      if ~loc_isdigit(Dims,1)
        strmessage = sprintf('\n ERROR: Invalid setting for the %s port dimensions ''%s'' : %s', portIOString,  portStruct.Name{k}, Dims); 
        isvalid = 0;
        return
      end
    end
    portStruct.Col{k} = Dims;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function out = loc_isdigit(in,validateMinusOne)
if nargin == 1
  validateMinusOne = '';
end
if isempty(in)
  out = 0;
  return
else
  if findstr(in,'.')
    out = 0;
  elseif strcmp(in,'-1')
    if(isempty(validateMinusOne))
      out = 1;
    else
      out = 0;
    end 
  else
    out = (all(abs(in) > abs('0'),1) & all(abs(in) <= abs('9')));
    out = out(1);
  end
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
    % Sample time could be a parameter
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