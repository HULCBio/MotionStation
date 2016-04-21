function [noverlap,str,overlap] = defnum2(nos,sym,newstring,skip)
% DEFNUM2  Sets Default channel names
%
%   [No_overl,STRING,Overlap] = DEFNUM2(OLDSTRING,SYMBOL,NEWSTRING)
%
%   No_overlap is the row vector of those entries of NEWSTRING
%   that do not overlap with entries in OLDSTRING
%   STRING is the concatenated {OLDSTRING;NEWSTRING} of surviving
%   entries.
%   Overlaps of the type 'SYMBOL#' (like 'u3') are renamed and don't
%   count as overlaps

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2001/04/06 14:21:48 $

if nargin<4
   str = nos;
else
   str = [];
   nos1=[];
for kk=1:length(nos)
   if ~any(kk==skip)
      nos1=[nos1;nos(kk)];
   end
end
nos = nos1;

end
noverlap =[];
overlap = [];
l = length(nos)+1;

for kk = 1:length(newstring)
   no = find(strcmp(str,newstring{kk}));
   if isempty(no)
      str = [str;newstring(kk)];
      l = l+1;
      noverlap = [noverlap,kk];
    else
      tv = newstring{kk};
      if length(tv)>length(sym) & ...
            tv(1:length(sym))==sym & abs(abs(tv(length(sym)+1))-53)<5
         % this means that the overlap should be ignored
         ov = 1;
         while ov
            newsym = [sym,int2str(l)];
            if any(strcmp(str,newsym))
               ov = 1; l=l+1;
            else
               ov = 0;
            end
         end 
         str = [str;{newsym}]; 
         l = l+1;
         noverlap = [noverlap,kk];
      else
         overlap = [overlap,kk];
         %str = [str;{tv}];
      end 
   end
end

 