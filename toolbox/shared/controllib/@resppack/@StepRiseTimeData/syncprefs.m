function syncprefs(this, Prefs)
% SYNCPREFS  Syncronizes plot preferences with those of characteristics
 
%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:19:48 $

cPrefs = get(this(1), 'RiseTimeLimits');

% Set new preferences
if isfield(Prefs, 'RiseTimeLimits') & any(Prefs.RiseTimeLimits ~= cPrefs)
  clear(this); % Vectorized clear
  set(this, 'RiseTimeLimits', Prefs.RiseTimeLimits);
end
