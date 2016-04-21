function mov = immovie(varargin)
%IMMOVIE Make movie from multiframe image.
%   MOV = IMMOVIE(X,MAP) returns the movie structure array MOV from the
%   images in the multiframe indexed image X with the colormap MAP. 
%   As it creates the movie array, it displays the movie frames on the 
%   screen. You can play the movie using the MATLAB MOVIE function.
%
%   MOV = IMMOVIE(RGB) returns the movie structure array MOV from the
%   images in the multiframe truecolor image RGB. 
%
%   For details about the movie structure array, see the reference page
%   for GETFRAME.
%
%   X comprises multiple indexed images, all having the same size
%   and all using the colormap MAP. X is an M-by-N-by-1-by-K
%   array, where K is the number of images.
%
%   RGB comprises multiple truecolor images, all having the same size.
%   RGB is an M-by-N-by-3-by-K array, where K is the number of images.
%
%   Class Support
%   -------------
%   An indexed image can be uint8, uint16, double, or logical.
%   A truecolor image can be uint8, uint16, or double.
%   MOV is a MATLAB movie structure.
%
%   Example
%   -------
%        load mri
%        mov = immovie(D,map);
%        movie(mov,3)
%
%   Remark
%   ------
%   You can also make movies from images by using the MATLAB function
%   AVIFILE, which creates AVI files.  In addition, you can convert an
%   existing MATLAB movie into an AVI file by using the MOVIE2AVI
%   function.
%
%   See also AVIFILE, GETFRAME, MONTAGE, MOVIE, MOVIE2AVI.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 5.23.4.4 $  $Date: 2003/08/23 05:52:35 $

[X,map] = parse_inputs(varargin{:});

numframes = size(X,4);
mov = repmat(struct('cdata',[],'colormap',[]),[1 numframes]);

figure(gcf);
set(gcf,'doublebuffer','on');
for k = 1 : numframes
  imshow(X(:,:,:,k));
  mov(k).cdata = X(:,:,:,k);
  mov(k).colormap = map;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Function: parse_inputs
%

function [X,map] = parse_inputs(varargin)
% Outputs: X    multiframe indexed or RGB image
%          map  colormap (:,3)

checknargin(1, 2, nargin,mfilename);

switch nargin
case 1                      % immovie(RGB)
    X = varargin{1};
    map = [];
case 2                      % immovie(X,map)
    X = varargin{1};
    map = varargin{2};
    % immovie(D,size) OBSOLETE
    if (isequal(size(map), [1 3]) && (prod(map) == numel(X)))
        wid = sprintf('Images:%s:obsoleteSyntax',mfilename);
        msg = ['IMMOVIE(D,size) is an obsolete syntax. Using current colormap. ',...
                 'For different colormap use IMMOVIE(X,map).'];
        warning(wid, '%s',msg);
        X = reshape(X,[map(1) map(2) 1 map(3)]);
        map = colormap;
    end
end

% Check parameter validity 

if isempty(map) %RGB image
  checkinput(X, {'uint8','uint16','double'},'','RGB', mfilename, 1);
  if size(X,3)~=3
    msgId = sprintf('Images:%s:invalidTruecolorImage', mfilename);
    msg = 'Truecolor RGB image has to be an M-by-N-by-3-by-K array.';
    error(msgId,'%s',msg);
  end
  if ~isa(X,'uint8')
    X = im2uint8(X);
  end

else % indexed image
    checkinput(X, {'uint8','uint16','double','logical'},'','X', mfilename, 1);
    if size(X,3)~=1
        msgId = sprintf('Images:%s:invalidIndexedImage', mfilename);
        msg = 'Indexed image has to be an M-by-N-by-1-by-K array.';
        error(msgId,'%s',msg);
    end
    if (~isreal(map) || any(map(:) > 1) || any(map(:) < 0) || ...
                ~isequal(size(map,2), 3) || size(map,1) < 2)
        msgId = sprintf('Images:%s:invalidColormap', mfilename);
        msg1 = 'MAP has to be a 2D array with at least 2 rows and ';
        msg2 = 'exactly 3 columns with array values between 0 and 1.';
        error(msgId,'%s\n%s',msg1,msg2);
    end
    if ~isa(X,'uint8')
      X = im2uint8(X,'indexed');
    end
end
