function [v,Fail] = utEvalModelVar(VarName,ModelWS,ModelWSVars)
% Evaluates model variable in appropriate workspace.

%   $Revision: 1.1.6.2 $ $Date: 2004/03/24 21:13:10 $
%   Copyright 1986-2004 The MathWorks, Inc.
Fail = false;
if nargin==3 && any(strcmp(ModelWSVars,strtok(VarName,'.({')))
   % Evaluate in model workspace
   v = ModelWS.evalin(VarName);
else
   try
      v = evalin('base',VarName);
   catch
      v = [];  Fail = true;
   end
end
