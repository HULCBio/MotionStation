function xpcpatchkernel(imgname, propval)

% XPCPATCHKERNEL - xPC Target private function

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.6.6.2 $ $Date: 2004/03/04 20:09:59 $

if ~isempty(findstr(imgname,'a16.rtb'))
  return;
end

fid   = fopen(imgname,'rb');
image = fread(fid, '*uint8')';
fclose(fid);

signature='AaAaAaAaA-XPCPATCHSTART-AaA';

k=findstr(image,signature);
if isempty(k)
   error('domain to patch not found in image')
end
patchdomainstart=k+length(signature)+1;

%image(k:k+50)

MemSearchIndex=patchdomainstart;
MemoryIndex=patchdomainstart+2;
ModelMemoryIndex=patchdomainstart+6;
TgScMouseIndex=patchdomainstart+8;
RS232Baudrate=patchdomainstart+10;

%patch MemSearch
if strcmp(propval{7},'Auto')
   image(MemSearchIndex)='1';
else
   image(MemSearchIndex)='0';
   %patch Memory
   a=propval{7};
   image(MemoryIndex:MemoryIndex+1)=bytes(str2double(a));
end

%patch ModelMemory
if strcmp(propval{8},'1MB')
   image(ModelMemoryIndex)='1';
elseif strcmp(propval{8},'4MB')
   image(ModelMemoryIndex)='2';
elseif strcmp(propval{8},'16MB')
   image(ModelMemoryIndex)='3';
end

%patch TgScMouse
if strcmp(propval{24},'None')
   image(TgScMouseIndex)='0';
elseif strcmp(propval{24},'PS2')
   image(TgScMouseIndex)='1';
elseif strcmp(propval{24},'RS232 COM1')
   image(TgScMouseIndex)='2';
elseif strcmp(propval{24},'RS232 COM2')
   image(TgScMouseIndex)='3';
end

%patch RS232Baudrate
if strcmp(propval{13},'115200')
   image(RS232Baudrate)='1';
elseif strcmp(propval{13},'57600')
   image(RS232Baudrate)='2';
elseif strcmp(propval{13},'38400')
   image(RS232Baudrate)='3';
elseif strcmp(propval{13},'19200')
   image(RS232Baudrate)='4';
elseif strcmp(propval{13},'9600')
   image(RS232Baudrate)='5';
elseif strcmp(propval{13},'4800')
   image(RS232Baudrate)='6';
elseif strcmp(propval{13},'2400')
   image(RS232Baudrate)='7';
elseif strcmp(propval{13},'1200')
   image(RS232Baudrate)='8';
end

%image(k:k+50)

%return
fid=fopen(imgname,'wb');
fwrite(fid,image);
fclose(fid);


function b = bytes(x)
% Generate little-endian bytes for uint16 representation of x
bin = dec2bin(x, 16);
b   = uint8(bin2dec([bin(9:16); bin(1:8)])');