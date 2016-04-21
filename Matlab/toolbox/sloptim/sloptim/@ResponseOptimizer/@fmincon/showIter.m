function showIter(this,type,hText,varargin)
% Iteration display.

% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:46:40 $
DisplayLevel = this.Options.Display;
switch type
   case 'init'
      if strcmp(DisplayLevel,'iter')
         header = sprintf(['\n                               max                   Directional   First-order \n',...
            ' Iter F-count        f(x)   constraint    Step-size   derivative   optimality Procedure']);
         this.postMessage(header,hText)
      end

   case 'iter'
      if strcmp(DisplayLevel,'iter')
         state = varargin{1};
         if state.iteration > 0
            formatstr = '%5.0f  %5.0f %12.6g %12.4g %12.3g %12.3g %12.3g %s';
            msg = sprintf(formatstr,state.iteration, state.funccount,state.fval, ...
               state.constrviolation,state.stepsize,state.directionalderivative, ...
               state.firstorderopt, state.procedure);
         else
            formatstr = '%5.0f  %5.0f %12.6g %12.4g                                         %s';
            msg = sprintf(formatstr,state.iteration, state.funccount, state.fval, ...
               state.constrviolation,state.procedure);
         end
         this.postMessage(msg,hText)
      end

   case 'done'
      if ~strcmp(DisplayLevel,'off')
         exitflag = varargin{1};
         if exitflag>1
            msg = sprintf('%s\n%s\n%s',...
               'Optimization terminated due to slow progress in parameter or objective values.',...
               'To optimize further, go to Optimization Options and decrease the parameter and/or',...
               'function tolerances.');
         else
            switch exitflag
               case 1
                  msg = sprintf('%s\n%s','Successful termination.',...
                     'Found a feasible or optimal solution within the specified tolerances.');
               case 0
                  msg = sprintf('%s\n%s','Maximum number of iterations exceeded.',...
                     'Restart or go to Optimization Options to increase the maximum of iterations.');
               case -1
                  msg = sprintf('%s','Optimization aborted by user.');
               case -2
                  msg = sprintf('%s\n%s','Could not find a solution that satisfies all constraints.',...
                     'Relax the constraints or increase the constraint tolerance to find a feasible solution.');
            end
         end
         this.postMessage(msg,hText)
      end
end
