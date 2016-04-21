function R = worldfileread(worldfilename)
%WORLDFILEREAD Read a worldfile and return a referencing matrix.
%   R = WORLDFILEREAD(WORLDFILENAME) reads the worldfile data 
%   from WORLDFILENAME and constructs the referencing matrix, R.
%
%   R is a 3 x 2 affine transformation matrix that is used in PIX2MAP
%   and MAP2PIX to transform pixel row and column coordinates to/from 
%   map/model coordinates according to [x y] = [row col 1] * R.
%
%   Example
%   -------
%      R = worldfileread('concord_ortho_w.tfw');
%
%   See also GETWORLDFILENAME, MAKEREFMAT, PIX2MAP, MAP2PIX,
%            WORLDFILEWRITE.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.10.3 $  $Date: 2004/02/01 22:01:33 $

% Check worldfilename argument.
if ~ischar(worldfilename)
   error('WORLDFILENAME must be a string.');
end

% Verify that the worldfilename is a file
if ~exist(worldfilename, 'file')
    error('The input worldfilename ''%s'' is not a file.', worldfilename);
end

% Initialize R
R = [];

% Try to open the input worldfilename
fid = fopen(worldfilename);
if fid == -1
    error('Unable to open file ''%s''.',worldfilename);
end

% Read W into a 6-element vector
[W, count] = fscanf(fid,'%f',6);
if count ~= 6
    fclose(fid);
    error('Unexpected World File contents.');
end

% Close the worldfile
fclose(fid);

% Transform W into the referencing matrix
R = makerefmat(W);
