function bt=circlepick(p,t,c,a,f,u,errf,atol)
%CIRCLEPICK Pick bad triangles using an absolute tolerance

%       A. Nordmark 2-6-95.
%       Copyright 1994-2001 The MathWorks, Inc.
%       $Revision: 1.8 $  $Date: 2001/02/09 17:03:11 $

level=atol;

bad=errf>level*ones(1,size(errf,2));

bt=find(bad);

