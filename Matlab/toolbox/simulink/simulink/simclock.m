function simclock(varargin)
%SIMCLOCK Simulink Clock block.
%   SIMCLOCK is an obsolete function.  To display the
%   simulation time in a Clock block, open the Clock's
%   parameter dialog and select the 'Display time' checkbox.
%
%   SIMCLOCK.M will be removed in the future.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.20 $

lock_status = get_param(bdroot(gcbh), 'lock');
if (strcmp(lock_status, 'off'))
  if (strcmp(get_param(gcbh, 'LinkStatus'), 'none'))
    % some versions of Simulink incorrectly defined callbacks
    % for the clock block. 
    % Delete the callbacks as they have no purpose
    set_param(gcbh, 'DeleteFcn', '',...
                    'PostSaveFcn', '',...
                    'CloseFcn', '');
  end
end  

