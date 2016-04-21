function [ad, isValid, errorMessage, d]  = sfbcheckstates(ad)

% Copyright 2003-2004 The MathWorks, Inc.

isValid = 1;
errorMessage = '';
cr = sprintf('\n');
NumDStates = ad.SfunBuilderWidgets.fDiscreteStatesValue;
NumDStates = char(NumDStates.getText);
ad.SfunWizardData.NumberOfDiscreteStates = NumDStates;
NumDStates =  strrep(NumDStates,']',''); 
NumDStates =  strrep(NumDStates,'[',''); 

DStatesIC = ad.SfunBuilderWidgets.fDiscreteStatesICValue;
DStatesIC = char(DStatesIC.getText);
[DStatesIC, isvalidDStatesIC , dstatesErrorMessage] = setInitCond(DStatesIC, NumDStates);

ad.SfunWizardData.DiscreteStatesIC = DStatesIC;

NumCStates = ad.SfunBuilderWidgets.fContinuousStatesValue;
NumCStates = char(NumCStates.getText);
ad.SfunWizardData.NumberOfContinuousStates = NumCStates;
NumCStates =  strrep(NumCStates,']',''); 
NumCStates =  strrep(NumCStates,'[',''); 

CStatesIC = ad.SfunBuilderWidgets.fContinuousStatesICValue;
CStatesIC = char(CStatesIC.getText);
[CStatesIC, isvalidCStatesIC , cstatesErrorMessage] = setInitCond(CStatesIC,NumCStates);
ad.SfunWizardData.ContinuousStatesIC = CStatesIC;

if ~isValidParams(NumDStates)
  errorMessage = sprintf(['Error: invalid setting for the S-function discrete states: %s\n',... 
		                     '       The states must be a numerical value greater than or equal to 0.'], NumDStates);
  isValid = 0;
end  

if ~isvalidDStatesIC
  errorMessage = horzcat(errorMessage, cr, dstatesErrorMessage);
  isValid = 0;
end  


if ~isValidParams(NumCStates)
  InvalidNumCStates = sprintf(['Error: invalid setting for the S-function continuous states: %s\n',... 
		                       '       The states must be a numerical value greater than or equal to 0.'], NumCStates);
  errorMessage = horzcat(errorMessage, cr, InvalidNumCStates);
end  

if ~isvalidCStatesIC
   errorMessage = horzcat(errorMessage, cr, cstatesErrorMessage);
end  

d.NumDStates = NumDStates;
d.DStatesIC  = DStatesIC;
d.NumCStates = NumCStates;
d.CStatesIC  = CStatesIC;

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
function [InitCond, isvalid , strmessage] = setInitCond(InitCond, NumStates,ad)
strmessage ='';
isvalid = 1;
tempInitCond = InitCond;

strmessageError = sprintf(['Error: Invalid setting for the states initial condition: ''%s''', ...
		    '\n       The length of the initial condition must be a numeric vector equal to the number of states.'], InitCond);

try

  InitCond = strtrim(InitCond);
  if ~(InitCond(1) == '[')
    InitCond = ['[' InitCond];
  end
  if ~(InitCond(end) == ']')
    InitCond = [InitCond ']'];
  end
  InitCond = regexprep(InitCond,'\s*\,?\s*',',');
  InitCond = regexprep(InitCond,'\,+','\,');
  
  n = length(findstr(InitCond,',')) + 1;
  if(~isempty(str2num(NumStates)))
    if (str2num(NumStates) == n | str2num(NumStates) == 0 )
      InitCond =  strrep(InitCond,']','');
      InitCond =  strrep(InitCond,'[','');
      isvalid = 1;
    else
      InitCond = tempInitCond;
      isvalid = 0;
      strmessage = strmessageError;
    end
  end
catch
  InitCond = tempInitCond;
  isvalid = 0;
  strmessage = strmessageError;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 