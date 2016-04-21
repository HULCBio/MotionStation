
%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

 function [gam,except] = gpredict(grdata,minrat,maxrat)

   [npts,dum] = size(grdata);
   gdata = grdata(:,2);
   [gdata,ind] = sort(gdata);
   rdata = grdata(ind,1);
   llow = max(find(rdata>1));
   glow = gdata(llow);
   lhigh = min(find(rdata<1));
   ghigh = gdata(lhigh);
   if llow >= 2
     llow = llow - 1;
   end
   if lhigh <= npts-1
     lhigh = lhigh + 1;
   end
   inclu = llow:lhigh;
   rdata = rdata(inclu);
   gdata = gdata(inclu);
   npts = length(inclu);
   except = 0;

   if npts == 2
     a = [gdata ones(npts,1)];
     ab = a\rdata;
     a = ab(1);
     b = ab(2);
     if a < 0
       gpr = (1-b)/a;
       if gpr < glow + minrat*(ghigh-glow)
         gam = glow + minrat*(ghigh-glow);
       elseif gpr > glow + maxrat*(ghigh-glow)
         gam = glow + maxrat*(ghigh-glow);
       else
         gam = gpr;
       end
     else
       except = 1;
       gam = 0.5*glow + 0.5*ghigh;
     end
   else
     a = [gdata.*gdata gdata ones(npts,1)];
     abc = a\rdata;
     a = abc(1);
     b = abc(2);
     c = abc(3);
     if a > 0
       gpr = (-b-sqrt(b*b-4*a*c+4*a))/2/a;
       if gpr < glow + minrat*(ghigh-glow)
         gam = glow + minrat*(ghigh-glow);
       elseif gpr > glow + maxrat*(ghigh-glow)
         gam = glow + maxrat*(ghigh-glow);
       else
         gam = gpr;
       end
     else
       except = 1;
       gam = 0.5*glow + 0.5*ghigh;
     end
   end