function setContents(this,s,Vars)
%SETCONTENTS  Sets values of all variable and link.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/11 00:28:58 $
if isempty(this.Storage)
   return
end
if nargin==2
   VarNames = getFields(this);
else
   VarNames = get(Vars,{'Name'});
end

% Update sample size
[junk,ia,ib] = intersect(getvars(this),Vars);
for ct=1:length(ia)
   this.Data_(ia(ct)).SampleSize = hdsGetSize(s.(Vars(ib(ct)).Name));
end

% Write data to file
try
   save(this.Storage.FileName,'-struct','s',VarNames{:},'-append')
catch
   try
      save(this.Storage.FileName,'-struct','s',VarNames{:})
   catch
      warning(sprintf('Cannot write to file %s',this.Storage.FileName))
   end
end

% TEMPORARY util g153395 gets saved
% for v_index=1:length(VarNames)
%    eval([VarNames{v_index} ' = c{v_index};']);
% end
% 
% if exist(this.Storage.FileName,'file')
% 	varNames{end+1} = '-append';
% end
% 
% try 
% 	save(this.Storage.FileName,VarNames{:})
% catch
% 	warning(sprintf('Cannot write to file %s',this.Storage.FileName))
% end
