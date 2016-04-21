echo off
%CHEBLOOP Used in chebdem.

%   changes: 21 jun 92, 9 may 95 (use .' instead of '), 13 feb 9
%   Copyright 1987-2002 C. de Boor and The MathWorks, Inc. 
%   $Revision: 1.14 $
    
echo on
% For the complete levelling, we use the  Remez algorithm. This means that we
% construct new tau's as the extrema of our current approximation to  c
% and try again.  We find the new interior  tau  as the zeros of  Dc .

     pause                      % touch any key to continue

Dc = fnder(c);

% We take the zeros of the corresponding control polygon as our first
% guess. For this, we must take apart the spline  Dc .

[knots,coefs,np,kp] = spbrk(Dc);

% The control polygon has the vertices  (tstar(i),coefs(i)) , with
%  tstar  the knot averages for the spline as supplied by

tstar = aveknt(knots,kp);

% Here are the zeros of the resulting control polygon of  Dc :
npp = [1:np-1];
guess = tstar(npp) - coefs(npp).*(diff(tstar)./diff(coefs));
plot(guess,zeros(1,np-1),'o')
xlabel('...and the zeros of the control polygon of its first derivative')
pause

% This provides already a very good first guess for the actual extrema.

     pause                      % touch any key to continue


% Now we compute the first derivative at both these point sets:
points = repmat( tau(2:n-1), 4,1 );
points(1,:) = guess;
values = zeros(4,n-2);
values(1:2,:)= reshape(fnval(Dc,points(1:2,:)),2,n-2);


% ... and use two steps of the secant method, getting iterates  points(3,:) and
%  points(4,:)  with corresponding derivative values  values(3,:)  and
%  values(4,:)  (but guard against division by zero):
     pause                      % touch any key to continue

for j = 2:3
   rows = [j,j-1]; Dcd = diff(values(rows,:));
   Dcd(find(Dcd==0)) = 1;
   points(j+1,:) = points(j,:)-values(j,:).*(diff(points(rows,:))./Dcd);
   values(j+1,:) = fnval(Dc,points(j+1,:));
end
   max(abs(values.'))
     pause                      % touch any key to continue

% These maxima of derivative values for the successive iterates show a good 
% improvement. Now we take the last iterate as our new guess for  tau : 

tau = [tau(1) points(4,:) tau(n)]
% .. and check the extreme values of our current approximation there
extremes = abs(fnval(c,tau));
     pause                      % touch any key to continue

% The difference
max(extremes)-min(extremes)
% is an estimate of how far we were from total levelling.
%
% Compare this with the difference in extrema heights in the new spline

c = spapi(t,tau,b);

% corresponding to our new choice of  tau  as evident from the plot of the new
% spline:

fnplt( c, 'k', lw )
title('a more nearly equioscillating spline'), xlabel(''),pause

% If this is not close enough, simply try again, starting from these new  tau .
%
echo off
  fprintf(' If you want to continue, type  1 , then RETURN.')
  answer = input(' Otherwise, just hit RETURN:  ');
if ~isempty(answer)&(answer==1), lw = lw+.5; chebloop
else,hold off, close
end
