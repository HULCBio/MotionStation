% Simulink.ModelDataLogs.whos
%
% Lists detailed information about the contents of a ModelDataLogs object. 
%
% For an object named logsout:
%
% logsout.whos  
%
%     Lists name, number of elements, and type for each signal in the top
%     level of a ModelDataLogs object
%
% logsout.whos('systems')
%
%     Lists name, number of elements, and type for all signals including
%     composite signals (i.e., buses and muxes) but not elements of 
%     composite signals
%
% logsout.whos('all')
%
%     Lists name, number of elements, and type for all signals including
%     the elements of composite signals
%
% S = logsout.whos
%
%     Returns an array of structures, one for each signal log
%     object in the top level of the ModelDataLogs object.
%     The structures have the following fields:
%
%     name  --  name of the signal log object
%     elements -- number of signal log objects contained by the object
%     simulinkClass -- class of the object
%
% S = logsout.whos('systems') , S = logsout.whos('all')
%
%     Return similar array of structures as 'logsout.who' corresponding
%     to the level of the {'systems', 'all'} argument
%
%
% Other methods for Simulink.ModelDataLogs: unpack, who
%
% Overloaded methods (ones with the same name in other directories)
%      help  Simulink.ModelDataLogs/who
%      help  Simulink.SubsysDataLogs/who

% Copyright 2004 The MathWorks, Inc.
