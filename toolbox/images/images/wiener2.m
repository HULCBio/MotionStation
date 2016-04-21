function [f,noise] = wiener2(varargin)
%WIENER2 Perform 2-D adaptive noise-removal filtering.
%   WIENER2 lowpass filters an intensity image that has been
%   degraded by constant power additive noise. WIENER2 uses a
%   pixel-wise adaptive Wiener method based on statistics
%   estimated from a local neighborhood of each pixel.
%
%   J = WIENER2(I,[M N],NOISE) filters the image I using
%   pixel-wise adaptive Wiener filtering, using neighborhoods of
%   size M-by-N to estimate the local image mean and standard
%   deviation. If you omit the [M N] argument, M and N default to
%   3. The additive noise (Gaussian white noise) power is assumed
%   to be NOISE.
%
%   [J,NOISE] = WIENER2(I,[M N]) also estimates the additive
%   noise power before doing the filtering. WIENER2 returns this
%   estimate as NOISE.
%
%   Class Support
%   -------------
%   The input image I can be of class uint8, uint16, or double. 
%   The output image J is of the same class as I.
%
%   Example
%   -------
%       RGB = imread('saturn.png');
%       I = rgb2gray(RGB);
%       J = imnoise(I,'gaussian',0,0.005);
%       K = wiener2(J,[5 5]);
%       imview(J), imview(K)
%
%   See also FILTER2, MEDFILT2.

%   The following syntax is grandfathered:
%
%   J = WIENER2(I,[M N],[MBLOCK NBLOCK],NOISE) or [J,NOISE] =
%   WIENER2(I,[M N],[MBLOCK NBLOCK]) processes the intensity
%   image I as above but in blocks of size MBLOCK-by-NBLOCK.  Use
%   J = WIENER2(I,[M N],SIZE(I),NOISE) to process the matrix all
%   at once. 

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 5.18.4.5 $  $Date: 2003/08/23 05:54:48 $

% Uses algorithm developed by Lee (1980).
% Reference: "Two-Dimensional Signal and Image Processing" by 
% Jae S. Lim, pp.536-540.

[g, nhood, noise] = ParseInputs(varargin{:});

classin = class(g);
classChanged = 0;
if ~isa(g, 'double')
  classChanged = 1;
  g = im2double(g);
end

% Estimate the local mean of f.
localMean = filter2(ones(nhood), g) / prod(nhood);

% Estimate of the local variance of f.
localVar = filter2(ones(nhood), g.^2) / prod(nhood) - localMean.^2;

% Estimate the noise power if necessary.
if (isempty(noise))
  noise = mean2(localVar);
end

% Compute result
% f = localMean + (max(0, localVar - noise) ./ ...
%           max(localVar, noise)) .* (g - localMean);
%
% Computation is split up to minimize use of memory
% for temp arrays.
f = g - localMean;
g = localVar - noise; 
g = max(g, 0);
localVar = max(localVar, noise);
f = f ./ localVar;
f = f .* g;
f = f + localMean;

if classChanged,
  f = changeclass(classin, f);
end


%%%
%%% Subfunction ParseInputs
%%%
function [g, nhood, noise] = ParseInputs(varargin)

g = [];
nhood = [3 3];
noise = [];

wid = sprintf('Images:%s:obsoleteSyntax',mfilename);            

switch nargin
case 0
    msg = 'Too few input arguments.';
    eid = sprintf('Images:%s:tooFewInputs',mfilename);            
    error(eid,'%s',msg);
    
case 1
    % wiener2(I)
    
    g = varargin{1};
    
case 2
    g = varargin{1};

    switch numel(varargin{2})
    case 1
        % wiener2(I,noise)
        
        noise = varargin{2};
        
    case 2
        % wiener2(I,[m n])

        nhood = varargin{2};
        
    otherwise
        msg = 'Invalid input syntax';
        eid = sprintf('Images:%s:invalidSyntax',mfilename);            
        error(eid,'%s',msg);
    end
    
case 3
    g = varargin{1};
        
    if (numel(varargin{3}) == 2)
        % wiener2(I,[m n],[mblock nblock])  OBSOLETE
        warning(wid,'%s %s',...
                'WIENER2(I,[m n],[mblock nblock]) is an obsolete syntax.',...
                'Omit the block size, the image matrix is processed all at once.');

        nhood = varargin{2};
    else
        % wiener2(I,[m n],noise)
        nhood = varargin{2};
        noise = varargin{3};
    end
    
case 4
    % wiener2(I,[m n],[mblock nblock],noise)  OBSOLETE
    warning(wid,'%s %s',...
            'WIENER2(I,[m n],[mblock nblock],noise) is an obsolete syntax.',...
            'Omit the block size, the image matrix is processed all at once.');
    g = varargin{1};
    nhood = varargin{2};
    noise = varargin{4};
    
otherwise
    msg = 'Too many input arguments.';
    eid = sprintf('Images:%s:tooManyInputs',mfilename);            
    error(eid,'%s',msg);

end

% checking if input image is a truecolor image-not supported by WIENER2
if (ndims(g) == 3)
    msg = 'WIENER2 does not support 3D truecolor images as an input.';
    eid = sprintf('Images:%s:wiener2DoesNotSupport3D',mfilename);            
    error(eid,'%s',msg); 
end
