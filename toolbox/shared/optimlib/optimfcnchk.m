function [allfcns,idandmsg] = optimfcnchk(funstr,caller,lenVarIn,funValCheck,gradflag,hessflag,constrflag,ntheta)
%OPTIMFCNCHK Pre- and post-process function expression for FCNCHK.
%
% This is a helper function.

%   [ALLFCNS,idandmsg] = OPTIMFCNCHK(FUNSTR,CALLER,lenVarIn,GRADFLAG) takes
%   the (nonempty) function handle or expression FUNSTR from CALLER with
%   LenVarIn extra arguments, parses it according to what CALLER is, then
%   returns a string or inline object in ALLFCNS.  If an error occurs,
%   this message is put in idandmsg.
%
%   ALLFCNS is a cell array:
%    ALLFCNS{1} contains a flag
%    that says if the objective and gradients are together in one function
%    (calltype=='fungrad') or in two functions (calltype='fun_then_grad')
%    or there is no gradient (calltype=='fun'), etc.
%    ALLFCNS{2} contains the string CALLER.
%    ALLFCNS{3}  contains the objective (or constraint) function
%    ALLFCNS{4}  contains the gradient function
%    ALLFCNS{5}  contains the hessian function (not used for constraint function).
%
%    If funValCheck is 'on', then we update the funfcn's (fun/grad/hess) so
%    they are called through CHECKFUN to check for NaN's, Inf's, or complex
%    values. Add a wrapper function, CHECKFUN, to check for NaN/complex
%    values without having to change the calls that look like this:
%    f = funfcn(x,varargin{:});
%    CHECKFUN is a nested function so we can get the 'caller', 'userfcn', and
%    'ntheta' (for fseminf constraint functions) information from this function
%    and the user's function and CHECKFUN can both be called with the same
%    arguments.

%    NOTE: we assume FUNSTR is nonempty.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/03/26 13:27:21 $

% Initialize
if nargin < 8
    ntheta = 0;
    if nargin < 7
        constrflag = false;
        if nargin < 6
            hessflag = false;
            if nargin < 5
                gradflag = false;
            end,end,end,end
if constrflag
    graderrid = 'optimlib:optimfcnchk:NoConstraintGradientFunction';
    graderrmsg = 'Constraint gradient function expected (OPTIONS.GradConstr=''on'') but not found.';
    warnid = 'optimlib:optimfcnchk:ConstraintGradientOptionOff';
    warnstr = ...
        sprintf('%s\n%s\n%s\n','Constraint gradient function provided but OPTIONS.GradConstr=''off'';', ...
        '  ignoring constraint gradient function and using finite-differencing.', ...
        '  Rerun with OPTIONS.GradConstr=''on'' to use constraint gradient function.');
else
    graderrid = 'optimlib:optimfcnchk:NoGradientFunction';
    graderrmsg = 'Gradient function expected (OPTIONS.GradObj=''on'') but not found.';
    warnid = 'optimlib:optimfcnchk:GradientOptionOff';
    warnstr = ...
        sprintf('%s\n%s\n%s\n','Gradient function provided but OPTIONS.GradObj=''off'';', ...
        '  ignoring gradient function and using finite-differencing.', ...
        '  Rerun with OPTIONS.GradObj=''on'' to use gradient function.');

end
idandmsg='';
if isequal(caller,'fseminf')
    nonlconmsg =  'SEMINFCON must be a function.';
    nonlconid = 'optimlib:optimfcnchk:SeminfconNotAFunction';
else
    nonlconmsg =  'NONLCON must be a function.';
    nonlconid = 'optimlib:optimfcnchk:NonlconNotAFunction';
end
allfcns = {};
funfcn = [];
gradfcn = [];
hessfcn = [];
if gradflag && hessflag
    calltype = 'fungradhess';
elseif gradflag
    calltype = 'fungrad';
