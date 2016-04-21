function setgrid(this,varargin)
%SETGRID  Defines underlying grid for gridded data sets.
%
%   SETGRID(D,X1,X2,...XN) specifies an N-dimensional grid for 
%   the data set D.  The grid data for the j-th grid dimension 
%   is specified by Xj, which can be either
%    (1) a string or string vector containing the names of the  
%        variables for this grid dimension.
%    (2) a vector of @variable object sdescribing the variables 
%        for this grid dimension.
%
%   Example:
%      d = hds.dataset('demo',{'x','y','z'})
%      d.setgrid('x','y');          % 2D grid
%      d.x = [1 2 3];
%      d.y = [4 5];
%      d.z = randn(3,2);
% 
%   See also GETGRID.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:28:18 $
ndims0 = length(this.Grid_);
ndims = length(varargin);
if ndims0>0 && ndims0~=ndims
   error('Number of grid dimensions cannot be redefined.')
end

% Data set variable list
AllVars = getvars(this);

% Update grid info
for ct=1:ndims
   % Locate specified variables
   try
      idx = locate(AllVars,varargin{ct});
   catch
      rethrow(lasterror)
   end
   this.Grid_(ct).Variable = AllVars(idx)';
   this.Grid_(ct).Length = 0;
end
