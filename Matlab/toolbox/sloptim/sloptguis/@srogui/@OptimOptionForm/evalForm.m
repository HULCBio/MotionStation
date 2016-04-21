function OptimOpt = evalForm(this,ModelWS,ModelWSVars)
% Evaluates literal optimization settings in appropriate workspace.

%   Author(s): P. Gahinet
%   $Revision: 1.1.6.2 $ $Date: 2004/03/10 21:55:42 $
%   Copyright 1986-2004 The MathWorks, Inc.
OptimOpt = ResponseOptimizer.OptimOptions;
% Transfer text fields
OptimOpt.Algorithm = this.Algorithm;
OptimOpt.Display = this.Display;
OptimOpt.GradientType = this.GradientType;
% Search method and limit
if strcmp(this.Algorithm,'patternsearch')
   switch this.SearchMethod
      case 'None'
         OptimOpt.SearchMethod = [];
      case 'Positive Basis Np1'
         OptimOpt.SearchMethod = @PositiveBasisNp1;
      case 'Positive Basis 2N'
         OptimOpt.SearchMethod = @PositiveBasis2N;
      case 'Genetic Algorithm'
         OptimOpt.SearchMethod = @searchga;
      case 'Latin Hypercube'
         [IterLimit,Fail] = utEvalModelVar(this.SearchLimit,ModelWS,ModelWSVars);
         if Fail
            error('Invalid optimization setting for search iteration limit.\nVariable %s not found.',...
              this.SearchLimit)
         end
         OptimOpt.SearchMethod = {@searchlhs IterLimit};
      case 'Nelder-Mead'
         OptimOpt.SearchMethod = @searchneldermead;
   end
end
% Evaluate numeric settings
NumFields = {'MaxIter','TolCon','TolFun','TolX','Restarts'};
for ct=1:length(NumFields)
   f = NumFields{ct};
   [v,Fail] = utEvalModelVar(this.(f),ModelWS,ModelWSVars);
   if Fail
      error('Invalid optimization setting %s: variable %s not found.',...
         f,this.(f))
   end
   OptimOpt.(f) = v;
end
   