function removeLayer(this,layername)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 21:56:39 $

if ~isempty(this.InfoBoxHandles)
  ind = strmatch(layername, this.InfoBoxHandles(:,1), 'exact');
  if ~isempty(ind)
    delete(this.InfoBoxHandles{ind,2});
    this.InfoBoxHandles(ind,:) = [];  
  end
end

