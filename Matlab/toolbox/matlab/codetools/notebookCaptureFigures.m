function notebookCaptureFigures
%NOTEBOOKCAPTUREFIGURES	Notebook utility routine to capture figures.

% Copyright 1984-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2003/11/10 13:37:33 $

global notebookGlobalData

notebookGlobalData = captureFigures;
