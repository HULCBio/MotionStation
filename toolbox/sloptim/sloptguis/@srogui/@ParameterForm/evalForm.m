function p = evalForm(this,ModelWS,ModelWSVars)
% Evaluates tuned parameter settings in appropriate workspace
% and returns @Parameter object with all-numerical values.

%   Author(s): P. Gahinet
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:44:13 $
%   Copyright 1986-2003 The MathWorks, Inc.
Fields = {'InitialGuess','Min','Max','TypicalValue','Tuned';...
   'Initial Guess','Minimum','Maximum','Scaling Factor','Tunable Elements'};

% Create @Parameter object
[pv,Fail] = utEvalModelVar(this.Name,ModelWS,ModelWSVars);
if Fail
   error('Cannot evaluate parameter %s',this.Name)
end
p = ResponseOptimizer.Parameter(this.Name,pv);

% Evaluate bounds and other settings
for ct=1:size(Fields,2)
   f = Fields{1,ct};
   [v,Fail] = utEvalModelVar(this.(f),ModelWS,ModelWSVars);
   if Fail
      error('Cannot evaluate %s for parameter %s: variable %s not found.',...
         Fields{2,ct},this.Name,this.(f))
   end
   try
      p.(f) = v;
   catch
      error('Invalid %s value for parameter %s.',Fields{2,ct},this.Name)
   end
end
% Check min<max
if any(p.Min>p.Max)
   error('Invalid settings for parameter %s: Minimum exceeds Maximum',this.Name)
end
p.TypicalValue = abs(p.TypicalValue);
p.Tuned = (p.Tuned ~= 0);
