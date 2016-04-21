% function [omega,chflg] = chomega(omega)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

function [omega,chflg] = chomega(omega)

  omega_in = omega;

  szi = 4;
  item1header = [blanks(szi) '(s) Frequency  Spacing']; item1t = 'car';
  item2header = [blanks(szi) '(n) # Frequency Points']; item2t = 'int';
  item3header = [blanks(szi) '(b) Frequency - bottom']; item3t = 'float';
  item4header = [blanks(szi) '(h) Frequency  -  high']; item4t = 'float';
  numitem = 4;
  itemwidth = 30;
  fldw = 10;
  extras = 34;
  tlin = itemwidth + fldw + extras;
  justin = 0;


checkgo = 1;
while checkgo
   justin = justin + 1;
   dat = zeros(4,1);
   mlogsp = max(diff(log(omega))) - min(diff(log(omega)));
   mlinsp = max(diff(omega)) - min(diff(omega));
%   [mlogsp mlinsp]
   if abs(mlogsp) < 1e-5
     spacing = 'log';
     dat(1) = 1;
   elseif abs(mlinsp) < 1e-5
     dat(1) = 2;
     spacing = 'linear';
   else
     dat(1) = 3;
     spacing = 'custom';
   end
   dat(2) = length(omega);
   npts = dat(2);
   dat(3) = min(omega);
   wmin = dat(3);
   dat(4) = max(omega);
   wmax = dat(4);
   dida = [];

   for i = 1:numitem
    co = ['lin = [item' int2str(i) 'header blanks(' ...
          'itemwidth-length(item' int2str(i) 'header))];'];
    eval(co);
    eval(['ty = item' int2str(i) 't;']);
    if strcmp(ty,'int')
       lin = [lin blanks(fldw-length(int2str(dat(i)))) ...
              int2str(dat(i)) blanks(extras)];
    elseif strcmp(ty,'float')
      if abs(dat(i)) >= 1000
        textv = sprintf('%8.2e',dat(i));
      elseif abs(dat(i)) >= 100 & abs(dat(i)) < 1000
        textv = sprintf('%8.0f',dat(i));
      elseif abs(dat(i)) >= 10 & abs(dat(i)) < 100
        textv = sprintf('%8.1f',dat(i));
      elseif abs(dat(i)) < 10 & abs(dat(i)) > 0.1
        textv = sprintf('%6.3f',dat(i));
      elseif abs(dat(i)) <= 0.1
        textv = sprintf('%8.2e',dat(i));
      end
      lin = [lin blanks(fldw-length(textv)) textv blanks(extras)];
    elseif strcmp(ty,'car')
      if dat(i) == 1
        textv = 'log';
      elseif dat(i) == 2
        textv = 'linear';
      else
        textv = 'custom';
      end
      lin = [lin blanks(fldw-length(textv)) textv blanks(extras)];
      if justin >= 2 & strcmp(textv,'custom')
        if length(om) < tlin-16
          lin = [lin ; ['        Omega = ' om blanks(tlin-16-length(om))]];
        else
          lin = [lin ; ['        Omega = ' om(1:tlin-16-3) '...']];
        end
      end
    end
    dida = [dida;lin];
   end
   thetitle = [blanks(szi) 'Current Frequency Variable'];
   topline=[thetitle blanks(length(lin)-length(thetitle))];
   dida = [topline ;...
           blanks(szi) setstr(ones(1,length(lin)-szi)*'-') ; dida];
   disp(dida)

   if strcmp(spacing,'custom')
     ssgo = 1;
     while ssgo
       if justin == 1
         x = [blanks(szi-1) ...
             'Enter (s) to change spacing, (u) to exit with OMEGA unchanged: '];
       else
         x = [blanks(szi-1) 'Enter (s) to change spacing, (e) to exit: '];
       end
       cc = input(x,'s');
       if strcmp(cc,'s') | strcmp(cc,'e') | strcmp(cc,'u')
         ssgo = 0;
       end
     end
   else
     if justin == 1
       x=[blanks(szi-1) 'Enter (s n b and/or h) to change OMEGA, (e) to exit unchanged: '];
     else
       x = [blanks(szi-1) 'Enter (s n b h) to change, (e) to exit: '];
     end
     cc = input(x,'s');
   end
   noquotes = find(cc~='''');
   cc = cc(noquotes);
   if strcmp(cc,'e') | strcmp(cc,'u')
     checkgo = 0;
   else
     if any(cc=='s')
       sgo = 1;
       disp(' ')
       disp(' ')
       disp([blanks(szi) '----------  SPACING  ----------'])
       while sgo
         x = [blanks(szi-1) 'Enter log, linear, or custom: '];
         spacing = input(x,'s');
         noquotes = find(spacing~='''');
         spacing = spacing(noquotes);
         if ~strcmp(spacing,'log') & ...
             ~strcmp(spacing,'linear') & ~strcmp(spacing,'custom')
           disp('Please enter log, linear or custom');
         else
           sgo = 0;
         end
       end
       if strcmp(spacing,'custom')
         disp('    Enter custom OMEGA as a valid MATLAB row vector')
         om = input('    OMEGA = ','s');
         notcolon = find(om~=';');
         om = om(notcolon);
         eval(['omega = ' setstr(om) ';']);
       else
         if any(cc=='n')
           ngo = 1;
           disp(' ')
           disp(' ')
           disp([blanks(szi) '--------- CHANGING # of Points  ---------'])
           while ngo
             x = [blanks(szi-1) 'Enter desired # of points: '];
             npts = input(x);
             if floor(npts) == ceil(npts) & max(size(npts)) == 1 &...
                 real(npts) >= 1 & imag(npts) == 0
               ngo = 0;
             else
               disp('# of points should be positive integer');
             end
           end
         end
         if any(cc=='b')
           bgo = 1;
           disp(' ')
           disp(' ')
           disp([blanks(szi) '---------- CHANGING min(OMEGA_DK)  ----------'])
           while bgo
             x = [blanks(szi-1) 'Enter omega_min: '];
             wmin = input(x);
             if  real(wmin) > 0 & imag(wmin) == 0
               bgo = 0;
             else
               disp('omega_min should be a positive number');
             end
           end
         end
         if any(cc=='h')
           hgo = 1;
           disp(' ')
           disp(' ')
           disp([blanks(szi) '---------- CHANGING max(OMEGA_DK)  ----------'])
           while hgo
             x = [blanks(szi-1) 'Enter omega_max: '];
             wmax = input(x);
             if  real(wmax) > 0 & imag(wmax) == 0
               hgo = 0;
             else
               disp('omega_max should be a positive number');
             end
           end
         end
       end
     else
       if any(cc=='n')
         ngo = 1;
         disp(' ')
         disp(' ')
         disp([blanks(szi) '----------  CHANGING # of Points  ----------'])
         while ngo
           x = [blanks(szi-1) 'Enter desired # of points: '];
           npts = input(x);
           if floor(npts) == ceil(npts) & max(size(npts)) == 1 &...
               real(npts) >= 1 & imag(npts) == 0
             ngo = 0;
           else
             disp('# of points should be positive integer');
           end
         end
       end
       if any(cc=='b')
         bgo = 1;
         disp(' ')
         disp(' ')
         disp([blanks(szi) '---------- CHANGING min(OMEGA_DK)  ----------'])
         while bgo
           x = [blanks(szi-1) 'Enter omega_min: '];
           wmin = input(x);
           if  real(wmin) > 0 & imag(wmin) == 0
             bgo = 0;
           else
             disp('omega_min should be a positive number');
           end
         end
       end
       if any(cc=='h')
         hgo = 1;
         disp(' ')
         disp(' ')
         disp([blanks(szi) '---------- CHANGING max(OMEGA_DK)  ----------'])
         while hgo
           x = [blanks(szi-1) 'Enter omega_max: '];
           wmax = input(x);
           if  real(wmax) > 0 & imag(wmax) == 0
             hgo = 0;
           else
             disp('omega_max should be a positive number');
           end
         end
       end
     end
     if strcmp(spacing,'log')
       if wmin <= 0 | wmax <= 0
         disp('WARNING: taking log of negative numbers, check results!')
       end
       omega = logspace(log10(wmin),log10(wmax),npts);
     elseif strcmp(spacing,'linear')
       omega = linspace(wmin,wmax,npts);
     end
     disp(' ')
   end
end
chflg = 1;
if length(omega_in) == length(omega)
  if omega_in == omega
    chflg = 0;
  end
end
