function value = get(obj,param)
% GET Query AVIFILE properties
%
%   VALUE = GET(AVIOBJ,'PropertyName') returns the value of the specified
%   property of the AVIFILE object AVIOBJ.  
%  
%   Although GET will return the values of many properties of the AVIFILE
%   object, some properties are not allowed to be modified.  They are
%   automatically updated as frames are added with ADDFRAME.  
%
%    Note: This function is a helper for SUBSREF and is not intended for
%    users.  To retrieve property values of the AVIFILE object, use
%    structure notation.  For example:
%
%               value = obj.Fps;

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/03/30 13:06:34 $

switch lower(param)
 case 'filename'
  value = obj.Filename;
 case 'fps'
  fps = obj.MainHeader.Fps;  
  value = 1/fps*10^6;
 case 'compression'
  value =obj.StreamHeader.fccHandler;
 case 'quality'
  value = obj.StreamHeader.Quality/100;
 case 'totalframes'
  value = obj.MainHeader.TotalFrames;
 case 'width'
  value = obj.MainHeader.Width;  
 case 'height'
  value = obj.MainHeader.Height;  
 case 'length'
  value = obj.MainHeader.Length;  
 case 'keyframepersec'
  fps = obj.MainHeader.Fps;  
  fps = 10^6/fps;
  KeyFrameEvery = obj.KeyFrameEveryNth;
  value = fps/KeyFrameEvery;
 case 'videoname'
  value = obj.StreamName;
 case 'imagetype'
  if obj.Bitmapheader.biBitCount == 24
    value = 'TrueColor';
  elseif obj.Bitmapheader.biBitCount == 8
    value = 'Indexed';
  else
    value = 'Unknown';
  end
 case 'currentstate'
  value = obj.CurrentState;
 otherwise
  error(sprintf('Unrecognized parameter name ''%s''.',param));
end
return;
  
  

