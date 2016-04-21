function [aviobj] = addframe(aviobj,varargin)
%ADDFRAME  Add video frame to AVI file.  
%   AVIOBJ = ADDFRAME(AVIOBJ,FRAME) appends the data in FRAME to AVIOBJ,
%   which is created with AVIFILE.  FRAME can be either an indexed image
%   (M-by-N) or a truecolor image (M-by-N-by-3) of double or uint8
%   precision.  If FRAME is not the first frame added to the AVI file, it
%   must be consistent with the dimensions of the previous frames.
%   
%   AVIOBJ = ADDFRAME(AVIOBJ,FRAME1,FRAME2,FRAME3,...) adds multiple
%   frames to an avifile.
%
%   AVIOBJ = ADDFRAME(AVIOBJ,MOV) appends the frame(s) contained in the
%   MATLAB movie MOV to the AVI file. MATLAB movies which store frames as
%   indexed images will use the colormap in the first frame as the colormap
%   for the AVI file unless the colormap has been previously set.
%
%   AVIOBJ = ADDFRAME(AVIOBJ,H) captures a frame from the figure or
%   axis handle H, and appends this frame to the AVI file. The frame is
%   rendered into an offscreen array before it is appended to the AVI file.
%   This syntax should not be used if the graphics in the animation are using
%   XOR graphics.
%
%   If the animation is using XOR graphics, use GETFRAME instead to capture
%   the graphics into one frame of a MATLAB movie and then use the syntax
%   [AVIOBJ] = ADDFRAME(AVIOBJ,MOV) as in the example below. GETFRAME will
%   perform a snapshot of the onscreen image.
% 
%    fig=figure;
%    set(fig,'DoubleBuffer','on');
%    set(gca,'xlim',[-80 80],'ylim',[-80 80],...
%        'nextplot','replace','Visible','off')
%    aviobj = avifile('example.avi')
%    x = -pi:.1:pi;
%    radius = [0:length(x)];
%    for i=1:length(x)
%     h = patch(sin(x)*radius(i),cos(x)*radius(i),[abs(cos(x(i))) 0 0]);
%     set(h,'EraseMode','xor');
%     frame = getframe(gca);
%     aviobj = addframe(aviobj,frame);
%    end
%    aviobj = close(aviobj);
%
%   See also AVIFILE, AVIFILE/CLOSE, and MOVIE2AVI.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/03/30 13:06:30 $

numframes = nargin - 1;
error(nargoutchk(1,1,nargout));
if ~isa(aviobj,'avifile')
  error('First input must be an avifile object.');
end

