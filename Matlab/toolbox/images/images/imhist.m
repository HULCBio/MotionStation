function [yout,x] = imhist(varargin)
%IMHIST Display histogram of image data.
%   IMHIST(I) displays a histogram for the intensity image I whose number of
%   bins are specified by the image type.  If I is a grayscale image, IMHIST
%   uses 256 bins as a default value. If I is a binary image, IMHIST uses
%   only 2 bins.
%
%   IMHIST(I,N) displays a histogram with N bins for the intensity image I
%   above a grayscale colorbar of length N.  If I is a binary image then N
%   can only be 2.
%
%   IMHIST(X,MAP) displays a histogram for the indexed image X. This
%   histogram shows the distribution of pixel values above a colorbar of the
%   colormap MAP. The colormap must be at least as long as the largest index
%   in X. The histogram has one bin for each entry in the colormap.
%
%   [COUNTS,X] = imhist(...) returns the histogram counts in COUNTS and the
%   bin locations in X so that stem(X,COUNTS) shows the histogram. For
%   indexed images, it returns the histogram counts for each colormap entry;
%   the length of COUNTS is the same as the length of the colormap.
%
%   Class Support
%   -------------
%   The input image can be of class uint8, uint16, double, or logical.
%
%   Note
%   ----
%   For intensity images, the N bins of the histogram are each
%   half-open intervals of width A/(N-1).  In particular, the
%   p-th bin is the half-open interval:
%
%        A*(p-1.5)/(N-1)  <= x  <  A*(p-0.5)/(N-1)
%
%   The scale factor A depends on the image class.  A is 1 if
%   the intensity image is double; A is 255 if the intensity
%   image is uint8; and A is 65535 if the intensity image is
%   uint16.
%
%   Example
%   -------
%        I = imread('pout.tif');
%        imhist(I)
%
%   See also HISTEQ, HIST.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 5.24.4.3 $  $Date: 2003/08/23 05:52:32 $

[a, n, isScaled, top, map] = parse_inputs(varargin{:});

if islogical(a)
    if (n ~= 2)
        messageId = 'Images:imhist:invalidParameterForLogical';
        message1 = 'N must be set to two for a logical image.'; 
        error(messageId, '%s', message1);
        return;
    end
    y(2) = sum(a(:));
    y(1) = numel(a) - y(2);
    y = y';
else
    y = imhistc(a, n, isScaled, top); % Call MEX file to do work.
end

classin = class(a);
switch classin
case 'uint8'
    x = linspace(0,255,n)';
case 'uint16'
    x = linspace(0,65535,n)';
case 'double'
    x = linspace(0,1,n)';
case 'logical'
    x = [0,1]';
otherwise
    messageId = 'Images:imhist:invalidImageClass';
    message2 = ['The input image must be uint8, uint16, double, or' ...
                ' logical.'];
    error(messageId,'%s', message2);             
end

if (nargout == 0)
    plot_result(x, y, map, isScaled, classin);
else
    yout = y;
end


%%%
%%% Function plot_result
%%%
function plot_result(x, y, cm, isScaled, classin)

n = length(x);
stem(x,y, 'Marker', 'none')
hs = gca;

limits = axis;
if n ~= 1
  limits(1) = min(x);
else
  limits(1) = 0;
end
limits(2) = max(x);
var = sqrt(y'*y/length(y));
limits(4) = 2.5*var;
axis(limits);

% Get axis position and make room for color stripe.
pos = get(hs,'pos');
stripe = 0.075;
set(hs,'pos',[pos(1) pos(2)+stripe*pos(4) pos(3) (1-stripe)*pos(4)])
set(hs,'xticklabel','')

% Create axis for stripe
axes('Position', [pos(1) pos(2) pos(3) stripe*pos(4)]);
limits = axis;

% Create color stripe
if isScaled,
    binInterval = 1/n;
    xdata = [binInterval/2 1-(binInterval/2)];
    switch classin
     case 'uint8'
        xdata = 255*xdata;
        limits(1) = 0;
        limits(2) = 255;
        C = (1:n)/n;
     case 'uint16'
        xdata = 65535*xdata;
        limits(1) = 0;
        limits(2) = 65535;
        C = (1:n)/n;
     case 'double'
        limits(1) = 0;
        limits(2) = 1;
        C = (1:n)/n;
     case 'logical'
        limits(1) = 0;
        limits(2) = 1;
        C = [0 1];
     otherwise
        messageId = sprintf('Images:%s:invalidImageClass', mfilename);
        message = ['The input image must be uint8, uint16, double, or' ...
                ' logical.'];
        error(messageId, '%s', message);    
    end
    image(xdata,[0 1],repmat(C, [1 1 3]));
else
    if length(cm)<=256
        image([1 n],[0 1],1:n); colormap(cm)
        limits(1) = 0.5;
        limits(2) = n + 0.5;
    else
        image([1 n],[0 1],permute(cm, [3 1 2]));
        limits(1) = 0.5;
        limits(2) = n + 0.5;
    end
end

set(gca,'yticklabel','')
axis(limits);
j=line(limits([1 2 2 1 1]),limits([3 3 4 4 3]));set(j,'linestyle','-')
set(j,'color',get(gca,'xcolor'))

% Put a border around the stripe.
j=line(limits([1 2 2 1 1]),limits([3 3 4 4 3]));set(j,'linestyle','-')
set(j,'color',get(gca,'xcolor'))

% Special code for a binary image
if strcmp(classin,'logical')
    % make sure that the stripe's X axis has 0 and 1 as tick marks.
    set(gca,'XTick',[0 1]);

    % remove unnecessary tick marks from axis showing the histogram
    axes(hs)
    set(gca,'XTick',0);
    
    % make the histogram lines thicker
    h = get(hs,'children');
    obj = findobj(h,'flat','Color','b');
    lineWidth = 10;
    set(obj,'LineWidth',lineWidth);
else
  axes(hs)
end

set(gcf,'Nextplot','replace')


%%%
%%% Function parse_inputs
%%%
function [a, n, isScaled, top, map] = parse_inputs(varargin)

checknargin(1,2,nargin,mfilename);
a = varargin{1};
checkinput(a, {'double','uint8','logical','uint16'}, {'2d'}, mfilename, ['I or ' ...
                    'X'], 1);
n = 256;
isScaled = [];
top = [];
map = [];

if (isa(a,'double'))
    isScaled = 1;
    top = 1;
    map = []; 
    
elseif (isa(a,'uint8'))
    isScaled = 1; 
    top = 255;
    map = [];
    
elseif (islogical(a))
    n = 2;
    isScaled = 1;
    top = 1;
    map = [];
    
else % a must be uint16
    isScaled = 1; 
    top = 65535;
    map = [];
end
    
if (nargin ==2)
    if (numel(varargin{2}) == 1)
        % IMHIST(I, N)
        n = varargin{2};
        checkinput(n, {'numeric'}, {'real','positive','integer'}, mfilename, ...
                   'N', 2);
        
    elseif (size(varargin{2},2) == 3)
        % IMHIST(X,MAP) or invalid second argument
        n = size(varargin{2},1);
        isScaled = 0;
        top = n;
        map = varargin{2};
        
    else
        messageId = sprintf('Images:%s:invalidSecondArgument', mfilename);
        message4 = 'Second argument must be a colormap or a positive integer.';
        error(messageId, '%s', message4); 
    end
end
