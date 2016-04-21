function resetListeners(this)
%ADDLISTENERS  Adds new listeners to listener set.
%
% Author(s): James G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:32:55 $

if ~isempty(this.Listeners)
    delete(this.Listeners);
    this.Listeners = [];
end
