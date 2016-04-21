function movie2avi(mov,filename,varargin)
%MOVIE2AVI(MOV,FILENAME) Create AVI movie from MATLAB movie
% 
%   MOVIE2AVI(MOV,FILENAME) creates an AVI movie from the MATLAB movie MOV.
%
%   MOVIE2AVI(MOV,FILENAME,PARAM,VALUE,PARAM,VALUE...) creates an AVI movie from
%   the MATLAB movie MOV using the specified parameter settings.  
%
%   Available parameters
%
%   FPS         - The frames per second for the AVI movie. The default 
%   is 15 fps.
%
%   COMPRESSION - A string indicating the compressor to use.  On UNIX, this
%   value must be 'None'.  Valid values for this parameter on Windows are
%   'Indeo3', 'Indeo5', 'Cinepak', 'MSVC', or 'None'.  To use a custom
%   compressor, the value can be the four character code as specified by the
%   codec documentation. An error will result if the specified custom
%   compressor can not be found.  The default is 'Indeo3' on Windows and
%   'None' on UNIX.
%
%   QUALITY      - A number between 0 and 100. This parameter has no effect
%   on uncompressed movies. Higher quality numbers result in higher video
%   quality and larger file sizes, where lower quality numbers result in
%   lower video quality and smaller file sizes.  The default is 75. 
%
%   KEYFRAME     - For compressors that support temporal compression, this
%   is the number of key frames per second. The default is 2 key frames per
%   second.
%
%   COLORMAP     - An M-by-3 matrix defining the colormap to be used for
%   indexed AVI movies.  M must be no greater than 256 (236 if using Indeo
%   compression). There is no default colormap.
%
%   VIDEONAME    - A descriptive name for the video stream.  This parameter
%   must be no greater than 64 characters long. The default name is the
%   filename. 
%
%   See also AVIFILE, AVIREAD, AVIINFO, MOVIE.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/03/05 18:10:37 $

if isstruct(mov)
  if (~isfield(mov,'cdata') || ~isfield(mov,'colormap'))
    error('First input must be a MATLAB movie.');
  end
else
  error('First input must be a MATLAB movie.');
end

if(~ischar(filename))
  error('Invalid input arguments. Second input argument must be a filename.');
end

if (nargin>2)
  if( rem(nargin,2) ~= 0 )
    error('Inputs must be a MATLAB movie, a filename, and param/value pairs.');
  end
end

% Create a new AVI movie
avimov = avifile(filename,varargin{:});
avimov = addframe(avimov,mov);
avimov = close(avimov);
return;  












