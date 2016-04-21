function removeLayer(this,layername)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/02/01 21:56:26 $

if ~isempty(this.LabelHandles)
  ind = strmatch(layername, this.LabelHandles(:,1), 'exact');
  if ~isempty(ind)
    delete(this.LabelHandles{ind,2});
    delete(this.LabelHandles{ind,3});
    this.LabelHandles(ind,:) = [];  
  end
end

