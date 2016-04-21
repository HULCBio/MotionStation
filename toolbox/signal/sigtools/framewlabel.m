function varargout = framewlabel(frameParentH,framePos,label,tag,bgc,viz)
% FRAMEWLABEL Creates a frame with the specified label.
%
% To create a frame without a label specify an empty string ('') for the 
% input argument label.
%
% Inputs:
%    frameParentH - handle to the parent of the frame (figure handle).
%    framePos     - frame position [x y w h].
%    label        - label for the frame.
%    tag          - string for the frame's tag property.
%    bgc          - background color of the frame.
%    viz          - specify visibility on/off.
%
% Outputs:
%    frH - two element vector:
%          frH(1) - frame handle.
%          frH(2) - frame label handle.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $  $Date: 2004/04/13 00:31:47 $ 

if nargin < 6, viz = 'on'; end

sz  = gui_sizes;
lfs = sz.lfs;   % label/frame spacing
tw  = sz.tw;    % text width
lh  = sz.lh;    % label height

if length(frameParentH) > 1,
    frH = frameParentH;
    resize = true;
    origUnits1 = get(frH(1), 'Units');
    origUnits2 = get(frH(2), 'Units');
    set(frH, 'Units', 'pixels');
    set(frH(1), 'Position', framePos);
else
    resize = false;
end

labelPos = [framePos(1)+lfs framePos(2)+framePos(4)-lh/2 tw lh];

if ~resize,
    
    % Set up default background color in case color was not specified.
    if nargin < 5,
        bgc = get(frameParentH,'color');
    end
    % Set up default tag in case tag was not specified.
    if nargin < 4,
        tag = '';
    end
    
    frH(1) = uicontrol('Parent',frameParentH, ...
        'Style','frame',...
        'BackgroundColor',bgc,...
        'Position',framePos, ...
        'visible', viz, ...
        'Tag',tag);
    
    if nargin > 2  & ~isempty(label) % Label was specified
        frH(2) = uicontrol('Parent',frameParentH, ...
            'HorizontalAlignment','Center', ...
            'BackgroundColor',bgc,...
            'Position',labelPos, ...
            'String',label, ...
            'Style','text',...
            'Tag',tag,...
            'visible','off');
    end
end

if length(frH) > 1,
    frLabelExt = get(frH(2),'extent');

    set(frH(2),'Position',[labelPos(1:2) frLabelExt(3) labelPos(4)],'visible',viz);
end

if resize
    set(frH(1), 'Units', origUnits1);
    set(frH(2), 'Units', origUnits2);
end

if nargout
    varargout = {frH};
end

% [EOF] framewlabel.m
