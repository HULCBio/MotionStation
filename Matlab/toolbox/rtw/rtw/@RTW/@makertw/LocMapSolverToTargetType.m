function output = LocMapSolverToTargetType(h, hModel, solver, tlcTargetType)
% Abstract:
%      Given the solver type (and tlcTargetType) determine the type of
%      target: RT or NRT.
%   Note: It's not recommended to be overloaded in subclass.

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/15 00:23:55 $


switch (solver)
    case {'FixedStepDiscrete', 'ode1', 'ode2', 'ode3', 'ode4', 'ode5', ...
          'ode14x'}
        output = 'RT';
    case {'VariableStepDiscrete', 'ode45', 'ode23', 'ode113', 'ode15s', ...
                'ode23s', 'ode23t', 'ode23tb'}
        output = 'NRT';
        if strcmp(tlcTargetType,'RT')
            modelName = h.ModelName;
            errmsg =['The specified Real-Time Workshop target cannot be used ', ...
                    'with a variable-step solver. You must configure ',...
                    'the solver options for a fixed-step solver with ', ...
                    'an appropriate integration algorithm.'];
            errmsg2 =' (press Open)';
            cmdTxt = sprintf( ...
                ['slCfgPrmDlg(''%s'', ''Open'');', ...
                 'slCfgPrmDlg(''%s'', ''TurnToPage'', ''Solver'');'], ...
                modelName, modelName);
            slsfnagctlr('Clear', modelName, 'RTW Builder');
            nag                = slsfnagctlr('NagTemplate');
            nag.type           = 'Error';
            nag.msg.details    = [errmsg errmsg2];
            nag.msg.type       = 'Build';
            nag.msg.summary    = [errmsg errmsg2];
            nag.component      = 'RTW';
            nag.sourceName     = modelName;
            nag.sourceFullName = modelName;
            nag.openFcn        = cmdTxt;
            slsfnagctlr('Push', nag);
            slsfnagctlr('View');
            % Throw the error as well so build stops and cmdline invocations get the
            % error.
            error('%s',errmsg);
        end
 
   otherwise
        error(['make_rtw.m: Unhandled solver ',solver]);
end
%endfunction LocMapSolverToTargetType
