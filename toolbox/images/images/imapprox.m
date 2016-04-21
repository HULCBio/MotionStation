function [cout,map] = imapprox(a,cm,n,flag)
%IMAPPROX Approximate indexed image by one with fewer colors.
%   [Y,NEWMAP] = IMAPPROX(X,MAP,N) approximates the colors in the
%   indexed image X and associated colormap MAP by using minimum
%   variance quantization. IMAPPROX returns indexed image Y with
%   colormap NEWMAP, which has at most N colors.
%
%   [Y,NEWMAP] = IMAPPROX(X,MAP,TOL) approximates the colors in X
%   and MAP through uniform quantization. NEWMAP contains at most
%   (FLOOR(1/TOL)+1)^3 colors.  TOL must be between 0 and 1.0.
%
%   Y = IMAPPROX(X,MAP,NEWMAP) approximates the colors in MAP by
%   using colormap mapping to find the colors in NEWMAP that best
%   match the colors in MAP.
%
%   Y = IMAPPROX(...,DITHER_OPTION) enables or disables
%   dithering. DITHER_OPTION is a string that can have one of
%   these values:
%
%       'dither'   dithers, if necessary, to achieve better color
%                  resolution at the expense of spatial
%                  resolution (default)
%
%       'nodither' maps each color in the original image to the
%                  closest color in the new map. No dithering is
%                  performed.
%
%   Class Support
%   -------------
%   The input image X can be of class uint8, uint16, or double. 
%   The output image Y is of class uint8 if the length of NEWMAP 
%   is less than or equal to 256. If the length of NEWMAP is 
%   greater than 256, Y is of class double.
%
%   Example
%   -------
%   Approximate the indexed image trees.tif by another indexed image
%   containing only 16 colors.
%
%       [X, map] = imread('trees.tif');
%       [Y, newmap] = imapprox(X, map, 16);
%       imview(Y, newmap)
%
%   See also CMUNIQUE, DITHER, RGB2IND.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 5.21.4.3 $  $Date: 2003/08/23 05:52:23 $

%   Obsolete syntax:
%   [Y,NEWMAP] = IMAPPROX(X,MAP) uniformly removes colors
%   from the colormap if necessary so that NEWMAP has fewer
%   than 256 colors.  The removed colors are approximated
%   by other colors in the colormap.

checknargin(2,4,nargin,mfilename);

if nargin==2, % imapprox(a,cm) (remove colors)
  msg='IMAPPROX(X,MAP) is an obsolete syntax. Specify additional parameters.';
  wid=sprintf('Images:%s:obsoleteSyntax',mfilename);
  warning(wid,msg);
  if size(cm,1)<=256,
    c = a; map = cm;
  else
    n = size(cm,1)-256; 
    ndx = floor((1:n)/(n+1)*size(cm,1)+1);
    map = cm; map(ndx,:) = [];
    rgb = ind2rgb(a,cm);
    c = dither(rgb,map);
  end

elseif ischar(n), % imapprox(a,cm,'dither_option')
  flag = [lower(n) ' ']; % Protect against short string
  if size(cm,1)<=256,
    c = a; map = cm;
  elseif flag(1)=='n', % 'nodither'
    n = size(cm,1)-256; 
    ndx = floor((1:n)/(n+1)*size(cm,1)+1);
    map = cm; map(ndx,:) = [];

    % Manhattan Distance to colors in reduced colormap
    M = size(map,1); N = length(ndx);
    [v,loc] = min(abs(repmat(map(:,1),1,N)-repmat(cm(ndx,1)',M,1)) + ...
                  abs(repmat(map(:,2),1,N)-repmat(cm(ndx,2)',M,1)) + ...
                  abs(repmat(map(:,3),1,N)-repmat(cm(ndx,3)',M,1)));
    dpos = ones(size(cm,1),1); 
    dpos(ndx) = zeros(size(ndx));
    pos = cumsum(dpos); pos(ndx) = loc;
    if ~isa(a, 'double')   % promotion to double is necessary until we have
        a = im2double(a,'indexed'); % the utility function for uint8 indexing.
    end
    c = reshape(pos(a),size(a));
  else
    n = size(cm,1)-256; 
    ndx = floor((1:n)/(n+1)*size(cm,1)+1);
    map = cm; map(ndx,:) = [];
    rgb = ind2rgb(a,cm);
    c = dither(rgb,map);
  end

elseif numel(n)==1, % imapprox(a,cm,tol) or imapprox(a,cm,n)
  if nargin<4, flag = 'dither'; end
  if n>size(cm,1),
    c = a; map = cm;
  else
    % Convert colormap to RGB so that rgb2ind can do all the work
    rgb(:,:,1) = cm(:,1); rgb(:,:,2) = cm(:,2); rgb(:,:,3) = cm(:,3);

    [ndx,map] = rgb2ind(rgb,n,'n');
    if flag(1)=='n', % 'nodither'
      if ~isa(a, 'double')   % promotion to double is necessary until we have
          a = im2double(a, 'indexed'); % the utility function for uint8 indexing.
      end
      c = reshape(ndx(a), size(a));
    else
      rgb = ind2rgb(a,cm);
      c = dither(rgb,map);
    end
  end

elseif size(n,2)==3, % imapprox(a,cm,map)
  if nargin<4, flag = 'dither'; end
  flag = [lower(flag) ' ']; % Protect against short string
  map = n;
  if flag(1)=='n', % 'nodither'
    % Manhattan Distance to colors in new colormap
    M = size(map,1); N = size(cm,1);
    
    [v,loc] = min(abs(repmat(map(:,1),1,N)-repmat(cm(:,1)',M,1)) + ...
                  abs(repmat(map(:,2),1,N)-repmat(cm(:,2)',M,1)) + ...
                  abs(repmat(map(:,3),1,N)-repmat(cm(:,3)',M,1)));
    if ~isa(a, 'double')   % promotion to double is necessary until we have
        a = im2double(a,'indexed'); % the utility function for uint8 indexing.
    end
    c = reshape(loc(a),size(a));
  else
    rgb = ind2rgb(a,cm);
    c = dither(rgb,map);
  end    
end

if nargout==0,
  imshow(c,map)
  return
end

if ~isa(c, 'uint8') && size(map,1) <= 256
   c = im2uint8(c, 'indexed');
elseif isa(c, 'uint16')
   c = im2double(c, 'indexed');
end

cout = c;



