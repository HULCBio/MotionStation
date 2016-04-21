function [sys,x0,str,ts] = predopt(t,x,u,flag,N2,Ts,Nu,maxiter,csrchfun,rho,alpha,S1,IW,LW1_2,LW2_1,B1,B2,Ni,Nj,min_i,max_i,minp,maxp,mint,maxt,Normalize)
%PREDOPT Executes the Predictive Controller Approximation based on Gauss Newton.
%   
    
% Copyright 1992-2003 The MathWorks, Inc.
% Orlando De Jesus, Martin Hagan, 1-25-00
% $Revision: 1.6.2.2 $ $Date: 2004/04/10 23:45:58 $

switch flag,

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0,
    load_system('ptest3sim2');
    if Normalize
       IW_gU=((maxt-mint)/(maxp-minp))*IW;
    else
       IW_gU=IW;
    end
    set_param('ptest3sim2/Subsystem','B2',num2str(B2,20),'B1',mat2str(B1,20),'LW2_1',mat2str(LW2_1,20), ...
                                      'LW1_2',mat2str(LW1_2,20),'IW',mat2str(IW,20),'IW_gU',mat2str(IW_gU,20), ...
                                      'Ts',num2str(Ts),'S1',num2str(S1),'Ni',num2str(Ni), ...
                                      'Nj',num2str(Nj),'minp',num2str(minp,20),'maxp',num2str(maxp,20), ...
                                      'minp',num2str(minp,20),'mint',num2str(mint,20),'maxt',num2str(maxt,20), ...
                                      'Normalize',num2str(Normalize),'Nu',num2str(Nu));
    assignin('base','t_init',cputime);
    assignin('base','cont_u',0);
    [sys,x0,str,ts]=mdlInitializeSizes(N2,Ts,Nu,alpha,S1,Ni,Nj,min_i,max_i);
  
  %%%%%%%%%%  
  % Update %
  %%%%%%%%%%
  case 2,                                               
    sys = mdlUpdate(t,x,u,N2,Ts,Nu,maxiter,csrchfun,rho,alpha,S1,Ni,Nj,min_i,max_i,minp,maxp,mint,maxt,Normalize);
    
  %%%%%%%%%%
  % Output %
  %%%%%%%%%%
  case 3,  
    sys = mdlOutputs(t,x,u,Nu,Ni);    

  %%%%%%%%%%%%%
  % Terminate %
  %%%%%%%%%%%%%
  case 9,                                               
    close_system('ptest3sim2',0);
    assignin('base','t_end',cputime);
    sys = [];

  otherwise
    error(['unhandled flag = ',num2str(flag)]);
end

%end sfundsc1

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts]=mdlInitializeSizes(N2,Ts,Nu,alpha,S1,Ni,Nj,min_i,max_i)

global tiu dUtilde_dU
global N1 d alpha2 upi uvi

sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = Ni+Nu-1+(S1+1)*(Nj-1);
sizes.NumOutputs     = 1;
sizes.NumInputs      = -1;
sizes.DirFeedthrough = 0;
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);

% State Index:
%
%             x(1:Ni-1) = Previous Plant input u - Controller output (Size Ni-1).
%                 x(Ni) = Actual Plant input u - Controller output (Size 1).
%       x(Ni+1:Nu+Ni-1) = Next Plant input u - Controller output (Size Nu-1).
%              x(Nu+Ni) = Previous NN 2nd layer output (Size 1). 
%   x(Nu+Ni+1:Nu+Ni+S1) = Previuos NN 1st layer output (Size S1).
%
%   Last two variables will repeat in case of multiple outputs. Not tested yet.
%
x0  = zeros(Ni+Nu-1+(S1+1)*(Nj-1),1);
% ODJ 1-31-00 We place initial Plant input u - Controller output at mid range.
x0(Ni:Nu+Ni-1) = (max_i-min_i)/2;
str = [];
ts  = [Ts 0]; % Inherited sample time


