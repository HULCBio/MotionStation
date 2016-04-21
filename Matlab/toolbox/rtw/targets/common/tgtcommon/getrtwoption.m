function val=getrtwoption(modelname,opt)
%GETRTWOPTION gets an RTW option for a Simulink model
%   VALUE = GETRTWOPTION(MODELNAME, OPT) returns the VALUE of the RTW 
%   option OPT for Simulink model MODELNAME.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $
%   $Date: 2004/03/15 22:22:13 $

  warning(['The function ' mfilename ' is now obsolete. Use uget_param instead.']);

  opts = get_param(modelname,'RTWOptions');
  
  if isempty(findstr(opts,['-a' opt '=']))
    val = '';
    return
  end
  
  [s,f,t] = regexp(opts, ['-a' opt '=\"([^"]*)\"']);
  
  isNumeric=0;
  if isempty(s)
    % Numeric values are not double quoted
    [s,f,t] = regexp(opts, ['-a' opt '=(\d*)']);
    isNumeric=1;
  end
  
  t1 = t{1};
  
  if isempty(t1)
    val = '';
  else
    if isNumeric==0
      val = opts(t1(1):t1(2));
    else
      eval(['val = ' opts(t1(1):t1(2)) ';']);
    end
  end 
