% Simulink.ModelDataLogs
%
%
% Simulink.ModelDataLogs class defines objects for storing signal data logged
% by Simulink for a model during simulation. A ModelDataLogs object has a 
% 'Name' field that specifies the name of the model whose signal data it
% records and a field for each recorded signal. Each field's name is the
% corresponding signal's log name. The field's value is an object that contains
% the time series data logged for the signal. These objects may be instances 
% of any of the following types of objects:
%
%   * Simulink.Timeseries
%
%     Log data for a single signal
%
%   * Simulink.TsArray
%
%     Log for a composite signal (e.g., a Mux or Bus signal)
%
%   * Simulink.ModelDataLogs
% 
%     Signal log for a Model block
%
%   * Simulink.SubsysDataLogs
%
%     Signal log for a subsystem
%
%
% Simulink.ModelDataLogs class defines the following methods for extracting
% data from a model data log object:
%
% * Simulink.ModelDataLogs.unpack
%
%   Extracts the objects contained by a ModelDataLogs object.
%
% * Simulink.ModelDataLogs.whos
%
%   Lists the contents of a ModelDataLogs object.
%
% * Simulink.ModelDataLogs.who
%
%   An abbreviated listing of the contents of a ModelDataLogs object.
%
% See the online documentation or use the help command to get more information
% on these methods. To use the help command, type help followed by the fully
% qualified name of the command, e.g., 'help Simulink.ModelDataLogs.unpack'

% Copyright 2004 The MathWorks, Inc.
