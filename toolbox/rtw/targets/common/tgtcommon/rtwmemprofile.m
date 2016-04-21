function rtwmemprofile(varargin)
%RTWMEMPROFILE invokes the generation of html file for RAM/ROM usage.
%   Used at command line to manually regenerate report.

%   Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $
%   $Date: 2004/04/19 01:22:21 $
  switch nargin
   case 0
    model = bdroot;
    if strcmp(model,'')
      disp('Unable to locate a model, specify a model name.');
      return;
    end
   case 1
    model = varargin{1};
   otherwise
      disp('Specify one model name');
      return;
  end
    
  try
    load_system(model);
  catch
    disp(['Unable to locate model: ',model]);
    return;
  end
  [fullSTFName, STFfid] = rtwprivate('getstf',model);
  %wait for Aslrtw:  [fullSTFName, STFfid, prevfpos] = getstf(model);
  [dummy, gensettings] = rtwprivate('tfile_optarr',STFfid);
  fclose(STFfid);
  %wait for Aslrtw:  rtwprivate('closestf',STFfid, prevfpos);
  
  if ~isfield(gensettings,'BuildDirSuffix')
    disp('Cannot find BuildDirSuffix used in RTW build directory name.');
    return;
  end
  
  % Only support overall model builds, subsystem builds are not (yet) supported.
  builddir = [model,gensettings.BuildDirSuffix];
  if exist(builddir,'dir') ~= 7
    disp('Cannot find RTW build directory.');
    return;
  end
  savedpwd = pwd;
  cd(builddir);
  try
    if exist('htmlreport.m') ~= 2
      disp('Cannot find file ''htmlreport'' in RTW build directory.');
      return;
    end
    htmlreport;
  end
  cd(savedpwd);
