function ScrollPanel = getDialogSchema(this, manager)
% GETDIALOGSCHEMA Constructs the default dialog panel

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:43 $

DialogPanel = com.mathworks.mwswing.MJPanel;
Button      = com.mathworks.mwswing.MJButton( 'Hello World!' );
ScrollPanel = com.mathworks.mwswing.MJScrollPane( DialogPanel );
DialogPanel.add( Button );

this.Handles.Button = Button;
set( Button, 'ActionPerformedCallback', { @LocalUpdate, this } );

% --------------------------------------------------------------------------- %
function LocalUpdate(eventSrc, eventData, this)
disp('Hello There!')
