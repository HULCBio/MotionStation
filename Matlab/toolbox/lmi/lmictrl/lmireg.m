% region = lmireg
% region = lmireg(reg1,reg2,...)
%
% Interactive specification of LMI regions for state-feedback
% synthesis with pole placement constraints (see MSFSYN).
% The output REGION is a description of the prescribed region
% and can be passed directly to MSFSYN.
%
% LMIREG can be used either interactively or to intersect a set
% of pre-existing LMI regions REG1, REG2, ...   The respective
% syntaxes are
%           region = lmireg
% and
%           region = lmireg(reg1,reg2,...)
%
%
% See also  MSFSYN.

% Author: M. Chilali   11/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function region=lmireg(d1,d2,d3,d4,d5,d6,d7,d8,d9,d10)


if nargin>10,
  error('LMIREG can intersect no more than 10 regions at a time');
end
mode=(nargin==0);

% Storing predefined regions
j=sqrt(-1);
nreg=nargin;
u=[]; v=[];

for k=1:nreg,
 eval(['d=d',int2str(k),';']);
 m=size(d,1);
 if size(d,2)~=2*m,
  error(sprintf('The %dth input is not a region',k));
 end
 i=1;
 while i<=m,
  mr=round(imag(d(i,i)));
  if mr==0,
   mr=m-i+1;
   d(i,i)=real(d(i,i))+j*mr;
  end
  i=i+mr;
 end
 u=mdiag(u,d(:,1:m));
 v=mdiag(v,d(:,m+1:2*m));
end


% Interactive Mode

while mode,
 disp(sprintf('\n\nSelect a region among the following:\n'));
 disp('h)   Half-plane');
 disp('d)   Disk ');
 disp('c)   Conic sector ');
 disp('e)   Ellipsoid ');
 disp('p)   Parabola ');
 disp('s)   Horizontal strip ');
 disp('m)   Matrix description of the LMI region');
 disp('q)   Quit');
 choice=input('choice: ','s');
 choice=choice(1:min(1,length(choice)));


 if strcmp(choice,'q'),	        %%%%%%%% quit
  mode=0;


 elseif strcmp(choice,'h'),	%%%%%%%% vertical half-plane
  x0=[];
  e=input('  Orientation (x < x0 -> l , x > x0 -> r):  ','s');
  while ~strcmp(e,'l') & ~strcmp(e,'r'),
     e=input('  Please enter l or r:  ','s');
  end
  if e=='l', e=1; else e=-1; end
  x0=input('  Specify x0:  ');
  while length(x0)~=1 | isstr(x0) | ~isreal(x0),
     x0=input('  Please specify a real number:  ');
  end
  u=mdiag(u,-2*e*x0+j);
  v=mdiag(v,e);


 elseif choice=='c'	        %%%%%%%% Conic Sector
  x0=[]; t=[];
  x0=input('  Absciss x0 of the tip of the sector:  ');
  while length(x0)~=1 | isstr(x0) | ~isreal(x0),
     x0=input('  Please enter a real number:  ');
  end
  t=input('  Inner angle (angle < pi -> sectors contains x = -Inf):  ')/2;
  if isempty(t), t=-1; end
  while length(t)~=1 | isstr(t) | t<=0 | t>= 2*pi | imag(t),
  t=input('  Please enter an angle in (0,2*pi):  ')/2;
  if isempty(t), t=-1; end
  end
  s=sin(t); c=cos(t);
  u=mdiag(u,2*[-s*x0+j 0;0 -s*x0]);
  v=mdiag(v,[s -c;c s]);


 elseif choice=='d'	       %%%%%%%% Disk
  q=[]; r=[];
  q=input('  Absciss q of the center:  ');
  while length(q)~=1 | isstr(q) | ~isreal(q),
    q=input('  Please enter a real number:  ');
  end
  r=input('  Radius r:  ');
  if isempty(r), r=-1; end
  while length(r)~=1 | isstr(r) | r<=0 | ~isreal(r),
    r=input('  Please enter a positive real number:  ')
    if isempty(r), r=-1; end
  end
  u=mdiag(u,[-r+2*j -q;-q -r]);
  v=mdiag(v,[0 0;1 0]);


 elseif choice=='e'	%%%%%%%% Ellipse
  q=[]; a=[]; b=[];
  disp(' ');
  disp('  Ellipse of equation  ((x-q)/a)^2 + (y/b)^2 < 1 ');
  q=input('  Absciss q of the center:  ');
  while length(q)~=1 | isstr(q) | ~isreal(q),
    q=input('  Please enter a real number:  ');
  end
  a=input('  Half-length a of the horizontal axis:  ');
  if isempty(a), a=-1; end
  while length(a)~=1 | isstr(a) | a <=0 | ~isreal(a),
    a=input('  Please enter a positive real number:  ');
    if isempty(a), a=-1; end
  end
  b=input('  Half-length b of the vertical axis:  ');
  if isempty(b), b=-1; end
  while length(b)~=1 | isstr(b) | b <=0 | ~isreal(b),
    b=input('  Please enter a positive real number:  ');
    if isempty(b), b=-1; end
  end
  a=1/abs(a);b=1/abs(b);
  u=mdiag(u,[-1+2*j -q*a;-q*a -1]);
  v=mdiag(v,[0 (a-b)/2;(a+b)/2 0]);


 elseif choice=='p'	%%%%%%%%% Parabola
  x0=[]; p=[];
  disp(' ');
  disp('  Parabola of equation  y^2 + p*(x-x0) < 0');
  x0=input('  Enter x0:  ');
  while length(x0)~=1 | isstr(x0) | ~isreal(x0),
     x0=input('  Please enter a real number:  ');
  end
  p=input('  Enter the parameter p:  ');
  while length(p)~=1 | isstr(p) | ~isreal(p),
     p=input('  Please enter a real number:  ');
  end
  q=-p*x0;
  u=mdiag(u,2*[q-1+j q+1;q+1 q-1]);
  v=mdiag(v,[p p-2;p+2 p]);


 elseif choice=='s'	%%%%%%%% horizontal strip
  r=[];
  disp(' ');
  disp('  Horizontal strip of equation  -r < y < r');
  r=input('  Enter r:  ');
  if isempty(r), r=-1; end
  while length(r)~=1 | isstr(r) | r<=0 | ~isreal(r),
    r=input('  Please enter a positive real number:  ');
    if isempty(r), r=-1; end
  end
  u=mdiag(u,[-r+2*j 0;0 -r]);
  v=mdiag(v,[0 -1;1 0]);


