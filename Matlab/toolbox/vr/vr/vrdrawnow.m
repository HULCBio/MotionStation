function vrdrawnow
%VRDRAWNOW Flush pending VR events.
%   VRDRAWNOW flushes the queue of VR changes and forces
%   viewers to update screen.
%   Normally, changes to VR scene are queued and the views
%   are updated when one of the following happens:
%
%   - MATLAB is idle for some time (no Simulink model is running
%     and no M-file is being executed).
%   - A Simulink step is finished.

%   Copyright 1998-2002 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.2.1 $ $Date: 2004/04/06 01:11:15 $ $Author: batserve $

vrsfunc('DrawNow');
