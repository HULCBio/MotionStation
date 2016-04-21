function rmlisteners(this)
%RMLISTENERS  Default implementation.

% Copyright 2003 The MathWorks, Inc.

% Used by the metada proeprty setFunction to keep the list of listeners in
% sync with the stored @metadata
if ~isempty(this.Listeners) && any(ishandle(this.Listeners))
    delete(this.Listeners)
    this.Listeners = [];
end
