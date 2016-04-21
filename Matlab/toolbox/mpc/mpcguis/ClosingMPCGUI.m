function ClosingMPCGUI(EventSrc, EventData, this)

% ClosingMPCGUI(EventSrc, EventData, this)

%  Author:  Larry Ricker
%  Copyright 1986-2003 The MathWorks, Inc. 
%  $Revision: 1.1.6.1 $ $Date: 2003/12/04 01:35:50 $

% React to user attempt to close the main GUI window.
% If no projects remain, just return.

if isa(this, 'mpcnodes.MPCGUI')
    this.Frame.setVisible(true);
    this.closeTool;
end