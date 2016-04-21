function [newmodel,newts,newxp0,newu1,uoff,yoff,xoff,dxoff]=mpc_chkmodel(...
    model,ts,offsets,xp0,u1,mvindex)
%MPC_CHKMODEL Check if 'model', 'ts', 'xp0', 'u1' are ok

%   Author: A. Bemporad
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.10 $  $Date: 2004/04/16 22:09:41 $   

verbose=warning('query','mpc:verbosity');
verbose=strcmp(verbose.state,'on');

if ~isa(model,'ss'),
    if verbose,
        fprintf('-->Converting Model.Plant to state-space.\n')
    end
    model=ss(model);
    offsets.X=zeros(size(model.A,1),1);
    offsets.DX=offsets.X;
    if ~isempty(xp0), 
        error('mpc:mpc_model:SSstate','You have specified and initial state for plant model, which is not a SS model');
    end   
end

% Delete input/output names, to avoid conflicts when augmenting the
% plant without adding names for new inputs/outputs
model.InputName(:) = {''};
model.OutputName(:) = {''};

% Check Offsets and augment model
xoff=offsets.X;
uoff=offsets.U;
yoff=offsets.Y;
dxoff=offsets.DX;

% Augment the model
[ny,nx]=size(model.c);

mts=model.ts;

if mts<0,
    if ts>0,
        wmsg1='No sampling time provided for plant model.';
        wmsg2=sprintf('Assuming sampling time = controller''s sampling time = %g',ts);
        warning('mpc:mpc_chkmodel:defaultts',sprintf('%s\n         %s',wmsg1,wmsg2));
        mts=ts;
        model.ts=ts;
    else
        error('mpc:mpc_chkmodel:noTs','No sampling time provided for plant model');
    end
end

if mts==0, % Continuous time model
    %   set(model,'b',[model.b,dx-model.b*u],'d',[model.d,y-model.d*u]); <<DOESN'T WORK IF THERE ARE DELAYS!
    set(model,'b',[model.b,dxoff],'d',[model.d,zeros(ny,1)],...
        'iodelay',[model.iodelay,zeros(ny,1)],'inputdelay',[model.inputdelay;0]);