else % ~gradflag & ~hessflag,   OR  ~gradflag & hessflag: this problem handled later
    calltype = 'fun';
end

if isa(funstr, 'cell') && length(funstr)==1 % {fun}
    % take the cellarray apart: we know it is nonempty
    if gradflag
        error(graderrid,graderrmsg)
    end
    [funfcn, idandmsg] = fcnchk(funstr{1},lenVarIn);
    % Insert call to nested function checkfun which calls user funfcn
    if funValCheck
        userfcn = funfcn;
        funfcn = @checkfun; %caller and userfcn are in scope in nested checkfun
    end
    if ~isempty(idandmsg)
        if constrflag % Constraint, not objective, function, so adjust error message
            error(nonlconid,nonlconmsg);
        else
            error(idandmsg);
        end
    end
elseif isa(funstr, 'cell') && length(funstr)==2 && isempty(funstr{2}) % {fun,[]}
    if gradflag
        error(graderrid,graderrmsg)
    end
    [funfcn, idandmsg] = fcnchk(funstr{1},lenVarIn);
    if funValCheck
        userfcn = funfcn;
        funfcn = @checkfun; %caller and userfcn are in scope in nested checkfun
    end
    if ~isempty(idandmsg)
        if constrflag
            error(nonlconid,nonlconmsg);
        else
            error(idandmsg);
        end
    end

elseif isa(funstr, 'cell') && length(funstr)==2 %  {fun, grad} and ~isempty(funstr{2})

    [funfcn, idandmsg] = fcnchk(funstr{1},lenVarIn);
    if funValCheck
        userfcn = funfcn;
        funfcn = @checkfun; %caller and userfcn are in scope in nested checkfun
    end

    if ~isempty(idandmsg)
        if constrflag
            error(nonlconid,nonlconmsg);
        else
            error(idandmsg);
        end
    end
    [gradfcn, idandmsg] = fcnchk(funstr{2},lenVarIn);
    if funValCheck
        userfcn = gradfcn;
        gradfcn = @checkfun; %caller and userfcn are in scope in nested checkfun
    end
    if ~isempty(idandmsg)
        if constrflag
            error(nonlconid,nonlconmsg);
        else
            error(idandmsg);
        end
    end
    calltype = 'fun_then_grad';
    if ~gradflag
        warning(warnid,warnstr);
        calltype = 'fun';
    end
elseif isa(funstr, 'cell') && length(funstr)==3 ...
        && ~isempty(funstr{1}) && isempty(funstr{2}) && isempty(funstr{3})    % {fun, [], []}
    if gradflag
        error(graderrid,graderrmsg)
    end
    if hessflag
        error('optimlib:optimfcnchk:NoHessianFunction','Hessian function expected but not found.')
    end
    [funfcn, idandmsg] = fcnchk(funstr{1},lenVarIn);
    if funValCheck
        userfcn = funfcn;
        funfcn = @checkfun; %caller and userfcn are in scope in nested checkfun
    end
    if ~isempty(idandmsg)
        if constrflag
            error(nonlconid,nonlconmsg);
        else
            error(idandmsg);
        end
    end

