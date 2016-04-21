function [transports, mexfiles] = extmode_transports(hSrc)
%EXTMODE_TRANSPORTS External Mode callback function for configuration sets.
%
%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $

  if ~isa(hSrc, 'Simulink.BaseConfig');
    error('This function must be associated with a configuration set object');
  end;
  
  %
  % Transport layers for External Mode supported targets.
  %
  % To create a custom transport layer that appears in the drop-list of the RTW
  %  options page:
  %
  %  1) Add the name of the new transport layer to the transports variable for
  %     the specific target using the following template:
  %
  %     transports = {'transport1', 'transport2', ..., 'transportN'}; 
  %
  %  2) Add the name of the MEX-File associated with the new transport layer to the
  %     mexfiles variable for the specific target using the following template:
  %
  %     mexfiles = {'mexfile1', 'mexfile2', ..., 'mexfileN'}; 
  %
  %  3) Modify the template makefiles for the targets supporting the new transport
  %     layer.  For example, the template makefiles for GRT are located in
  %     <matlabroot>/rtw/c/grt/*.tmf
  %
  %  The variables transports and mexfiles must be 1xN arrays.
  
  %
  % GRT/GRT Malloc Targets
  %
  if isa(hSrc, 'Simulink.GRTTargetCC');
    transports = {
        'tcpip'                 % Index 0 in the template makefiles
        'serial_win32'          % Index 1
                 };
    mexfiles = {
        'ext_comm',             % MEX-File for 'tcpip'
        'ext_serial_win32_comm' % MEX-File for 'serial_win32'
               };
  %
  % ERT Target
  %
  elseif isa(hSrc, 'Simulink.ERTTargetCC');
    transports = {
        'tcpip'                 % Index 0 in the template makefiles
        'serial_win32'          % Index 1
                 };
    mexfiles = {
        'ext_comm',             % MEX-File for 'tcpip'
        'ext_serial_win32_comm' % MEX-File for 'serial_win32'
               };
  %
  % RSim Target
  %
  elseif isa(hSrc, 'RTW.RSimTargetCC')
    transports = {
        'tcpip'                 % Index 0 in the template makefiles
        'serial_win32'          % Index 1
                 };
    mexfiles = {
        'ext_comm',             % MEX-File for 'tcpip'
        'ext_serial_win32_comm' % MEX-File for 'serial_win32'
               };
  %
  % Tornado Target
  %
  elseif isa(hSrc, 'RTW.TornadoTargetCC')
    transports = {
        'tcpip'                 % Index 0 in the template makefiles
                 };
    mexfiles = {
        'ext_comm'              % MEX-File for 'tcpip'
               };
  %
  % Real-Time Windows Target
  %
  elseif isa(hSrc, 'RTW.RTWinTargetCC')
    transports = {
        'sharedmem'             % Index 0 in the template makefiles
                 };
    mexfiles = {
        'rtwinext'              % MEX-File for 'sharedmem'
               };

  %
  % Unsupported Targets
  %
  else
    transports = {'none'};
    mexfiles   = {'noextcomm'};
  end;
  
  % Both variables should be 1xN arrays
  transports = transports';
  mexfiles   = mexfiles';
  
% end extmode_transports
