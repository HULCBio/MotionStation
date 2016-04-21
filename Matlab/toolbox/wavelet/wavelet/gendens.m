function gendens(opt,nb,fname)
%GENDENS Generate random samples.
%   GENDENS(OPT,NB,FNAME) generates random samples of 
%   length NB from a given density and stores the result
%   in a MAT-file of name FNAME.
%
%   OPT = 1, y = c1*exp(-128*((x-0.3).^2))-3*(abs(x-0.7).^0.4)
%   OPT = 2, y = c2*exp(-128*((x-0.3).^2))-1*(abs(x-0.7).^0.4)
%   OPT = 3, Gaussian density

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 02-Jun-99.
%   Last Revision: 14-Jun-1999.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/04/14 19:47:48 $

ingen = 1;
switch opt
  case 1
    x = linspace(0,1,max(3*nb,100)); 
    y = exp(-128*((x-0.3).^2))-3*(abs(x-0.7).^0.4);
    eval([fname, ' = genSIG(x,y,nb,ingen);'])

  case 2
    x = linspace(0,1,max(3*nb,100)); 
    y = exp(-128*((x-0.3).^2))-1*(abs(x-0.7).^0.4);
    eval([fname, ' = genSIG(x,y,nb,ingen);'])

  case 3
    eval([fname,' = randn(1,nb);'])

  otherwise
    msg = 'input argument must be 1,2 or 3';
    errargt(mfilename,msg,'msg');
    error('*');
end
eval(['save ',fname,' ',fname])


function sig = genSIG(x,y,nb,ingen)

y = y-[(y(end)-y(1))*x+y(1)]+sqrt(eps);
d = y/sum(y);
r = randd(d,nb,ingen);
sig = x(r);

function r = randd(proba,nb,ingen)

reps = sqrt(eps);
s = sum(proba);
if s<(1-reps) | s>(1+reps)
  msg = 'Invalid argument value for proba'; 
  errargt(mfilename,msg,'msg');
  error('*');
end
n = length(proba);
q = cumsum(proba);
tab = [[0 q]' [0:n]'];
rand('seed',ingen);
u = rand(nb,1);

% Since table1 is obsolete, use interp1.
%r = 1 + fix(table1(tab,u));
r = 1 + fix(interp1(tab,u));      


