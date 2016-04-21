function [info,msg] = imgifinfo(filename)
%IMGIFINFO Information about a GIF file.
%   [INFO,MSG] = IMGIFINFO(FILENAME) returns a structure containing
%   information about the GIF file specified by the string
%   FILENAME. 
%
%   If any error condition is encountered, such as an error opening
%   the file, MSG will contain a string describing the error and
%   INFO will be empty.  Otherwise, MSG will be empty.
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:04:26 $

info = [];
msg = '';

if (~ischar(filename))
    msg = 'FILENAME must be a string';
    return;
end

[fid,m] = fopen(filename, 'r', 'ieee-le');
if (fid == -1)
    info = [];
    msg = m;
    return;
else
    filename = fopen(fid);
end

% Read directory information about the file
s = dir(filename);

%
% Initialize universal structure fields to fix the order
%
info.Filename = '';
info.FileModDate = '';
info.FileSize = [];
info.Format = '';
info.FormatVersion = [];
info.Width = [];
info.Height = [];
info.BitDepth = [];
info.ColorType = [];
info.FormatSignature = '';

% Initialize other tags
info.BackgroundColor = [];
info.AspectRatio = [];
info.ColorTable = [];
info.Interlaced = [];

sig = fread(fid, 3)';
if ~isequal(sig, [71 73 70])
    info = [];
    msg = 'Not a GIF file';
    fclose(fid);
    return;
end
 
fseek(fid,0,'bof');

% read in the Header, Logical Screen Descriptor and if there, the Global Color Table.
GIFheader = fread(fid,6)';
fread(fid,2,'uint16');  % ScreenSize
LogicalScreenDescriptor = fread(fid,3,'uint8')';
PackedByte = LogicalScreenDescriptor(1);

GCTbool = bitget(PackedByte,8)==1;  % do we have a Global Color Table?

if GCTbool
   sizeGCT = bitget(PackedByte,1:3);
	bitdepth = sum(sizeGCT.*[1 2 4]) + 1;
   table = fread(fid,3*bitshift(1,bitdepth),'uint8');
   GlobalColorTable = reshape(table,3,length(table)/3)'./255;
end

% Since those extension blocks can be anywhere (including before the Local
% Image Descriptor), we have to fread and sort until we hit a Separator
k = 0; CommentExtension = '';

separator = fread(fid,1,'uint8');


while (separator ~= 59)
   % keep going past the blocks until we hit an Image Descriptor or Extension Block
   if (separator == 33)
      blockLabel = fread(fid,1,'uint8');
      
      switch blockLabel
      case 249 % Graphics Control Extension
         fseek(fid,6,'cof'); %6
      case 1 % Plain Text Extension
         fseek(fid,13,'cof');
         countByte = fread(fid,1,'uint8');
         while (countByte ~=0)
            fseek(fid,countByte+1,'cof');
            countByte = fread(fid,1,'uint8');
         end
      case 255 % Application Extension
         fseek(fid,12,'cof');
         countByte = fread(fid,1,'uint8');
         while (countByte ~= 0)
            fseek(fid,countByte,'cof');
            countByte = fread(fid,1,'uint8');
         end
      case 254 % Comment Extension
         fread(fid,1); % pointer
         letter = fread(fid,1);
         CommentExtension = char(letter);
         while (letter ~= 0)
            letter = fread(fid,1);
            CommentExtension = [CommentExtension char(letter)];
         end
      otherwise
         info = [];
         msg = 'Corrupt GIF file';
         fclose(fid);
         return;
      end
   elseif (separator == 44)   
      k = k+1;
      % First, fill in all the fields that aren't dependent on a Local Color Table
      info(k).Filename = filename;
      info(k).FileModDate = s.date;
      info(k).FileSize = s.bytes;
      info(k).Format = char(GIFheader(1:3));
      info(k).FormatVersion = char(GIFheader(4:6));
      info(k).ColorType = 'indexed';
      info(k).FormatSignature = [info(k).Format info(k).FormatVersion];
      
      % If GlobalColorTable Flag is set to 0, then Background Color is null.
      if bitget(PackedByte,8) == 0
         info(k).BackgroundColor = [];
      else
         info(k).BackgroundColor = LogicalScreenDescriptor(2);
      end
      info(k).AspectRatio = LogicalScreenDescriptor(3);
         
      % Now fill in the fields which we must first check for a Local Image Descriptor
      LocalID = fread(fid,4,'uint16');
      LocalPacked = fread(fid,1,'uint8');
      
      % Account for reading in an extra byte.
      fread(fid,1,'uint8');
      
      info(k).Width = LocalID(3);
      info(k).Height = LocalID(4);
      
      % Is it interlaced?
      if (bitget(LocalPacked,7) == 1)
         info(k).Interlaced = 'yes';
      else
         info(k).Interlaced = 'no';
      end
      
      % Check and see if we have a Local Color Table
      LCTbool = bitget(LocalPacked,8)==1;
      if LCTbool
         Localbitdepth = bitget(LocalPacked,1:3);
         Localbitdepth = sum(Localbitdepth.*[1 2 4]) + 1; 
         info(k).BitDepth = Localbitdepth;
         ltable = fread(fid,3*bitshift(1,Localbitdepth),'uint8');
         info(k).ColorTable = reshape(ltable,3,length(ltable)/3)'./255;
      elseif GCTbool
         % use the Global Color Table
         info(k).BitDepth = bitdepth;
         info(k).ColorTable = GlobalColorTable;   
      else
         % use a default color table
         info(k).ColorTable = [0 0 0;1 1 1];
         info(k).BitDepth = 1;
      end
      
      % fseek past the Image data 
      % "A block with a zero byte count terminates the Raster Data 
      %  stream for a given image."
      countByte = fread(fid,1,'uint8');
      while countByte~=0
	fseek(fid,countByte,'cof');
	countByte = fread(fid,1,'uint8');
      end
   end  %%% IF
   separator = fread(fid,1,'uint8');   
end  %%% WHILE

numImages = k;
if ~isempty(CommentExtension)
  for i = 1:numImages
    info(i).CommentExtension = CommentExtension;
  end
end

if (numImages == 0)
  info = [];
  msg = 'No images found in GIF file';
  fclose(fid);
  return;
end

fclose(fid);
