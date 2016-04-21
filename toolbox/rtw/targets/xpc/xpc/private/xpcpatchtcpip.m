function argout=xpcpatchtcpip(imgname,propval)

% XPCPATCHTCPIP - xPC Target private function

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.5.2.2 $ $Date: 2004/04/08 21:04:43 $


fid   = fopen(imgname,'rb');
image = fread(fid, '*char')';
fclose(fid);

signature='AaAaAaAaA-Rl32_Synch-AaA';

k=findstr(image,signature);
if isempty(k)
  error(['domain to patch not found in image ',imgname]);
end
patchdomainstart=k+length(signature)+1;

if nargin==1
  argout=readpatchdomain(imgname,patchdomainstart);
end

if nargin==2
  writepatchdomain(imgname,patchdomainstart,propval);
end



function patchinfo=readpatchdomain(imgname,patchdomainstart)

fid=fopen(imgname,'rb');
fseek(fid,patchdomainstart,'bof');
tmp=fread(fid,3,'schar')';
index=find(tmp==0);if ~isempty(index), tmp=tmp(1:index(1)-1); end;
patchinfo.version=char(tmp);

fseek(fid,2,'cof');
tmp=fread(fid,3,'schar')';
index=find(tmp==0);if ~isempty(index), tmp=tmp(1:index(1)-1); end;
patchinfo.revision=char(tmp);

fseek(fid,19,'cof');
tmp=fread(fid,15,'schar')';
index=find(tmp==0);if ~isempty(index), tmp=tmp(1:index(1)-1); end;
patchinfo.hostaddress=char(tmp);

fseek(fid,1,'cof');
tmp=fread(fid,23,'schar')';
index=find(tmp==0);if ~isempty(index), tmp=tmp(1:index(1)-1); end;
patchinfo.hostname=char(tmp);

fseek(fid,1,'cof');
tmp=fread(fid,7,'schar')';
index=find(tmp==0);if ~isempty(index), tmp=tmp(1:index(1)-1); end;
patchinfo.hostport=char(tmp);

fseek(fid,1,'cof');
tmp=fread(fid,23,'schar')';
index=find(tmp==0);if ~isempty(index), tmp=tmp(1:index(1)-1); end;
patchinfo.hostportname=char(tmp);

fseek(fid,1,'cof');
tmp=fread(fid,15,'schar')';
index=find(tmp==0);if ~isempty(index), tmp=tmp(1:index(1)-1); end;
patchinfo.serveraddress=char(tmp);

fseek(fid,1,'cof');
tmp=fread(fid,23,'schar')';
index=find(tmp==0);if ~isempty(index), tmp=tmp(1:index(1)-1); end;
patchinfo.servername=char(tmp);

fseek(fid,1,'cof');
tmp=fread(fid,7,'schar')';
index=find(tmp==0);if ~isempty(index), tmp=tmp(1:index(1)-1); end;
patchinfo.serverport=char(tmp);

fseek(fid,1,'cof');
tmp=fread(fid,23,'schar')';
index=find(tmp==0);if ~isempty(index), tmp=tmp(1:index(1)-1); end;
patchinfo.serverportname=char(tmp);

fseek(fid,1,'cof');
tmp=fread(fid,15,'schar')';
index=find(tmp==0);if ~isempty(index), tmp=tmp(1:index(1)-1); end;
patchinfo.targetaddress=char(tmp);

fseek(fid,1,'cof');
tmp=fread(fid,23,'schar')';
index=find(tmp==0);if ~isempty(index), tmp=tmp(1:index(1)-1); end;
patchinfo.targetname=char(tmp);

fseek(fid,1,'cof');
tmp=fread(fid,7,'schar')';
index=find(tmp==0);if ~isempty(index), tmp=tmp(1:index(1)-1); end;
patchinfo.targetport=char(tmp);

fseek(fid,1,'cof');
tmp=fread(fid,23,'schar')';
index=find(tmp==0);if ~isempty(index), tmp=tmp(1:index(1)-1); end;
patchinfo.targetportname=char(tmp);

fseek(fid,1,'cof');
tmp=fread(fid,15,'schar')';
index=find(tmp==0);if ~isempty(index), tmp=tmp(1:index(1)-1); end;
patchinfo.netmask=char(tmp);

