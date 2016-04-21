function showIter(this,type,hText,varargin)
% Iteration display.

% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:46:48 $
DisplayLevel = this.Options.Display;

switch type
   case 'init'
      if strcmp(DisplayLevel,'iter')
         header = sprintf('\n Iter     f-count        MeshSize      f(x)        Method');
         this.postMessage(header,hText)
      end

   case 'iter'
      if strcmp(DisplayLevel,'iter')
         state = varargin{1};
         formatstr = ' %5.0f    %5.0f   %12.4g  %12.4g     %s';
         msg = sprintf(formatstr,state.iteration, state.funccount,state.meshsize,state.fval, ...
            state.method);
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
               msg = sprintf('%s\n','Optimization aborted by user.');
            case -2
               msg = sprintf('%s\n%s','Could not find a solution that satisfies all constraints.',...
                  'Relax the constraints or decrease the parameter and function tolerances.');
         end
         this.postMessage(msg,hText)
      end
end
