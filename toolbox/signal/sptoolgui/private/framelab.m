function fl = framelab(framehand,labelstr,lfs,lh,varargin)
% FRAMELAB Create UIControl of style static text for frame label.
%   Assumes all positions and units are in pixels.
%   Inputs:
%     framehand - handle of frame
%     labelstr - string
%     lfs - spacing between label text and left edge of frame
%     lh - label height 
%     varargin{:} - param/value pairs for uicontrol creation
%   Outputs:
%     fl - frame label handle
 
%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.8 $

    pos = get(framehand,'position');

    lpos = [pos(1)+lfs pos(2)+pos(4)-lh/2 100 lh];
    
    l = uicontrol('style','text',...
          'units','pixels',...
          'string',[labelstr ' '],...
          'position',lpos,varargin{:});

    ex = get(l,'extent');

    set(l,'position',[lpos(1:2) ex(3) lpos(4)])
    set(l,'horizontalalignment','center')

    if nargout > 0
        fl = l;
    end

