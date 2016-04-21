function pnum = pnam2num(Plist,Pname)
% PNAM2NUM Transforms Parameternames to Parameternumbers
%
%   PNUM = PNAM2NUM(Plist,Pname)
%
%   Plist, Pname: Cell arrays of strings.
%   PNUM: A vector, with i'th entry Pi being such that Plist{i} = Pname{Pi}.
%   
%   An entry in Plist, with a trailing '*' is interpreted as a wildcard for 
%   all strings that match, up to this symbol.
%
%   An entry in Plist with the symbol '?' is interpreted as a wildcard for
%   all strings that match, except for the symbol in this position.

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.2 $ $Date: 2001/04/06 14:21:57 $

pnum = [];
if isa(Plist,'double') % just return a sorted list
   pnum = unique(sort(Plist));
   return
end
if ~iscell(Plist),
   Plist = {Plist};
end
qm = strmatch('?',Plist);

for kl = 1:length(Plist)
   pn = Plist{kl};
   qmnr = find(pn == '?');
   if ~isempty(qmnr) % then there is a '?' wildcard
      asnr = find(pn=='*');
      if ~isempty(asnr)
         error('Both wildcards ''*'' and ''?'' in the same entry is not supported.')
      end
      
      %qmnr = find(pn=='?');
      for kk = 1:length(Pname)
         pnk = Pname{kk};
         try
            if strcmp(pn([1:qmnr-1,qmnr+1:length(pn)]),...
                  pnk([1:qmnr-1,qmnr+1:length(pnk)]))
               pnum=[pnum;kk];
            end
         end
      end
   else
      
      if ~isempty(pn)
         asnr = find(pn=='*');
         if ~isempty(asnr)
            if asnr>1
               ppn = strmatch(pn(1:asnr-1),Pname);
            else
               pnum = [1:length(Pname)]';
               break
            end
            
            pnum = [pnum;ppn];
         else
            ppn = strmatch(pn,Pname,'exact');
            if isempty(ppn)
               warning(sprintf('%s is not a parameter name.',pn))
            else
               pnum=[pnum;ppn];
            end
         end
      end
   end
end
pnum = unique(sort(pnum));

