function I = checkerboard(varargin)
%CHECKERBOARD Create checkerboard image.
%   I = CHECKERBOARD creates a checkerboard image composed of squares that
%   have 10 pixels per side. The light squares on the left half of the
%   checkerboard are white. The light squares on the right half of the
%   checkerboard are gray.
%
%   I = CHECKERBOARD(N) creates a checkerboard where each square has N
%   pixels per side.
%
%   I = CHECKERBOARD(N,P,Q) creates a rectangular checkerboard. There are P
%   rows of TILE and Q columns of TILE. TILE = [DARK LIGHT; LIGHT DARK]
%   where DARK and LIGHT are squares with N pixels per side. If you omit Q,
%   it defaults to P and the checkerboard is square.
%
%   The CHECKERBOARD function is useful for creating test images for
%   geometric operations.
%   
%   Examples
%   --------
%       I = checkerboard(20);
%       imview(I)
%
%       J = checkerboard(10,2,3);
%       imview(J)
%
%       K = (checkerboard > 0.5); % creates a black and white checkerboard
%       imview(K)
%
%  See also CP2TFORM, IMTRANSFORM, MAKETFORM.


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.9.4.2 $  $Date: 2003/05/03 17:50:17 $

%   Input-output specs
%   ------------------ 
%   N,P,Q:    scalar positive integers 
%
%   I:        real double 2D matrix

[n, p, q] = ParseInputs(varargin{:});

black = zeros(n);
white = ones(n);
tile = [black white; white black];
I = repmat(tile,p,q);

% make right half plane have light gray tiles
ncols = size(I,2);
midcol = ncols/2 + 1; 
I(:,midcol:ncols) = I(:,midcol:ncols) - .3;
I(I<0) = 0;

%-------------------------------
% Function  ParseInputs
%
function [n, p, q] = ParseInputs(varargin)

% defaults
n = 10;
p = 4;
q = p;

checknargin(0,3,nargin,mfilename);

varNames={'N', 'P', 'Q'};
for x = 1:1:length(varargin)
    checkinput(varargin{x}, {'numeric'}, {'integer' 'real' 'positive' 'scalar'}, ...
               mfilename,varNames{x},x);
end

switch nargin
  case 0
    % I = CHECKERBOARD
    return;
    
  case 1
    % I = CHECKERBOARD(N)
    n = varargin{1};

  case 2
    % I = CHECKERBOARD(N,P)
    n = varargin{1};
    p = varargin{2};
    q = p;

  case 3
    % I = CHECKERBOARD(N,P,Q)
    n = varargin{1};
    p = varargin{2};    
    q = varargin{3};    
end

n = double(n);
p = double(p);
q = double(q);
