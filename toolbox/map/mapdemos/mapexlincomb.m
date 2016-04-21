function J = mapexlincomb(I, in, out)
%MAPEXLINCOMB Apply a piecewise-linear curve to adjust an image.
%
%   J = MAPEXLINCOMB(I, IN, OUT) maps the values in intensity image I 
%   to new values in J such that values in vector IN map to values in
%   vector OUT.
%
%   See also IMLINCOMB (Image Processing Toolbox).

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:54:53 $

% Check inputs
if ((~isequal(size(in), size(out))) && ...
   (~isequal(size(in), numel(in))))
    error('map:mapexlincomb:invalidVector', ...
          'Input and output values must be vectors.')
end

diff_in = diff(in);
diff_out = diff(out);
if ((~isequal(diff_in, abs(diff_in))) || ...
   (~isequal(diff_out, abs(diff_out))))
   error('map:mapexlincomb:invalidOutputValues', ...
         'Input and output values must be monotonically increasing.')
end

J = I;
for p = 1:(numel(in) - 1)
    mask = find((I >= in(p)) & (I < in(p + 1)));
    scale = (out(p + 1) - out(p)) / (in(p + 1) - in(p));
    J(mask) = imlincomb(scale, (I(mask) - in(p)), out(p));
end
