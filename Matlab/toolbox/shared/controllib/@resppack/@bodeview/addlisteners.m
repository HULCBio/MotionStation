function addlisteners(this)
%  ADDLISTENERS  Installs additional listeners for @bodeview class.

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:20:30 $

% Initialization. First install generic listeners
this.generic_listeners;

% Add @timeplot specific listeners
L = [handle.listener(this, 'ObjectBeingDestroyed', @LocalCleanUp)];
set(L, 'CallbackTarget', this);
this.Listeners = [this.Listeners ; L];


% ----------------------------------------------------------------------------%
% Local Functions
% ----------------------------------------------------------------------------%

% ----------------------------------------------------------------------------%
% Purpose:  Clean up when @bodeview (@respview) object is destroyed.
% ----------------------------------------------------------------------------%
function LocalCleanUp(this, eventdata)
% Delete hg lines
delete(this.MagCurves(ishandle(this.MagCurves)))
delete(this.PhaseCurves(ishandle(this.PhaseCurves)))
