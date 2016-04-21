function [rout,g,b] = ind2rgb(a,cm)
%IND2RGB Convert indexed image to RGB image.
%   RGB = IND2RGB(X,MAP) converts the matrix X and corresponding
%   colormap MAP to RGB (truecolor) format.
%
%   Class Support
%   -------------
%   X can be of class uint8, uint16, or double. RGB is an 
%   M-by-N-by-3 array of class double.
%
%   See also IND2GRAY, RGB2IND (in the Image Processing Toolbox).

%   Clay M. Thompson 9-29-92
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/06/17 13:37:57 $

if ~isa(a, 'double')
    a = double(a)+1;    % Switch to one based indexing
end

error(nargchk(2,2,nargin));

% Make sure A is in the range from 1 to size(cm,1)
a = max(1,min(a,size(cm,1)));

% Extract r,g,b components
r = zeros(size(a)); r(:) = cm(a,1);
g = zeros(size(a)); g(:) = cm(a,2);
b = zeros(size(a)); b(:) = cm(a,3);

if nargout==3,
  rout = r;
else
  rout = zeros([size(r),3]);
  rout(:,:,1) = r;
  rout(:,:,2) = g;
  rout(:,:,3) = b;
end
  
