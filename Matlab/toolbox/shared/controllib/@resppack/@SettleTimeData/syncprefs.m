function syncprefs(this, Prefs)
% SYNCPREFS  Syncronizes plot preferences with those of characteristics
 
%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:19:19 $

cPrefs = get(this(1), 'SettlingTimeThreshold');

% Set new preferences
if isfield(Prefs, 'SettlingTimeThreshold') & ...
      (Prefs.SettlingTimeThreshold ~= cPrefs)
  clear(this); % Vectorized clear
  set(this, 'SettlingTimeThreshold', Prefs.SettlingTimeThreshold);
end
