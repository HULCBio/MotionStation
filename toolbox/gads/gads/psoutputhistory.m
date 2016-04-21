function [stop, options,optchanged] = psoutputhistory(optimvalues,options,flag,interval)
%PSOUTPUTHISTORY Output function for PATTERNSEARCH.
%   [STOP, OPTIONS, OPTCHANGED] = PSOUTPUTHISTORY(OPTIMVALUES,OPTIONS, ...
%   FLAG,INTERVAL) where OPTIMVALUES is a structure containing information
%   about the state of the optimization:
%            x: current point X 
%    iteration: iteration number
%         fval: function value 
%     meshsize: current mesh size 
%    funccount: number of function evaluations
%       method: method used in last iteration 
%       TolFun: tolerance on fval
%         TolX: tolerance on X
%
%   OPTIONS: Options structure used by PATTERNSEARCH.
%
%   FLAG: Current state in which OutPutFcn is called. Possible values are:
%         init: initialization state 
%         iter: iteration state
%         done: final state
% 		
%   INTERVAL: Optional interval argument for Output function.
%
%   STOP: A boolean to stop the algorithm.
%   OPTCHANGED: A boolean indicating if the options have changed.
%
%   See also PATTERNSEARCH, GA, PSOPTIMSET.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.10.6.2 $  $Date: 2004/04/06 01:09:57 $
stop = false;
optchanged = false;

if nargin <4
    interval = 1;
end
if interval <= 0
    interval = 1;
end

if (rem(optimvalues.iteration,interval) ~=0)
    return;
end

switch flag
    case 'init'
        header = sprintf(' Iter    f-count        MeshSize        f(x)        Method\n');
        setappdata(0,'patternsearchH', iterativedisplay(header,'Iterative History'));
    case 'iter'
        h = getappdata(0,'patternsearchH');
        if  ~isempty(h) && h.isShowing
            if optimvalues.iteration >= 0
                formatstr = ' %5.0f    %5.0f   %12.4g  %12.4g     %s\n';
                h.append(sprintf(formatstr,optimvalues.iteration, optimvalues.funccount,optimvalues.meshsize,optimvalues.fval, ...
                    optimvalues.method));
            end
        else
            stop = false;
            header = sprintf(' Iter    f-count        MeshSize        f(x)        Method\n');
            setappdata(0,'patternsearchH', iterativedisplay(header,'Iterative History'));
        end
    case 'done'
        h = getappdata(0,'patternsearchH');
        if  ~isempty(h) && h.isShowing
            h.append(sprintf('%s\n','Optimization terminated.'));
        end
        if ~(h.isShowing)
            stop = true;
        end
end