elseif isa(funstr, 'cell') && length(funstr)==3 ...
        && ~isempty(funstr{2}) && ~isempty(funstr{3})     % {fun, grad, hess}
    [funfcn, idandmsg] = fcnchk(funstr{1},lenVarIn);
    if funValCheck
        userfcn = funfcn;
        funfcn = @checkfun; %caller and userfcn are in scope in nested checkfun
    end

    if ~isempty(idandmsg)
        if constrflag
            error(nonlconid,nonlconmsg);
        else
            error(idandmsg);
        end
    end
    [gradfcn, idandmsg] = fcnchk(funstr{2},lenVarIn);
    if funValCheck
        userfcn = gradfcn;
        gradfcn = @checkfun; %caller and userfcn are in scope in nested checkfun
    end

    if ~isempty(idandmsg)
        if constrflag
            error(nonlconid,nonlconmsg);
        else
            error(idandmsg);
        end
    end
    [hessfcn, idandmsg] = fcnchk(funstr{3},lenVarIn);
    if funValCheck
        userfcn = hessfcn;
        hessfcn = @checkfun; %caller and userfcn are in scope in nested checkfun
    end

    if ~isempty(idandmsg)
        if constrflag
            error(nonlconid,nonlconmsg);
        else
            error(idandmsg);
        end
    end
    calltype = 'fun_then_grad_then_hess';
    if ~hessflag && ~gradflag
        hwarnstr = sprintf('%s\n%s\n%s\n','Hessian and gradient functions provided ', ...
            '  but OPTIONS.HEssian=''off'' and OPTIONS.GradObj=''off''; ignoring Hessian and gradient functions.', ...
            '  Rerun with OPTIONS.Hessian=''on'' and OPTIONS.GradObj=''on'' to use derivative functions.');
        warning('optimlib:optimfcnchk:HessianAndGradientOptionsOff',hwarnstr)
        calltype = 'fun';
    elseif hessflag && ~gradflag
        warnstr = ...
            sprintf('%s\n%s\n%s\n','Hessian and gradient functions provided ', ...
            '  but OPTIONS.GradObj=''off''; ignoring Hessian and gradient functions.', ...
            '  Rerun with OPTIONS.Hessian=''on'' and OPTIONS.GradObj=''on'' to use derivative functions.');
        warning('optimlib:optimfcnchk:GradientOptionOff',warnstr)
        calltype = 'fun';
    elseif ~hessflag && gradflag
        hwarnstr = ...
            sprintf('%s\n%s\n%s\n','Hessian function provided but OPTIONS.Hessian=''off'';', ...
            '  ignoring Hessian function,', ...
            '  Rerun with OPTIONS.Hessian=''on'' to use Hessian function.');
        warning('optimlib:optimfcnchk:HessianOptionOff',hwarnstr);
        calltype = 'fun_then_grad';
    end


elseif isa(funstr, 'cell') && length(funstr)==3 ...
        && ~isempty(funstr{2}) && isempty(funstr{3})    % {fun, grad, []}
    if hessflag
        error('optimlib:optimfcnchk:NoHessianFunction','Hessian function expected but not found.')
    end
    [funfcn, idandmsg] = fcnchk(funstr{1},lenVarIn);
    if funValCheck
        userfcn = funfcn;
        funfcn = @checkfun; %caller and userfcn are in scope in nested checkfun
    end
    if ~isempty(idandmsg)
        if constrflag
            error(nonlconid,nonlconmsg);
        else
            error(idandmsg);
        end
    end
    [gradfcn, idandmsg] = fcnchk(funstr{2},lenVarIn);
    if funValCheck
        userfcn = gradfcn;
        gradfcn = @checkfun; %caller and userfcn are in scope in nested checkfun
    end
    if ~isempty(idandmsg)
        if constrflag
            error(nonlconid,nonlconmsg);
        else
            error(idandmsg);
        end
    end
    calltype = 'fun_then_grad';
    if ~gradflag
        warning(warnid,warnstr);
        calltype = 'fun';
    end


elseif isa(funstr, 'cell') && length(funstr)==3 ...
        && isempty(funstr{2}) && ~isempty(funstr{3})     % {fun, [], hess}
    error('optimlib:optimfcnchk:NoGradientWithHessian','Hessian function given without gradient function.')

