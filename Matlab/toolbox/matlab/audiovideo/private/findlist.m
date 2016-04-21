function [listsize,msg] = findlist(fid,listtype)
%FINDLIST find LIST in AVI
%   [LISTSIZE,MSG] = FINDLIST(FID,LISTTYPE) finds the LISTTYPE 'LIST' in
%   the file represented by FID and returns LISTSIZE, the size of the LIST,
%   and MSG. If the LIST is not found, MSG will contain a string with an
%   error message, otherwise MSG is empty.  Unknown chunks in the AVI file
%   are ignored. 

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/03/30 13:06:55 $


% Search for the LIST, ignore unknown chunks
found = -1;
while(found == -1)
  [chunk,msg] = findchunk(fid,'LIST');
  error(msg);
  [checktype,msg] = readfourcc(fid);
  error(msg);
  if (checktype == listtype)
    listsize = chunk.cksize;
    break;
  else
    fseek(fid,-4,0); %Go back so we can skip the LIST
    msg = skipchunk(fid,chunk); 
    error(msg);
  end
  if ( feof(fid) ) 
    msg = sprintf('LIST ''%s'' did not appear as expected',listtype);
    listsize = -1;
  end
end
return;
