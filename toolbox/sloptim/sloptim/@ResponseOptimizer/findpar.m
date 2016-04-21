%FINDPAR  Find specifications for given tuned parameter.
%
%   P=FINDPAR(PROJ,'PARAM') returns a tuned parameters object for the
%   parameter with the name PARAM within the response optimization project,
%   PROJ. The tuned parameters object defines specifications for each tuned
%   parameter that the response optimization algorithm uses, such as
%   initial guesses, lower bounds etc. 
%
%   The properties of each tuned parameter object are:
%   Name           A string giving the parameter’s name.
%   Value          The current value of the parameter. This will change 
%                  during the optimization.
%   InitialGuess   The initial guess for the parameter value for the 
%                  optimization
%   Minimum        The minimum value this parameter can take. By default it 
%                  is set to -Inf.
%   Maximum        The maximum value this parameter can take. By default it 
%                  is set to Inf.
%   TypicalValue   A value that the tuned parameter is scaled by during the 
%                  optimization.
%   ReferencedBy   The block, or blocks, in which the parameter appears.
%   Description    An optional string giving a description of the parameter
%   Tuned          Set to 1 or 0 to indicate if this parameter is to be 
%                  tuned or not.
%
%   Edit these properties to specify additional information about your 
%   parameters.
%
%   Example:
%     proj = getsro('srodemo1')
%     p = findpar(proj,'P')
% 
%   See also RESPONSEOPTIMIZER/FINDCONSTR, GETSRO, NEWSRO,
%   RESPONSEOPTIMIZER/OPTIMIZE.

%  Author(s): Pascal Gahinet
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.1 $ $Date: 2004/04/19 01:33:37 $



