function [x,m]=getframe(varargin)
%GETFRAME Get movie frame.
%   GETFRAME returns a movie frame. The frame is a snapshot
%   of the current axis. GETFRAME is usually used in a FOR loop 
%   to assemble an array of movie frames for playback using MOVIE.  
%   For example:
%
%      for j=1:n
%         plot_command
%         M(j) = getframe;
%      end
%      movie(M)
%
%   GETFRAME(H) gets a frame from object H, where H is a handle
%   to a figure or an axis.
%   GETFRAME(H,RECT) specifies the rectangle to copy the bitmap
%   from, in pixels, relative to the lower-left corner of object H.
%
%   F = GETFRAME(...) returns a movie frame which is a structure 
%   having the fields "cdata" and "colormap" which contain the
%   the image data in a uint8 matrix and the colormap in a double
%   matrix. F.cdata will be Height-by-Width-by-3 and F.colormap  
%   will be empty on systems that use TrueColor graphics.  
%   For example:
%
%      f = getframe(gcf);
%      colormap(f.colormap);
%      image(f.cdata);
%
%   See also MOVIE, IMAGE, IM2FRAME, FRAME2IM.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.13.4.6 $  $Date: 2004/04/10 23:31:50 $

  x=capturescreen(varargin{:});

  if (nargout == 2)
    m=x.colormap;
    x=x.cdata;
  end
  