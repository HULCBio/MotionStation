function [state, options,optchanged] = gaoutputgen(options,state,flag,interval)
%GAOUTPUTGEN Prints generations and best fitness value.
%   [STATE, OPTIONS, OPTCHANGED] = GAOUTPUTGEN(OPTIONS,STATE,FLAG,INTERVAL) is
%   used as a output function for iterative display of generation and best 
%   fitness values.
%
%   OPTIONS: Options structure used by GA.
%
%   STATE: A structure containing the following information about the state 
%   of the optimization:
%             Population: Population in the current generation
%                  Score: Scores of the current population
%             Generation: Current generation number
%              StartTime: Time when GA started 
%               StopFlag: String containing the reason for stopping
%              Selection: Indices of individuals selected for elite,
%                         crossover and mutation
%            Expectation: Expectation for selection of individuals
%                   Best: Vector containing the best score in each generation
%        LastImprovement: Generation at which the last improvement in
%                         fitness value occurred
%    LastImprovementTime: Time at which last improvement occurred
%
%   FLAG: Current state in which OutPutFcn is called. Possible values are:
%         init: initialization state 
%         iter: iteration state
%         done: final state
% 		
%   INTERVAL: Optional Interval argument for Output function
%
%   STATE: Structure containing information about the state of the
%          optimization.
%   OPTCHANGED: Boolean indicating if the options have changed.
%
%   Example:
%    Create an options structure that uses GAOUTPUTHISTORY
%    as the output function
%      options = gaoptimset('outputfcns', @gaoutputhistory)
%
%   See also GA, GAOPTIMSET, GAOUTPUTFCNTEMPLATE.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.9.6.1 $  $Date: 2004/02/01 21:44:10 $

optchanged = false;

if nargin <4
    interval = 1;
end
if interval <= 0
    interval = 1;
end

if (rem(state.Generation,interval) ~=0)
    return;
end

switch flag
    case 'init'
        header = sprintf(' Generation    f(x)\n');
        setappdata(0,'GeneticAlgorithmH', iterativedisplay(header,'Iterative History'));
    case 'iter'
        h = getappdata(0,'GeneticAlgorithmH');
        if  ~isempty(h) && h.isShowing
            if state.Generation >= 0
                formatstr = ' %5.0f    %12.4g\n';
                h.append(sprintf(formatstr,state.Generation,min(state.Score)));
            end
        else
            header = sprintf(' Generation    f(x)\n');
            setappdata(0,'GeneticAlgorithmH', iterativedisplay(header,'Iterative History'));
        end
    case 'done'
        h = getappdata(0,'GeneticAlgorithmH');
        if  ~isempty(h) && h.isShowing
            h.append(sprintf('%s\n','Optimization terminated.'));
        end
end
