function h = C2400Scheduler(varargin)
%MEMORY  Class instantiation function (for DSPTgtPkg.C2400Scheduler).

%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/08 21:05:59 $

%%%% Instantiate class
h = DSPTgtPkg.C2400Scheduler;

%%%% Initialize property values
% ENTER CLASS INITIALIZATION CODE HERE (optional) ...

h.Timer = 'EVA_timer2';