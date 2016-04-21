function W = hmfbx4(H,Y,XMAT);
%HMFBX4 Hessian-matrix product for test FBOX4
%
%    W = hmfbx4(H,Y,XMAT);
%
%    The Hessian is H + XMAT*XMAT'

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2004/02/07 19:13:13 $

  W = H*Y - XMAT*(XMAT'*Y);



