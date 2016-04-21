function cleardata(this,Domain)
%CLEARDATA  Clears all cached data.

%   Authors: Kamesh Subbarao
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2002/11/11 22:22:47 $

% Clear cached data from the ltisources first.
for s=this.Systems'
   % Clear all cached data for the specified domain (forces
   % recomputing the time or frequency response)
   reset(s,Domain)
end

% Clear the dependent data cached in the @data object associated with each
% response (forces reevaluation of the DataFcn)
for v=this.Views(ishandle(this.Views))'
   cleardata(v,Domain)
end