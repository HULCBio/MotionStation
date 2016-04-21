function setSelectedRow(this, Row)

% Called by the java table when a row has been selected.  Update
% the UDD property.

%  Author:  Larry Ricker
%  Copyright 1986-2003 The MathWorks, Inc.
%  $Revision: 1.1.6.3 $ $Date: 2004/04/10 23:37:32 $

this.ListenerEnabled = false;
this.selectedRow = Row;
this.ListenerEnabled = true;