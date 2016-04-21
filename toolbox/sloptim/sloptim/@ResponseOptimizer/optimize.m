%OPTIMIZE  Run response optimization project.
% 
%   RESULT=OPTIMIZE(PROJ) optimizes the responses specified in the project,
%   PROJ, with the constraints, parameters and settings. The results are
%   displayed after each iteration. The tuned parameters are changed in the
%   workspace. Enter the parameter name at the MATLAB prompt to see its new
%   value.
% 
%   The output, RESULT, is a structure with fields::
%      Cost:      the final value of the cost function.
%      ExitFlag:  1 if the optimization terminated successfully, 
%                 0 if it did not.
%      Iteration: the number of iterations.
%
%   For more information on the results properties, see the documentation
%   for the Optimization Toolbox functions FMINCON and FMINSEARCH and the
%   Genetic Algorithm and Direct Search Toolbox function PATTERNSEARCH.
%
%   Example:
%     pitchrate_demo
%     proj = getsro('pitchrate_demo');
%     results = optimize(proj)
%
%   See also RESPONSEOPTIMIZER/FINDCONSTR, RESPONSEOPTIMIZER/FINDPAR,
%   GETSRO, NEWSRO, RESPONSEOPTIMIZER/OPTIMGET, RESPONSEOPTIMIZER/OPTIMSET

%  Author(s): Pascal Gahinet
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.1 $ $Date: 2004/04/19 01:33:40 $