function SimOpt = evalForm(this,Model,ModelWS,ModelWSVars)
% Evaluates literal optimization settings in appropriate workspace.

%   Author(s): P. Gahinet
%   $Revision: 1.1.6.1 $ $Date: 2004/03/24 21:07:21 $
%   Copyright 1986-2004 The MathWorks, Inc.
SimOpt = simget(Model);
% Transfer text fields
SimOpt.Solver = this.Solver;
SimOpt.ZeroCross = this.ZeroCross;
% Evaluate numeric settings
NumFields = {'AbsTol','FixedStep','InitialStep','MaxStep','MinStep','RelTol'};
for ct=1:length(NumFields)
   f = NumFields{ct};
   if strcmp(this.(f),'auto')
      SimOpt.(f) = 'auto';
   else
      [v,Fail] = utEvalModelVar(this.(f),ModelWS,ModelWSVars);
      if Fail
         error('Invalid simulation setting %s: variable %s not found.',...
            f,this.(f))
      end
      SimOpt.(f) = v;
   end
end
