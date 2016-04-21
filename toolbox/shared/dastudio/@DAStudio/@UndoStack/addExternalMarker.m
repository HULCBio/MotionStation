function addExternalMarker(h)

% Copyright 2004 The MathWorks, Inc.
  
% For right now, we are just incrementing a counter
% to emulate the addition of a marker.  Only when the 
% counter is at zero are undos allowed.  There is a future
% problem with this:
%   We aren't tracking where in the stack the marker goes
%   This is not currently a problem as the marker is 
%   always at the top of the stack.  The only way to add
%   to the stack is to make a UDD change.  However, a UDD 
%   change will trigger a flush of the SF undo stack
%   and this will clear any markers anyways.  Therefore, if 
%   there is a marker, it must be at the top of the stack!
  
  h.externalMarkers = h.externalMarkers + 1;
  
  
