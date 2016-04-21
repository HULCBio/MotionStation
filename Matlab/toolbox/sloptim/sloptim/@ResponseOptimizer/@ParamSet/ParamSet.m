function this = ParamSet(ParNames)
% Creates Parameter Set object.

% Author(s): P. Gahinet
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $Date: 2004/04/11 00:45:39 $
this = ResponseOptimizer.ParamSet;

% Add variables
this.addvar('Optimized');
for ct=1:length(ParNames)
   this.addvar(ParNames{ct});
end
