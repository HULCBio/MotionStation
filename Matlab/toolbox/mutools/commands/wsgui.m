% wsgui: Main program for Workspace Tool

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.9.2.3 $

wsguin;
MUWHOVAR=who; wsguin([],'who',MUWHOVAR); clear MUWHOVAR;
wsminfo;
wsguin([],'applysr');
wsguic;
wsguin([],'refill');
wsguin([],'reclock');

wsguin([],'hide');
