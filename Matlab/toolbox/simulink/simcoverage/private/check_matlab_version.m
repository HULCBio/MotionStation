function matlabVersion = check_matlab_version
%CHECK_MATLAB_VERSION This M-function is called when initializing Stateflow.
%                     It checks that the Stateflow image is running with a
%                     valid MATLAB version.

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/03/23 03:00:34 $

matlabVersion = version;
matlabVersion = [matlabVersion(1),matlabVersion(3),matlabVersion(5)];
matlabVersion =  eval(matlabVersion);


isOk = (matlabVersion>=530);
if ~isOk
  more('off');
  fileName = mfilename;
  [i,j,k]=regexp(fileName,['\',filesep,'(\w+)\',filesep,'private\',filesep,'.*$'], 'once');
  if (~isempty(i) & ~isempty(k))
      %extract the (\w+) component name match
      componentName = fileName(k{1}(1):k{1}(2));
      componentVersion = evalc(['type(''',componentName,'/Contents.m'')']);
      [s,e] = regexp(componentVersion,'Version[^\n]*', 'once');
      if (~isempty(s))
          componentVersion = componentVersion(s:e);
      else
          componentVersion = 'unknown (there is no version number in its Contents.m)';
      end
  else
      componentName = '<unknown component>';
      componentVersion = 'unknown';
  end

  componentName(1) = upper(componentName(1));
  errorMsg = sprintf(...
    ['\nCan not initialize %s due to incompatible versions of %s and MATLAB images!\n'...
    ,'   %s image is %s\n'...
    ,'   MATLAB image is Version %s\n'...
    ,'Please check your installation of MATLAB, SIMULINK, and %s.']...
    ,componentName, componentName, componentName, componentVersion, version, componentName);

  lasterr(errorMsg);
  matlabVersion = [];
end


