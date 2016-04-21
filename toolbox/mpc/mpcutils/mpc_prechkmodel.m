function [Model,nu,ny,nutot,mvindex,mdindex,unindex,myindex]=...
    mpc_prechkmodel(Model,Ts,simmodelflag)
% MPC_PRECHKMODEL Check the Model structure, and consistency of Model.Plant.

%   Author: A. Bemporad
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.8 $  $Date: 2004/04/10 23:39:20 $

if nargin<4,
    simmodelflag=0;
end

fields={'Plant','Disturbance','Noise','Nominal'};
names=fieldnames(Model);

% Check names and convert to right case
for i=1:length(names),
    j=find(ismember(lower(fields),lower(names{i}))==1);
    if isempty(j)
        error('mpc:mpc_prechkmodel:field',sprintf('%s is not a valid field name for Model. Valid field names: Plant,Nominal,Disturbance,Noise',names{i}));
    else
        %eval(['Model.' fields{j} '=Model.' names{i} ';']);
        Model.(fields{j})=Model.(names{i});
        if ~strcmp(names{i},fields{j}),
            %remove field
            %eval(['Model=rmfield(Model,''' names{i} ''');']);
            Model=rmfield(Model,names{i});
        end
    end
end

for i=1:length(fields),
    %eval(['isf=isfield(Model,''' fields{i} ''');']);
    isf=isfield(Model,fields{i});
    if ~isf,
        %eval(['Model.' fields{i} '=[];']);
        Model.(fields{i})=[];
    end
end

if ~isa(Model.Plant,'lti'),
    error('mpc:mpc_prechkmodel:ltiplant','Model.Plant is not an LTI object.')
end

if length(size(Model.Plant))>2,
    error('mpc:mpc_prechkmodel:array','Arrays of LTI objects not supported for Model.Plant')
end

if ~isreal(Model.Plant),
    error('mpc:mpc_prechkmodel:cplxplant','Model.Plant has complex coefficients.')
end

if Model.Plant.Ts==0 & isempty(Ts),
    error('mpc:mpc_prechkmodel:ts','You must specify a sampling time when Model.Plant is continuous time')
end

% Check correctness of signal types
[mvindex,mdindex,unindex,myindex,uyindex]=mpc_chkindex(Model.Plant);

if isempty(mvindex),
    error('mpc:mpc_prechkmodel:noMV','Model.Plant has no manipulated variable');
end
group=struct('Manipulated',mvindex(:)');
if ~isempty(mdindex), % Matlab 6 doesn't like empty indices
    group.Measured=mdindex(:)';
end
if ~isempty(unindex),
    group.Unmeasured=unindex(:)';
end
Model.Plant.InputGroup=group;

group=struct('Measured',myindex(:)');
if ~isempty(uyindex), % Matlab 6 doesn't like empty indices
    group.Unmeasured=uyindex(:)';
end
Model.Plant.OutputGroup=group;

Model.Nominal=mpc_chkoffsets(Model.Plant,Model.Nominal);

% Nonzero offsets on unmeasured disturbances are not allowed
if max(abs(Model.Nominal.U(unindex)))>0,
    error('mpc:mpc_prechkmodel:umdoff','Nonzero offsets on unmeasured disturbance inputs are not allowed -- Please treat such offsets as extra measured disturbances');
end


[ny,nutot]=size(Model.Plant);% number of outputs and inputs
nu=length(mvindex);   % number of manipulated vars
nym=length(myindex);

% Check for direct feedthrough from manipulated variables to measured outputs
% We avoid here computing a full state-space realization, just compute the D matrix
Dmu=zeros(nym,nu);
sys=Model.Plant;
if hasdelay(sys), % Plant model has delays
    if sys.ts==0,
        % Continuous time model, we must discretize it before converting
        % delays to poles in z=0
        sys=c2d(sys,Ts);
    end
    sys=delay2z(sys);
end
if isa(sys,'ss'),
    Dmu=sys.D(myindex,mvindex);
elseif isa(sys,'tf'),
    for i=1:nym,
        for j=1:nu,
            num=sys.num{myindex(i),mvindex(j)};
            den=sys.den{myindex(i),mvindex(j)};
            if (length(num)==length(den)),
                Dmu(i,j)=num(1)/den(1);
            else
                Dmu(i,j)=0;
            end
        end
    end
elseif isa(sys,'zpk'),
    for i=1:nym,
        for j=1:nu,
            zer=sys.z{myindex(i),mvindex(j)};
            pol=sys.p{myindex(i),mvindex(j)};
            if (length(zer)==length(pol)),
                Dmu(i,j)=1;
            else
                Dmu(i,j)=0;
            end
        end
    end
    Dmu=sys.k(myindex,mvindex).*Dmu;
end
%nDmu=norm(Dmu,'inf');
%if nDmu>1e-8,
%   error('Direct feedthrough from manipulated variables to measured outputs is not allowed.')
%end
%if nDmu<1e-8 & nDmu>0,
%   warning('Nonzero direct feedthrough from manipulated variables to measured outputs.')
%end
if norm(Dmu,'inf'),
    error('mpc:mpc_prechkmodel:feedthrough','Direct feedthrough from manipulated variables to measured outputs is not allowed.')
end

% if isa(Model.Plant,'ss'),
%     % Check for controllability from MVs
% 
%     if rank(ctrb(Model.Plant(:,mvindex)))<size(Model.Plant.A,1),
%         warning('mpc:mpc_prechkmodel:ctrb','Model.Plant is not fully controllable from manipulated variables.')
%     end
% else
%     sys1=ss(Model.Plant(:,mvindex));
%     sys2=ss(Model.Plant);
%     if rank(size(sys1.A)<size(sys2.A,1),
%         warning('mpc:mpc_prechkmodel:ctrb','Model.Plant is not fully controllable from manipulated variables.')
%     end
% end

if isa(Model.Plant,'ss') & ~simmodelflag,
     % Check for observability from MOs
    theta=obsv(Model.Plant.A,Model.Plant.C(myindex,:));
    obs=rank(theta,0);
    if obs<size(Model.Plant.A,1),
        error('mpc:mpc_prechkmodel:obsv','Model.Plant is unobservable.');
    end
    % Now check for "numerical" observability
    obs=rank(theta);
    if obs<size(Model.Plant.A,1),
        warning('mpc:mpc_prechkmodel:obsv',sprintf([ ...
            'Model.Plant is almost unobservable, the condition number of the observability'...
            ' matrix is %g.'],cond(theta)));
    end
end

% Check Model.Disturbance

if ~isempty(Model.Disturbance),
    if isa(Model.Disturbance,'double'),
        % Static gain, convert to LTI
        Model.Disturbance=tf(Model.Disturbance);
    end

    if ~isa(Model.Disturbance,'lti'),
        error('mpc:mpc_prechkmodel:ltidist','Model.Disturbance is not an LTI object.')
    end
    if length(size(Model.Disturbance))>2,
        error('mpc:mpc_prechkmodel:arraydist','Arrays of LTI objects not supported for Model.Disturbance')
    end
    if ~isreal(Model.Disturbance),
        error('mpc:mpc_prechkmodel:cplxdist','Model.Disturbance has complex coefficients.')
    end
    nun=length(unindex);
    if nun~=size(Model.Disturbance,1),
        error('mpc:mpc_prechkmodel:sizedist',sprintf('Model.Disturbance should have %d outputs',nun))
    end
    
    % The observability of the series Disturbance->Plant will be checked
    % by MPC_PRECHKMODEL when the MPC object is first used
end

% Check Model.Noise

if ~isempty(Model.Noise),
    if isa(Model.Noise,'double'),
        % Static gain, convert to LTI
        Model.Noise=tf(Model.Noise);
    end

    if ~isa(Model.Noise,'lti'),
        error('mpc:mpc_prechkmodel:ltinoise','Model.Noise is not an LTI object.')
    end
    if length(size(Model.Noise))>2,
        error('mpc:mpc_prechkmodel:arraynoise','Arrays of LTI objects not supported for Model.Disturbance')
    end
    if ~isreal(Model.Noise),
        error('mpc:mpc_prechkmodel:cplxnoise','Model.Noise has complex coefficients.')
    end

    if nym~=size(Model.Noise,1),
        error('mpc:mpc_prechkmodel:sizenoise',sprintf('Model.Noise should have %d outputs = number of measured outputs',nym))
    end
end


% Set Default I/O Names

uname=Model.Plant.InputName;
for i=1:nutot,
    if isempty(uname{i}),
        [yn,j]=ismember(i,mvindex);
        if yn,
            signal='MV';
            num=j;
        end
        [yn,j]=ismember(i,mdindex);
        if yn,
            signal='MD';
            num=j;
        end
        [yn,j]=ismember(i,unindex);
        if yn,
            signal='UD';
            num=j;
        end
        uname{i}=sprintf('%s%d',signal,num);
    end
end
Model.Plant.InputName=uname;

yname=Model.Plant.OutputName;
uyindex=setdiff([1:ny]',myindex(:));
for i=1:ny,
    if isempty(yname{i}),
        [yn,j]=ismember(i,myindex);
        if yn,
            signal='MO';
            num=j;
        end
        [yn,j]=ismember(i,uyindex);
        if yn,
            signal='UO';
            num=j;
        end
        yname{i}=sprintf('%s%d',signal,num);
    end
end
Model.Plant.OutputName=yname;

if ~isempty(Model.Disturbance) & ~isempty(Model.Disturbance.OutputName{:}),
    error('mpc:mpc_prechkmodel:dnames',...
        'Disturbance signal names must be specified in Model.Plant.InputName');
end
% if ~isempty(Model.Noise.OutputName{:}),
%     warning('Noise signal names must be specified in Model.Plant.OutputName');
% end