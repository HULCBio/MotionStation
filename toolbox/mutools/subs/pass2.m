%function [od,odl,fromsys,gains,er] = pass2(i,ard,arl,names,namelen,sysd)
% this works on the data between colons on a INPUT_TO_SYS, determining
% which system the outputs come from (FROMSYS), which particular
% outputs (OD), and the scalar gain (GAINS).

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [od,odl,fromsys,gains,er]=pass2(i,ard,arl,names,namelen,sysdata)
 er = 0;
 maxl = 0;
 od = [];
 odl = [];
 fromsys = [];
 gains = [];
 [num,dummy] = size(ard);
 var = ard(i,1:arl(i));
 lvar = length(var);
 signs = find(var=='+'|var=='-');
 signs = [signs length(var)+1];
 for j=1:length(signs)-1
   if var(signs(j)) == '+'
     pm = 1;
   else
     pm = -1;
   end
   data = var(signs(j)+1:signs(j+1)-1);
   anymult = find(data=='*');
   if isempty(anymult)
     gains = [gains ; pm];
   elseif length(anymult) > 1
     er = 1;
     return
   else
%    test to see if const premult the input or output
     if chstr(data(1:anymult-1)) == 1
      er = 4;
      return
     end
     gains = [gains ; pm*eval(data(1:anymult-1))];
     data = data(anymult+1:length(data));
   end
   lparen = find(data=='(');
   rparen = find(data==')');
   if length(lparen) == 0 & length(rparen) == 0
     [iloc,finderr] = findsys(names,namelen,data);
     if finderr == 1
       er = 5;
       return
     end
     fromsys = [fromsys ; iloc];
     tmp = ['1:' int2str(sysdata(2,iloc)) ];
     od = [od ; [tmp mtblanks(3*lvar-length(tmp))] ];
     odl = [odl ; length(tmp)];
     if length(tmp) > maxl
       maxl = length(tmp);
     end
   elseif length(lparen) == 1 & length(rparen) == 1
     if (rparen(1) == length(data)) & (lparen(1) < rparen(1))
       [iloc,finderr] = findsys(names,namelen,data(1:lparen(1)-1));
       if finderr == 1
         er = 5;
         return
       end
       fromsys = [fromsys ; iloc];
       tmp = data(lparen(1)+1:rparen(1)-1);
       od = [od ; [tmp mtblanks(3*lvar-length(tmp))] ];
       odl = [odl ; length(tmp)];
       if length(tmp) > maxl
         maxl = length(tmp);
       end
     else
       er = 2;
       return
     end
   else
     er = 3;
     return
   end
 end
 od = od(:,1:maxl);
%
%