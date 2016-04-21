function [prop] = initprop
% INITPROP xpcsc Initializer (private)
%
%   INITPROP initializes the properties for the xpcsc object; it fills
%   the structure with the default values.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.12.4.1 $ $Date: 2004/04/08 21:03:40 $

propname = {
    'Version',                          % 01
    'ScopeId',                          % 02
    'Status',                           % 03
    'Type',                             % 04
    'NumSamples',                       % 05
    'Decimation',                       % 06
    'TriggerMode',                      % 07
    'TriggerSignal',                    % 08
    'TriggerLevel',                     % 09
    'TriggerSlope',                     % 10
    'TriggerScope',                     % 11
    'StartTime',                        % 12
    'Signals',                          % 13
    'Data',                             % 14
    'Command',                          % 15
    'Application',                      % 16
    'Mode',                             % 17
    'YLimit',                           % 18
    'Grid',                             % 19
    'Time',                             % 20
    'NumPrePostSamples'                 % 21
    'TriggerSample'                     % 22
    'Signalnames'                       % 23
           };

propval = {
    '1.1',                              % 01
    'unknown',                          % 02
    'interrupted',                      % 03
    'host',                             % 04
    '500',                              % 05
    'unknown',                          % 06
    'unknown',                          % 07
    'NaN',                              % 08
    'NaN',                              % 09
    'NaN',                              % 10
    'NaN',                              % 11
    'unknown',                          % 12
    'unknown',                          % 13
    '',                                 % 14
    'unknown',                          % 15
    'unknown',                          % 16
    'unknown',                          % 17
    'unknown',                          % 18
    'unknown',                          % 19
    '',                                 % 20
    '0'                                 % 21
    '0'                                 % 22
    ' '                                 % 23
          };

propWritable =  {
    'NumSamples',    '';                % 05
    'Decimation',    '';                % 06
    'TriggerMode',   '[{FreeRun} | Software | Signal | Scope | Endscope]';% 07
    'TriggerSignal', '';                % 08
    'TriggerLevel',  '';                % 09
    'TriggerSlope',  '[{Either} | Rising | Falling]';              % 10
    'TriggerScope',  '';                % 11
    'Signals',       '';                % 13
    'Command',       '[Start | Stop | Trigger]';                   % 15
    'Mode',          '[Numerical | {Redraw} | Sliding | Rolling]'; % 17
    'YLimit',        '';                % 18
    'Grid',          '[{On }| Off]';    % 19
    'NumPrePostSamples','';             % 21
    'TriggerSample',    '';             % 22
             };

propWriteOnly = {'Command'};

prop.propname      = propname;
prop.propval       = propval;
prop.propWritable  = propWritable;
prop.propWriteOnly = propWriteOnly;

%% EOF initprop.m
