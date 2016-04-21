function M=pdeasma(it1,it2,it3,np,ar,x,y,sd,u,ux,uy,time,a)
%PDEASMA Assemble the A coefficient.

%       A. Nordmark 12-19-94.
%       Copyright 1994-2001 The MathWorks, Inc.
%       $Revision: 1.9 $  $Date: 2001/02/09 17:03:13 $

a=pdetexpd(x,y,sd,u,ux,uy,time,a);
aod=a.*ar/12; % Off diagonal element
ad=2*aod; % Diagonal element
M=sparse(it1,it2,aod,np,np);
M=M+sparse(it2,it3,aod,np,np);
M=M+sparse(it3,it1,aod,np,np);
M=M+M.';
M=M+sparse(it1,it1,ad,np,np);
M=M+sparse(it2,it2,ad,np,np);
M=M+sparse(it3,it3,ad,np,np);

