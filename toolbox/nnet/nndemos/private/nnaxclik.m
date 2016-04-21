function [f,x,y] = nnaxclik(a,x,y)
%NNAXCLIK Neural Network Design utility function.

%  [F,X,Y] = NNAXCLIK(A)
%    A - Axis handle.
%  Returns:
%    (X,Y) - Coordinates of last click in axis A coordinates.
%   F     - 1 if (X,Y) is in A, otherwise returns 0.
%
% NNAXCLIK(A,X,Y)
% Returns 1 if (X,Y) is in A, otherwise returns 0.

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% First Version, 8-31-95.
% $Revision: 1.7 $

if nargin == 1
  pt = get(a,'currentpoint');
  x = pt(1);
  y = pt(3);
end
xlim = get(a,'xlim');
ylim = get(a,'ylim');
f = (x >= xlim(1)) & (x <= xlim(2)) & (y >= ylim(1)) & (y <= ylim(2));

