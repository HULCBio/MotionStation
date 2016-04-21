function status = abccheck(a,b,c,d,k,x0,cas)
%ABCCHECK  check consistency of state space matrices

%   xxx private function?

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2001/04/06 14:21:47 $

status=[];
%mats=struct2cell(mat);

[nx,nd]=size(a);
[nd4,nu]=size(b);
[ny,nd5]=size(c);
[nd1,nd2]=size(d);
[nd6,nd7]=size(k);
[nd8,nd9]=size(x0);

if nx ~= nd, 
   status=['The A-matrix must be square.'];
elseif nx ~= nd4 & nu~=0, 
   status=['A and B must have the same number of rows.'];
elseif nx ~= nd5, 
   status=['A and C must have the same number of columns.']; 
elseif nd1 ~= ny & nu~=0, 
   status=['D and C must have the same number of rows.'];
elseif nd2 ~= nu, 
   status=['D and B must have the same number of columns.'];
elseif nd6 ~= nx, 
   status=['K and A must have the same number of rows.'];
elseif nd7 ~= ny, 
   status=['The number of columns in K must equal the number of rows in C.'];
elseif nd8~=nx, 
   status=['X0 and A must have the same number of rows.'];
elseif nd9 ~= 1,
   status=['X0 must be a column vector.'];
end
if ~isempty(status)
   if strcmp(cas,'nan')
      status=['Misspecified NaN-structure:\n',status];
   else
      status=['Misspecified model matrices:\n',status];
   end
   status=sprintf(status);
end


