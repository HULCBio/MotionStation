function rtwho
%RTWHO  Print information about Real-Time Windows Target status.
%
%   RTWHO prints all useful information about the Real-Time Windows Target
%   status, i.e. lists all hardware drivers, timers, kernel performance,
%   machine type and version.
%
%   See also RTLOAD, RTCLEAR.

%   Copyright 1994-2003 The MathWorks, Inc.
%   $Revision: 1.11.2.3 $  $Date: 2003/12/31 19:46:04 $  $Author: batserve $

try

vers = rttool('Read',0,'Version');
if vers~=2.50


fprintf('\nReal-Time Windows Target version %.0f.%.1f (C) The MathWorks, Inc. 1994-2003\n\n',fix(vers),10*rem(vers,1));
fprintf('Incorrect kernel version is installed.\nUse RTWINTGT -SETUP to install the correct version.\n\n');

else

[tim,dummy,dummy,drv,slice,perf,dummy,dummy,mach]=rttool('Read',0,'Timers');  %#ok DUMMY is dummy

fprintf('\nReal-Time Windows Target version %.0f.%.1f (C) The MathWorks, Inc. 1994-2003\n',fix(vers),10*rem(vers,1));
fprintf('Running on %s computer.\n',mach);
if isempty(perf)
  perf = 1;
else
  perf = 1 - mean(perf(:,2)-perf(:,1)) / mean(diff(perf(:,1)));
end;
fprintf('MATLAB performance = %4.1f%%\n',100*perf);
fprintf('Kernel timeslice period = %g ms\n\n',1000*slice);

if ~isempty(tim)
  fprintf('TIMERS:  Number   Period   Running\n\n');
    yn = {'No','Yes'};
  for i=tim
    [per,dummy,dummy,run]=rttool('Read',i,'Period');  %#ok DUMMY is dummy
    fprintf('%13d %9g      %-s\n',i,per,yn{run+1});
  end;
  disp(' ');
end;
  
if ~isempty(drv)
  disp('DRIVERS:                             Name    Address   Parameters');
  disp(' ');
  for i=drv
    [desc,dummy,dummy,addr,opt]=rttool('Read',i,'Description');  %#ok DUMMY is dummy
    if isempty(opt); opt=[]; end;
    fprintf('%41s%#11x   %s\n',desc,addr,mat2str(opt));
  end;
  disp(' ');
end;

end;

catch

rterror(lasterr);

end;
