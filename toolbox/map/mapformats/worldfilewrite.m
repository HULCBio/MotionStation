function worldfilewrite(R, worldfilename)
%WORLDFILEWRITE Construct a worldfile from a referencing matrix.
%   WORLDFILEWRITE(R, WORLDFILENAME) calculates the worldfile entries
%   corresponding to a referencing matrix R and writes them into the 
%   file WORLDFILENAME. 
%
%   R is a 3 x 2 affine transformation matrix that is used in PIX2MAP
%   and MAP2PIX to transform pixel row and column coordinates to/from 
%   map/model coordinates according to [x y] = [row col 1] * R.
%
%   For example,
%
%      R = worldfileread('concord_ortho_w.tfw');
%      worldfilewrite(R, 'concord_ortho_w_test.tfw');
%
%   constructs the referencing matrix R from concord_ortho_w.tfw,
%   then reconstructs a copy of the worldfile from R.
%
%   See also GETWORLDFILENAME, PIX2MAP, MAP2PIX, WORLDFILEREAD.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.10.3 $  $Date: 2004/02/01 22:01:34 $

% Verify 2 input arguments
error(nargchk(2,2,nargin));

% Check and validate input arguments.
error(checkinputs(R, worldfilename));

% Try to open the output worldfilename
fid = fopen(worldfilename, 'w');
if fid == -1
    error('Unable to open the file ''%s'' for writing.',worldfilename);
end

% Transform R into W 
% (see MAKEREFMAT.M for complete documentation of Cinv and W)
Cinv = [0  1  1;...
        1  0  1;...
        0  0  1];
W = R' * Cinv;

% Write W to the worldfile
count = fprintf(fid, '%20.8f\n', W);

% Close the worldfile
fclose(fid);

%--------------------------------------------------------------------------

function msg = checkinputs(R, worldfilename)
% Validates and checks the input arguments.
msg = [];

% Verify that the size of R is 3-by-2 
if any(size(R) ~= [3 2])
    msg = 'R must be a 3-by-2 matrix.'; return;
end

% Verify that R is numeric and real
if ~(isnumeric(R) && isreal(R))
    msg = 'R must contain real numbers.'; return;
end

% Check worldfilename argument.
if ~ischar(worldfilename)
    msg = 'WORLDFILENAME must be a string.'; return;
end

% Verify that the worldfilename is not a directory
if exist(worldfilename, 'dir')
    msg = sprintf('The input worldfilename ''%s'' is a directory.', worldfilename);
    return;
end

