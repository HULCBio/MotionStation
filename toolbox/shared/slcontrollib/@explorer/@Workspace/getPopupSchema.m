function menu = getPopupSchema(this, manager)
% GETPOPUPSCHEMA 

% Author(s): John Glass, B. Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:29 $

menu  = com.mathworks.mwswing.MJPopupMenu('Default Menu');
item1 = com.mathworks.mwswing.MJMenuItem('Load...');
item2 = com.mathworks.mwswing.MJMenuItem('Save...');

menu.add( item1 );
menu.add( item2 );

h = handle( item1, 'callbackproperties' );
h.ActionPerformedCallback = { @LocalOpen, this, manager };
h.MouseClickedCallback    = { @LocalOpen, this, manager };

h = handle( item2, 'callbackproperties' );
h.ActionPerformedCallback = { @LocalSave, this, manager };
h.MouseClickedCallback    = { @LocalSave, this, manager };

% --------------------------------------------------------------------------- %
function LocalOpen(hSrc, hData, this, manager)
manager.loadfrom(this.getChildren);

% --------------------------------------------------------------------------- %
function LocalSave(hSrc, hData, this, manager)
manager.saveas(this.getChildren)
