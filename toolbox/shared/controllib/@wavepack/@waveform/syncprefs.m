function syncprefs(this, Prefs)
% SYNCPREFS  Syncronizes Response and Characteristics preferences

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:26:23 $

% Response curve preferences
syncprefs(this.Data, Prefs)
syncprefs(this.View, Prefs)

% Characteristics prefenreces
for ch = this.Characteristics'  % @wavechar
  syncprefs(ch.Data, Prefs)
  syncprefs(ch.View, Prefs)
end