tiu=Ni;
dUtilde_dU = eye(Nu);
dUtilde_dU(1:Nu-1,2:Nu)=dUtilde_dU(1:Nu-1,2:Nu)-eye(Nu-1);
N1=1;
d=1;
alpha2     = alpha*alpha;
upi   = [1:Nu-1 Nu(ones(1,N2-d-Nu+2))];
uvi   = [tiu:N2-N1+Ni];

% end mdlInitializeSizes

%
%=======================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=======================================================================
%
function sys = mdlOutputs(t,x,u,Nu,Ni)
sys = x(Ni);

%end mdlUpdate

%
%=======================================================================
% mdlOutputs
% Return the output vector for the S-function
%=======================================================================
%
function sys = mdlUpdate(t,x,u,N2,Ts,Nu,maxiter,csrchfun,rho,alpha,S1,Ni,Nj,min_i,max_i,minp,maxp,mint,maxt,Normalize)

global tiu dUtilde_dU
global N1 d alpha2 upi uvi

Ai=num2cell(zeros(2,Nj));
for k=1:Nj-1
  Ai{1,k}=x(Nu+Ni+1+(k-1)*(S1+1):Nu+Ni+S1+(k-1)*(S1+1));
  Ai{2,k}=x(Nu+Ni+(k-1)*(S1+1));                             % delayed plant output
end
Ai{1,Nj}=u(4:3+S1);

ref(1:N2,1)=u(1);
initval = '[upmin(Nu)]';

upmin=[x(Ni+1:Nu+Ni-1);x(Nu+Ni-1)];
u_vec(1:Ni-1,1)=x(2:Ni);
if Normalize
   ref=((ref-mint)*2/(maxt-mint)-1);
   Ai{2,Nj}=((u(3)-mint)*2/(maxt-mint)-1);           % Actual NN output
   upmin=((upmin-minp)*2/(maxp-minp)-1); 
   u_vec=((u_vec-minp)*2/(maxp-minp)-1); 
else
   Ai{2,Nj}=u(3);
end

upmin0   = upmin;             
einitval = eval(initval);     % Evaluate inival string

