function [newp,p_defaulted]=mpc_chkp(p,default,Model,Ts)

%MPC_CHKP Check correctness of prediction horizon p

%    A. Bemporad
%    Copyright 2001-2004 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date:  

verbose=warning('query','mpc:verbosity');
verbose=strcmp(verbose.state,'on');

if ~isa(p,'double'),
   error('mpc:mpc_chkp:double','PredictionHorizon must be a real greater or equal than one.')
end
if p~=round(p),
   p=round(p);   
   warning('mpc:mpc_chkp:prounded',sprintf('PredictionHorizon has been rounded to the nearest integer, p=%d',p));
end
p_defaulted=0;
if isempty(p),
   p_defaulted=1;
   if verbose,
      fprintf('-->No value for PredictionHorizon supplied. Trying PredictionHorizon=%d.\n',default);
   end
   newp=default;
   return
elseif ~isfinite(p), %p=Inf
   error('mpc:mpc_chkp:inf','Infinite prediction horizon not implemented. Try a large horizon instead')
else
   [nrow,nb]=size(p);
   if nrow*nb~=1 | any(p<1), 
      error('mpc:mpc_chkp:pos','PredictionHorizon must be a real greater or equal than one.')
   end
end

% Check if p>=maximum delay
maxdelay=max(max(totaldelay(Model.Plant)));
if maxdelay>0,
    if Model.Plant.Ts==0,
        % The following will be the delay when the model is sampled using
        % C2D
        pdelay=floor(maxdelay/Ts); 
    else
        pdelay=maxdelay;
    end
    if p<=pdelay,
        if ~p_defaulted, % P was supplied by the user
            warning('mpc:mpc_chkp:delay',sprintf([...
                'Prediction horizon %d smaller than the maximum delay %d.\n'...
                '         You should choose a larger prediction horizon, for instance %d'],p,pdelay,p+pdelay));
        else
            p=p+pdelay;
            warning('mpc:mpc_chkp:delay',sprintf('PredictionHorizon further increased to %d because of system I/O delays.',p));
        end
    end
end
newp=p;

% end mpc_chkp
