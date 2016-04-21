function [ts,A,Cm,Dvm,Bu,Bv,...
      PTYPE,nu,nv,nym,ny,nx,...
      degrees,M,MuKduINV,KduINV,Kx,Ku1,Kut,Kr,Kv,zmin,rhsc0,...
      Mlim,Mx,Mu1,Mv,rhsa0,TAB,optimalseq,utarget,... %rv,anticipate,
      lastx,lastu,p,Jm,DUFree,uoff,yoff,voff,myoff,no_md,no_ref,...
      ref_from_ws,ref_signal,ref_preview,md_from_ws,md_signal,md_preview,...
      maxiter,nxQP,openloopflag,md_inport,no_ym] = mpc_get_param_sim

%MPC_GET_PARAM_SIM Get all necessary matrices needed by the S-function MPC_SFUN.DLL

%   Author: A. Bemporad
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.7 $  $Date: 2004/04/10 23:39:13 $   


MPCstruct=get_param(gcb,'Userdata');

% If there is no MPC object set all param to be empty - jgo
openloopflag = 0;
if isempty(MPCstruct) || ~isstruct(MPCstruct)
    [ts,A,Cm,Dvm,Bu,Bv,...
      PTYPE,nu,nv,nym,ny,nx,...
      degrees,M,MuKduINV,KduINV,Kx,Ku1,Kut,Kr,Kv,zmin,rhsc0,...
      Mlim,Mx,Mu1,Mv,rhsa0,TAB,optimalseq,utarget,... %rv,anticipate,
      lastx,lastu,p,Jm,DUFree,uoff,yoff,voff,myoff,no_md,no_ref,...
      ref_from_ws,ref_signal,ref_preview,md_from_ws,md_signal,md_preview,...
      maxiter,nxQP,md_inport,no_ym] = deal(0);
    % (jgo) When the mask is initialized with no MPC object the userdata
    % property is used to store the number of outputs. This must be passed
    % to the mpc_sfun so that it can initialize the number of open loop
    % states
    nu = eval(get_param(gcb,'n_mv'));
    openloopflag = 1;
    return
end

names=fieldnames(MPCstruct);

for i=1:length(names),
   aux=names{i};
   eval(sprintf('%s=MPCstruct.%s;',aux,aux));
end

% Get name of root simulink diagram
root=gcs;
i=find(root=='/');
if ~isempty(i),
   root=root(1:i(1)-1); 
end
t0=str2num(get_param(root,'StartTime'));

% Define ref_signal and md_signal
ref_signal=[];
if MPCstruct.ref_from_ws,
   try
      % Try evaluating signal_name
      ref_signal=evalin('base',ref_signal_name);
   catch
      error('mpc:mpc_get_param_sim:ref','Invalid Reference signal');
   end
   ref_signal=mpc_chk_ext_signal(ref_signal,'Reference',ny,ts,yoff,t0);
end
MPCstruct.ref_signal=ref_signal;

md_signal=[];
if MPCstruct.md_from_ws,
   try
      % Try evaluating signal_name
      md_signal=evalin('base',md_signal_name);
   catch
      error('mpc:mpc_get_param_sim:md','Invalid Measured Disturbance signal');
   end
   md_signal=mpc_chk_ext_signal(md_signal,'Measured disturbance',nv-1,ts,voff,t0);
end
MPCstruct.md_signal=md_signal;

set_param(gcb,'Userdata',MPCstruct);
