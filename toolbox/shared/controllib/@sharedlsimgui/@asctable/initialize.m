function initialize(h)
% INITIALIZE inializes the properties and listeners of an empty @asctable

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:24:27 $

import com.mathworks.toolbox.control.spreadsheet.*;

h.colnames = {' ' ' '};
h.setCells({' '});

h.leadingcolumn = 'on';
h.STable = STable(SheetTableModel(NaN,h));
h.STable.setVisible(0);
h.STable.getTableHeader.setVisible(0);
h.filename = '';

% Context menus are disabled in the base class
%h.menulabels = {'Copy'};
%h.STable.getModel.setMenuStatus(1);

% add listeners
L = [handle.listener(h, findprop(h,'filename'),'PropertyPostSet',{@localSheetUpdate h});
     handle.listener(h, findprop(h,'delimeter'),'PropertyPostSet',{@localSheetUpdate h})];
h.addlisteners(L);
 

%-------------------- Local Functions ---------------------------


function localSheetUpdate(eventSrc, eventData, h)

h.open
