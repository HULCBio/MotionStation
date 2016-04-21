function setoutdist(MPCobj,method,extra)

%SETOUTDIST modifies the model used for representing output disturbances
%
%   SETOUTDIST(MPCobj,'integrators') imposes the default output disturbance
%   model based on the specs stored in MPCobj.OutputVariables.Integrator 
%   and MPCobj.Weights.OutputVariables. Output integrators are added according 
%   to the following rule: (1) outputs are ordered by decreasing output weight 
%   (2) an output integrator is added per measured output unless (a) there is a 
%   violation of observability, or (b) the corresponding value in Integrator is 
%   zero, or (c) the corresponding weight is zero.  
%
%   SETOUTDIST(MPCobj,'remove',channels) removes integrators from the output channels 
%   specified in vector channels. It corresponds to setting 
%   MPCobj.OutputVariables(channels).Integrator=0. The default for channels is (1:ny), 
%   where ny is the total number of outputs (all output integrators are removed).
%
%   SETOUTDIST(MPCobj,'model',model) replaces the array of output integrators designed 
%   according to MPCobj.OutputVariables.Integrator with the LTI model model. This 
%   must have ny outputs, where ny is the total number of outputs. The provided
%   model is stored internally in the mpc object MPCobj. If no model is specified, then 
%   the default model based on the specs stored in MPCobj.OutputVariables.Integrator 
%   and MPCobj.Weights.OutputVariables is used (same as  SETOUTDIST(MPCobj,'integrators')).
%
%   See also GETOUTDIST.

%   Author: A. Bemporad
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2004/04/10 23:35:15 $   

verbose=warning('query','mpc:verbosity');
verbose=strcmp(verbose.state,'on');

if nargin<1,
    error('mpc:setoutdist:none','No MPC object supplied.');
end
if ~isa(MPCobj,'mpc'),
    error('mpc:setoutdist:obj','Invalid MPC object');
end
if isempty(MPCobj),
    error('mpc:setoutdist:empty','Empty MPC object');
end

if nargin<2,
    method='integrators';
else
    if ischar(method)
        method=lower(method);
    end
    if ~ischar(method)|(~strcmp(method,'remove')&~strcmp(method,'model')&~strcmp(method,'svd')&~strcmp(method,'integrators')),
        error('mpc:setoutdist:method','Method should be ''integrators'' or ''remove'' or ''model'' or ''svd''');
    end
end

MPCData=getmpcdata(MPCobj);
ny=MPCData.ny;

% Transform 'model' with no model to 'integrators'
if strcmp(method,'model') & nargin<3,
    if verbose,
        fprintf('-->No output disturbance model specified -- Assuming default output integrators\n');
    end
    method='integrators';
end

outmodelflag=0; % if outmodelflag=0, then output disturbance model = integrators

try
    switch method
        case 'model'

            OutDistModel=extra; % Save original model

            extra=mpc_chkoutdistmodel(extra,ny,MPCobj.Ts,'Output');

            % Now replace default integrators with the new output disturbance model
            MPCstruct=mpc_struct(MPCobj,[],'outdistmodel',extra); % xmpc0=[]

            outmodelflag=1;

        case 'integrators'
            % Default method
            MPCstruct=mpc_struct(MPCobj,[],'base'); % xmpc0=[]

        case 'remove'
            if nargin<3,
                extra=(1:ny); % all output integrators removed
            else
                err=1;
                if isnumeric(extra),
                    extra=unique(round(extra)); % round, sort, and delete duplicates
                    if all(extra>0)&all(extra<=ny),
                        err=0;
                    end
                end
                if err,
                    error('mpc:setoutdist:channel',sprintf('Output channels should have indices between 1 and %d',ny));
                end
            end

            ov=MPCobj.OutputVariables;
            % Remove output integrators by zeroing the corresponding magnitude
            for h=1:ny,
                if ismember(h,extra),
                    ov(h).Integrator=0;
                end
            end
            MPCobj.OutputVariables=ov;
            MPCstruct=mpc_struct(MPCobj,[],'base'); % xmpc0=[]
        case 'svd'
            error('mpc:setoutdist:svd','SVD method will be available in future releases.')
    end
catch
    rethrow(lasterror);
end

MPCData.MPCstruct=MPCstruct;
MPCData.Init=1;
MPCData.QP_ready=1;
MPCData.L_ready=1;
MPCData.OutDistFlag=outmodelflag;

if outmodelflag,
    MPCData.OutDistModel=OutDistModel;
end

setmpcdata(MPCobj,MPCData);

% Update MPC object in the workspace
try
   assignin('caller',inputname(1),MPCobj);
end
