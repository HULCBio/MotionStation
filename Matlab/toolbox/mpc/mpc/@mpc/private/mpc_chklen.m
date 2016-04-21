function newwt=mpc_chklen(wt,p);

%MPC_CHKLEN Check dimension of a matrix and possibly repeat the last row 
%   up to fill in the whole prediction horizon p

%    A. Bemporad
%    Copyright 2001-2004 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2004/04/16 22:09:06 $  

[nrow,ncol]=size(wt);
if nrow<p 
    % If fewer rows than needed, must copy the last one
    %newamin=[amin;kron(ones(p-nrow,1),amin(nrow,:))];    
    newwt=[wt;ones(p-nrow,1)*wt(nrow,:)];    
else
    newwt=wt;
end

%end mpc_chklen