fseek(fid,1,'cof');
tmp=fread(fid,15,'schar')';
index=find(tmp==0);if ~isempty(index), tmp=tmp(1:index(1)-1); end;
patchinfo.gateway=char(tmp);

fseek(fid,1,'cof');
tmp=fread(fid,9,'schar')';
index=find(tmp==0);if ~isempty(index), tmp=tmp(1:index(1)-1); end;
patchinfo.targetdriver=char(tmp);

fseek(fid,1,'cof');
tmp=fread(fid,6,'schar')';
index=find(tmp==0);if ~isempty(index), tmp=tmp(1:index(1)-1); end;
patchinfo.targetbus=char(tmp);

fseek(fid,1,'cof');
patchinfo.memport=fread(fid,1,'uint16');
patchinfo.memaddress=fread(fid,1,'uint32');
patchinfo.irq=fread(fid,1,'uint16');

fclose(fid);


function writepatchdomain(imgname,patchdomainstart,propval)

fid=fopen(imgname,'r+b');
fseek(fid,patchdomainstart,'bof');
tmp=fread(fid,3,'schar')';
index=find(tmp==0);if ~isempty(index), tmp=tmp(1:index(1)-1); end;
patchinfo.version=char(tmp);

fseek(fid,2,'cof');
tmp=fread(fid,3,'schar')';
index=find(tmp==0);if ~isempty(index), tmp=tmp(1:index(1)-1); end;
patchinfo.revision=char(tmp);

fseek(fid,19,'cof');
tmp=fread(fid,15,'schar')';
index=find(tmp==0);if ~isempty(index), tmp=tmp(1:index(1)-1); end;
patchinfo.hostaddress=char(tmp);

fseek(fid,1,'cof');
tmp=fread(fid,23,'schar')';
index=find(tmp==0);if ~isempty(index), tmp=tmp(1:index(1)-1); end;
patchinfo.hostname=char(tmp);

fseek(fid,1,'cof');
tmp=fread(fid,7,'schar')';
index=find(tmp==0);if ~isempty(index), tmp=tmp(1:index(1)-1); end;
patchinfo.hostport=char(tmp);

fseek(fid,1,'cof');
tmp=fread(fid,23,'schar')';
index=find(tmp==0);if ~isempty(index), tmp=tmp(1:index(1)-1); end;
patchinfo.hostportname=char(tmp);

fseek(fid,1,'cof');

tmp=zeros(1,16);
tmp(1:length(propval{14}))=propval{14};
fwrite(fid,tmp,'schar');

tmp=zeros(1,24);
tmp(1:length('xpcserver'))='xpcserver';
fwrite(fid,tmp,'schar');

tmp=zeros(1,8);
tmp(1:length(propval{15}))=propval{15};
fwrite(fid,tmp,'schar');

tmp=zeros(1,24);
tmp(1:length('xpccomm'))='xpccomm';
fwrite(fid,tmp,'schar');

tmp=zeros(1,16);
tmp(1:length(propval{14}))=propval{14};
fwrite(fid,tmp,'schar');

tmp=zeros(1,24);
tmp(1:length('xpcserver'))='xpcserver';
fwrite(fid,tmp,'schar');

tmp=zeros(1,8);
tmp(1:length(propval{15}))=propval{15};
fwrite(fid,tmp,'schar');

tmp=zeros(1,24);
tmp(1:length('xpccomm'))='xpccomm';
fwrite(fid,tmp,'schar');

tmp=zeros(1,16);
tmp(1:length(propval{16}))=propval{16};
fwrite(fid,tmp,'schar');

tmp=zeros(1,16);
tmp(1:length(propval{17}))=propval{17};
fwrite(fid,tmp,'schar');

tmp=zeros(1,10);
tmp(1:length(propval{18}))=propval{18};
fwrite(fid,tmp,'schar');

tmp=zeros(1,7);
tmp(1:length(propval{19}))=propval{19};
fwrite(fid,tmp,'schar');

tmp=propval{20};
tmp=hex2dec(tmp(3:end));
fwrite(fid,tmp,'uint16');

patchinfo.memaddress=fread(fid,1,'uint32');
fseek(fid, 0, 0);

tmp=propval{21};
tmp=str2num(tmp);
fwrite(fid,tmp,'uint16');

fclose(fid);
