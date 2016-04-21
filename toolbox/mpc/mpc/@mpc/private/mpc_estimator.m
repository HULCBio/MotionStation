function M=mpc_estimator(model,Bmn,Dmn,S13,S2,mvindex,mdindex,myindex,nnUMDtot);

%MPC_ESTIMATOR Design default Kalman filter

%    A. Bemporad
%    Copyright 2001-2004 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2004/04/16 22:09:17 $     


%NOTE: what is called M here is also called M in KALMAN's help file

%Bmn=MNmodel.b and Dmn=MNmodel.d are needed to rescale covariance matrices

Q=blkdiag(S13,Bmn*S2*Bmn');
R=Dmn*S2*Dmn';
N=[zeros(nnUMDtot+length(mvindex)+length(mdindex),length(myindex));Bmn*S2*Dmn'];


% Model is already in the A,[B G],C,[D H] format.
try
    [dummy1,dummy2,dummy3,M]=kalman(model,Q,R,N,myindex,[mvindex;mdindex]);
catch
    err=lasterror;
    err.identifier='mpc:mpc_estimator:kalman';
    rethrow(err);
end