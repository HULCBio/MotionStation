function frameObj = framerect(varargin)
%FRAMERECT/FRAMERECT

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/15 04:02:07 $

switch nargin
case 0
   frameObj.Class = 'framerect';
   frameObj.ContentType = [];
   frameObj.fResizable = [];
   frameObj.MinWidth = [];
   frameObj.MaxLine = [];
   frameObj.MinLine = [];
   frameObj = class(frameObj,'framerect',hgbin);
   return
case 1
   HGpatch = varargin{1};
otherwise
   HGpatch = patch(varargin{:},'w');
end

set(HGpatch,'FaceColor','none');
set(HGpatch,'EdgeColor','none');
set(HGpatch,...
	'ButtonDownFcn','doclick(gcbo)','EraseMode','xor');

frameObj.Class = 'framerect';
frameObj.ContentType = '';
frameObj.fResizable = [0 0 0 0];
frameObj.MinWidth = 0.01;

frameObj.MaxLine = [];
frameObj.MinLine = [];

binObj = hgbin(HGpatch);

frameObj = class(frameObj,'framerect',binObj);
