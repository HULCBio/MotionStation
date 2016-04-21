function this = Parameter(name, value)
% Creates parameter object.

% Author(s): P. Gahinet
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $Date: 2004/04/11 00:45:44 $
this = ResponseOptimizer.Parameter;

% Parse input arguments
ni = nargin;
if ni==1
   this.Name = name;
elseif ni==2
   % Initialize data
   this.initialize( name, value);
   % Set properties
   this.Tuned = true( this.Dimensions );
end
