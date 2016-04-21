function coeffs=checkequation(customgeneral)
% CHECKEQUATION Helper function for CFTOOL

% CHECKEQUATION gets called when the equation updates.  It returns
% a vector of the valid coefficients.

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.4.2.2 $  $Date: 2004/02/01 21:40:21 $

coeffs = java.util.Vector;

warnState=warning('off', 'all');
try
   f=fittype(char(customgeneral.getEquation), ...
      'independent',char(customgeneral.getIndependentVariable), ...
      'dependent',char(customgeneral.getDependentVariable));
   names=coeffnames(f);
catch
  % Return an empty vector
  return
end
warning(warnState)

% Add list of coefficients to the return vector
for i=1:length(names)
   coeffs.addElement(java.lang.String(names(i)));
end
