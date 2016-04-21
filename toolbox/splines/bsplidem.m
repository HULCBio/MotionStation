echo off
%BSPLIDEM Show some B-splines.

%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
%   changes: 24 January 1992; 21 June 1992; 21 June 1992; 15 feb 96; 07 apr 96;
%   26sep96; 8aug97; 13dec98
%   $Revision: 1.18 $

home, close, echo on

%      The B-spline

%                     B(. | t(i), ..., t(i+k))

% with knots  t(i) <= ... <= t(i+k)  is positive on the interval
%  (t(i) .. t(i+k))  and is zero outside the interval.  It is pp of order  k
% with breaks at the points  t(i), ..., t(i+k) . These knots may coincide,
% and the precise  m u l t i p l i c i t y  of a knot governs the smoothness
% with which the two polynomial pieces join there.

%     Here are some pictures of B-splines, together with the
% polynomials whose pieces make up the B-spline. The pictures also show the
% knot locations.

pause                 % Touch any key to continue

echo off
for j=1:6
   plot(NaN,NaN), hold on
   title(['a B-spline of order ', num2str(j)])
   xlabel(' touch any key to continue')
   bspline([0:j]), hold off, clf
end
echo on

%     Here is a sequence of pictures of a cubic B-spline as more and more
% knots become coincident.

%	First, a double knot develops.

pause				% Touch any key to continue
clf
t=[0:4];k=4;bspline(t)
quarters = [0 .5 .5 .5;
           .5 .5 .5 .5;
            0  0 .5 .5;
           .5  0 .5 .5];
i=1;propor=[1/2,1/8,1/32,0];delta=t(i+1)-t(i+2);
for j=3:-1:0; axes('pos', quarters(4-j,:))
t(i+1)=t(i+2)+propor(4-j)*delta;bspline(t,4-j), end
hold off, pp = bspline(t); t(i+1)=t(i+2)+delta;

%	In the last picture, t(i+1)=t(i+2) and, correspondingly, the continuity
%  of the second derivative is lost. This can be seen quite nicely by
%  looking at the two polynomials that join there: One is convex, the other
%  concave at that point.

pause				% Touch any key to continue

clf, hold off
xl=[t(i)*10:t(i+2)*10]/10; xr=[t(i+2)*10:t(i+k)*10]/10;
pl=fnbrk(pp,1);pr=fnbrk(pp,2);
title('jump discontinuity in second derivative made visible'), hold on
plot(xl,fnval(pl,xl),'r','linew',2.8), plot(xr,fnval(pl,xr),'r')
plot(xl,fnval(pr,xl),'g'); plot(xr,fnval(pr,xr),'g','linew',2.8)
plot(t(i+2)*[1 1],[-20,10],'w'), hold off
grid off, pause

%	Next, we let a triple knot develop and expect, correspondingly, to see
%  a jump in the first derivative at that break.

pause				% Touch any key to continue

delta=t(i+1:i+2)-t(i+3);
for j=3:-1:0, t(i+1:i+2)=t(i+3)+propor(4-j)*delta;bspline(t,4-j), end
clf, t(i+1:i+2)=t(i+3)+delta;

%	We were not disappointed.

%	Finally, a quadruple knot, at which, for a fourth order spline, we
%  expect a discontinuity in the function values.

pause				% Touch any key to continue

clf; delta=t(i+1:i+3)-t(i+4);
for j=3:-1:0; t(i+1:i+3)=t(i+4)+propor(4-j)*delta;bspline(t,4-j), end
clf

t=[0 1 1 3 4 6 6 6];
clc;clf;home
%     The rule connecting smoothness across a knot with the multiplicity of
%  that knot is easy to remember if we designate the number of smoothness
%  conditions across a knot as the condition multiplicity there.
%  The rule is:

%           knot multiplicity + condition multiplicity = order.


%  For example, for a B-spline of order  3 , a simple knot would mean  2
%  smoothness conditions, i.e., continuity of function and first derivative,
%  while a double knot would only leave one smoothness condition, i.e., just
%  continuity, and a triple knot would leave no smoothness condition, i.e.,
%  even the function would be discontinuous.

pause				%  Touch any key to continue

%     Here is a picture of all the third-order B-splines for a certain
%  knot sequence. For each break, try to determine its multiplicity in
%  the knot sequence, as well as its multiplicity as a knot in each of the
%  B-splines.

pause				%  Touch any key to continue

x=[-10:70]/10;
c=spcol(t,3,x);[l,m]=size(c);c=c+repmat([0:m-1],l,1);
axis([-1 7 0 m]),hold on, grid off, axis off
title('All quadratic B-splines for the knot sequence  [0 1 1 3 4 6 6 6]')
for tt=t, plot([tt tt],[0 m],'-k'), end, plot(x,c), pause
hold off, echo off, close