elseif ~isa(funstr, 'cell')  %Not a cell; is a string expression, function name string or inline object
    [funfcn, idandmsg] = fcnchk(funstr,lenVarIn);
    if funValCheck
        userfcn = funfcn;
        funfcn = @checkfun; %caller and userfcn are in scope in nested checkfun
    end

    if ~isempty(idandmsg)
        if constrflag
            error(nonlconid,nonlconmsg);
        else
            error(idandmsg);
        end
    end
    if gradflag % gradient and function in one function/M-file
        gradfcn = funfcn; % Do this so graderr will print the correct name
    end
    if hessflag && ~gradflag
        hwarnstr = ...
            sprintf('%s\n%s\n%s\n','OPTIONS.Hessian=''on''', ...
            '  but OPTIONS.GradObj=''off''; ignoring Hessian and gradient functions.', ...
            '  Rerun with OPTIONS.Hessian=''on'' and OPTIONS.GradObj=''on'' to use derivative functions.');
        warning('optimlib:optimfcnchk:GradientOptionOff',hwarnstr)
    end

else
    errmsg = sprintf('%s\n%s', ...
        'FUN must be a function or an inline object;', ...
        ' or, FUN may be a cell array that contains these type of objects.');
    error('optimlib:optimfcnchk:MustBeAFunction',errmsg)
end

