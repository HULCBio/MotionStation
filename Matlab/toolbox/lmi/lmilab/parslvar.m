% called by LMIEDIT

% Authors: P. Gahinet and A. Nemirovski 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.10.2.3 $

function  [addvcmd,varlist]=parslvar(hdl,lminame)


names=char(get(hdl(8),'str'));    % var names
types=char(get(hdl(9),'str'));    % var types
structs=char(get(hdl(10),'str')); % var structures

if isempty(dblnk(names(:))) | isempty(dblnk(types(:))) | ...
   isempty(dblnk(structs(:))),
   addvcmd=' '; return
end

varlist=',';
for t=names',
  t=dblnk(t);
  if ~isempty(t), varlist=[varlist t' ',']; end
end

addvcmd='setlmis([]);';
header='=lmivar(';

nvars=min([size(names,1) size(types,1) size(structs,1)]);

rem1=names(nvars+1:size(names,1),:);
rem2=types(nvars+1:size(types,1),:);
rem3=structs(nvars+1:size(structs,1),:);
if ~isempty(dblnk([rem1(:);rem2(:);rem3(:)])),
  str1='The "variable name", "type", and "structure" text';
  str2='areas should have the same number of lines.';
  parslerr(hdl,str1,str2); addvcmd=' '; return
end

for i=1:nvars,

  X=dblnk(names(i,:));
  type=dblnk(types(i,:));
  struct=dblnk(structs(i,:));

  if ~isempty([X type struct]) & (isempty(X)|isempty(type)|isempty(struct)),
     str1=sprintf('The variable #%d is not completely specified',i);
     parslerr(hdl,str1); addvcmd=' '; return
  elseif ~isempty([X type struct])
     if isempty(findstr(type,'Rr1Ss2Gg3')),
        str1=sprintf('Variable #%d is of unknown type',i);
        parslerr(hdl,str1); addvcmd=' '; return
     end

     type=num2str((~isempty(findstr(type,'Ss1')))+...
                   2*(~isempty(findstr(type,'Rr2')))+...
                   3*(~isempty(findstr(type,'Gg3'))));

     addvcmd=str2mat(addvcmd,[X header type ',' struct ');']);
  end

end
