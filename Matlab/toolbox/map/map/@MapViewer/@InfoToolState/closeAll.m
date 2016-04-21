function closeAll(this)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:49:32 $

if ~isempty(this.InfoBoxHandles)
  delete([this.InfoBoxHandles{:,2}]);
  this.InfoBoxHandles = [];
end