for i = 1:numframes
  MovieLength = 1;
  mlMovie = 0;
  % Parse input arguments
  inputType = getInputType(aviobj,varargin{i});
  switch inputType
   case 'axes'
    screenp = get(0,'screenp');
    pos =  get(get(varargin{i},'parent'),'position');
    set(get(varargin{i},'parent'), 'paperposition',pos./screenp);
    renderer = get(get(varargin{i},'parent'),'renderer');
    if strcmp(renderer,'painters')
     renderer = 'opengl';
    end
    %Turn off warning in case opengl is not supported and 
    %hardcopy needs to use zbuffer
    warnstate = warning('off');
    noanimate('save',get(varargin{i},'parent'));
    frame = hardcopy(varargin{i}, ['-d' renderer], ['-r' round(num2str(screenp))]);
    noanimate('restore',get(varargin{i},'parent'));
    warning(warnstate);
   case 'figure'
    screenp = get(0,'screenp');
    pos = get(varargin{i},'position');
    set(varargin{i}, 'paperposition',pos./screenp);
    renderer = get(varargin{i},'renderer');
    if strcmp(renderer,'painters')
     renderer = 'opengl';
    end
    %Temporarily turn off warning in case opengl is not supported and 
    %hardcopy needs to use zbuffer
    warnstate = warning('off');
    noanimate('save',varargin{i});
    frame = hardcopy(varargin{i}, ['-d' renderer], ['-r' round(num2str(screenp))]);
    noanimate('restore',varargin{i});
    warning(warnstate);
   case 'movie'
    mlMovie = 1;
    MovieLength = length(varargin{i});
    if ( ~isempty(varargin{i}(1).colormap) & ...
	 isempty(aviobj.Bitmapheader.Colormap) & ...
	 aviobj.MainHeader.TotalFrames == 0 )
      aviobj = set(aviobj,'Colormap',varargin{i}(1).colormap);
    end
   case 'data'
    frame = varargin{i};
  end

  for j = 1:MovieLength
    if mlMovie 
      frame = varargin{i}(j).cdata;
    end
    
    frameClass = class(frame);
    if isempty(strmatch(frameClass,strvcat('double','uint8')))
      error('FRAME must be of either double or uint8 precision');
    end
        
    % Determine image dimensions
    height = size(frame,1); 
    width = size(frame,2);
    dims = size(frame,3);

    % Check requirements for the Intel Indeo codec
    % Intel Indeo requires images dimensions to be a multiple of four,
    % greater than 32, and no more than 4,194,304 pixels.
    isIndeo = strncmpi('iv',aviobj.StreamHeader.fccHandler, 2);

    if isIndeo
      if (aviobj.MainHeader.TotalFrames == 0) & ...
	    (aviobj.Bitmapheader.biBitCount == 8) & ...
	    (aviobj.Bitmapheader.biClrUsed >236)
	error('The colormap can not exceed 236 colors, as specified by the Intel Indeo compressor.');
      end
            
      if (width < 32) | (height < 32)
	error('The minimum frame size for the Indeo compressor is 32x32.');
      end
      if width*height > 4194304
	error('The Intel Indeo compressor can not compress frame sizes that exceed a maximum frame size of 4,194,304 pixels.');
      end
    end % if isIndeo

    % Check requirements for MPEG-4 compressors.  This list is maintained
    % from Microsoft's list of registered codecs:
    % http://msdn.microsoft.com/library/default.asp?url=/library/en-us/dnwmt/html/registeredfourcccodesandwaveformats.asp
    codec = aviobj.StreamHeader.fccHandler;
    isMPG4 = any(strncmpi(codec, {'M4S2', 'MP43', 'MP42', 'MP4S', 'MP4V'}, 4));

    % Indeo and MPEG-4 codecs require that frame height and width
    % are multiples of 4.
    if isMPG4 || isIndeo
      hpad = rem(height,4);
      wpad = rem(width,4);
      if hpad
	if  aviobj.MainHeader.TotalFrames == 0
	  warning('The frame height has been padded to be a multiple of four as required by the specified codec.');
	end
	frame = [frame;zeros(4-hpad,size(frame,2),dims)];
      end
      if wpad
	if  aviobj.MainHeader.TotalFrames == 0
	  warning('The frame width has been padded to be a multiple of four as required by the specified codec.');
	end
	frame = [frame, zeros(size(frame,1),4-wpad,dims)];
      end

      % Determine adjusted image dimensions
      height = size(frame,1);
      width = size(frame,2);
      dims = size(frame,3);
    end
    
    % Truecolor images can not be compressed with RLE or MSVC compression 
    if dims == 3
      msg = 'Use a compression method other than RLE or MSVC for truecolor images.';
      if strmatch(lower(aviobj.StreamHeader.fccHandler),'mrle') 
	error(msg);
      elseif strmatch(lower(aviobj.StreamHeader.fccHandler),'msvc')
	error(msg);
      end
    end
    
    % If this is not the first frame, make sure it is consistent
    if aviobj.MainHeader.TotalFrames ~= 0
      ValidateFrame(aviobj,width, height,dims);
    end

    % Reshape image data
    frame = ReshapeImage(frame);

    % Compute memory requirements for frame storage
    numFrameElements = prod(size(frame));

    % If this is the first frame, set necessary fields
    if aviobj.MainHeader.TotalFrames==0
      aviobj.MainHeader.SuggestedBufferSize = numFrameElements;
      aviobj.StreamHeader.SuggestedBufferSize = numFrameElements;
      aviobj.MainHeader.Width = width;
      aviobj.MainHeader.Height = height;
      aviobj.Bitmapheader.biWidth = width;
      aviobj.Bitmapheader.biHeight = height;
      aviobj.Bitmapheader.biSizeImage = numFrameElements;
      if dims == 3 
	aviobj.Bitmapheader.biBitCount = 24;
      else
	aviobj.Bitmapheader.biBitCount = 8;
      end
    end

    % On Windows use Video for Windows to write the video stream
    if ispc
      % fps is calculated in avi.c by dividing the rate by the scale (100).
      % The scale of 100 is hard coded into avi.c
      rate = aviobj.StreamHeader.Rate; 
    
      avi('addframe',rot90(frame,-1), aviobj.Bitmapheader, ...
	  aviobj.MainHeader.TotalFrames,rate, ...
	  aviobj.StreamHeader.Quality,aviobj.FileHandle, ...
	  aviobj.StreamName,aviobj.KeyFrameEveryNth);
    end
    
    if isunix
      % Update length of movie in seconds
      %aviobj = update(aviobj,'Length',aviobj.MainHeader.TotalFrames* ...
      %		 aviobj.MainHeader.Fps/10^6);
      %aviobj = update(aviobj,'Length',aviobj.MainHeader.TotalFrames* ...
      %		 aviobj.MainHeader.Fps/10^6);
      %

      % Update the length of the movie using frame number
      % This seems to be how Video for Windows does it
      aviobj.MainHeader.Length = aviobj.MainHeader.TotalFrames;
      aviobj.StreamHeader.Length = aviobj.MainHeader.TotalFrames;
      
      % Determine and update new size of movi LIST
      % ------------------------------------------
      %   '00db' or '00dc'   4 bytes
      %   size               4 bytes
      %   <movie data>       N
      %   Padd byte          rem(numFrameElements,2)
      newMovieListSize = aviobj.Sizes.movilist+4+4+numFrameElements + ...
	  rem(numFrameElements,2);
      aviobj.Sizes.movilist = newMovieListSize;

      % Determine and update new size of idx1 chunk
      % ------------------------------------------
      %   '00db' or '00dc'   4 bytes
      %   flags              4 bytes
      %   offset             4 bytes
      %   length             4 bytes
      newidx1size = aviobj.Sizes.idx1size + 4*4; 
      aviobj.Sizes.idx1size = newidx1size;

      % Determine and update new size of RIFF chunk
      % ------------------------------------------
      %   '00db' or '00dc'   4 bytes
      %   size               4 bytes
      %   <movie data>       N
      %   Padd byte          rem(numFrameElements,2)
      %   '00db' or '00dc'   4 bytes
      %   flags              4 bytes
      %   offset             4 bytes
      %   length             4 bytes
      newRIFFsize = aviobj.Sizes.riffsize + 4+4+numFrameElements + 4*4 ...
	  + rem(numFrameElements,2);
      aviobj.Sizes.riffsize = newRIFFsize;

      % Write  movi chunk to temp file
      if aviobj.Compression == 1
	ckid = '00dc';
      else
	ckid = '00db';
      end
      msg = WriteTempdata(ckid,numFrameElements,frame,aviobj.TempDataFile);
      error(msg);
    end %End of UNIX specific code
  % Update the total frames
  aviobj.MainHeader.TotalFrames = aviobj.MainHeader.TotalFrames + 1;
  end
