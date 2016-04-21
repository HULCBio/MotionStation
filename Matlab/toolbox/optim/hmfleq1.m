function W = hmfleq1(Hinfo,Y,V);
%HMFLEQ1 Hessian-matrix product function for BROWNVV objective.
%   W = hmfbx4(Hinfo,Y,V) computes W = (Hinfo-V*V')*Y
%   where Hinfo is a sparse matrix computed by BROWNVV 
%   and V is a 2 column matrix.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.3.4.1 $  $Date: 2004/02/07 19:13:14 $
  
W = Hinfo*Y - V*(V'*Y);
  



