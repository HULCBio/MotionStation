function close(sisodb)
%CLOSE  Close SISO Tool and its dependencies.
%
%   See also SISOTOOL.

%   Author: P. Gahinet  
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/10 04:59:33 $

SISOfig = sisodb.Figure;
set(SISOfig,'DeleteFcn','')

% Delete all editors
delete(sisodb.TextEditors)
delete(sisodb.PlotEditors)

% Destroy data kernel to trigger closing of all dependencies
delete(sisodb.LoopData)

% Clear main database
delete(sisodb)

% Delete HG figure
delete(SISOfig(ishandle(SISOfig)))

