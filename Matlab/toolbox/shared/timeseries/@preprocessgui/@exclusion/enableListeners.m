function enableListeners(this)

% Copyright 2003 The MathWorks, Inc.

if ~isempty(this.Listeners) 
    set(this.Listeners,'Enabled','on')
end
 