% elseif choice=='c'	%%%%%%%%%% Conic curve
%  coef=input('[a1 b1 a2 b2 a3 b3]= ');
%  if size(coef,1)~=1 | size(coef,2)~=6 | any(~isreal(coef)),
%   error('[a1 b1 a2 b2 a3 b3] must be a 1x6 vector of real numbers');
%  end
%  a1=coef(1);b1=coef(2);a2=coef(3);b2=coef(4);a3=coef(5);b3=coef(6);
%  if a1==0 & b1==0,
%   error('[a1 b1] must not be a null vector');
%  end
%  u=mdiag(u,2*[b1+j b3;b3 b2]);
%  v=mdiag(v,[a1 a3-1;a3+1 a2]);


 elseif choice=='m'	%%%%%%%%%% Matrix specification
  disp(' ');
  disp('  Select one of the following two formats:');
  disp('       z) A+z*B+conj(z)*B'' < 0      x) A+x*B+j*y*C < 0');
  var=input('  choice:  ','s');
  while length(var)~=1 | (var~='z' & var~='x'),
   var=input('   choose z or x: ','s');
  end
  if var=='z',
   a=input('  A (symmetric) = ');
   b=input('  B = ');
   if size(a,1)~=size(a,2) | size(b,1)~=size(b,2) | size(b,1)~=size(a,1) | ...
    any(~isreal(a)) | any(~isreal(b)),
      error('A and B must be square matrices with the same dimension');
   end
  else
   a=input('  A (symmetric) = ');
   b=input('  B = ');
   c=input('  C = ');
   if size(a,1)~=size(a,2) | size(b,1)~=size(b,2) | size(b,1)~=size(a,1) | ...
     size(c,1)~=size(c,2) | size(c,1)~=size(a,1) |...
     any(~isreal(a)) | any(~isreal(b)) | any(~isreal(c)),
       error('A, B and C must be square matrices with the same dimension');
   end
   a=a;
   b=(b+c)/2;
  end
  a(1,1)=a(1,1)+j*size(a,1);
  u=mdiag(u,a);
  v=mdiag(v,b);
 end
end
region=[u,v];
