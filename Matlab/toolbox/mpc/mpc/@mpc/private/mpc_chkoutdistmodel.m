function newmodel=mpc_chkoutdistmodel(model,ny,ts,type);

%MPC_CHKOUTDISTMODEL Check output or input disturbance model 
%   and convert it to discrete-time, state-space, delay-free form

%    A. Bemporad
%    Copyright 2001-2004 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date:   

verbose=warning('query','mpc:verbosity');
verbose=strcmp(verbose.state,'on');

errmsg=sprintf('%s disturbance model must be an LTI object with %d outputs',type,ny);
if isa(model,'double'),
    % Static gain, convert to LTI
    model=tf(model);
end
if ~isa(model,'lti'), % |~isa(model,'fir'), %<<<<<========== CHECK OUT for FIR models !!!
    error('mpc:mpc_outdistmodel:lti',errmsg);
end
outnum=size(model,1);
if outnum~=ny,
    error('mpc:mpc_outdistmodel:outsize',errmsg);
end
if ~isa(model,'ss'),
    model=ss(model);
end
nts=model.Ts;
if nts==0,
    model=c2d(model,ts);    % Note: UserData field is lost during conversion !!!
    
elseif abs(ts-nts)>1e-10, % ts different from nts
    if verbose,
        fprintf('-->%s disturbance model resampled to controller''s sampling time Ts=%0.4g\n',type,ts);
    end
    model=d2d(model,ts);
    %takes out possible imaginary parts
    set(model,'a',real(model.a),'b',real(model.b));
end
if hasdelay(model),
    %model=d2d(model,'nodelay');
    if verbose,        
        fprintf('-->%s disturbance model: converting delays to states.\n',type);
    end
    model=delay2z(model);
end   

newmodel=model;
% end of mpc_chkoutdistmodel