end
return;

% ------------------------------------------------------------------------
function msg = WriteTempdata(chunktype,chunksize,chunkdata,filename)
% WRITETEMPDATA 
%   Append the frame data to a temporary file. The data is written as
% 
%   chunktype  4 bytes
%   chunksize  4 bytes
%   chunkdata  N bytes  
%   

msg = '';
fid = fopen(filename,'a','l');
fseek(fid,0,'eof');

count = fwrite(fid,chunktype,'char');
if count ~= 4
  msg = 'Unable to write data to temp file.';
end

count = fwrite(fid,chunksize,'uint32');
if count ~= 1
  msg = 'Unable to write data to temp file.';
end

count = fwrite(fid,rot90(chunkdata,-1),'uint8');
if count ~= prod(size(chunkdata))
  msg = 'Unable to write data to temp file.';
end

fclose(fid);
return;

% ------------------------------------------------------------------------
function ValidateFrame(aviobj, width, height, dims)
% VALIDATEFRAME
%   Verify the frame is consistent with header information in AVIOBJ.  The
%   frame must have the same WIDTH, HEIGHT, and DIMS as the previous frames.

if width ~= aviobj.MainHeader.Width
  error(sprintf('Frame must be %d by %d.', ...
		aviobj.MainHeader.Width,aviobj.MainHeader.Height))
elseif height ~= aviobj.MainHeader.Height
  error(sprintf('Frame must be %d by %d.', ...
		aviobj.MainHeader.Width,aviobj.MainHeader.Height))
end

if (aviobj.Bitmapheader.biBitCount == 24) & (dims ~= 3)
  error('Frame must be a truecolor image.');
elseif (aviobj.Bitmapheader.biBitCount == 8) & (dims ~= 1)
  error('Frame must be an indexed image.')
end
return;

% ------------------------------------------------------------------------
function X = ReshapeImage(X)
numdims = ndims(X);
numcomps = size(X,3);

if (isa(X,'double'))
  if (numcomps == 3)
    X = uint8(round(255*X));
  else
    X = uint8(X-1);
  end
end

% Squeeze 3rd dimension into second
if (numcomps == 3)
  X = X(:,:,[3 2 1]);
  X = permute(X, [1 3 2]);
  X = reshape(X, [size(X,1) size(X,2)*size(X,3)]);
end

width = size(X,2);
tmp = rem(width,4);
if (tmp > 0)
    padding = 4 - tmp;
    X = cat(2, X, repmat(uint8(0), [size(X,1) padding]));
end

return;

% ------------------------------------------------------------------------
function inputType = getInputType(aviobj,frame)
  if isscalar(frame) && ishandle(frame)   
    inputType = get(frame,'type');
  elseif isstruct(frame) & isfield(frame,'cdata')
    inputType = 'movie';
  elseif isa(frame,'numeric')
    inputType = 'data';
  else
    error('Invalid input argument.  Each frame must be a numeric matrix, a MATLAB movie structure, or a handle to a figure or axis.');
  end









