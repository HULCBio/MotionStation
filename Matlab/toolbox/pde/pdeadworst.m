function bt=pdeadworst(p,t,c,a,f,u,errf,wlevel)
%PDEADWORST Select triangles relative to the worst value
%
%       BT=PDEADWORST(P,T,C,A,F,U,ERRF,WLEVEL) returns indices of triangles
%       to be refined in BT.
%
%       The geometry of the PDE problem is given by the triangle data P,
%       and T. Details under INITMESH.
%
%       C, A, and F are PDE coefficients. See ASSEMPDE for details.
%
%       U is the current solution, given as a column vector.
%       See ASSEMPDE for details.
%
%       ERRF is the error indicator, as calculated by PDEJMPS.
%
%       WLEVEL is the error level relative to the worst error.
%       WLEVEL must be between 0 and 1.
%
%       Triangles are selected using the criterion
%       ERRF>WLEVEL*MAX(ERRF).
%
%       See also ADAPTMESH, PDEJMPS

%       A. Nordmark 12-27-94.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/11/01 04:28:05 $

if wlevel>1 || wlevel<0
  error('PDE:pdeadworst:WlevelOutOfRange', 'wlevel must be between 0 and 1.')
end

worst=max(errf')';
level=wlevel*worst;

bad=errf>level*ones(1,size(errf,2));

if size(errf,1)>1
  bad=max(bad);
end

bt=find(bad);

