function display(aviobj)
%DISPLAY Displays the AVIFILE object

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/03/30 13:06:33 $

disp('')
disp('Adjustable parameters:');
user.Fps = 1/aviobj.MainHeader.Fps*10^6;
switch  lower(aviobj.StreamHeader.fccHandler)
 case 'cvid'
  user.Compression = 'Cinepak';
 case 'iv32'
  user.Compression = 'Indeo3';
 case 'iv50'
  user.Compression = 'Indeo5';
 case 'msvc'
  user.Compression = 'MSVC';
 case 'dib '
  user.Compression = 'None';
 case 'mrle'
  user.Compression = 'RLE';
 otherwise
  user.Compression = 'Unknown';
end
user.Quality = aviobj.StreamHeader.Quality/100;
user.KeyFramePerSec = user.Fps/aviobj.KeyFrameEveryNth;
user.VideoName = aviobj.StreamName;
disp(user);

disp('Automatically updated parameters:');
if aviobj.Bitmapheader.biBitCount == 24
  imagetype = 'Truecolor';
elseif aviobj.Bitmapheader.biBitCount == 8
  imagetype = 'Indexed';
else 
  imagetype = 'Unknown';
end
auto.Filename  = aviobj.Filename;                  
auto.TotalFrames =aviobj.MainHeader.TotalFrames;
auto.Width = aviobj.MainHeader.Width;  
auto.Height = aviobj.MainHeader.Height;
auto.Length = aviobj.MainHeader.Length/user.Fps;
auto.ImageType = imagetype;
auto.CurrentState = aviobj.CurrentState;
disp(auto)




