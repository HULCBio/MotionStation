function h = dffit(varargin)
%DFFIT Constructor for stats.distfit class (distribution fitting fit object)

% $Revision: 1.1.6.2 $  $Date: 2004/01/24 09:32:43 $
% Copyright 2003-2004 The MathWorks, Inc.

% We may be asked to create an empty object not connected to the database
toconnect = 1;
if nargin==1 & isequal(varargin{1},'disconnected')
   varargin(1) = [];
   toconnect = 0;
end

% The meat of the constructor is in the helper function below.
% See the comments in that file for more information.
h = initdistfit(stats.dffit,varargin{:});
