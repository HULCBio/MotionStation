function [stop,options,optchanged]  = psoutputfcntemplate(optimvalues,options,flag,p1,p2)
%PSOUTPUTFCNTEMPLATE Template to write custom OutputFcn for PATTERNSEARCH.
%   [STOP,OPTIONS,OPTCHANGED] = PSOUTPUTFCNTEMPLATE(OPTIMVALUES,OPTIONS, ...
%   FLAG,P1,P2) where OPTIMVALUES is a structure containing information
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
%   P1,P2: Additional arguments as needed for OutputFcn.
% 		
%   STOP: A boolean to stop the algorithm.
%   OPTCHANGED: A boolean indicating if the options have changed.
%
%	See also PATTERNSEARCH, GA, PSOPTIMSET, SEARCHFCNTEMPLATE


%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.7.6.2 $  $Date: 2004/04/06 01:09:56 $

stop = false;
optchanged = false;

switch flag
    case 'init'
        disp('Starting the algorithm');
    case 'iter'
        disp('Iterating ...')
    case 'done'
        disp('Performing final task');
    otherwise
        disp('Nothing to do');
end
  