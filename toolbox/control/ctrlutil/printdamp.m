function printdamp(r,wn,z,Ts)
%PRINTDAMP  Displays pole damping information.
%
%   See also DAMP.

%   Author(s): J.N. Little
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/04/10 06:38:53 $

% Derive magnitude data
mag = [];
if Ts,
   mag = abs(r);
end

% Print result
form = '%7.2e';  
rstr = dprint(r,'Eigenvalue',form);
rstr(:,1:min(1,end)) = [];
magstr = dprint(mag,'Magnitude',form);
if Ts==0,
   wnstr = dprint(wn,'Freq. (rad/s)',form);
   zstr = dprint(z,'Damping',form);
else
   wnstr = dprint(wn,'Equiv. Freq. (rad/s)',form);
   zstr = dprint(z,'Equiv. Damping',form);
end
disp([rstr magstr zstr wnstr])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function s = dprint(v,str,form)
%DPRINT  Prints a column vector V with a centered caption STR on top

if isempty(v), 
   s = [];  return
end

nv = length(v);
lrpad = char(' '*ones(nv+4,2));  % left and right spacing
lstr = length(str);

% Convert V to string
rev = real(v);
s = [blanks(nv)' num2str(abs(rev),form)];
s(rev<0,1) = '-';
if ~isreal(v),
   % Add complex part
   imv = imag(v);
   imags = num2str(abs(imv),[form 'i']);
   imags(~imv,:) = ' ';
   signs = char(' '*ones(nv,3));
   signs(imv>0,2) = '+';
   signs(imv<0,2) = '-';
   s = [s signs imags];
end

% Dimensions
ls = size(s,2);
lmax = max(ls,lstr);
ldiff = lstr - ls;
ldiff2 = floor(ldiff/2);
str = [blanks(-ldiff2) str blanks(-ldiff+ldiff2)];
s = [char(' '*ones(nv,ldiff2)) s char(' '*ones(nv,ldiff-ldiff2))];

% Put pieces together
s = [blanks(lmax) ; str ; blanks(lmax) ; s ; blanks(lmax)];
s = [lrpad s lrpad];
