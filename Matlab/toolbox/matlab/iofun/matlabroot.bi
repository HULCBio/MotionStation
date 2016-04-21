function rootDir = matlabroot
%MATLABROOT Root directory of MATLAB installation.
%   S = MATLABROOT returns a string that is the name of the directory
%   where the MATLAB software is installed.
%
%   MATLABROOT is used to produce platform dependent paths
%   to the various MATLAB and toolbox directories.
%
%   Example
%      fullfile(matlabroot,'toolbox','matlab','general','')
%   produces a full path to the toolbox/matlab/general directory that
%   is correct for platform it's executed on.
%
%   See also FULLFILE, PATH, TEMPDIR, PREFDIR.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.9.4.1 $  $Date: 2004/03/26 13:26:30 $

rootDir = getenv('MATLAB');
