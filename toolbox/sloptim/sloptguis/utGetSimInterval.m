function [Start,Stop,Fail] = utGetSimInterval(Model,FiniteFlag)
% Evaluates model variable in appropriate workspace.

%   $Revision: 1.1.6.2 $ $Date: 2004/03/10 21:56:14 $
%   Copyright 1986-2004 The MathWorks, Inc.
ModelWS = get_param(Model,'ModelWorkspace');
s = whos(ModelWS);
ModelWSVars = {s.name};

[Start,FailStart] = utEvalModelVar(...
   get_param(Model,'StartTime'),ModelWS,ModelWSVars);

[Stop,FailStop] = utEvalModelVar(...
   get_param(Model,'StopTime'),ModelWS,ModelWSVars);

if nargin==2 && isinf(Stop)
   % Always return finite Stop time
   Stop = Start + 10;
end

Fail = FailStart || FailStop;
