function map = encodem(map,seedmat,stopvals)

%ENCODEM  Fills in indexed maps with specified seeds
%
%  map = ENCODEM(map,seedmat) will flood fill seeds in a
%  matrix map up to specified boundaries.  This process allows
%  indexed maps to be quickly created.  The seed location and value are
%  specified by the input seedmat, which is [row, col, value]
%  output from GETSEEDS.  The flood fill process continues until
%  stop values of 1 are encountered.
%
%  map = ENCODEM(map,seedmat,stopvals) continues the flood fill
%  process until any value in the input vector stopvals are 
%  encountered.
%
%  See also GETSEEDS

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%  $Revision: 1.10.4.1 $  $Date: 2003/08/01 18:16:08 $

%  Argument input tests

if nargin < 2;           error('Incorrect number of arguments')
    elseif nargin == 2;  stopvals = 1;
end

%  Argument error tests

if size(seedmat,2) ~= 3
    error('Input seed matrix must have three columns')
elseif any(seedmat(:,1) > size(map,1)) | any(seedmat(:,2) > size(map,2))
    error('Seed locations exceed size of map')
elseif any(seedmat(:,[1 2]) <= 0)
    error('Seed locations must be greater than zero')
end

%  Define the floodfill connections for all maps (8 connection map).

connect = 8;

%  Split the seed matrix into its component columns

row = seedmat(:,1);      col = seedmat(:,2);     val = seedmat(:,3);

%  Determine the locations of the blocks of identical seed values.
%  The function floodfill requires a scalar seed value (It's not
%  straightforward to vectorize this part of floodfill -- I tried EVB).
%  So, the most efficient use of floodfill is to group all like seeds
%  together and then call floodfill with all these locations.  Floodfill
%  does allow vectors of seed locations, but they all must have the
%  same seed.

[val,indx] = sort(val);
row = row(indx);   col = col(indx);

newvalLoc = find(diff(val));            %  Will be empty if all seeds are same
newvalLoc = [newvalLoc; length(val)];   %  Add length(val) to always get last group


%  The for loop below is commented out because FLOODFILL is not
%  correctly supporting vectorized row, col entries (4/10/96).  When
%  this is fixed, then use the vectorized approach (instead of the
%  second for loop) because this will require less looping in the
%  vectored row, col approach.  EVB

%for i = 1:length(newvalLoc)             %  Fill each unique seed
%     if i == 1;   startloc = 1;
%	    else;     startloc = newvalLoc(i-1)+1;
%     end

%	 endloc = newvalLoc(i);

%     map = floodfill(map,row(startloc:endloc),col(startloc:endloc),...
%	                 connect,val(startloc),stopvals);
%end

for i = 1:length(row)             %  Loop one seed at a time
     map = floodfill(map,row(i),col(i),connect,val(i),stopvals);
end


%*********************************************************************
%*********************************************************************
%*********************************************************************


function [J,Jidx,cout]=floodfill(I,r,c,style,seedval,stopval)
%FLOODFILL Image flood fill.
%       J=FLOODFILL(I,R,C) performs a flood-fill operation on the
%       input image I, given the starting pixel location (R,C).
%       By default, the fill is performed assuming that the
%       foreground is 8-connected.  FLOODFILL(I,R,C,N) performs
%       the fill assuming that the foreground is N-connected (N
%       can be 4 or 8).
%
%       FLOODFILL(I,R,C,N,SEEDVAL) fills with the value SEEDVAL
%       rather than 1.
%
%       FLOODFILL(I,R,C,N,SEEDVAL,STOPVAL) uses the values in the
%       vector STOPVAL, in addition to SEEDVAL, to indicate fill
%       boundaries.
%
%       [J,IDX]=IMFLOOD(...) returns in IDX a vector containing
%       linear indices of the pixels that have been filled,
%       including boundary pixels.  [J,ROUT,COUT]=IMFLOOD(...)
%       returns in ROUT and COUT the row-column coordinates of
%       the pixels that have been filled.
%
%       See also ROIPOLY.

%  Written by:  Steven L. Eddins, November 1995

error(nargchk(3,6,nargin));

if (nargin < 4)
  style = 8;
else
  if ((style ~= 4) & (style ~= 8))
    error('STYLE must be 4 or 8.');
  end
end
if (nargin < 5);    seedval = 1;     end
if (nargin < 6);    stopval = 1;     end

if length(seedval) > 1;  error('Scalar seed value required');  end

stopval = union(seedval,stopval);
if (ismember(I(r,c), stopval))
  J = I;     rout = [];     cout = [];  % Start pixel is already a stopval
  return;
end

[M,N] = size(I);
Ip = stopval(1)*ones(M+2,N+2);
Ip(2:M+1,2:N+1) = I;
Jp = zeros(size(Ip));
r = r+1;
c = c+1;

if (style == 4)
  % N NE E SE S SW W NW
  idxOffsets = [-1 M+1 M+2 M+3 1 -M-1 -M-2 -M-3];
elseif (style == 8)
  % N E S W
  idxOffsets = [-1 M+2  1 -M-2];
else
  error('Invalid input value for STYLE.');
end

nextIdxList = r + (c-1)*(M+2);
Jp(r,c) = seedval;

numStopVals = prod(size(stopval));

while (~isempty(nextIdxList))
  idxList = [];
  for offset = idxOffsets
    idx = nextIdxList + offset;
    for k = 1:numStopVals
      if ~isempty(idx)
          idx((Jp(idx) == stopval(k)) | (Ip(idx) == stopval(k))) = [];
      end
    end
    Jp(idx) = seedval;
	if ~isempty(idx);  idxList = [idxList ; idx];  end
  end
  nextIdxList = idxList;
end

Jp = Jp(2:M+1,2:N+1);
Jidx = find(Jp);
J = I;
J(Jidx) = Jp(Jidx);

if (nargout == 3)
  [Jidx,cout] = find(J);
end

