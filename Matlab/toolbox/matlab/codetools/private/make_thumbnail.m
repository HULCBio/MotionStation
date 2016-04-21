function out = make_thumbnail(in,out_size)
%MAKE_THUMBNAIL Make thumbnail from image.
%   RGB2 = MAKE_THUMBNAIL(RGB1,OUT_SIZE) shrinks the uint8 image RGB1.
%   OUT_SIZE is a two-element vector specifying the desired number of
%   rows and columns.
%
%   Example
%   -------
%   plot(1:10)      
%   f = getframe;
%   thumb = make_thumbnail(f.cdata,[64 64]);

% Copyright 1984-2003 The MathWorks, Inc.

% If it is grayscale, convert it to RGB.
if (size(in,3) == 1)
    in = cat(3,in,in,in);
end

% Convert to double and preallocate the output.
in = double(in);

% Shrink each component along the columns.
temp = zeros(out_size(1), size(in,2), 3);
for k = 1:3
    temp(:,:,k) = shrink_columns(in(:,:,k), out_size(1));
end

% Shrink each component along the rows.
out = zeros([out_size 3]);
for k = 1:3
    out(:,:,k) = shrink_columns(temp(:,:,k)', out_size(2))';
end

% Round and convert back to uint8.
out = uint8(round(out));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = shrink_columns(in, Mout)
%SHRINK_COLUMNS Shrink matrix vertically.
%   OUT = SHRINK_COLUMNS(IN, M_OUT) resizes the matrix IN so that it has
%   M_OUT columns.  M_OUT must be smaller than SIZE(IN,1).
%   SHRINK_COLUMNS automatically applies an anti-aliasing filter and uses
%   bilinear interpolation.


filter_length = 11;
scale = Mout / size(in,1);
b = design_filter(11, scale)';

% Pad input, duplicating first and last rows.  This is to avoid making
% the edges look dark because of the operation of the filter near the
% edge.

pad_length = floor(filter_length/2);
in = [in(ones(pad_length,1),:) ; in ; in(end*ones(pad_length,1),:)];

% Apply the 1-d anti-aliasing filter along the columns.
in = conv2(in, b, 'valid');

% Interpolate along the columns.
yi = linspace(1,size(in,1),Mout)';
out = interp1(in, yi);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function b = design_filter(N,Wn)
% Modified from SPT v3 fir1.m and hanning.m first creates only first half
% of the filter  and later mirrors it to the other half

odd = rem(N,2);
vec = [1:floor(N/2)];
vec2 = pi*(vec-(1-odd)/2);

wind = .54-.46*cos(2*pi*(vec-1)/(N-1));
b = [fliplr(sin(Wn*vec2)./vec2).*wind Wn];    % first half is ready
b = b([vec floor(N/2)+[1:odd] fliplr(vec)]);  % entire filter
b = b/abs(polyval(b,1));                      % norm
