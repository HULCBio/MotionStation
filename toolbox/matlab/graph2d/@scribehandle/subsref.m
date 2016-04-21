function B = subsref(hndl,S)
%SCRIBEHANDLE/SUBSREF Subscripted reference for scribehandle object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.13.4.1 $  $Date: 2004/01/15 21:13:19 $


switch S(1).type
case {'()' '{}' }
   indices = S(1).subs;
   structH = struct(hndl);
   tmp = structH(indices{:});
   %We temporarily skip the overloading due to a language problem
   %B= class(tmp,'scribehandle');
   B=builtin('class',tmp,'scribehandle');
   if length(S)>1
      B = subsref(B,S(2:end));
   end
case '.'
   Hstruct = struct(hndl);
   HG = squeeze(struct2cell(Hstruct));
   switch S(1).subs
   case 'Object'
      for idx = 1:prod(size(HG))
         ud = getscribeobjectdata(HG{idx});
         MLObj = ud.ObjectStore;
         if idx == 1
        	B = MLObj;
         else
        	B = [B MLObj];
         end
      end
	  B = reshape(B,size(hndl));
   case 'HGHandle'
      if prod(size(HG)) == 1
         B = HG{1};
      else
         B = HG;
      end
   otherwise
      for idx = 1:prod(size(HG))
         ud = getscribeobjectdata(HG{idx});
         MLObj = ud.ObjectStore;
         if idx == 1
	         B = {subsref(MLObj,S)};
         else
             B = [B {subsref(MLObj,S)}];
         end
      end
      if prod(size(hndl)) == 1
          B = B{:};
      else
          B = reshape(B,size(hndl));
      end
   end
end % switch