allfcns{1} = calltype;
allfcns{2} = caller;
allfcns{3} = funfcn;
allfcns{4} = gradfcn;
allfcns{5} = hessfcn;

    %------------------------------------------------------------
    function [varargout] = checkfun(x,varargin)
    % CHECKFUN checks for complex, Inf, or NaN results from userfcn.
    % Inputs CALLER, USERFCN, and NTHETA come from the scope of OPTIMFCNCHK.
    % We do not make assumptions about f, g, or H. For generality, assume
    % they can all be matrices.
   
        if nargout == 1
            f = userfcn(x,varargin{:});
            if any(any(isnan(f)))
                error('optimlib:optimfcnchk:checkfun:NaNFval', ...
                    'User function ''%s'' returned NaN when evaluated;\n %s cannot continue.', ...
                    functiontostring(userfcn),upper(caller));
            elseif ~isreal(f)
                error('optimlib:optimfcnchk:checkfun:ComplexFval', ...
                    'User function ''%s'' returned a complex value when evaluated;\n %s cannot continue.', ...
                    functiontostring(userfcn),upper(caller));
            elseif any(any(isinf(f)))
                error('optimlib:optimfcnchk:checkfun:InfFval', ...
                    'User function ''%s'' returned Inf or -Inf when evaluated;\n %s cannot continue.', ...
                    functiontostring(userfcn),upper(caller));
            else
                varargout{1} = f;
            end

        elseif nargout == 2 % Two output could be f,g (from objective fcn) or c,ceq (from NONLCON)
            [f,g] = userfcn(x,varargin{:});
            if any(any(isnan(f))) || any(any(isnan(g)))
                error('optimlib:optimfcnchk:checkfun:NaNFval', ...
                    'User function ''%s'' returned NaN when evaluated;\n %s cannot continue.', ...
                    functiontostring(userfcn),upper(caller));
            elseif ~isreal(f) || ~isreal(g)
                error('optimlib:optimfcnchk:checkfun:ComplexFval', ...
                    'User function ''%s'' returned a complex value when evaluated;\n %s cannot continue.', ...
                    functiontostring(userfcn),upper(caller));
            elseif any(any(isinf(f))) || any(any(isinf(g)))
                error('optimlib:optimfcnchk:checkfun:InfFval', ...
                    'User function ''%s'' returned Inf or -Inf when evaluated;\n %s cannot continue.', ...
                    functiontostring(userfcn),upper(caller));
            else
                varargout{1} = f;
                varargout{2} = g;
            end

        elseif nargout == 3 % This case only happens for objective functions
            [f,g,H] = userfcn(x,varargin{:});
            if any(any(isnan(f))) || any(any(isnan(g))) || any(any(isnan(H)))
                error('optimlib:optimfcnchk:checkfun:NaNFval', ...
                    'User function ''%s'' returned NaN when evaluated;\n %s cannot continue.', ...
                    functiontostring(userfcn),upper(caller));
            elseif ~isreal(f) || ~isreal(g) || ~isreal(H)
                error('optimlib:optimfcnchk:checkfun:ComplexFval', ...
                    'User function ''%s'' returned a complex value when evaluated;\n %s cannot continue.', ...
                    functiontostring(userfcn),upper(caller));
            elseif any(any(isinf(f))) || any(any(isinf(g))) || any(any(isinf(H)))
                error('optimlib:optimfcnchk:checkfun:InfFval', ...
                    'User function ''%s'' returned Inf or -Inf when evaluated;\n %s cannot continue.', ...
                    functiontostring(userfcn),upper(caller));
            else
                varargout{1} = f;
                varargout{2} = g;
                varargout{3} = H;
            end
        elseif nargout == 4 & ~isequal(caller,'fseminf')
            % In this case we are calling NONLCON, e.g. for FMINCON, and
            % the outputs are [c,ceq,gc,gceq]
            [c,ceq,gc,gceq] = userfcn(x,varargin{:}); 
            if any(any(isnan(c))) || any(any(isnan(ceq))) || any(any(isnan(gc))) || any(any(isnan(gceq)))
                error('optimlib:optimfcnchk:checkfun:NaNFval', ...
                    'User function ''%s'' returned NaN when evaluated;\n %s cannot continue.', ...
                    functiontostring(userfcn),upper(caller));
            elseif ~isreal(c) || ~isreal(ceq) || ~isreal(gc) || ~isreal(gceq)
                error('optimlib:optimfcnchk:checkfun:ComplexFval', ...
                    'User function ''%s'' returned a complex value when evaluated;\n %s cannot continue.', ...
                    functiontostring(userfcn),upper(caller));
            elseif any(any(isinf(c))) || any(any(isinf(ceq))) || any(any(isinf(gc))) || any(any(isinf(gceq))) 
                error('optimlib:optimfcnchk:checkfun:InfFval', ...
                    'User function ''%s'' returned Inf or -Inf when evaluated;\n %s cannot continue.', ...
                    functiontostring(userfcn),upper(caller));
            else
                varargout{1} = c;
                varargout{2} = ceq;
                varargout{3} = gc;
                varargout{4} = gceq;
            end
        else % fseminf constraints have a variable number of outputs, but at 
             % least 4: see semicon.m
            % Also, don't check 's' for NaN as NaN is a valid value
            T = cell(1,ntheta);
            [c,ceq,T{:},s] = userfcn(x,varargin{:});
            nanfound = any(any(isnan(c))) || any(any(isnan(ceq)));
            complexfound = ~isreal(c) || ~isreal(ceq) || ~isreal(s);
            inffound = any(any(isinf(c))) || any(any(isinf(ceq))) || any(any(isinf(s)));
            for ii=1:length(T) % Elements of T are matrices
                if nanfound || complexfound || inffound
                    break
                end
                nanfound = any(any(isnan(T{ii})));
                complexfound = ~isreal(T{ii});
                inffound = any(any(isinf(T{ii})));
            end
            if nanfound
                error('optimlib:optimfcnchk:checkfun:NaNFval', ...
                    'User function ''%s'' returned NaN when evaluated;\n %s cannot continue.', ...
                    functiontostring(userfcn),upper(caller));
            elseif complexfound
                error('optimlib:optimfcnchk:checkfun:ComplexFval', ...
                    'User function ''%s'' returned a complex value when evaluated;\n %s cannot continue.', ...
                    functiontostring(userfcn),upper(caller));
            elseif inffound
                error('optimlib:optimfcnchk:checkfun:InfFval', ...
                    'User function ''%s'' returned Inf or -Inf when evaluated;\n %s cannot continue.', ...
                    functiontostring(userfcn),upper(caller));
            else
                varargout{1} = c;
                varargout{2} = ceq;
                varargout(3:ntheta+2) = T;
                varargout{ntheta+3} = s;
            end
        end

    end %checkfun
    %----------------------------------------------------------
end % optimfcnchk
