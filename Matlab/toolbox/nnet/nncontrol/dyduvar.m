function [sys,x0,str,ts] = dyduvar(t,x,u,flag,Nu,Ni,Nj,Ts,minp,maxp,mint,maxt,Normalize)
%DYDUVAR This function calculates the partial derivative of the 
%   output Y respect to the input U. It's intended to be used with
%   the function ptest2sim2 of the Neural Network Predictive Controller.
%   
%   See sfuntmpl.m for a general S-function template.
%
%   See also SFUNTMPL.
    
% Orlando De Jesus, Martin Hagan, 1-30-00
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.3 $ $Date: 2002/04/14 21:12:07 $

switch flag,

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0,
   [sys,x0,str,ts]=mdlInitializeSizes(Nu,Ni,Nj,Ts);
  
  %%%%%%%%%%  
  % Update %
  %%%%%%%%%%
  case 2,                                               
    sys = mdlUpdate(t,x,u,Nu,Ni,Nj);
    
  %%%%%%%%%%
  % Output %
  %%%%%%%%%%
  case 3,  
    sys = mdlOutputs(t,x,u,Nu,Ni,Nj,minp,maxp,mint,maxt,Normalize);    

  %%%%%%%%%%%%%
  % Terminate %
  %%%%%%%%%%%%%
  case 9,                                               
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
function [sys,x0,str,ts]=mdlInitializeSizes(Nu,Ni,Nj,Ts)

sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = Nu*(Ni+Nj);
sizes.NumOutputs     = Nu;
sizes.NumInputs      = -1;
sizes.DirFeedthrough = 0;
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);

x0  = zeros(Nu*(Ni+Nj),1);
x0(1)=1;
str = [];
ts  = [Ts 0]; % Inherited sample time

% end mdlInitializeSizes

%
%=======================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=======================================================================
%
function sys = mdlOutputs(t,x,u,Nu,Ni,Nj,minp,maxp,mint,maxt,Normalize)
sys = x(Ni+1);
for k=1:Nu-1
   sys = [sys;x(k*(Ni+Nj)+Ni+1)];%u;    
   if Normalize
      sys=sys*(maxt-mint)/(maxp-minp);
   end
end

%end mdlUpdate

%
%=======================================================================
% mdlOutputs
% Return the output vector for the S-function
%=======================================================================
%
function sys = mdlUpdate(t,x,u,Nu,Ni,Nj)

kk=(Nu-1)*(Ni+Nj);
out=u(1:Ni)'*x(kk+1:kk+Ni)+u(Ni+1:Ni+Nj)'*x(kk+Ni+1:kk+Ni+Nj);
x(kk+2:kk+Ni)=x(kk+1:kk+Ni-1);           
if x((Nu-2)*(Ni+Nj)+1)==1 | x(kk+1)==1
  x(kk+1)=1;            
else
  x(kk+1)=0;
end
x(kk+Ni+2:kk+(Ni+Nj))=x(kk+Ni+1:kk+(Ni+Nj)-1);           
x(kk+Ni+1)=out;    

for k=Nu-1:-1:1
  kk=(k-1)*(Ni+Nj);
  out=u(1:Ni)'*x(kk+1:kk+Ni)+u(Ni+1:Ni+Nj)'*x(kk+Ni+1:kk+Ni+Nj);
  if k~=1
    x(kk+1:kk+Ni)=x((k-2)*(Ni+Nj)+1:(k-2)*(Ni+Nj)+Ni);
  else
    x(kk+2:kk+Ni)=x(kk+1:kk+Ni-1);           
    x(kk+1)=0;            
  end
  x(kk+Ni+2:kk+Ni+Nj)=x(kk+Ni+1:kk+Ni+Nj-1);           
  x(kk+Ni+1)=out;    
end


sys=x;

%end mdlUpdate