else % discrete time model
    %   set(model,'b',[model.b,dx-x-model.b*u],'d',[model.d,y-model.d*u]);
    %WAS: set(model,'b',[model.b,dxoff-xoff],'d',[model.d,zeros(ny,1)],...
    set(model,'b',[model.b,dxoff],'d',[model.d,zeros(ny,1)],...
        'iodelay',[model.iodelay,zeros(ny,1)],'inputdelay',[model.inputdelay;0]);
end   

% Name the additional signal as 'Offset'

ingroup=model.InputGroup;
% Convert possible old 6.xx cell format to structure, using mpc_getgroup 
ingroup=mpc_getgroup(ingroup); 
ingroup.Offset=size(model.b,2);

set(model,'InputGroup',ingroup);


% Check consistency of xp0
xp0=mpc_chkx0u1(xp0,nx,xoff,'InitialState.Plant');


xp0=xp0-xoff; % Initial condition for the linearized plant

% Check consistency of u1
nu=length(mvindex); 
u1=mpc_chkx0u1(u1,nu,uoff(mvindex),'LastMove');
u1=u1-uoff(mvindex); % Initial condition for linearized previous input

if mts==0,
    %if isempty(ts), 
    %   error('No sampling time specified')   << Already checked by MPC constructor
    %end
    if verbose,        
        fprintf('-->Converting model to discrete time.\n');
    end

    newts=ts;
    
    try 
        % Try is needed because C2D may give the error 'Initial state mapping G is not meaningful for 
        % models with I/O delays.' when iodelays are present
        
        [model,TRmat]=c2d(model,ts);    % Note: UserData field is lost during conversion !!!
        % TRmat maps continuous initial conditions
        % into discrete initial conditions.  Specifically, if x0,u0 
        % are initial states and inputs for the continuous time model, 
        % then equivalent initial conditions for the discrete time model 
        % are given by  xd0 = TRmat * [x0;u0],  ud0 = u0 .
        
        if ~norm(u1)>0,
            xp0=TRmat(:,1:size(model.A,1))*xp0; % u1 might be empty
        else
            xp0=TRmat*[xp0;u1;1]; % u1=initial input, 1=initial input for the offset MD
        end
        %if norm(xp0)>0 & norm(u1)>0 & norm(TRmat(:,nx+1:size(TRmat,2)))>0,
        %   % Usually this never happens
        %   disp('Warning: initial state information might be wrong')
        %   disp('         because of continuous->discrete conversion.')
        %end
    catch
        if model.ts==0,
            model=c2d(model,ts);    % Note: UserData field is lost during conversion !!!
        end
        if norm(xp0)>0,
            warning('mpc:mpc_chkmodel:zerox0','Initial conditions are zeroed');
        end
        xp0=zeros(size(model.A,1),1);
        if norm(xoff)>0|norm(dxoff)>0,
            warning('mpc:mpc_chkmodel:zerooffset','State offsets are zeroed');
        end
        xoff=xp0;
        dxoff=xp0;
    end
elseif isempty(ts) | abs(ts-mts)<=1e-10,
    newts=mts; % inherit controller sampling time from model
    
elseif abs(ts-mts)>1e-10, % ts different from mts
    if verbose,        
        fprintf('-->Resampling Model.Plant to controller''s sampling time.\n');
    end
    model=d2d(model,ts);
    %takes out possible imaginary parts 
    %set(model,'a',real(model.a),'b',real(model.b));
    newts=ts;
    % Initial state information should still be consistent 
    %xp0=zeros(size(model.a,1));
    
    % No, state dimension may not be consistent in case d2d augments the
    % order of the system
    xextra=zeros(size(model.A,1)-length(xp0),1);
    xp0=[xp0;xextra];
    xoff=[xoff(:);xextra];
    dxoff=[dxoff(:);xextra];
    if norm(xp0,'inf')>1e-10,
        warning('mpc:mpc_chkmodel:x0info','Initial state information may be incorrect');
    end
    if norm(xoff,'inf')>1e-10,
        warning('mpc:mpc_chkmodel:offsetinfox','State offset information may be incorrect');
    end
    if norm(dxoff,'inf')>1e-10,
        warning('mpc:mpc_chkmodel:offsetinfodx','State derivative offset information may be incorrect');
    end
end

% Eventually transforms I/O delays into poles in z=0

%if any(model.InputDelay)|any(model.OutputDelay)|any(model.ioDelayMatrix),   
if hasdelay(model),
    
    %model=d2d(model,'nodelay');
    if verbose,        
        fprintf('-->Converting delays to states.\n')
    end
    model=delay2z(model);
    % Pad xp0 with zeros 
    % Maybe only works for SISO
    aux=size(model.A,1)-length(xp0);
    xp0=[xp0(:);zeros(aux,1)];
    if norm(u1)>0,
        warning('mpc:mpc_chkmodel:nonzerou0','Initial state may be wrong, because initial input is nonzero.')
    end   
    xoff=[xoff(:);zeros(aux,1)];
    dxoff=[dxoff(:);zeros(aux,1)];
    
    
end

% Balancing

%try % try fails if model is not stable 
%   % Use BALREAL + MODRED
%   [bmodel,Gmodel,Tx]=balreal(model);
%	xp0=Tx*xp0; % Compatible initial state
%
%	% Use MODRED
%	modredtol=1e-4;
%	maxG=Gmodel(1); % Largest element (Gmodel is ordered)
%	ii=find(Gmodel<maxG*modredtol);
%	if ~isempty(ii),
%  	model=modred(bmodel,ii); % Get rid of those states
%		xp0=xp0(1:ii(1)-1); % get rid also of those corresponding initial states
%	end
%catch
%
% Because it modifies b,c matrices, and therefore
% weights, noise covariance matrices, and indices can cause problems
%
%   % USE BALANCE
%	[Tx,Bx]=balance(model.a);
%	model.a=Bx;
%	model.b=Tx\model.b;
%	model.c=model.c*Tx;
%	xp0=Tx\xp0;  % so that, for instance y(0)=Cx(0)=C*TX*inv(TX)*xp0=C*TX*z0
%end

% USE MINREAL
%modredtol=1e-5; % default is sqrt(eps)=1.5e-8
%[model,Tx]=minreal(model,modredtol);
%xp0=Tx*xp0; % Tx is always a square matrix, dim(Tx)=dim(original state)
%xp0=xp0(1:size(model.a,1)); 


newmodel=model;
newxp0=xp0;
newu1=u1;
