function refvec = refmat2vec(R,S)
%REFMAT2VEC Convert a referencing matrix to a referencing vector.
%
%   REFVEC = REFMAT2VEC(R,S) converts a referencing matrix, R, to the 
%   referencing vector REFVEC.  R is a 3-by-2 referencing matrix defining a
%   2-dimensional affine transformation from pixel coordinates to
%   geographic coordinates.  S is the size of the data grid that is being
%   referenced. REFVEC is a 1-by-3 referencing vector with elements
%   [cells/angleunit north-latitude west-longitude].  
%
%   Example 
%   -------
%      % Verify the conversion of the geoid referencing vector to a
%      % referencing matrix.
%      load geoid
%      geoidrefvec
%      R = refvec2mat(geoidrefvec, size(geoid))
%      refvec = refmat2vec(R, size(geoid))
%
%   See also MAKEREFMAT, REFVEC2MAT.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2003/12/13 02:53:05 $ 

% Check if R is a referencing vector
if numel(R) == 3
    try
        refvec = R;
        checkrefvec(refvec,mfilename,'REFVEC',1);
        return
    catch
    end
end

% Check the referencing matrix
checkrefmat(R,mfilename,'R',1);
if (R(1,1) ~= 0) || (R(2,2) ~= 0)
    eid = sprintf('%s:%s:rotationInRefmat', getcomp, mfilename);
    error(eid, 'R must be irrotational.');
end
if R(1,2) <= 0
    eid = sprintf('%s:%s:rowNotIncreasing', getcomp, mfilename);
    msg = sprintf('%s\n%s','Row subscript must increase with latitude.');
    error(eid,msg);
end
if R(2,1) <= 0
    eid = sprintf('%s:%s:colNotIncreasing', getcomp, mfilename);
    msg = sprintf('%s\n%s','Column subscript must increase with longitude.');
    error(eid,msg);
end
if R(1,2) ~= R(2,1)
    eid = sprintf('%s:%s:cellsNotSquare', getcomp, mfilename);
    msg = sprintf('%s\n%s','Grid cells must be square.');
    error(eid,msg);
end

% Check the size
checkinput(S, {'double'}, {'real','vector','finite'}, mfilename,'S',2);

% Calculate refvec
[lat, lon]   = pix2latlon(R, S(1)+.5, .5);
[latm1, tmp] = pix2latlon(R, S(1)-.5, .5);
refvec = [1/(lat-latm1) lat lon ];

