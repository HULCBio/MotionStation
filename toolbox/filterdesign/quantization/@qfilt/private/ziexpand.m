function zcell = ziexpand(zi,ndata, statespersection, numberofsections)
%ZIEXPAND Expand initial conditions
%   ZI = ZIEXPAND(Hq, X, ZI)
%
%   EXPANSION RULES.
%  
%   In the following, the term matrix means that it may be a scalar, a vector,
%   or a matrix.
%
%   If zi is numeric, do the numeric expansion followed by expanding to a
%   cell array.
%
%   If zi is a cell array, expand each element of zi.
%
%
%   Let x, z be vectors, X, Z be matrices, h, h1, h2, ... be cell arrays
%   containing filter coefficients.  
%   x, {h}           ndata=1, numberofsections=1, zi = {z}
%   x, {h1,h2,...}   ndata=1, numberofsections>1, zi = {z1, z2, ...}
%   X, {h}           ndata>1, numberofsections=1, zi = {Z}
%   X, {h1,h2,...}   ndata>1, numberofsections>1, zi = {Z1, Z2, ...}
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NUMERIC EXPANSION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% zi is empty.  Set zi=0 and do the numeric scalar case.
%
% zi is a numeric scalar.  Scalar expand to a vector or matrix.
%
% zi is a numeric vector.  Leave as a vector or expand to a matrix.  Error if
% length(zi) is not equal to statespersection(k) for k=1:numberofsections.  If
% X, zi = z is a row or column vector, then verify that z is the right length,
% and [m,n]=size(X), and let z=z(:), zi = z(:, ones(1,n)).
%
% zi is a 2-D matrix.  Leave as a matrix.  Error if size(zi,1) is not equal to
% statespersection(k) for k=1:numberofsections.
%
% The numeric expansion routines each have their own subfunctions.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CELL ARRAY EXPANSION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Expand a numeric array to a cell array of the right size.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ZI STARTS AS A CELL ARRAY.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% zi is a cell array.  Expand each element of zi using the numeric expansion
% routines.  Error if the length of zi is not equal to numberofsections.  zi must be
% one-dimensional.
%

%   Thomas A. Bryan, 14 July 1999
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $  $Date: 2004/04/12 23:26:03 $

% If the input is empty, then return the final conditions equal to the
% initial conditions (scalar expanded if necessary).
% [y,zf] = filter(Hq,[],zi)
ndata = max(ndata,1);

if iscell(zi)
  zcell = zicell(zi,statespersection,numberofsections,ndata);
elseif isnumeric(zi)
  zcell = cell(1,numberofsections);
  for k=1:numberofsections
    zcell{k} = zinumericexpand(zi,statespersection(k),ndata);
  end
else
  error('ZI must be numeric or a cell array of numeric.')
end
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function zcell = zicell(zcell,statespersection,numberofsections,ndata)
if ~privisvector(zcell)
  error('Cell array ZI must be 1-dimensional.');
end
if length(zcell)~=numberofsections
  error('Length of cell array ZI must be NumberOfSections')
end
for k=1:numberofsections
  zcell{k} = zinumericexpand(zcell{k},statespersection(k),ndata);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function zi = zinumericexpand(zi,statespersection,ndata);
if ~isnumeric(zi)
  error('ZI must be numeric or a cell array of numeric.')
end

if isempty(zi)
  zi = 0;
end
if isscalar(zi)
  zi = ziscalarexpand(zi,statespersection,ndata);
elseif privisvector(zi)
  zi = zivectorexpand(zi,statespersection,ndata);
elseif ismatrix(zi)
  zi = zimatrixexpand(zi,statespersection,ndata);
else
  error('ZI must be empty, scalar, or matrix, or a cell array of same.');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function zi = ziscalarexpand(zi,statespersection,ndata)
zi = zi(ones(statespersection,ndata));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function zi = zivectorexpand(zi,statespersection,ndata)
% When zi is a vector, always treat it as the initial condition vector for
% every dimension being filtered.
zi = zi(:);
if length(zi)~=statespersection
  error('Wrong number of states in ZI.');
end
zi = zi(:,ones(1,ndata));
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function zi = zimatrixexpand(zi,statespersection,ndata)
% Just do error checking if it's already a matrix.
[m,n] = size(zi);
if n~=ndata
  error(['Number of columns of ZI must equal the number of dimensions being' ...
        ' filtered.'])
end
if m~=statespersection
  error('Wrong number of states in ZI.');
end


