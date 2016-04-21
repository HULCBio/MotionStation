function run(script)
%RUN Run script.
%   Typically, you just type the name of a script at the prompt to
%   execute it.  This works when the script is on your path.  Use CD
%   or ADDPATH to make the script executable from the prompt.
%
%   RUN is a convenience function that runs scripts that are not
%   currently on the path. 
%
%   RUN SCRIPTNAME runs the specified script.  If SCRIPTNAME contains
%   the full pathname to the script, then RUN changes the current
%   directory to where the script lives, executes the script, and then
%   changes back to the original starting point.  The script is run
%   within the caller's workspace.
%
%   See also CD, ADDPATH.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.17 $  $Date: 2002/04/15 04:16:48 $

cur = cd;

if isempty(script), return, end
if ispc, script(find(script=='/'))='\'; end
if ~isunix
  [p,s,ext,ver] = fileparts(lower(script));
else
  [p,s,ext,ver] = fileparts(script);
end
if ~isempty(p),
  if exist(p,'dir'),
    cd(p)
    w = which(s);
    if ~isempty(w),
      % Check to make sure everything matches
      if ~isunix
        [wp,ws,wext,wver] = fileparts(lower(w));
      else
        [wp,ws,wext,wver] = fileparts(w);
      end
      % Allow users to choose the .m file and run a .p
      if strcmp(wext,'.p') & strcmp(ext,'.m'),
         wext = '.m';
      end
      
      if ispc
        cont = ~strcmpi(wp,pwd) | ~strcmpi(ws,s) | ...
          (~isempty(ext) & ~strcmpi(wext,ext));
      else
        cont = ~isequal(wp,pwd) | ~isequal(ws,s) | ...
          (~isempty(ext) & ~isequal(wext,ext));
      end
      if cont
         if exist([s ext],'file')
           cd(cur)
           error('Can''t run %s.',[s ext]);
         else
           cd(cur)
           error('Can''t find %s.',[s ext]);
         end
      end
      evalin('caller',s,'cd(cur);error(lasterr)')
    else
      cd(cur)
      error([script ' not found.'])
    end
    cd(cur)
  else
    error([script ' not found.']);
  end
else
  if exist(script)
    evalin('caller',script,'error(lasterr)')
  else
    error([script ' not found.'])
  end
end

