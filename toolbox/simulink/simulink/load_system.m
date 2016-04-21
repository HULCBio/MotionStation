function varargout=load_system(sys)
%LOAD_SYSTEM Invisibly load a Simulink model.
%   LOAD_SYSTEM('SYS') loads the specified system without making the
%   model window visible.  If the specified system is 'built-in', 
%   no action is taken.
%   
%   See also OPEN_SYSTEM.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.11.2.1 $
  
  if ~strcmp(sys,'built-in'),
    sysInput = sys;
    sys = StripTrailingDotMdl(sys);

    try
      if (exist(sys) == 4) | strcmpi(sys, 'simulink')
	feval(sys,[],[],[],'load');
      else
        feval(sys); % M-file models are now called without arguments
	            % This avoids internal ouput variables from being
                    % uninitialized.  However, it means that these models
                    % will now 'open' instead of simply 'load'ing
      end
      if nargout,
	varargout{1} = get_param(sys,'Handle');
      end
    catch
      error(['There is no system named ''' sysInput ''' to open.'])
    end
  end
  
  
function oMdl = StripTrailingDotMdl(iMdl)

% Strip trailing .mdl if it is present.

  [aDummyPath aMdl aExt] = fileparts(iMdl);
  
  if (strcmp(aExt,'.mdl'))
    oMdl = aMdl;
  else
    oMdl = iMdl;
  end

% [EOF] load_system.m
