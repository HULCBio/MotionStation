function figureChanged = notebookCompareFigures
%NOTEBOOKCOMPAREFIGURES	Notebook utility routine to compare figures

% Copyright 1984-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2003/11/10 13:37:34 $

global notebookGlobalData

figurelist = compareFigures(notebookGlobalData);
clear global notebookGlobalData

% Return 0 if no figures have changed; otherwise return 1
if isempty(figurelist)
    figureChanged = 0;
else
    figureChanged = 1;
end

