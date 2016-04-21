function StartStop = getSimInterval(this)
% Gets simulation interval [StartTime,StopTime].

%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:44:58 $
%   Copyright 1986-2004 The MathWorks, Inc.
StartStop = getSimInterval(this.Tests(1));
