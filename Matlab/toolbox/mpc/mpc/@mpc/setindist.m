function setindist(MPCobj,method,extra)
%SETINDIST modifies the model used for representing unmeasured input disturbances
%
%   SETINDIST(MPCobj,'integrators') imposes the default disturbance
%   model for unmeasured inputs, that is for each unmeasured input disturbance
%   channel, an integrator is added unless there is a violation of
%   observability, otherwise the input is treated as white noise with unit
%   variance (this is equivalent to MPCobj.Model.Disturbance=[]).
%   Type "getindist(MPCobj)" to obtain the default model.
%
%   SETINDIST(MPCobj,'model',model) sets the input disturbance model to
%   MODEL (this is equivalent to MPCobj.Model.Disturbance=model);
%
%   See also GETINDIST, SET.

%   Author: A. Bemporad
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2004/04/10 23:35:13 $

verbose=warning('query','mpc:verbosity');
verbose=strcmp(verbose.state,'on');

if nargin<1,
    error('mpc:setindist:none','No MPC object supplied.');
end
if ~isa(MPCobj,'mpc'),
    error('mpc:setindist:obj','Invalid MPC object');
end
if isempty(MPCobj),
    error('mpc:setindist:empty','Empty MPC object');
end

if nargin<2,
    method='default';
else
    if ischar(method)
        method=lower(method);
    end
    if ~ischar(method)|(~strcmp(method,'integrators')&~strcmp(method,'model')),
        error('mpc:setindist:method','Method should be ''integrators'' or ''model''');
    end
end

% Transform 'model' with no model to 'integrators'
if strcmp(method,'model') & nargin<3,
    if verbose,
        fprintf('-->No input disturbance model specified -- Assuming default integrators\n');
    end
    method='integrators';
end

try
    switch method
        case 'model'
            Model=MPCobj.Model;
            Model.Disturbance=extra;
            set(MPCobj,'Model',Model);

        case 'integrators'
            % Default method

            Model=MPCobj.Model;
            Model.Disturbance=[];
            set(MPCobj,'Model',Model);
    end
catch
    rethrow(lasterror);
end

% Update MPC object in the workspace
try
    assignin('caller',inputname(1),MPCobj);
end
