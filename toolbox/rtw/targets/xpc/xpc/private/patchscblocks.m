function patchscblocks(modelname, bio, bioNames)

% PATCHSCBLOCKS - xPC Target private function

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.16.6.2 $ $Date: 2004/04/08 21:04:35 $


disp('### Patch Scope blocks')

currentDir=pwd;
cd('..');

clear([modelname, 'bio']);
if isempty(bio)
  searchcell = {};
else
  [searchcell{1:length(bio)}] = deal(bio.sigAddress);
end
cd(currentDir);
if ~isempty(bio)
    width=cat(1,bio(:).sigWidth)';
    sigidx=filter([0 1],[1 -1],width);
    patchfile([modelname,'.c'], searchcell, bio, bioNames,sigidx);
end
    sFiles=dir([modelname,'_s*.c']);
for s=1:length(sFiles)
  patchfile(sFiles(s).name,searchcell, bio, bioNames,sigidx);
end

function patchfile(filename, searchcell, bio, bio1,sigidx)

fid  = fopen(filename,'r');
cont = fread(fid, '*char')';
fclose(fid);

startSignature='SCBLOCKPATCHSTART';
start1Signature='SCBLOCKPATCHSINDEX';
start2Signature='SCBLOCKPATCHSWIDTH';
stopSignature='SCBLOCKPATCHEND';

modelname = evalin('caller', 'modelname');

startindex=findstr(cont,startSignature);
start1index=findstr(cont,start1Signature);
start2index=findstr(cont,start2Signature);
stopindex=findstr(cont,stopSignature);

if isempty(startindex)
  return;
end

search1=cell(1,length(startindex));
replace1=cell(1,length(startindex));
for i=1:length(startindex)
   search1{i}=cont(startindex(i):stopindex(i)+length(stopSignature)-1);
   searchstr=cont(startindex(i)+length(startSignature):start1index(i)-1);
   sigIndex=str2num(cont(start1index(i)+length(start1Signature):start2index(i)-1));
   sigWidth=str2num(cont(start2index(i)+length(start2Signature):stopindex(i)-1));
   index=strmatch(searchstr,searchcell,'exact');
   if isempty(index)
        index=strmatch([searchstr,'[0]'],searchcell,'exact');
        if isempty(index)
        error(['Block I/O signal ',searchstr,' not available']);
      end
   end
   blkName=bio(index).blkName;
   sigAddress=bio(index).sigAddress;
   index=strmatch(blkName,bio1,'exact');
   index=sigidx(index)+sigIndex;
   replace1(i)={num2str(index)};
end

for i=1:length(search1)
   cont=strrep(cont,search1{i},replace1{i});
end

fid=fopen(filename,'w');
fwrite(fid,cont);
fclose(fid);
