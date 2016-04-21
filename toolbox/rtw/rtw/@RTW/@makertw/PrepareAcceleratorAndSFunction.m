function PrepareAcceleratorAndSFunction(h)
%   PREPAREACCELERATORANDSFUNCTION  prepare for accelerator mode and
%   s-function target.
%   Note: It's not recommended to be overloaded in subclass.

%   Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/01/22 06:53:53 $


% need to know where it's got called (from simprm, accel, or ssgenxxx, etc)
callerName = LocTDisplayCallerInfo(h, '');

% determine if we need to set the start time to be zero
resetToZero = 0;

% switch off RTWCodeReuse for the s-function target
h.CodeReuse = feature('RTWCodeReuse');
if any(findstr(get_param(h.ModelHandle, 'RTWSystemTargetFile'), 'rtwsfcn.tlc'))
    feature('RTWCodeReuse',0);
end

% accelerator mode simulation, need to set
if ~isempty(findstr(callerName, 'simprm')) & ...
	( isempty(findstr(get_param(h.ModelHandle, 'RTWSystemTargetFile'), ...
    		'rtwsfcn.tlc')) & ...
    isempty(findstr(get_param(h.ModelHandle, 'RTWSystemTargetFile'), ...
			'rsim.tlc')) )
    resetToZero = 1;
end

if str2num(h.OrigStartTime) ~= 0 & resetToZero == 1
    buttonName = questdlg(...
	['Start time must be zero for a real time system. ' ...
	 'Do you want Real-Time Workshop to generate code with start ' ...
	 'time zero? '], 'Build question', 'Yes', 'No', 'Yes');
    switch buttonName
     case 'Yes',
      set_param(h.ModelHandle, 'StartTime', '0');
      feval(h.DispHook{:},[sprintf('\n'), '### Setting start time to zero.']);
     case 'No',
      % warn user
      warnStatus = [warning; warning('query','backtrace')];
      warning off backtrace;
      warning on;
      warning('Start time is not zero for this real time system.');
      warning(warnStatus);
    end
end