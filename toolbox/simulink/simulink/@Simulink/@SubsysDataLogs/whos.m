% Simulink.SubsysDataLogs.whos
%
% Lists detailed information about the contents of a SubsysDataLogs object.
%
% For an object named subsystem:
%
% subsystem.whos
%
%     Lists name, number of elements, and type for each signal in the top
%     level of a SubsysDataLogs object
%
% subsystem.whos('systems')
%
%     Lists name, number of elements, and type for all signals including
%     composite signals (i.e., buses and muxes) but not elements of
%     composite signals
%
% subsystem.whos('all')
%
%     Lists name, number of elements, and type for all signals including
%     the elements of composite signals
%
% S = subsystem.whos
%
%     Returns an array of structures, one for each signal log
%     object in the top level of the SubsysDataLogs object.
%     The structures have the following fields:
%
%     name  --  name of the signal log object
%     elements -- number of signal log objects contained by the object
%     simulinkClass -- class of the object
%
% S = subsystem.whos('systems') , S = subsystem.whos('all')
%
%     Return similar array of structures as 'subsystem.who' corresponding
%     to the level of the {'systems', 'all'} argument
%
%
% Other methods for Simulink.SubsysDataLogs: unpack, who

% Copyright 2004 The MathWorks, Inc.
