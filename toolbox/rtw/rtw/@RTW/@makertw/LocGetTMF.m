function LocGetTMF(h, hModel,rtwroot)
% LOCGETTMF:
%     Get the template makefile to be used by the build process
%   Note: It's not recommended to be overloaded in subclass.

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2004/04/15 00:23:53 $

  h.TemplateMakefile = deblank(get_param(hModel,'RTWTemplateMakefile'));
  h.TemplateMakefile = fliplr(deblank(fliplr(h.TemplateMakefile)));
  if isempty(h.TemplateMakefile)
    error('No template makefile specified');
  end
  
  h.CompilerEnvVal = ''; % assume
  if ~any(find(h.TemplateMakefile=='.'))
    if ~exist([h.TemplateMakefile,'.m'],'file')
      error('Invalid template makefile specified');
    end
    % No extension, so assume MATLAB command which returns the template
    % makefile
    if nargout(h.TemplateMakefile) == 3
        [h.TemplateMakefile,h.CompilerEnvVal,h.mexOpts] = feval(h.TemplateMakefile);
    elseif nargout(h.TemplateMakefile) == 2
      [h.TemplateMakefile,h.CompilerEnvVal] = feval(h.TemplateMakefile);
    else
      h.TemplateMakefile = feval(h.TemplateMakefile);
    end
  end
  
  if exist(h.TemplateMakefile) ~= 2
    [file]=LocGetTMFFromRTWRoot(h, rtwroot, 'c', h.TemplateMakefile);
    if ~isempty(file)
      h.TemplateMakefile = file;
    else
      error('%s', ['Unable to locate template makefile: ',h.TemplateMakefile]);
    end
  else
    h.TemplateMakefile = which(h.TemplateMakefile);
  end

%endfunction LocGetTMF
