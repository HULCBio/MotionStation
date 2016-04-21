function status=cfaddgeneralcustomequation(customgeneral,sp,lower,upper)
% CFADDGENERALCUSTOMEQUATION Helper function for CFTOOL.

% CFADDGENERALCUSTOMEQUATION is called by the custom equations 
% panel to save a custom equation.

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.6.2.1 $  $Date: 2004/02/01 21:39:34 $

try
   f=fittype(char(customgeneral.getEquation), ...
      'independent',char(customgeneral.getIndependentVariable), ...
      'dependent',char(customgeneral.getDependentVariable));
   opts=fitoptions(f);
   opts.StartPoint=sp;
   opts.Lower=lower;
   opts.Upper=upper;
catch
   err=lasterr;
   % trim off the first line ("error using suchandsuch")
   err=err(min(find(err==10)):end);
   status=java.lang.String(err);
   return
end

% Add this fittype to the list
managecustom('set',char(customgeneral.getEquationName),f,opts);
status=java.lang.String('OK');
