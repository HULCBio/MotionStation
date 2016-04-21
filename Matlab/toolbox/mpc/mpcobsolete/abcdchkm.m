function msg = abcdchkm(a,b,c,d)
%ABCDCHKM Check whether the entered system is valid.
%	msg = abcdchkm(a,b,c,d)
%
% msg = empty if system is ok; otherwise msg tells what is wrong
% with the system.

%     Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

msg=[];
[nx,nx2]  = size(a);
if(nx ~= nx2),
  msg = 'Matrix A must be square';
end
if(nargin > 1),
  [nx2,nu] = size(b);
  if(nx ~= nx2),
    msg = 'Matrices A and B must have same number of rows';
  end
end
if(nargin > 2),
  [ny,nx2] = size(c);
  if(nx ~= nx2),
    msg = 'Matrices A and C must have same number of columns';
  end
end
if(nargin > 3),
  [ny2,nu2] = size(d);
  if(nu ~= nu2)
    msg = 'Matrices B and D must have same number of columns';
  end
  if(ny ~= ny2),
    msg = 'Matrices C and D must have same number of rows';
  end
end