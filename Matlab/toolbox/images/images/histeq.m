function [out,T] = histeq(a,cm,hgram)
%HISTEQ Enhance contrast using histogram equalization.
%   HISTEQ enhances the contrast of images by transforming the
%   values in an intensity image, or the values in the colormap
%   of an indexed image, so that the histogram of the output
%   image approximately matches a specified histogram.
%
%   J = HISTEQ(I,HGRAM) transforms the intensity image I so that 
%   the histogram of the output image J with length(HGRAM) bins 
%   approximately matches HGRAM.  The vector HGRAM should contain 
%   integer counts for equally spaced bins with intensity values 
%   in the appropriate range: [0,1] for images of class double, 
%   [0,255] for images of class uint8, and [0,65535] for images 
%   of class uint16. HISTEQ automatically scales HGRAM so that
%   sum(HGRAM) = prod(size(I)). The histogram of J will better
%   match HGRAM when length(HGRAM) is much smaller than the
%   number of discrete levels in I.
%
%   J = HISTEQ(I,N) transforms the intensity image I, returning
%   in J an intensity image with N discrete levels. A roughly
%   equal number of pixels is mapped to each of the N levels in
%   J, so that the histogram of J is approximately flat. (The
%   histogram of J is flatter when N is much smaller than the
%   number of discrete levels in I.) The default value for N is
%   64.
%
%   [J,T] = HISTEQ(I) returns the gray scale transformation that
%   maps gray levels in the intensity image I to gray levels in
%   J.
%
%   NEWMAP = HISTEQ(X,MAP,HGRAM) transforms the colormap
%   associated with the indexed image X so that the histogram of
%   the gray component of the indexed image (X,NEWMAP)
%   approximately matches HGRAM. HISTEQ returns the transformed
%   colormap in NEWMAP. length(HGRAM) must be the same as
%   size(MAP,1).
%
%   NEWMAP = HISTEQ(X,MAP) transforms the values in the colormap
%   so that the histogram of the gray component of the indexed
%   image X is approximately flat. It returns the transformed
%   colormap in NEWMAP.
%
%   [NEWMAP,T] = HISTEQ(X,...) returns the gray scale
%   transformation T that maps the gray component of MAP to the
%   gray component of NEWMAP.
%
%   Class Support
%   -------------
%   For syntaxes that include an intensity image I as input, I
%   can be of class uint8, uint16, or double, and the output 
%   image J has the same class as I. For syntaxes that include 
%   an indexed image X as input, X can be of class uint8 or 
%   double; the output colormap is always of class double. 
%   Also, the optional output T (the gray level transform) 
%   is always of class double.
%
%   Example
%   -------
%   Enhance the contrast of an intensity image using histogram
%   equalization.
%
%       I = imread('tire.tif');
%       J = histeq(I);
%       imview(I), imview(J)
%
%   See also ADAPTHISTEQ, BRIGHTEN, IMADJUST, IMHIST.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 5.18.4.3 $  $Date: 2003/05/03 17:50:34 $

checknargin(1,3,nargin,mfilename);
checkinput(a,'uint8 uint16 double','nonsparse 2d',mfilename,'I',1);

NPTS = 256;

if nargin==1, % Histogram equalization of intensity image
    n = 64; % Default n
    hgram = ones(1,n)*(prod(size(a))/n);
    n = NPTS;
    kind = 1;
elseif nargin==2,
    if prod(size(cm))==1,  
        % histeq(I,N); Histogram equalization of intensity image
        m = cm;
        hgram = ones(1,m)*(prod(size(a))/m);
        n = NPTS;
        kind = 1;
    elseif size(cm,2)==3 & size(cm,1)>1,
        % histeq(X,map); Histogram equalization of indexed image
        n = size(cm,1);
        hgram = ones(1,n)*(prod(size(a))/n);
        kind = 2;
        if isa(a, 'uint16')
            msg = 'Histogram equalization of UINT16 indexed images is not supported.';
            eid = sprintf('Images:%s:unsupportedUint16IndexedImages',mfilename);
            error(eid, msg);
        end
    else,       
        % histeq(I, HGRAM); Histogram modification of intensity image
        hgram = cm;
        n = NPTS;
        kind = 1;
    end
else,   % Histogram modification of indexed image
    n = size(cm,1);
    if length(hgram)~=n, 
        msg = 'HGRAM must be the same size as MAP.';
        eid = sprintf('Images:%s:HGRAMmustBeSameSizeAsMAP',mfilename);
        error(eid, msg);
    end
    kind = 2;
    if isa(a, 'uint16')
        msg = 'Histogram equalization of UINT16 indexed images is not supported.';
        eid = sprintf('Images:%s:unsupportedUint16IndexedImages',mfilename);
        error(eid, msg);
    end
end

if min(size(hgram))>1, 
    msg = 'HGRAM must be a vector.';
    eid = sprintf('Images:%s:hgramMustBeAVector',mfilename);
    error(eid, msg);
end

% Normalize hgram 
hgram = hgram*(prod(size(a))/sum(hgram));       % Set sum = prod(size(a))
m = length(hgram);

% Compute cumulative histograms
if kind==1,
    nn = imhist(a,n)';
    cum = cumsum(nn);
else
    % Convert image to equivalent gray image
    I = ind2gray(a,cm);
    nn = imhist(I,n)';
    cum = cumsum(nn);
end
cumd = cumsum(hgram*prod(size(a))/sum(hgram));

% Create transformation to an intensity image by minimizing the error
% between desired and actual cumulative histogram.
tol = ones(m,1)*min([nn(1:n-1),0;0,nn(2:n)])/2;
err = (cumd(:)*ones(1,n)-ones(m,1)*cum(:)')+tol;
d = find(err < -prod(size(a))*sqrt(eps));
if ~isempty(d), err(d) = prod(size(a))*ones(size(d)); end
[dum,T] = min(err);
T = (T-1)/(m-1); 

if kind == 1, % Modify intensity image
    b = grayxform(a, T);
else % Modify colormap by extending the (r,g,b) vectors.

  % Compute equivalent colormap luminance
  ntsc = rgb2ntsc(cm);

  % Map to new luminance using T, store in 2nd column of ntsc.
  ntsc(:,2) = T(floor(ntsc(:,1)*(n-1))+1)';

  % Scale (r,g,b) vectors by relative luminance change
  map = cm.*((ntsc(:,2)./max(ntsc(:,1),eps))*ones(1,3));

  % Clip the (r,g,b) vectors to the unit color cube
  map = map ./ (max(max(map')',1)*ones(1,3));
end

if nargout==0,
    if kind==1, 
        imshow(b,n); 
    else, 
        imshow(a,map), 
    end
    return
end

if kind==1, 
    out = b;
else 
    out = map; 
end
