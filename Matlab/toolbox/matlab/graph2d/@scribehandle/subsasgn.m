function hndl = subsasgn(hndl,S,B);
%SCRIBEHANDLE/SUBSASGN Subscripted assign scribehandle object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.12.4.1 $  $Date: 2004/01/15 21:13:18 $

switch S(1).type
case {'()' '{}' }

   idx = S(1).subs;
	hndlstruct = struct(hndl);
   
   if length(S)>1
		if length(idx) == 1
		   indices = idx{:};
         tmp = class(hndlstruct(idx{:}),'scribehandle');
         tmp = subsasgn(tmp,S(2:end),B);
		   hndl(indices) = tmp;
		else
         tmp = class(hndlstruct(idx{1}(:),idx{2}(:)),'scribehandle');
         tmp = subsasgn(tmp,S(2:end),B);
		   hndl(idx{1}(:),idx{2}(:)) = tmp;
		end
   else
      Bstruct = struct(B);
		hndlstruct(idx{:}) = Bstruct;
		hndl = class(hndlstruct,'scribehandle');
   end

case '.'

   if length(hndl) == 1
      hndls = hndl;
   else
      if iscell(hndl)
         hndls = [hndl{:}];
      end
      [row, col] =  size(hndl);
      if col == 1
         hndls = hndl';
      else
         hndls = hndl;
      end
   end

   for idx = 1:prod(size(hndls))
		aHndl = hndls(idx);
      ud = getscribeobjectdata(aHndl.HGHandle);
      MLObj = ud.ObjectStore;
      switch S(1).subs
      case 'Object'
         MLObj = B;
         % writeback
         ud.ObjectStore = MLObj;
         setscribeobjectdata(aHndl.HGHandle,ud);
      otherwise
         if length(S)==1
            if prod(size(hndls)) == 1
               MLObj = subsasgn(MLObj,S,B);
            else
               MLObj = subsasgn(MLObj,S,B{idx});
            end
         else
            subSet = subsref(MLObj,S(1));
            subSet = subsasgn(subSet,S(2:end),B);
         end
         % writeback
         ud.ObjectStore = MLObj;
         setscribeobjectdata(aHndl.HGHandle,ud);
      end % switch S(1).subs
   end % for aHndl...
end % switch S(1).type




