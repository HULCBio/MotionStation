function result = sf_display(compName,msgString,force)
%SF_DISPLAY(COMPNAME, MSGSTRING)
% writes msgString to teh logfile and displays it

%   Vijaya Raghavan
%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.6.2.5 $  $Date: 2004/04/15 00:59:28 $

if(nargin<3)
    force = 0;
end
log_file_manager('add_log',0,msgString);
if ~sf_use_silent_build | force
   % we need the log to be displayed if we are testing Stateflow in BAT
   % it is caught in an evalc anyway so it gets displayed only if there is
   % an error.
   if(force==1)
       disp(msgString);
   else
      % force=2 means dont use disp, so msgs can be on a single line.
      fprintf(1,'%s',msgString);
   end
end

