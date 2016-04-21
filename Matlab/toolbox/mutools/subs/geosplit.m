%function out = geosplit(freq)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

function out = geosplit(freq)

   freq = sort(freq);
   if length(freq) == 1
     out = freq;
   else
     posf = freq(find(freq>0));
     if length(posf) == length(freq)
       out = sqrt(posf(1:length(posf)-1).*posf(2:length(posf)));
     else % NOT ALL POSITIVE
       negf = freq(find(freq<0));
       if length(negf) == length(freq)
         out = -sqrt(negf(1:length(negf)-1).*negf(2:length(negf)));
       else % NOT ALL NEGATIVE and NOT ALL POSITIVE
         if length(posf)+length(negf) == length(freq)
%          BOTH EXIST, BUT NO ZERO
           posp = sqrt(posf(1:length(posf)-1).*posf(2:length(posf)));
           negp = -sqrt(negf(1:length(negf)-1).*negf(2:length(negf)));
           midpoint = sign(posf(1)+negf(length(negf)))* ...
                      sqrt(abs(posf(1)*negf(length(negf))));
           out = [negp midpoint posp];
         else
%          ONE OR BOTH EXIST, PLUS ZERO
           if isempty(negf)
%          if length(posf)+1 == length(freq)
%            POSITIVE PLUS ZERO
             posp = sqrt(posf(1:length(posf)-1).*posf(2:length(posf)));
             leftpoint = 0.5*posf(1);
             out = [leftpoint posp];
           elseif isempty(posf)
%          elseif length(negf)+1 == length(freq)
%            NEGATIVE PLUS ZERO(S)
             negp = -sqrt(negf(1:length(negf)-1).*negf(2:length(negf)));
             rightpoint = 0.5*negf(length(negf));
             out = [negp rightpoint];
           else
             posp = sqrt(posf(1:length(posf)-1).*posf(2:length(posf)));
             leftpoint = 0.5*posf(1);
             negp = -sqrt(negf(1:length(negf)-1).*negf(2:length(negf)));
             rightpoint = 0.5*negf(length(negf));
             out = [negp rightpoint leftpoint posp];
           end
         end
       end
     end
   end
%
%