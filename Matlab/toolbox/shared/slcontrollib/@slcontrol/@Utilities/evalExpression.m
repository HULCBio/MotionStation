function [v, Fail] = evalExpression(this, name, ModelWS, ModelWSVars)
% Evaluates model variable in appropriate workspace.

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:32:01 $

Fail = false;
if (nargin == 4) && any( strcmp( ModelWSVars, strtok(name,'.({') ) )
  % Model workspace variable. Evaluate in model workspace.
  v = ModelWS.evalin(name);
else
  try
    % Base workspace variable or expression. Evaluate in base workspace.
    v = evalin('base', name);
  catch
    v = [];
    Fail = true;
  end
end
