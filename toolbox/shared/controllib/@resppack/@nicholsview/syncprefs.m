function syncprefs(this, Prefs)
% SYNCPREFS  nicholsview preferences

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:21:37 $

cPrefs = get(this(1), 'UnwrapPhase');

% Set new preferences
if isfield(Prefs, 'UnwrapPhase') & ~strcmp(Prefs.UnwrapPhase,cPrefs)
  set(this, 'UnwrapPhase', Prefs.UnwrapPhase);
end
