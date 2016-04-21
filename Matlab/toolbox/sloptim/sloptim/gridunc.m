function uset = gridunc(varargin)
%GRIDUNC  Define grid of uncertain parameter values.
%
%   USET = GRIDUNC('P1',VALUES1,'P2',VALUES2,...) takes vectors or cell
%   arrays of values VALUES1, VALUES2,... for the uncertain parameters 
%   P1, P2,... and constructs the multi-dimensional grid of all uncertain
%   parameter value combinations for use in a response optimization
%   project.
%
%   Optimize the responses based on uncertain parameter values by setting
%   the Optimized property of the uncertain parameter object, USET, to true
%   (by default this value is set to false).
%
%   Use the SETUNC function to set the uncertain parameter values within
%   the response optimization project.
%   
%   Example:
%     uset1=gridunc('P',[1,2,3,4],'I',[0.1,0.2,0.3],'D',[30,35,40])
%
%     uset2=gridunc('Kp',{[1,2;3,4]},'Kd',{[0.1,0.3;0.2,0.3;0.1,0.2]})
%   
%   See also RANDUNC, RESPONSEOPTIMIZER/SETUNC.

%   Author(s): P. Gahinet
%   $Revision: 1.1.6.2 $ $Date: 2004/04/19 01:33:49 $
%   Copyright 1990-2003 The MathWorks, Inc.
ni = nargin;
ParNames = varargin(1:2:ni);
if rem(ni,2)~=0
   error('Expects an even number of inputs.')
elseif ~iscellstr(ParNames)
   error('Parameter names must be strings.')
end

% Construct data set
uset = ResponseOptimizer.ParamSet(ParNames);
uset.setgrid(ParNames{:});
for ct=1:length(ParNames)
   try
      uset.(ParNames{ct}) = varargin{2*ct};
   catch
      rethrow(lasterror)
   end
end
uset.Optimized = false;
