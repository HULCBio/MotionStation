function showIter(this,type,hText,varargin)
% Iteration display.

% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2004/04/11 00:46:44 $
persistent Algorithm
DisplayLevel = this.Options.Display;

switch type
   case 'init'
      Algorithm = varargin{1};
      if strcmp(DisplayLevel,'iter')
         switch Algorithm
            case 1  % fminbnd
               header = sprintf('\n Func-count     x          f(x)         Procedure');
            case 2  % fminsearch
               header = sprintf('\n Iteration   Func-count     min f(x)         Procedure');
         end
         this.postMessage(header,hText)
      end

   case 'iter'
      if strcmp(DisplayLevel,'iter')
         state = varargin{1};
         switch Algorithm
            case 1
               formatstr = ' %5.0f   %12.6g %12.6g %s';
               msg = sprintf(formatstr,state.funccount,varargin{2},state.fval,state.procedure);
            case 2
               formatstr = ' %5.0f        %5.0f     %12.6g         %s';
               msg = sprintf(formatstr,state.iteration,state.funccount,state.fval,state.procedure);
         end
         this.postMessage(msg,hText)
      end

   case 'done'
      if ~strcmp(DisplayLevel,'off')
         switch varargin{1}  % exitflag
            case 1
               msg = sprintf('%s\n%s','Successful termination.',...
                  'Found an optimal solution within the specified tolerances.');
            case 2
               msg = sprintf('%s\n%s','Successful termination.',...
                  'Found a feasible solution within the specified constraint tolerances.');
            case 0
               msg = sprintf('%s\n%s','Maximum number of iterations exceeded.',...
                  'Restart or go to Optimization Options to increase the number of iterations.');
            case -1
               msg = sprintf('%s','Optimization aborted by user.');
            case -2
               switch Algorithm
                  case 1
                     msg = sprintf('%s\n%s','Could not find a solution that satisfies all constraints.',...
                        'Relax the constraints to find a feasible solution.');
                  case 2
                     msg = sprintf('%s\n%s\n%s','Could not find a solution that satisfies all constraints.',...
                        'If nearly feasible, relax the constraints to find a feasible solution.',...
                        'Otherwise, decrease the parameter and constraint tolerances to optimize further.');
               end
         end
         this.postMessage(msg,hText)
      end
end
