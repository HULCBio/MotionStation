function value = ismstruct(proj)
%ISMSTRUCT True for a MSTRUCT projection structure.
%
%   VALUE = ISMSTRUCT(PROJ) returns 1 if PROJ contains mstruct projection
%   fields, 0 otherwise.
%
%   See also ISGEOTIFF, ISVALIDPROJ.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/08/01 18:24:22 $

fieldNames = {'falsenorthing',  ...
              'falseeasting',  ...
              'geoid', ...
              'mapprojection',  ...
              'origin',  ...
              'scalefactor'};
value = isValidProj(proj, fieldNames);

