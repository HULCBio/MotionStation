function str =  check_for_long_model_name(machineName)
  
%       Copyright 1995-2002 The MathWorks, Inc.
%	$Revision: 1.1.4.1 $
  sfMaxLength = namelengthmax-5;
  if(length(machineName)>sfMaxLength)
    line1 = sprintf('Stateflow model name "%s" contains more than %d characters.',...
                    machineName,sfMaxLength);
    line2 = sprintf('Stateflow needs to auto-generate an S-Function "%s_sfun" for simulation',...
                    machineName);
    line3 = sprintf('that needs to be under %d characters for it to be a valid MATLAB identifier',...
                    namelengthmax);
    line4 = sprintf('Please resave this model to be under %d characters',sfMaxLength);
    str = sprintf('%s\n%s\n%s\n%s\n',line1,line2,line3,line4);
  else
    str = '';
  end
  