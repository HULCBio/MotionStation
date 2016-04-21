function s = poly2str(p,ch,ppar)
%POLY2STR Return polynomial as string.
%       S = POLY2STR(P,ch) where ch is 's', 'z', 'z^-1', or 'q'
%       returns a string S consisting of the polynomial coefficients 
%       in the vector P multiplied by powers of the transform variable 
%       's', 'z', 'z^-1', or 'q'.  Quite similar to old poly2str.
%
%       Example: POLY2STR([1 0 2],'s') returns the string  's^2 + 2'. 

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2001/10/12 15:57:16 $

form = '%.4g';
relprec = 0.0005;   % 1+relprec displays as 1
if nargin < 3
   ppar=zeros(size(p));
end
if isempty(ppar)
   ppar=zeros(size(p));
end


ind = find(p);
if isempty(ind),
   s = '0';
   return
elseif length(p)==1,
   % Quick exit if constant gain
   if p==round(p) & abs(p) < 1e6,
      s = int2str(p);
   else
      s = sprintf(form,p);
   end
   return
end

zinv = 0;
if strcmp(ch,'z^-1'),
   ch = 'Q';
   chz = 1;
   zinv = 1;
elseif strcmp(ch,'q'),
   ch='Q';
   chz=0;
   zinv=1;
end


if strcmp(lower(ch),'q'),
   % Ascending powers
   pow = 0:length(p)-1;
else
   % Descending power
   pow = length(p)-1:-1:0;
end
pow = pow(ind); 
s = '';
% For each non-zero element of the polynomial ...
for i=1:length(ind),
   pi = pow(i);
   el = p(ind(i));
   stdev = ppar(ind(i));
   if stdev ~=0
      stdev = [' (+-',sprintf('%.4g',stdev),')'];
   else
      stdev = '';
   end
   pii = imag(el);
   if pii ~=0
      if pii>0
         pm = ' + ';
      else
         pm = ' - ';
      end
       if abs(abs(pii)-1)<relprec
           stdev = [pm,'i)'];
       else
      stdev = [pm,sprintf('%.2g',abs(pii)),'i)'];
  end
   end
   
   % ... if it's not the first non-zero element of the polynomial ...
   if i~=1,
      if pii ~=0
         s = [s ' + ('];
      else
         if el>0,
            % Add a plus sign if the element is positive
            s = [s ' + '];
         else
            % Add a minus sign if the element is negative
            s = [s ' - '];  
         end
      end
   else
      if isreal(el)
         if el<0,
            s = [s '-'];
            end
         else
            s = [s '('];
         end
      end
      % If the element isn't 1, or display in "/", or power is zero
      if isreal(el)
         el = abs(el);
         cflag = 0;
      else
         el = real(el);
         cflag = 1;
      end
      if abs(el-1)>relprec | (pi==0) | cflag, %% complex case
         % Add the absolute value of the element
         if el==round(el) & el < 1e6,
            s = [s int2str(el) stdev blanks(pi~=0)];
         else
            s = [s sprintf(form,el) stdev blanks(pi~=0)];
         end
      end
      % Note: in following clause, never print "ch" to 0th power
   if pi==1,
      % Positive powers don't need exponents if to the 1st power
      s = [s ch];
   elseif pi~=0,
      % As long as the power is non-zero add "ch" raised to power
      s = [s ch '^' int2str(pi)];
   end
end

% Take care of ch='z^-1'
if zinv,
   if chz
      rep1='z^-';
      rep2='z^-1';
   else
      rep1='q^-';
      rep2='q^-1';
   end
   
  s = strrep(s,'Q^',rep1);
  s = strrep(s,'Q',rep2);
end

% end poly2str



