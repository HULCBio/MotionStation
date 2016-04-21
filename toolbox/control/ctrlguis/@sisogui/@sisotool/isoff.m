function boo = isoff(sisodb)
%ISOFF  Returns 1 (true) if editors are off (no data loaded).

%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/10 05:00:30 $
boo = strcmp(sisodb.PlotEditors(1).EditMode,'off');