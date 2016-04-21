function [X,map,alpha] = readpng(filename, varargin)
%READPNG Read an image from a PNG file.
%   [X,MAP] = READPNG(FILENAME) reads the image from the
%   specified file.
%
%   [X,MAP] = READPNG(FILENAME,'BackgroundColor',BG) uses the
%   specified background color for compositing transparent
%   pixels.  By default, READPNG uses the background color
%   specified in the file, if present.  If not present, the
%   default is either the first colormap color or black.  If the
%   file contains an indexed image, BG must be an integer in the
%   range [1,P] where P is the colormap length.  If the file
%   contains a grayscale image, BG must be an integer in the
%   range [0,65535].  If the file contains an RGB image, BG must
%   be a 3-element vector whose values are in the range
%   [0,65535].
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:04:50 $

bg = [];

% Process param/value pairs
propStrings = 'backgroundcolor';
    
for k = 1:2:length(varargin)
    prop = lower(varargin{k});
    if (~ischar(prop))
        error('MATLAB:readpng:badParameter', ...
              'Parameter name must be a string');
    end
    idx = strmatch(prop, propStrings);
    if (isempty(idx))
        error('MATLAB:readpng:badParameter', ...
              'Unrecognized parameter name "%s"', prop);
    elseif (length(idx) > 1)
        error('MATLAB:readpng:badParameter', ...
              'Ambiguous parameter name "%s"', prop);
    end
    
    prop = deblank(propStrings(idx,:));
    
    switch prop
        case 'backgroundcolor'
            bg = varargin{k+1};
    end
end

if (isempty(bg) && (nargout >= 3))
    % User asked for alpha and didn't specify a background
    % color; in this case we don't perform the compositing.
    bg = 'none';
end

alpha = [];
[X,map] = png('read',filename, bg);
X = permute(X, ndims(X):-1:1);
if (ismember(size(X,3), [2 4]))
    alpha = X(:,:,end);
    % Strip the alpha channel off of X.
    X = X(:,:,1:end-1);
end

