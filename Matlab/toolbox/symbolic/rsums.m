function rsums(f,a,b)
%RSUMS  Interactive evaluation of Riemann sums.
%   RSUMS(f) approximates the integral of f from 0 to 1 by Riemann sums.
%   RSUMS(f,a,b) and RSUMS(f,[a,b]) approximates the integral from a to b.
%   f is a string, or a sym, or an inline function of one variable.
%   RSUMS is often called with the command line form, eg.
%      rsums exp(-5*x^2)

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.15.4.2 $  $Date: 2004/04/16 22:23:28 $

if nargin ~= 0
   % Initialization
   % Make sure f is an inline function.
   args.f = vectorize(inline(f));
   if nargin == 1
      args.a = 0; args.b = 1;
   elseif nargin == 2
      args.a = a(1); args.b = a(2);
   else
      args.a = a; args.b = b;
   end
   clf reset
   set(gcf,'userdata',args,'doublebuffer','on')
   set(gca,'position',get(gca,'position')+[0 .05 0 -.05])
   uicontrol('units','normal','style','slider','pos',[.18 .03 .70 .04],...
      'min',2,'max',128,'value',10,'callback','rsums');
end

args = get(gcf,'userdata');
f = args.f;
a = args.a;
b = args.b;
n = round(get(findobj(gcf,'type','uicontrol'),'value'));
x = a + (b-a)*(1/2:1:n-1/2)/n;
y = feval(f,x);
r = (b-a)*sum(y)/n;
bar(x,y)
title([char(f) '  :  ' sprintf('%9.6f',r)],'interpreter','none')
xlabel(int2str(n))
axis([a b min(0,min(y)) max(0,max(y))])
