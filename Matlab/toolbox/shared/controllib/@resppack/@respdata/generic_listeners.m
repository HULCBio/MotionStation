function generic_listeners(h)
%  GENERIC_LISTENERS  Installs generic listeners for @respdata class.

%  Author(s): Bora Eryilmaz
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:22:23 $

% Install attribute listeners

% Install targeted listeners
L = [handle.listener(h, 'ObjectBeingDestroyed', @LocalDeleteAll)];
set(L, 'CallbackTarget', h);
h.Listeners = [h.Listeners ; L];


% ----------------------------------------------------------------------------%
% Local Functions
% ----------------------------------------------------------------------------%

% ----------------------------------------------------------------------------%
% Purpose: Clean up reference to @respplot object.
% ----------------------------------------------------------------------------%
function LocalDeleteAll(h, eventdata)
disp('   in LocalDeleteAll, @respdata')
