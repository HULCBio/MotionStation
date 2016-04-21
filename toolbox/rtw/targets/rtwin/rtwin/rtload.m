function rtload(fname,varargin)
%RTLOAD Load hardware driver manually.
%
%   RTLOAD displays GUI for loading hardware drivers.
%   RTLOAD('driver') loads hardware driver with default settings.
%   RTLOAD('driver',ADDR) loads hardware driver with specific I/O address.
%   RTLOAD('driver',ADDR,PARM) loads hardware driver with specific I/O
%   address and parameters.
%
%   Normally, hardware drivers are loaded automatically before real-time
%   execution starts. Use this function for troubleshooting purposes only.
%
%   See also RTUNLOAD.

%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.12.2.3 $  $Date: 2004/03/21 22:59:24 $  $Author: batserve $


% drivers are located here

drvdir = fullfile(fileparts(fileparts(which(mfilename))), 'drv');

% if no parameters given, offer a list of drivers

if nargin==0

  olddir=cd;    % preserve original working directory
  cd(drvdir);   % change to drivers directory
  [fname,path] = uigetfile('*.rwd','Select a hardware driver');    % display the driver selection GUI
  if ~fname
    return;
  end;
  cd(olddir);  % restore original working directory

  [dummy,fname] = fileparts(fname);       %#ok strip the extension (DUMMY is dummy)
  lastsep = find(path==filesep);          % form the MANUFACTURER/MODEL name
  lastsep = lastsep(end-1);
  fname = [path(lastsep+1:end) fname];
  fname(fname==filesep) = '/';

end;

% check if the driver exists

osfname = fname;
osfname(osfname=='/') = filesep;
if ~exist(fullfile(drvdir,[osfname '.rwd']), 'file')
  error([upper(fname) '.RWD cannot be found in driver directory.']);
end;

% if driver selected from a list, call the driver GUI

if nargin==0
  opt = rtdrvgui('Open',fname);
  if isempty(opt)
    return;
  end;
  varargin{1} = opt(1);
  varargin{2} = opt(2:end);
end

% load the driver, with address and options if specified

rttool('Load',fname,varargin{:});
