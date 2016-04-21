%function [arraydata,arraylen,err] = pass1(var)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

%mod 7/6/90
%  simply pulls apart a    INPUT_TO_     or     OUTPUTVAR
%  variable to get the various channels that make it up
%   EXAMPLE:   >> var = '[ andy(3,4) + johanna ; -tedd - keith + john(7)]';
%              >> [arraydata,arraylen,err] = pass1(var);
%
%      THEN  arraydata = (character string array, a line for each
%                                                     set of channels)
%                         +andy(3,4)+johanna
%                         -tedd-keith+john(7)
%
%            arraylen = (integer array, lengths of the strings)
%                         18
%                         19
%
%            err = 0 (integer, signifies all is OK)
%
function [arraydata,arraylen,err] = pass1(var)
 err = 0;
 var = var(find(var~=' '));
 if var(1) ~= '[' | var(length(var)) ~= ']'
   err = 1;
 else
   var = var(2:length(var)-1);
   if length(find(var=='[' | var==']')) > 0
     err = 5;
     return
   end
   scol = find(var==';');
   lparens = find(var=='(');
   rparens = find(var==')');
   if length(lparens) ~= length(rparens)
     err = 2;
   else
%    lefts have to occur before rights
     if min(rparens-lparens) <= 0
       err = 3;
     else
       go = 1;
       j = 1;
       while go == 1
         if length(scol) > 0
           if length(find(scol(j)>rparens)) ~= length(find(scol(j)>lparens))
             go = 0;
             err = 4;
             return
           end
         end
         j = j+1;
         if j > length(scol)
           go = 0;
           arraydata = [];
           arraylen = [];
           tlen = length(var);
           places = [0 scol length(var)+1];
           for i=1:length(scol)+1
             data = var(places(i)+1:places(i+1)-1);
             if data(1) ~= '+' & data(1) ~= '-'
               data = ['+' data];
             end
             arraylen = [arraylen ; length(data) ];
             arraydata = [arraydata ; data mtblanks(tlen-length(data)) ];
           end
           arraydata = arraydata(:,1:max(arraylen));
         end
       end
     end
   end
 end