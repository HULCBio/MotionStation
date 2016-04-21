function GroupBox = groupbox(fig, pos, string, htextObj),
%GROUPBOX Create a frame with embedded text description.
%   GROUPBOX(fig, pos, string, htextObj), creates a frame and returns a vector 
%   of length 2:
%
%     [hFrame, hText].
%
%   fig      - desired parent of frame
%   pos      - position of frame: [left bottom width height]
%   string   - frame description
%   htextObj - handle of uicontrol text object for use in getting the text 
%              extent of the string.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.12 $

GroupBox(2) = 0;  % alloc vector
style = 'frame';

GroupBox(1) = uicontrol( ...
  'Parent',             fig, ...
  'Style',              style, ...
  'Enable',             'inactive', ...
  'Foreground',         [255 251 240]/255, ...
  'Position',           pos ...
);

set(htextObj, 'String', string);
ext = get(htextObj, 'Extent');

posText = [
  pos(1) + (ext(3)/length(string))
  pos(2) + pos(4) - (ext(4)/1.75)
  ext(3)
  ext(4)
];

GroupBox(2) = uicontrol( ...
  'Parent',             fig, ...
  'Style',              'text', ...
  'String',             string, ...
  'Position',           posText ...
);