for tr=1:length(einitval),
  up=upmin0;                  % Initial value for numerical search for a new u  
  up(Nu)=einitval(tr);
  u_vec(uvi,1) = up(upi);  
  dw = 1;                     % Flag specifying that up is new
  lambda = 0.1;               % Initialize Levenberg-Marquardt parameter
  
  
  %>>>>>>>>>>>>>>> COMPUTE PREDICTIONS FROM TIME t+N1 TO t+N2 <<<<<<<<<<<<<<<<
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
  
  %>>>>>>>>>>>>>>>>>>>>>>    EVALUATE CRITERION    <<<<<<<<<<<<<<<<<<<<<<
  J = JJ;
    
    
  %>>>>>>>>>>>>>>>>>>>>>>>>      DETERMINE dyhat/du       <<<<<<<<<<<<<<<<<<<<<<<<<

  %>>>>>>>>>>>>>>>>>>>>>>>>>>>>    DETERMINE dJ/du     <<<<<<<<<<<<<<<<<<<<<<<<<<<<
  dJdu   = dJJ;


  %>>>>>>>>>>>>>>>>>>>>>>    DETERMINE INVERSE HESSIAN    <<<<<<<<<<<<<<<<<<<<<<<<<
  B = eye(Nu);                  % Initialize Hessian to I


  delta=1;
  tol=1/delta;
  ch_perf = J;      % for first iteration.
  %>>>>>>>>>>>>>>>>>>>>>>>     BEGIN SEARCH FOR MINIMUM      <<<<<<<<<<<<<<<<<<<<<<    
  for m = 1:maxiter,
  
  
    %>>>>>>>>>>>>>>>>>>>>>>>   DETERMINE SEARCH DIRECTION   <<<<<<<<<<<<<<<<<<<<<<<
    dX = -B*dJdu;
    
    if dX'*dJdu>0    % We reset the gradient if positive.
        %>>>>>>>>>>>>>>>>>>>>>>    DETERMINE INVERSE HESSIAN    <<<<<<<<<<<<<<<<<<<<<<<<<
      B = eye(Nu);                  % Initialize Hessian to I
      delta=1;
      tol=1/delta;
      ch_perf = J;      % for first iteration.
        %>>>>>>>>>>>>>>>>>>>>>>>   DETERMINE SEARCH DIRECTION   <<<<<<<<<<<<<<<<<<<<<<<
      dX = -B*dJdu;
    end

    if Normalize
     switch csrchfun,
      case 1, %'csrchgol',
        [up_delta,J,dJdu_old,dJdu,retcode,delta,tol]=csrchgol(up,u_vec,ref,Ai,Nu,N1,N2,d,Ni,Nj,dX,dJdu,J,dX'*dJdu,delta,rho,dUtilde_dU,alpha,tol,Ts,-1,1,Normalize,minp,maxp);
      case 2  %'csrchbac',
        [up_delta,J,dJdu_old,dJdu,retcode,delta,tol]=csrchbac(up,u_vec,ref,Ai,Nu,N1,N2,d,Ni,Nj,dX,dJdu,J,dX'*dJdu,delta,rho,dUtilde_dU,alpha,tol,Ts,-1,1,Normalize,minp,maxp);
     case 3  %'csrchhyb'
        [up_delta,J,dJdu_old,dJdu,retcode,delta,tol]=csrchhyb(up,u_vec,ref,Ai,Nu,N1,N2,d,Ni,Nj,dX,dJdu,J,dX'*dJdu,delta,rho,dUtilde_dU,alpha,tol,Ts,-1,1,Normalize,minp,maxp);
      case 4  %'csrchbre'
        [up_delta,J,dJdu_old,dJdu,retcode,delta,tol]=csrchbre(up,u_vec,ref,Ai,Nu,N1,N2,d,Ni,Nj,dX,dJdu,J,dX'*dJdu,delta,rho,dUtilde_dU,alpha,tol,Ts,-1,1,Normalize,minp,maxp);
      case 5  %'csrchcha'
        J_old=J;
        [up_delta,J,dJdu_old,dJdu,retcode,delta,tol]=csrchcha(up,u_vec,ref,Ai,Nu,N1,N2,d,Ni,Nj,dX,dJdu,J,dX'*dJdu,delta,rho,dUtilde_dU,alpha,tol,Ts,-1,1,Normalize,minp,maxp,ch_perf);
        ch_perf = J - J_old;
      otherwise
        J_old=J;
        [up_delta,J,dJdu_old,dJdu,retcode,delta,tol]=feval(csrchfun,up,u_vec,ref,Ai,Nu,N1,N2,d,Ni,Nj,dX,dJdu,J,dX'*dJdu,delta,rho,dUtilde_dU,alpha,tol,Ts,-1,1,Normalize,minp,maxp,ch_perf);
        ch_perf = J - J_old;
     end
    else
     switch csrchfun,
      case 1, %'csrchgol',
        [up_delta,J,dJdu_old,dJdu,retcode,delta,tol]=csrchgol(up,u_vec,ref,Ai,Nu,N1,N2,d,Ni,Nj,dX,dJdu,J,dX'*dJdu,delta,rho,dUtilde_dU,alpha,tol,Ts,min_i,max_i,Normalize,minp,maxp);
      case 2  %'csrchbac',
        [up_delta,J,dJdu_old,dJdu,retcode,delta,tol]=csrchbac(up,u_vec,ref,Ai,Nu,N1,N2,d,Ni,Nj,dX,dJdu,J,dX'*dJdu,delta,rho,dUtilde_dU,alpha,tol,Ts,min_i,max_i,Normalize,minp,maxp);
     case 3  %'csrchhyb'
        [up_delta,J,dJdu_old,dJdu,retcode,delta,tol]=csrchhyb(up,u_vec,ref,Ai,Nu,N1,N2,d,Ni,Nj,dX,dJdu,J,dX'*dJdu,delta,rho,dUtilde_dU,alpha,tol,Ts,min_i,max_i,Normalize,minp,maxp);
      case 4  %'csrchbre'
        [up_delta,J,dJdu_old,dJdu,retcode,delta,tol]=csrchbre(up,u_vec,ref,Ai,Nu,N1,N2,d,Ni,Nj,dX,dJdu,J,dX'*dJdu,delta,rho,dUtilde_dU,alpha,tol,Ts,min_i,max_i,Normalize,minp,maxp);
      case 5  %'csrchcha'
        J_old=J;
        [up_delta,J,dJdu_old,dJdu,retcode,delta,tol]=csrchcha(up,u_vec,ref,Ai,Nu,N1,N2,d,Ni,Nj,dX,dJdu,J,dX'*dJdu,delta,rho,dUtilde_dU,alpha,tol,Ts,min_i,max_i,Normalize,minp,maxp,ch_perf);
        ch_perf = J - J_old;
      otherwise
        J_old=J;
        [up_delta,J,dJdu_old,dJdu,retcode,delta,tol]=feval(csrchfun,up,u_vec,ref,Ai,Nu,N1,N2,d,Ni,Nj,dX,dJdu,J,dX'*dJdu,delta,rho,dUtilde_dU,alpha,tol,Ts,min_i,max_i,Normalize,minp,maxp,ch_perf);
        ch_perf = J - J_old;
     end
    end

    
    %>>>>>>>>>>>>>>>>>>>>>>>>   UPDATE FUTURE CONTROLS   <<<<<<<<<<<<<<<<<<<<<<<<<
    up_old = up;
    up = up_delta; 
     
     
     %>>>>>>>>>>>>>>>>>>>>>>>>     CHECK STOP CONDITION     <<<<<<<<<<<<<<<<<<<<<<<
    dup = up-up_old;
    if (dup'*dup < alpha2) | (ch_perf==0),
      break;
    end 
       
       
     %>>>>>>>>>>>>>>>>>>>     BFGS UPDATE OF INVERSE HESSIAN    <<<<<<<<<<<<<<<<<<
    dG  = dJdu - dJdu_old;
    BdG = B*dG;
    dupdG = dup'*dG;
    fac = 1/dupdG;
    diff = dup - BdG;
    dupfac=dup*fac;
    diffdup = diff*(dupfac'); 
    B = B + diffdup + diffdup' - (diff'*dG)*(dupfac*dupfac');
  end


    %>>>>>>>>>>>>>>>>>>>>>>>     SELECT BEST MINIMUM     <<<<<<<<<<<<<<<<<<<<<<<<<
  if tr==1,
    Jmin_old = J;
    upmin = up;
  else
    if J<Jmin_old,
      upmin = up;
    end
  end
end

x(1:Ni-1)=x(2:Ni);           % State 1 to Nu = actual controls
if upmin(1)>1 | upmin(1)<-1
   upmin(1)=upmin(1);
end
if Normalize
   upmin=(upmin+1)*(maxp-minp)/2+minp;
end
x(Ni:Nu+Ni-1)=upmin;           % State 1 to Nu = actual controls
for k=1:Nj-2
  x(Nu+Ni+1+(k-1)*(S1+1):Nu+Ni+S1+(k-1)*(S1+1))=x(Nu+Ni+1+(k)*(S1+1):Nu+Ni+S1+(k)*(S1+1));
  x(Nu+Ni+(k-1)*(S1+1))=x(Nu+Ni+(k)*(S1+1));                             % delayed plant output
end
if Nj>=2
   if Normalize
      x(Nu+Ni+(Nj-2)*(S1+1))=((u(3)-mint)*2/(maxt-mint)-1);            % state Nu+1 = NN output
   else
      x(Nu+Ni+(Nj-2)*(S1+1))=u(2);
   end
   x(Nu+Ni+1+(Nj-2)*(S1+1):Nu+Ni+S1+(Nj-2)*(S1+1))=Ai{1,Nj};    % State Nu+2... = delayed layer 1 output.
end
 

sys=x;


%end mdlUpdate


x(Nu+Ni+1+(Nj-2)*(S1+1):Nu+Ni+S1+(Nj-2)*(S1+1))=Ai{1,Nj};    % State Nu+2... = delayed layer 1 output.
sys=x;


%end mdlUpdate


