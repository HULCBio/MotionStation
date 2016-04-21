function F=pdeasmf(it1,it2,it3,np,ar,x,y,sd,u,ux,uy,time,f)
%PDEASMF Assemble the f coefficient.

%       A. Nordmark 12-19-94.
%       Copyright 1994-2001 The MathWorks, Inc.
%       $Revision: 1.9 $  $Date: 2001/02/09 17:03:13 $

f=pdetexpd(x,y,sd,u,ux,uy,time,f);
f=f.*ar/3;
F=sparse(it1,1,f,np,1);
F=F+sparse(it2,1,f,np,1);
F=F+sparse(it3,1,f,np,1);

