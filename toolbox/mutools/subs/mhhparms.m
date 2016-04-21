% function [gmax_new,gmin_new,gtol_new,epd_new,epr_new] = ...
%           mhhsparm(gmax,gmin,gtol,epd,epr,premax)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [gmax_new,gmin_new,gtol_new,epd_new,epr_new] = ...
          mhhsparm(gmax,gmin,gtol,epd,epr,premax)

  szi = 4;
  item1header = [blanks(szi) '(u) GAMMA Upper Bound'];
  item1t = 'float';
%  item2header = [blanks(szi) '    Estimated GAMMA Upper Bound'];
%  item2t = 'float';
  item2header = [blanks(szi) '(l) GAMMA Lower Bound'];
  item2t = 'float';
  item3header = [blanks(szi) '(t) Bisection Tolerance'];
  item3t = 'float';
  item4header = [blanks(szi) '(p) Riccati PSD epsilon'];
  item4t = 'float';
  item5header = [blanks(szi) '(j) Riccati j-w epsilon'];
  item5t = 'float';

  numitem = 6;
  itemwidth = 34;
  fldw = 14;
  justin = 0;
  gmax_new = premax;
  gmin_new = gmin;
  gtol_new = 0.02*(gmax_new-gmin);
  epd_new = epd;
  epr_new = epr;
  pdat = [gmax;gmin;gtol;epd;epr];
  t1 = 'HINFSYN Settings';
  t2 = 'Previously';
  t3 = 'Next';

checkgo = 1;
while checkgo
   dat = [gmax_new;gmin_new;gtol_new;epd_new;epr_new];
   justin = justin + 1;
   dida = [];
   for i = 1:5
    co = ['lin = [item' int2str(i) 'header blanks(' ...
          'itemwidth-length(item' int2str(i) 'header))];'];
    eval(co);
    eval(['ty = item' int2str(i) 't;']);
    if strcmp(ty,'int')
       lin = [lin blanks(fldw-length(int2str(pdat(i)))) int2str(pdat(i))];
       lin = [lin blanks(fldw-length(int2str(dat(i)))) int2str(dat(i))];
    elseif strcmp(ty,'float')
      if abs(pdat(i)) >= 1000
        textpv = sprintf('%8.2e',pdat(i));
      elseif abs(pdat(i)) >= 100 & abs(pdat(i)) < 1000
        textpv = sprintf('%8.0f',pdat(i));
      elseif abs(pdat(i)) >= 10 & abs(pdat(i)) < 100
        textpv = sprintf('%8.1f',pdat(i));
      elseif abs(pdat(i)) < 10 & abs(pdat(i)) > 0.1
        textpv = sprintf('%6.3f',pdat(i));
      elseif abs(pdat(i)) <= 0.1 & abs(pdat(i)) > 0
        textpv = sprintf('%8.2e',pdat(i));
      else
        textpv = sprintf('%6.2e',pdat(i));
      end
      if abs(dat(i)) >= 1000
        textv = sprintf('%8.2e',dat(i));
      elseif abs(dat(i)) >= 100 & abs(dat(i)) < 1000
        textv = sprintf('%8.0f',dat(i));
      elseif abs(dat(i)) >= 10 & abs(dat(i)) < 100
        textv = sprintf('%8.1f',dat(i));
      elseif abs(dat(i)) < 10 & abs(dat(i)) > 0.1
        textv = sprintf('%6.3f',dat(i));
      elseif abs(dat(i)) <= 0.1 & abs(dat(i)) > 0
        textv = sprintf('%8.2e',dat(i));
      else
        textv = sprintf('%6.2e',dat(i));
      end
      lin = [lin blanks(fldw-length(textpv)) textpv];
      lin = [lin blanks(fldw-length(textv)) textv];
    end
    dida = [dida;lin];
   end
   thetitle = [blanks(szi) t1 blanks(itemwidth-szi-length(t1)) ...
                 blanks(fldw-length(t2)) t2 ...
                 blanks(fldw-length(t3)) t3];
   topline=[thetitle blanks(length(lin)-length(thetitle))];
   dida = [topline ; blanks(szi) setstr(ones(1,length(lin)-szi)*'-') ; dida];
   disp(dida)

   x = [blanks(szi-1) 'Enter (u l t p j) to change, (e) to exit: '];
   cc = input(x,'s');

   noquotes = find(cc~='''');
   if isempty(cc)
	cc = 'a';
   end
   cc = cc(noquotes);
   if strcmp(cc,'e')
     checkgo = 0;
   else
     if any(cc=='u')
       ugo = 1;
       while ugo
         x = [blanks(szi-1) 'Enter new GAMMA Upper bound: '];
         gmax_new = input(x);
         if real(gmax_new) > 0 & imag(gmax_new) == 0
           ugo = 0;
         else
           disp('GAMMA Upper bound should be Positive');
         end
       end
     end
     if any(cc=='l')
       lgo = 1;
       while lgo
         x = [blanks(szi-1) 'Enter new GAMMA Lower bound: '];
         gmin_new = input(x);
         if real(gmin_new) >= 0 & imag(gmin_new) == 0
           lgo = 0;
         else
           disp('GAMMA Lower bound should be Non-Negative');
         end
       end
     end
     if any(cc=='t')
       tgo = 1;
       while tgo
         x = [blanks(szi-1) 'Enter new Bisection Tolerance: '];
         gtol_new = input(x);
         if real(gtol_new) > 0 & imag(gtol_new) == 0
           tgo = 0;
         else
           disp('Bisection tolerance should be positive: ');
         end
       end
     end
     if any(cc=='p')
       pgo = 1;
       while pgo
         x = [blanks(szi-1) 'Enter new Riccati PSD Tolerance: '];
         epd_new = input(x);
         if real(epd_new) > 0 & imag(epd_new) == 0
           pgo = 0;
         else
           disp('Riccati PSD tolerance should be positive: ');
         end
       end
     end
     if any(cc=='j')
       jgo = 1;
       while jgo
         x = [blanks(szi-1) 'Enter new Riccati j-w Tolerance: '];
         epr_new = input(x);
         if real(epr_new) > 0 & imag(epr_new) == 0
           jgo = 0;
         else
           disp('Riccati j-w tolerance should be positive: ');
         end
       end
     end
     disp(' ')
   end
end
disp(' ')