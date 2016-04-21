function [epsgDirName, projDirName] = getprojdirs(varargin)
%GETPROJDIRS Return the EPSG and proj directories.
%
%   [espgDirName, projDirName] = GETPROJDIRS returns the default EPSG and
%   PROJ directories.
%
%   [espgDirName, projDirName] = GETPROJDIRS(EPSGFILENAME, PROJFILENAME)
%   returns  the EPSG and PROJ directories, from an EPSGFILENAME and a
%   PROJFILENAME.
%
%   See also GEOTIFFINFO, PROJ4FWD, PROJ4INV.

%   Copyright 1996-2004  The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/23 19:09:41 $

% Obtain the EPSG and PROJ directories
if nargin ~= 2
  if isdeployed
    % <CTFDIR>
    pathstr = fileparts(which('mapproj/vgrint1.m'));
  else
    % <matlabroot>/toolbox/map/mapproj
    pathstr = fullfile(matlabroot,'toolbox','map','mapproj');
  end
    % <pathstr>/projdata/epsg_csv/pcs.csv
    epsgFile = fullfile(pathstr,'projdata','epsg_csv','pcs.csv');
    % <pathstr>/projdata/proj/proj_def.dat
    projFile = fullfile(pathstr,'projdata','proj','proj_def.dat');
else
    epsgFile = varargin{1};
    projFile = varargin{2};
end
epsgDirName = checkprojdir(epsgFile);
projDirName = checkprojdir(projFile);

%--------------------------------------------------------------------------
function dirName = checkprojdir(fname)
% Obtain the directory name from the input filename 
%
% Set the default dirName to an empty string.
%  NOTE: The GeoTIFF and PROJ.4 libraries will check
%  the directory names for empty if checkfilename
%  returns with an error, ie if the projdata is not
%  found on the path. If the directory name is empty
%  the libraries will attempt to use MATLABROOT
%  and the hardwired pathname for the location of the
%  proj data files.
dirName = '';
try
    fileName = checkfilename(fname, mfilename, 1);
    dirName  = fileparts(fileName);
end

