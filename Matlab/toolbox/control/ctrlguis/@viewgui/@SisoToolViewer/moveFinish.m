function moveFinish(this)
%MOVEFINISH  Clean up after mouse edit.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.1 $  $Date: 2002/04/03 04:14:56 $

set(this.RealTimeData.VisibleResponses,'RefreshMode','normal')
set(this.RealTimeData.HiddenResponseListeners,'Enable','on')  
% Delete listener
delete(this.RealTimeData.DataListener);