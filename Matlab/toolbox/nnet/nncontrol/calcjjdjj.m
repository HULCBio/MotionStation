function [JJ,dJJ]=calcjjdjj(u_vec,Ni,Nu,Nj,N2,Ai,Ts,ref,tiu,rho,dUtilde_dU,Normalize,minp,maxp)
%CALCJJDJJ Calculate the cost function JJ and the change in the cost function dJJ
%with respect to U for the NN Predictive Controller.
%
%  Synopsis
%
%    [JJ,dJJ]=calcJJdJJ(u_vec,Ni,Nu,Nj,N2,Ai,Ts,ref,tiu,rho,dUtilde_dU,Normalize)
%
%  Description
%
%    This function predict the output of the system based on a previously trained
%    NN. With that information, calculates the cost function and the change in the
%    cost function based on the inputs to the plant. The cost function is:
%
%    JJ = evec'*evec + rho*(duvec'*duvec);
%
%    where: evec = Error during the cost horizon time.
%           duvec = Change in the control action during the control horizon time.
%           rho = Control weighting factor.
%
%    [JJ,dJJ]=CALCJJDJJ(u_vec,Ni,Nu,Nj,N2,Ai,Ts,ref,tiu,rho,dUtilde_dU,Normalize) takes,
%      u_vec - Vector with sequence of control actions.
%      Ni    - Number of delayed plant inputs.
%      Nu    - Control Horizon.
%      Nj    - Number of delayed plant outputs.
%      N2    - Cost Horizon.
%      Ai    - Initial layer delay conditions.
%      Ts    - Time steps.
%      ref   - Reference input.
%      tiu   - Initial time for U.
%      rho   - Control weighting factor.
%      dUtlde_dU - Derivate of the difference of U(t)-U(t-1) respect U.
%      Normalize - Indicate if the NN has input-output normalized.
%    and returns,
%      JJ    - Cost function value.
%      dJJ   - Derivate of the cost function respect U.
%
%    This function is being called by the line search functions (CSRCHBAC, CSRCHGOL, 
%    CSRCHHYB, CSRCHCHA, CSRCHBRE) inside the function PREDOPT, that is located in
%    the Simulink block for the NN Predictive Controller.

% Orlando De Jesus, Martin Hagan, 1-30-00
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.6 $ $Date: 2002/04/14 21:11:45 $

assignin('base','cont_u',evalin('base','cont_u')+1);

set_param('ptest3sim2/Subsystem','u_init',mat2str(u_vec(Ni),20),'ud_init',mat2str(u_vec(Ni-1:-1:1),20), ...
                                  'y_init',mat2str(Ai{2,Nj},20),'yd_init',mat2str(cat(1,Ai{2,Nj-1:-1:1}),20));
[time,xx0,Ac1,Ac2,E,gU,gUd,dY_dU] = sim('ptest3sim2',[0 N2*Ts],[],[(0:Ts:(N2-2)*Ts)' u_vec(1:N2-1) ref(1:N2-1)]);

yhat_vec=Ac1(1:N2+1,1)';

E=E(2:N2+1,:);
gU=gU(1:N2,:)';
gUd=gUd(1:N2,:)';

evec=E;

if tiu==1
   duvec = [0; u_vec(tiu+1:tiu+Nu-1)-u_vec(tiu:tiu+Nu-2)];
else   
   duvec = u_vec(tiu:tiu+Nu-1)-u_vec(tiu-1:tiu+Nu-2);
end
 
JJ = evec'*evec + rho*(duvec'*duvec);

% Forward Perturbation
dY_dU=dY_dU(2:N2+1,:)';
dJJ   = 2*(-dY_dU*evec + rho*(dUtilde_dU*duvec));
if Normalize
   dJJ=dJJ/(maxp-minp);
end
