function out = openother(name)
%OPENOTHER    Default action to open unrecognized file types
%   This is a helper function for OPEN.M.
%
%   OPENOTHER(NAME), where NAME contains a string, is called by OPEN to if
%   the appropriate helper function OPENEXT is not found.
%
%   OPENOTHER opens the file NAME using the MATLAB Editor.  To override this
%   behavior, modify this file and save a copy on the MATLAB path ahead of
%   this file.
%
%   See also OPEN.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.12 $  $Date: 2002/04/10 17:05:07 $

% to import files by default, uncomment the following line
%out = uiimport(name);

% to edit files by default, uncomment the following line
out = []; edit(name);
