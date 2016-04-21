function incscid
% incscid - Increments Scope(xPC) ID dialog parameter

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.7.6.1 $  $Date: 2004/04/08 21:02:36 $
scblks = find_system(bdroot, 'LookUnderMasks', 'all', ...
                             'MaskType',       'xpcscopeblock');
ScopeTypes={'Host','Target','File'};                         

if isempty(scblks)
  set_param(gcb, 'scopeno','1');
  return
else
  scid = str2num(char(get_param(scblks, 'scopeno')));
  tmpsctypes = get_param(scblks, 'scopetype');
  blksctypecr=get_param(gcb,'scopeType');
  idx=strmatch(blksctypecr,tmpsctypes,'exact');
  if length(idx) > 10
         error(['You can only have up to ten scope blocks of Type ',blksctypecr])  
  end
  newscid = setdiff([1 : max(scid) + 1], scid);
  set_param(gcb,'Scopeno', sprintf('%d', newscid(1)));
end

thisScType=get_param(gcb,'scopetype');
thisFileName=get_param(gcb,'FileName');


if strcmp(thisScType,'File')
   Fidx=strmatch('File',tmpsctypes,'exact');
   if (length(Fidx) == 1)%no file blocks dont increment
       return
   end
   if ~strcmp(thisFileName,'auto') %has a default name specified we increment by adding scId
        fileblks=scblks(Fidx);
        AllfileNames=get_param(fileblks,'FileName');
        %search for all string with filenamexx.dat
        pat=rettokpat(thisFileName);
        idx=regexp(AllfileNames,pat);
        D=cellfun('isempty',idx);
        symfnidx=find(cellfun('isempty',idx)==0);
        AllfileNames=AllfileNames(symfnidx);
        [y,idxsort]=sort(AllfileNames);
        stridx=strmatch(thisFileName,AllfileNames,'exact');
        if ~isempty(stridx) %proccess the increment of filename
            newfname=filenameinc(y{end});
            set_param(gcb, 'FileName',newfname);           
        end        
    end%if auto    
end%if file
%%%%%%%%%%%%%%%%%%%%%%   

%%%%%%%%%%%%%%%%%%%%%%   
function newFileName=filenameinc(fname)
dotidx=findstr(fname,'.');
if ~isempty(dotidx)%file has extension filename.dat
    FileNamebef=fname(1:dotidx-1);
    FileExt=fname(dotidx+1:end);
    %check if filename has number to increment
    idsofstr=regexp(FileNamebef,'\D');
    numstrend=FileNamebef(idsofstr(end)+1:end);
    if ~isempty(numstrend) %file is filename11..
        newFileName=[FileNamebef(1:idsofstr(end)),num2str((str2num(numstrend) + 1)),'.',FileExt];    
        %set_param(gcb, 'FileName',newFileName);    
    else %file is filename
        newFileName=[FileNamebef,'1','.',FileExt];    
        %set_param(gcb, 'FileName',newFileName);    
    end
else%filename contains no extension....  filename
    idsofstr=regexp(fname,'\D');
    numstrend=fname(idsofstr(end)+1:end);
    if ~isempty(numstrend) %file is filename11..
        newFileName=[fname(1:idsofstr(end)),num2str((str2num(numstrend) + 1))];    
    else %file is filename
        newFileName=[fname,'1'];
        %set_param(gcb, 'FileName',newFileName);
    end
end        
%%%%%%%%%%%%%%%%%%%%%%   
function pat=rettokpat(fname)
dotidx=findstr(fname,'.');
if ~isempty(dotidx)
    FileNamebef=fname(1:dotidx-1);
    FileExt=fname(dotidx+1:end);
    idsofstr=regexp(FileNamebef,'\D');
    numstrend=FileNamebef(idsofstr(end)+1:end);
    if ~isempty(numstrend) 
        newFileName=[FileNamebef(1:idsofstr(end)),num2str((str2num(numstrend) + 1)),'.',FileExt];    
        pat=[FileNamebef(1:idsofstr(end)),'+\d+[.',FileExt,']'];        
    else %file is filename
        pat=[FileNamebef((1:idsofstr(end))),'+[.',FileExt,']'];
    end
else%filename contains no extension....  filename
    idsofstr=regexp(fname,'\D');
    numstrend=fname(idsofstr(end)+1:end);
    if ~isempty(numstrend) %file is filename11..
        pat=[fname(1:idsofstr(end)),'+\d'];        
    else %file is filename
        pat=[fname(1:idsofstr(end))];        
    end    
end
%%%%%%%%%%%%%%%%%%%%%%   
        