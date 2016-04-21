function [bio, bioNames] = biotarget(biofile)

% BIOTARGET - xPC Target private function

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.11.6.1 $ $Date: 2004/04/08 21:04:25 $

biofile=biofile(4:end);
actdir=pwd;
cd('..');
eval(['bio=',biofile,'bio;']);
cd(actdir);
if isempty(bio)
  names = {};
  bioNames=[];
  %return
else
  [names{1:length(bio)}]=deal(bio.blkName);
end
%handle warning for non-unique long signal names
% flag=0;
% blklabels=cellstr(strvcat(1,bio(:).blkName));
% blklabels=blklabels(2:end);
% inststr=unique(blklabels);
% 
% if (length(inststr) < length(blklabels))
%         flag=1;
% end
% if (flag)
%    cr=sprintf('\n');
%    maxnamelen=num2str(namelengthmax);
%    messagestr=['WARNING! Detected block labels in Simulink model that contain more than ',...
%                maxnamelen,'  characters.',cr,'Currently xPC Target does not support ',...
%                'Simulink block labels that contain more than ', maxnamelen, cr,'characters long', ...
%                'please shorten any block labels which contain more than ',maxnamelen,' characters.'];
%    warndlg(messagestr)
% end
if isempty(bio)
  names = {};
  sortnames={};
  numofblockIO=0;
else
  [names{1:length(bio)}]=deal(bio.blkName);
end
% Calculate the signal indexes for each block io element
if ~isempty(bio)
    width=cat(1,bio(:).sigWidth)';
    sigidx=filter([0 1],[1 -1],width);
    bioNames=names;
    [sortnames, map]= sort(names);
    sigid=sigidx(map);
    width=width(map);
    [maxid,mxidx]=max(sigid);
    
    if width(mxidx) > 1
        numofblockIO=maxid+width(mxidx);
    else
        numofblockIO=maxid+1;
    end
    map1=map-1;
end    

% generate model_xpctarget.bio file
fid=fopen('xpctarget.bio','w');

fprintf(fid,'const SortedBlockIOSignals sortedBIO[] =\n');
fprintf(fid,'  {\n');
for i=1:length(sortnames)
   fprintf(fid,'    {\n');
%  fprintf(fid,'      "%s",\n', sortnames{i});
%  fprintf(fid,'      %d, %d\n', map1(i),width1(i));
   fprintf(fid,'      %d,%d,%d\n', map1(i),sigid(i),width(i));
   fprintf(fid,'    },\n');
end
fprintf(fid,'    {\n');
fprintf(fid,'      -1, -1,%d\n',numofblockIO);
fprintf(fid,'    }\n');
fprintf(fid,'  };\n');

fclose(fid);
