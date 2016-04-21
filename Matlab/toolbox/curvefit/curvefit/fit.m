function [fitobj,goodness,output,warnstr,errstr,convmsg] = fit(xdatain,ydatain,fittypeobj,varargin)
%FIT Fit data to a fit type object.
%   FITTEDMODEL=FIT(XDATA,YDATA,FITTYPE) when FITTYPE is a string fits the
%   data XDATA and YDATA according to FITTYPE, returning a fitted model
%   FITTEDMODEL. FITTYPE may be:
%                FITTYPE                DESCRIPTION       
%   Splines:     
%                'smoothingspline'      smoothing spline
%                'cubicspline'          cubic (interpolating) spline
%   Interpolants:
%                'linearinterp'         linear interpolation
%                'nearestinterp'        nearest neighbor interpolation
%                'splineinterp'         cubic spline interpolation
%                'pchipinterp'          shape-preserving (pchip) interpolation
%
%   or any of the names of library models described in CFLIBHELP (type
%   CFLIBHELP to see the names and descriptions of library models). XDATA and
%   YDATA must be column vectors. Note: 'cubicspline' and 'splineinterp' are
%   the same FITTYPE.
%
%   FITTEDMODEL=FIT(XDATA,YDATA,FITTYPE) when FITTYPE is a FITTYPE object fits
%   the data XDATA and YDATA according to the information in FITTYPE,
%   returning a fitted model FITTEDMODEL. Custom models can be created using
%   the FITTYPE function.
%
%   FITTEDMODEL=FIT(XDATA,YDATA,FITTYPE,...,PROP1,VAL1,PROP2,VAL2,...) fits
%   the data XDATA and YDATA using the problem and algorithm options specified
%   in the property-value pairs PROP1,VAL1,etc, returning the fitted model
%   FITTEDMODEL. For FITOPIONS properties and default values (for FITTYPE), 
%   type FITOPTIONS(FITTYPE), e.g. 
%      fitoptions('cubicspline')
%      fitoptions('exp2')
%
%   FITTEDMODEL=FIT(XDATA,YDATA,FITTYPE,OPTIONS) fits the data XDATA and YDATA
%   using the problem and algorithm options specified in the FITOPTIONS object
%   OPTIONS. This is an alternative syntax to specifying the property-value
%   pairs. For help on constructing the OPTIONS object, see FITOPTIONS.
%
%   FITTEDMODEL=FIT(XDATA,YDATA,FITTYPE,...,'problem',VALUES) assigns VALUES
%   to the problem dependent constants. VALUES is a cell array with one
%   element per problem dependent constant. See FITTYPE for more information
%   on problem dependent constants.
%
%   [FITTEDMODEL,GOODNESS] = FIT(XDATA,YDATA,...) returns appropriate
%   goodness-of-fit measures, for the given inputs, in the structure GOODNESS.
%   GOODNESS includes the fields: SSE (sum of squares due to error), R2
%   (coefficient of determination or R^2), adjustedR2 (degree of freedom
%   adjusted R^2, and stdError (fit standard error or root mean square error).
%
%   [FITTEDMODEL,GOODNESS,OUTPUT] = FIT(XDATA,YDATA,...) returns an OUTPUT
%   structure with output values appropriate for the given inputs. For
%   example, for nonlinear fitting problems, the number of iterations, number
%   of model evaluations, an exitflag denoting convergence, the residuals, and
%   the Jacobian are returned in the structure OUTPUT.
%
%   Examples:
%      [curve, goodness] = fit(xdata,ydata,'pchipinterp');
%   fits a cubic interpolating spline through xdata and ydata.
%      curve = fit(x,y,'exp1','Startpoint',p0)
%   fits the 3rd equation in the curve fitting library of rational functions,
%   overriding the starting point to be p0.
%
%   See also CFLIBHELP, FITTYPE, FITOPTIONS.

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.59.2.4 $  $Date: 2004/02/07 19:11:52 $

fitobj = cfit;
goodness = [];
output = [];
warnstr = '';
errstr = '';
convmsg = '';
probparams = {};
suppresswarn = 0;
suppresserr = 0;
if nargout > 3
    suppresswarn = 1;
    if nargout > 4
        suppresserr = 1;
    end
end

% column vectors are assumed throughout rest of code.
if size(xdatain,2) ~= 1
    errstr = handleerr('curvefit:fit:xDataMustBeColumnVector', ...
                       'XDATA must be a column vector.',suppresserr); 
    return; 
end
if size(ydatain,2) ~= 1
    errstr = handleerr('curvefit:fit:yDataMustBeColumnVector', ...
                       'YDATA must be a column vector.',suppresserr); 
    return; 
end
if length(xdatain) ~= length(ydatain)
    errstr = handleerr('curvefit:fit:yxMustBeSameLength', ...
                       'XDATA and YDATA must be the same length.', suppresserr); 
    return; 
end

% Is fittypeobj a fittype object or a string?
model = fittype(fittypeobj);
ftype = type(model);
fcategory = category(model);

useroptions = [];
if nargin > 3
    if length(varargin) == 1 && isfitoptions(varargin{1}) % fitoptions object
        useroptions = varargin{1};
    elseif length(varargin) == 3 
        if isfitoptions(varargin{1})
            useroptions = varargin{1};
            probparams = varargin{3};
            if ~iscell(probparams)
                probparams = {probparams};
            end    
        elseif isfitoptions(varargin{3})
            useroptions = varargin{3};
            probparams = varargin{2};
            if ~iscell(probparams)
                probparams = {probparams};
            end    
        else
            error('curvefit:fit:unknownCallingSequence', ...
                  'Unknown calling sequence to FIT.')
        end
    else
        % Check for problem parameters by looking thru the params.
        % Only param that start with p is problem.
        ind = strmatch('p',varargin(1:2:end)); 
        ind = ind*2-1; % we skipped every other one when computing index
        if length(ind) > 1
            error('curvefit:fit:tooManyProblemParams',...
                  'Cannot have more than one set of problem parameters.')
        elseif length(ind) == 1
            probparams = varargin{ind+1};
            if ~iscell(probparams)
                probparams = {probparams};
            end    
            varargin(ind:ind+1) = [];
        end
        % Param-value pairs: construct fitoptions object
        if isequal(ftype,'customnonlinear')
            useroptions = fitoptions('method','nonlinearleastsquares',varargin{:});
        elseif isequal(ftype,'customlinear')
            useroptions = fitoptions('method','linearleastsquares',varargin{:});
        else    
            useroptions = fitoptions(ftype,varargin{:});
        end
    end
end
if ~isempty(useroptions) % merge model and user provided options
    options = fitoptions(fitoptions(model),useroptions);
else
    options = fitoptions(model);
end
% Update .fitoptions field in model to be the fitoptions used in the fit.
model = setoptions(model,options);
weightsin = get(options,'weights');
exclude = get(options,'exclude');

if isempty(weightsin) 
    weightsin = ones(length(xdatain),1);
elseif any(weightsin < 0)
    errstr = handleerr('curvefit:fit:weightsMustBePostive', ...
                       'Weights must be non-negative in FIT.',suppresserr); return;
else
    weightsin = weightsin(:);
end
if length(ydatain) ~= length(weightsin)
    errstr = handleerr('curvefit:fit:yDataAndWeightsMustBeSameLength', ...
                       'YDATA and WEIGHTS must be the same length.',suppresserr); return;
end

if ~isempty(exclude)
    exclude = exclude(:);
    if length(exclude) < length(xdatain)
        exclude(end+1:(length(xdatain)),1) = logical(zeros(length(xdatain)-length(exclude),1));
    elseif length(exclude) > length(xdatain)
        errstr = handleerr('curvefit:fit:excludedataLengthTooLong', ...
                           'EXCLUDEDATA has greater length than XDATA.',...
                            suppresserr); 
        return;
    end
    xdata=xdatain(~exclude);
    ydata=ydatain(~exclude);
    weights=weightsin(~exclude);
else
    xdata=xdatain;
    ydata=ydatain;
    weights=weightsin;
end

% After data is excluded, check for NaN, Inf, or complex
if any(isnan(xdata)) || any(isnan(ydata)) || any(isnan(weights))
    errstr = handleerr('curvefit:fit:nansNotAllowed', ...
                       'XDATA, YDATA or WEIGHTS cannot have NaN values.',...
                        suppresserr);
    return;
end
if any(isinf(xdata)) || any(isinf(ydata)) || any(isinf(weights))
    errstr = handleerr('curvefit:fit:infsNotAllowed', ...
                       'XDATA, YDATA or WEIGHTS cannot have Inf values.',...
                        suppresserr); 
    return;
end

if any(~isreal(xdata))
    xdata = real(xdata);
    wstr = ('Complex XDATA detected. Will use real components only.');
    warnstr = handlewarn('curvefit:fit:complexXusingOnlyReal', ...
                          wstr,warnstr,suppresswarn);
end
if any(~isreal(ydata))
    ydata = real(ydata);
    wstr = ('Complex YDATA detected. Will use real components only.');
    warnstr = handlewarn('curvefit:fit:complexYusingOnlyReal', ...
                          wstr,warnstr,suppresswarn);
end
if any(~isreal(weights))
    weights = real(weights);
    wstr = ('Complex WEIGHTS  detected. Will use real components only.');
    warnstr = handlewarn('curvefit:fit:complexWeightsUsingOnlyReal', ...
                          wstr,warnstr,suppresswarn);
end

% Check for at least 2 data points
n = length(xdata);
if n < 2
    errstr=handleerr('curvefit:fit:notEnoughDataPoints',...
                     'There should be at least two data points.',suppresserr); 
    return;
end


%%% Check if normalize is on and then center and scale
xlim = [min(xdata) max(xdata)];
if isequal(options.normalize, 'on')
    meanx =  mean(xdata); 
    stdx = std(xdata);
    if isequal(stdx,0)
        errstr = handleerr('curvefit:fit:cannotCenterAndScale', ...
                           ['Standard deviation of xdata is 0; '...'
                            'cannot center and scale xdata.'],suppresserr); 
        return;
    end
    xdata = (xdata - meanx)/stdx;            
else
    meanx = 0;
    stdx = 1;
end

switch fcategory
case {'custom','library'} 
    numcoeff = numcoeffs(model); 
    n = length(xdata);
    dfe = n - numcoeff;
    if dfe < 0
        errstr = handleerr('curvefit:fit:sprintf:notEnoughPoints', ...
                           sprintf(['You need at least %d data points to '...
                           'determine %d coefficients.'],numcoeff,numcoeff),...
                           suppresserr); 
        return;
    end
    lowerbnd = get(options,'lower');
    upperbnd = get(options,'upper');
    % Make sure bounds are valid and same length as number of coefficients.
    [lowerbnd,upperbnd,errstr,wstr, errid, warnid] = checkbounds(lowerbnd,upperbnd,numcoeffs(model));
    if ~isempty(errstr)
        errstr = handleerr(errid, errstr,suppresserr);
        return;
    end
    warnstr = handlewarn(warnid, wstr,warnstr,suppresswarn);
    
    switch ftype(1:3)
    case {'wei'}
        if any(xdata <= 0)
            errstr = handleerr('curvefit:fit:weibullRequiresPositiveData', ...
                  'Weibull function cannot be fit to non-positive xdata.', ...
                   suppresserr); 
            return;
        end
    case {'pow'}
        if any(xdata <= 0)
            errstr = handleerr('curvefit:fit:powerFcnsRequirePositiveData', ...
                    'Power functions cannot be fit to non-positive xdata.', ...
                     suppresserr); 
            return;
        end
    case {'fou'}
        if isequal(std(xdata),0)
            errstr = handleerr('curvefit:fit:fourierFcnsIdenticalDataError', ...
                  'Fourier functions cannot be fit to all identical xdata.', ...
                   suppresserr); 
            return;
        end
    end
    
    if ~islinear(model) % nonlinear custom or library equation
        start = options.startpoint;
        if isempty(start) && ~isempty(startpt(model))   
            h = constants(model); % Get constants parameters for library functions
            try
                start = feval(startpt(model),probparams{:},xdata,ydata,h{:});
            catch
                es = lasterror;
                errstr = handleerr(es.identifier, es.message, suppresserr); return;
            end
        elseif isempty(start)
            S = rand('state');  % save and restore rand state 
            rand('state',3);    % for now always use state 3 
            start = rand(numcoeff,1);
            rand('state',S); 
            wstr = ('Start point not provided, choosing random start point.');
            warnstr = handlewarn('curvefit:fit:noStartPoint', ...
                                  wstr,warnstr,suppresswarn);
        end
        if ~all(isfinite(start)) || ~isreal(start)
            wstr = sprintf(['NaN, Inf, or complex value detected in startpoint; \n',...
                     'choosing random starting point instead.']);
            S = rand('state');  % save and restore rand state 
            rand('state',3);    % for now always use state 3 
            start = rand(size(start)); 
            rand('state',S); 
            warnstr = handlewarn('curvefit:fit:invalidStartPoint', ...
                                  wstr,warnstr,suppresswarn);
        end
        
        if all(weights==1)
            wtdydata = ydata;
            optimargs = {'optim'};
        else
            wtdydata = sqrt(weights).*ydata;
            optimargs = {weights,'optimweight'};
        end
        
        separargs = {};
        nonlcoeffindex = nonlinearcoeffs(model);
        if ~isempty(nonlcoeffindex) 
            % If any of the linear coefficients of the separable problem are
            % bounded, then treat as if not separable so the bounds on the
            % linear coefficients will be used.
            lincoeffindex = (1:numcoeffs(model))';
            lincoeffindex(nonlcoeffindex) = [];
            if ~any(isfinite([lowerbnd(lincoeffindex); upperbnd(lincoeffindex)]))
                start = start(nonlcoeffindex);
                lowerbnd = lowerbnd(nonlcoeffindex);
                upperbnd = upperbnd(nonlcoeffindex);
                separargs = {ydata,weights,'separable'};
            end
        end
        
        lFinite = ~isinf(lowerbnd);
        uFinite = ~isinf(upperbnd);
        if ~isequal(lower(options.Algorithm),'trust-region') && ...
                ( ~isempty(lowerbnd(lFinite)) || ~isempty(upperbnd(uFinite)))
            wstr = sprintf(['Levenberg-Marquardt and Gauss-Newton algorithms do not handle\n',...
                      'bound constraints; switching to trust-region algorithm instead.\n']);
            warnstr = handlewarn('curvefit:fit:usingTrustRegion', ...
                                  wstr,warnstr,suppresswarn);
            options.Algorithm = 'trust-region';
            model = setoptions(model,options);
        end
        try
            robustflag = lower(options.robust);
            dorobust = ~isequal(robustflag,'off');
            % resnorm, res and jacob all include weights after cflsqcurvefit
            if dorobust && isequal(lower(options.Display),'iter') 
                disp(sprintf('\nInitial fitting:\n----------------'));
                optimoptions = options;
            elseif dorobust && ( isequal(lower(options.Display),'notify') || isequal(lower(options.Display),'final') )
                % If 'notify' or 'final', only want to print final convmsg, so turn Display 'off'.
                optimoptions = fitoptions(options, 'Display', 'off');
            else
                optimoptions = options;
            end
            [ xout,resnorm,res,exitflag,optoutput,lam,jacob,convmsg] = ...
                cflsqcurvefit(model,start,xdata,wtdydata,lowerbnd,upperbnd,...
                optimoptions,probparams{:},separargs{:},optimargs{:});
            J = full(jacob); % Trust region method may return a sparse Jacobian
            if dorobust && exitflag~=0
                % res, jacob from cfrobnlinfit have user wts but not the robust wts; 
                % resnorm has special calculation involving both: see cfrobnlinfit
                [xout,resnorm,res,exitflag,optoutput,lam,jacob,convmsg] = ...  
                    cfrobnlinfit(model,xout,xdata,wtdydata,lowerbnd,upperbnd,...
                    optimoptions,probparams,separargs,weights,res,jacob,...
                    robustflag,optoutput.iterations,optoutput.funcCount);
                J = full(jacob); % Trust region method may return a sparse Jacobian
            elseif ~isempty(separargs)
                % If separable and not robust (because cfrobnlinfit will get all coefficients)
                %  calculate Jacobian J at the solution, with weights, but not robust weights.
                % Note only library equations can be separable, so J always computable analytically.
                [f,J,xout] = feval(model,xout,xdata,probparams{:},separargs{:},optimargs{:}); 
            end
            % Note: if we did do separable, the lambda ('lam') from cflsqcurvefit
            %       can come back the wrong size as it will only represent the 
            %       nonlinear coefficients (and would break predint).
            if ~isempty(separargs) && ( ~isempty(lowerbnd(lFinite)) || ~isempty(upperbnd(uFinite)))
                   tmplam = lam;
                   lam.lower = zeros(numcoeffs(model),1);
                   lam.upper = zeros(numcoeffs(model),1);
                   lam.lower(nonlcoeffindex) = tmplam.lower;
                   lam.upper(nonlcoeffindex) = tmplam.upper;
            end
            
            % If robust and original options Display is Notify or Final, need to display convmsg
            if dorobust 
                if ( isequal(lower(options.Display),'notify') && exitflag <= 0 ) 
                    disp(convmsg);
                elseif ( isequal(lower(options.Display),'final') )
                        disp(convmsg);
                end
            end
        catch
            
            if ~isempty(strfind(lasterr,xlate('Inf computed by model function.'))) || ...    
                ~isempty(strfind(lasterr,xlate('Inf computed by model Jacobian function.')))     
              errmsg = sprintf('Inf computed by model function, fitting cannot continue.\n%s',...
                       'Try using or tightening upper and lower bounds on coefficients.');
              errstr = handleerr('curvefit:fit:infComputed',errmsg,suppresserr); 
              return;
            elseif ~isempty(strfind(lasterr, xlate('NaN computed by model function.'))) || ...
                   ~isempty(strfind(lasterr, xlate('NaN computed by model Jacobian function.'))) 
                errmsg = sprintf('NaN computed by model function, fitting cannot continue.\n%s',...
                        'Try using or tightening upper and lower bounds on coefficients.');
                errstr = handleerr('curvefit:fit:nanComputed',errmsg,suppresserr); 
                return;
            elseif ~isempty(strfind(lasterr, xlate('Complex value computed by model function.'))) || ...
                   ~isempty(strfind(lasterr, xlate('Complex value computed by model Jacobian function.')))
                errmsg = sprintf('Complex value computed by model function, fitting cannot continue.\n%s',...
                      'Try using or tightening upper and lower bounds on coefficients.');
                errstr = handleerr('curvefit:fit:complexValueComputed',errmsg,suppresserr); 
                return;
            else                
                es = lasterror;
                errstr = handleerr(es.identifier, es.message, suppresserr); return;
            end
        end
        
        coeffcell = num2cell(xout);
        output = outputstruct(n,numcoeff,res,J,exitflag,optoutput);
        sse = resnorm;
        if isstruct(lam)
            dfe = dfe + sum(lam.lower | lam.upper);
        end
        goodness = goodstruct(ydata,weights,res,dfe,output,sse);
        fitobj = cfit(model, coeffcell{:},probparams{:},'sse',goodness.sse,'dfe',goodness.dfe, ...
            'Jacobian',J,'meanx',meanx,'stdx',stdx,'activebounds',lam,'xlim',xlim); 
        
    else % linear custom or linear library equation
        
        n = length(xdata);
        params = numcoeffs(model);
        dfe = n-params;
        if dfe < 0
            errstr = handleerr('curvefit:fit:sprintf:notEnoughPoints', ...
                               sprintf(['You need at least %d data points to '...
                               'determine %d coefficients.'],params,params),...
                               suppresserr); 
            return;
        end
        
        if isequal(fcategory,'custom')
            A = getcoeffmatrix(model,probparams{:},xdata);
        else
            coefftemp = num2cell(rand(1,numcoeffs(model)));
            [ftemp, A] = feval(model,coefftemp{:},probparams{:},xdata); % calculates analytically at the solution
        end
        
        % Prior weights are done here, robust weights inside cfroblinfit
        sqrtwts = sqrt(weights);
        Awtd = A .* repmat(sqrtwts,1,size(A,2));
        wtdydata = ydata .* sqrtwts;
        [p,s,J,wstr,optoutput,convmsg,lam,res,leverage, warnid] = ...
            linearfit(Awtd,wtdydata,[],lowerbnd,upperbnd,options,suppresserr);
        warnstr = handlewarn(warnid, ...
                              wstr,warnstr,suppresswarn);
        
        robustflag = lower(options.robust);
        dorobust = ~isequal(robustflag,'off');
        if dorobust
            try
            [p,s,Jwtd,wstr,lam,optoutput,convmsg,warnid] = cfroblinfit(Awtd,wtdydata,p,s,robustflag,...
                lowerbnd,upperbnd,options,suppresserr,leverage,res);
            warnstr = handlewarn(warnid, ...
                                  wstr,warnstr,suppresswarn);
            catch
                es = lasterror;
                errstr = handleerr(es.identifier, es.message, suppresserr); return;
            end
        end
        
        pcell = num2cell(p);
        res = sqrtwts.*(ydata-feval(model,pcell{:},probparams{:},xdata));
        exitflag = 1; 
        
        output = outputstruct(n,numcoeff,res,J,exitflag,optoutput);
        sse = s.normr^2;
        if isstruct(lam)
            dfe = dfe + sum(lam.lower | lam.upper);
        end
        goodness = goodstruct(ydata,weights,res,dfe,output,sse);
        
        fitobj = cfit(model, pcell{:},probparams{:},'sse',goodness.sse,'dfe',dfe,...
            'Jacobian',J,'meanx',meanx,'stdx',stdx, 'activebounds',lam,'xlim',xlim);
    end 
    
case {'spline'}   
    switch ftype
    case 'cubicspline'
        if ~all(weights==1)    
            wstr = 'Weights ignored for cubic spline fit.';
            warnstr = handlewarn('curvefit:fit:cubicSplineIgnoresWeights', ...
                                  wstr,warnstr,suppresswarn);
        end
        try
            pp = spline(xdata,ydata);
        catch
            % Special case a common error
            if findstr(lasterr,'The data abscissae should be distinct.')
                errstr = handleerr('curvefit:fit:xDataMustBeDistinct', ...
                         'Interpolation methods require the xdata to be distinct.', ...
                         suppresserr); 
                return; 
            else
                es = lasterror;
                errstr = handleerr(es.identifier, es.message, suppresserr); return;
            end
        end
        df = length(xdata);
        splineoutput = [];
    case 'smoothingspline'
        try
            [pp,pout,df] = cfsmthspl(xdata,ydata,options.smoothingparam,weights);
        catch
            es = lasterror;
            errstr = handleerr(es.identifier, es.message, suppresserr);
            % Failed so return
            return;
        end
        splineoutput.p = pout; 
    otherwise
        errstr = handleerr('curvefit:fit:unknownSplineType', ...
                           'Unknown spline type.',suppresserr); 
        return;
    end % switch ftype
    res = ydata - ppval(pp,xdata);
    jacob = [];
    n = length(xdata);
    if df >= n
        dfe = 0;
    else
        dfe = n-df;
    end
    exitflag = 1;
    output = outputstruct(n,df,res,jacob,exitflag,splineoutput); 
    goodness = goodstruct(ydata,weights,res,dfe,output);
    
    fitobj = cfit(model,pp,'sse',goodness.sse,'dfe',goodness.dfe, ...
        'Jacobian',jacob,'meanx',meanx,'stdx',stdx,'xlim',xlim);
    
case 'interpolant'
    switch ftype
    case {'linearinterp','pchipinterp','splineinterp','nearestinterp'}  
        [xdatasorted,indexsort] = sort(xdata);
        h = diff(xdatasorted);
        if any(h == 0)
            errstr = handleerr('curvefit:fit:xDataMustBeDistinct', ...
                     'Interpolation methods require the xdata to be distinct.', ...
                     suppresserr); 
            return;
        end
        ydatasorted = ydata(indexsort);
        try
            pp = cfinterp1(xdata,ydata,ftype(1),'pp');
        catch
            es = lasterror;
            errstr = handleerr(es.identifier, es.message, suppresserr); 
            % Failed so return
            return;
        end
        if ~all(weights==1)
            wstr = ('Weights ignored for interpolation.');
            warnstr = handlewarn('curvefit:fit:interpolationIgnoresWeights', ...
                                  wstr,warnstr,suppresswarn);
        end
        res = ydata - ppval(pp,xdata);
        dfe = 0;
        jacob = [];
        numparams = length(ydata);   % each obs. is a parameter
        exitflag = 1;  
        output = outputstruct(length(xdata),numparams,res,jacob,exitflag,[]); 
        goodness = goodstruct(ydata,weights,res,dfe,output);
        
        fitobj = cfit(model,pp,'sse',0,'dfe',0,'Jacobian',jacob,...
            'meanx',meanx,'stdx',stdx,'xlim',xlim); 
        
    otherwise
        errstr = handleerr('curvefit:fit:unknownInterpType', ...
                           'Unknown interpolant type.',suppresserr); 
        return;
    end
    
otherwise
    errstr = handleerr('curvefit:fit:unrecognizedFittype',...
                       'Unrecognized fittype',suppresserr); 
    return;   
end

%-------------------------------------------------------
function output = outputstruct(numobs,numparam,resids,J,exitflag,oldoutput)
% OUTPUTSTRUCT Construct an output structure.
%
% OUTPUT = OUTPUTSTRUCT(NUMOBS,NUMPARAM,RESIDS,JACOB) creates
% structure OUTPUT with fields number of observations, number of 
% parameters, residuals, and Jacobian matrix.

output.numobs = numobs;
output.numparam = numparam;
output.residuals = resids;
output.Jacobian = J;
output.exitflag = exitflag;

if ~isempty(oldoutput)
    fnames = fieldnames(oldoutput);
    for i=1:length(fnames)
        output = setfield(output,fnames{i},getfield(oldoutput,fnames{i}));
    end
end
%-------------------------------------------------------
function goodness = goodstruct(ydata,weights,res,dfe,output,sse)
% GOODSTRUCT Construct a structure of goodness of fit values.
%
% GOODNESS = GOODSTRUCT(NUMOBS,NUMPARAM,RESIDS,JACOB) creates
% structure GOODNESS with fields sse, rsquare, adjrsquare and rmse
% from YDATA, WEIGHTS, YBAR, RES, DFE, and values of OUTPUT structure.

ybar = sum(ydata.*weights)/sum(weights);
sst = sum(weights.*(ydata - ybar).^2);

if nargin>=6
    goodness.sse = sse;
else
    goodness.sse = norm(res)^2;
end

% Avoid divide by zero warning
if ~isequal(sst,0)
    goodness.rsquare = 1 - goodness.sse/sst;
elseif isequal(sst,0) && isequal(goodness.sse,0)
    goodness.rsquare = NaN;
else % sst==0 && sse ~== 0
    % This is unusual, so try to determine if sse is just roundoff error
    if sqrt(abs(sse))<sqrt(eps)*mean(abs(ydata))
        goodness.rsquare = NaN;
    else
        goodness.rsquare = -Inf;
    end
end
goodness.dfe = dfe;
if dfe > 0
    goodness.adjrsquare = 1 - (1-goodness.rsquare)*(output.numobs-1)/dfe;
    mse = goodness.sse/dfe;
    goodness.rmse = sqrt(mse);
else
    goodness.dfe = 0;
    goodness.adjrsquare = NaN;
    goodness.rmse = NaN;
end
%-------------------------------------------------
function f = getfield(s,field)
%GETFIELD Get structure field contents.
%   F = GETFIELD(S,'field') returns the contents of the specified
%   field.  This is equivalent to the syntax F = S.field.
%   S must be a 1-by-1 structure.  
% 

sref.type = '.'; sref.subs = field;
f = subsref(s,sref);

%-------------------------------------------------
function s = setfield(s,field,value)
%SETFIELD Set structure field contents.
%   S = SETFIELD(S,'field',V) sets the contents of the specified
%   field to the value V.  This is equivalent to the syntax S.field = V.
%   S must be a 1-by-1 structure.  The changed structure is returned.
%

sref.type = '.'; sref.subs = field;
s = subsasgn(s,sref,value);
%-------------------------------------------------
function errstr = handleerr(id, errstr, suppresserr)
%HANDLEERR Handle error according to SUPPRESSERR.
        
if suppresserr
    errstr = xlate(errstr);
    return;
else
    if isempty(id)
        % This might occur if lasterror did not have an id assigned.
        id = 'curvefit:fit:generalFitError';
    end
    error(id, errstr);
end      

%-------------------------------------------------
function warnstr = handlewarn(id, wstr,warnstr,suppresswarn)
%HANDLEWARN Handle warning according to SUPPRESSWARN.

if (suppresswarn == 1) && ~isempty(warnstr)
    warnstr = sprintf('%s\n%s',xlate(warnstr),xlate(wstr));
elseif suppresswarn % && isempty(warnstr)
    warnstr = sprintf(wstr);
else
    warning(id, wstr);
end
%-------------------------------------------------
function [p,S,J,warnstr,optoutput,convmsg,lam,residual,leverage,warnid] = ...
    linearfit(A,y,w,lowerbnd,upperbnd,fitopt,suppresserr)
% LINEARFIT Solve linear least squares y = A*x, possibly
% with weights w.

optoutput = [];
warnstr = '';
warnid = '';
convmsg = '';
lowerbnd = lowerbnd(:);
upperbnd = upperbnd(:);
boundsexist = logical(0);
if ( ~isempty(lowerbnd) && any(~(lowerbnd==-inf)) ) ...
        || ( ~isempty(upperbnd) && any(~(upperbnd==inf)) )
    boundsexist = logical(1);
end
n = size(A,2);
if ~isempty(w)
    w = w(:);
    sqrtw = sqrt(w);
    J = repmat(sqrtw,1,n).*A;
    Dy = sqrtw.*y;
else
    J = A;
    Dy = y;
end

if boundsexist
    try
        [p,resnorm,residual,exitflag,optoutput,lam,convmsg]=cflsqlin(J,Dy,lowerbnd,upperbnd,fitopt);
    catch
        es = lasterror;
        errstr = handleerr(es.identifier, es.message, suppresserr); return;
    end
    [Q,R] = qr(J,0);
else
    % Solve least squares problem, and save the Cholesky factor.
    lam = [];
    [Q,R] = qr(J,0);
    ws = warning('off', 'all'); 
    p = full(R\(Q'*Dy));    % Same as p = D*A\(D*y);
    warning(ws);
    if size(R,2) > size(R,1)
        warnstr = 'Equation coefficients are not unique; degree >= number of data points.';
        warnid = 'curvefit:fit:coeffsNotUnique';
    elseif condest(R) > 1.0e10
        warnstr = sprintf( ...
            ['Equation is badly conditioned. Remove repeated data points\n' ...
                '         or try centering and scaling.']);
        warnid = 'curvefit:fit:equationBadlyConditioned';
    end
    if nargout < 4
        warning(warnid, warnstr)
    end
    residual = Dy - J*p;
    optoutput.algorithm = 'QR factorization and solve';
end

% S is a structure containing three elements: the Cholesky factor of the
% A matrix, the degrees of freedom and the norm of the residuals.
S.R = R;
S.df = length(y) - n;
S.normr = norm(residual);

% Compute leverage if requested
if nargout>=9
    ws = warning('off', 'all'); 
    E = J/R;
    leverage = sum(E.*E,2);
    warning(ws);
end

%-------------------------------------------------

function [p,s,J,wstr,lam,optoutput,convmsg,warnid] = ...
    cfroblinfit(X,y,p0,s,robtype,lowerbnd,upperbnd,fitopt,suppresserr,leverage,res)
%CFROBLINFIT Do robust linear fitting for curve fitting toolbox
%   [P,S,WSTR] = CFROBLINFIT(X,Y,W,P,S) takes as input an x data
%   matrix X, a response vector Y, a weight vector W, a vector P of
%   starting estimates (usually from ordinary least squares), and a
%   stats structure S compatible with polyfit output.  Outputs are
%   a vector P of coefficient estimates, an updated stats structure
%   S, and a string WSTR that may contain warning messages.

% Note: y is unweighted intentionally

% Global parameter, OPT_STOP is used for canceling fits
% It is initialized and set in the Curve Fitting GUI (CreateAFit.java)
global OPT_STOP 

if nargin<4 || isempty(p0)
    p0 = ones(size(X,2),1);
end
p = p0(:);
p0 = zeros(size(p));
P = length(p0);
N = length(y);

% Adjust residuals using leverage, as advised by DuMouchel & O'Brien
h = min(.9999, leverage);
adjfactor = 1 ./ sqrt(1-h);

dfe = N-P;
ols_s = s.normr / sqrt(dfe);

% Perform iteratively reweighted least squares to get coefficient estimates
D = 1e-6;
iter = 0;
iterlim = 50;
wstr = '';
warnid  = '';
while((iter==0) || any(abs(p-p0) > D*max(abs(p),abs(p0)))) && ~isequal(OPT_STOP, 1) 
    iter = iter+1;
    if (iter>iterlim)
        wstr = 'Iteration limit reached for robust fitting.';
        warnid = 'curvefit:fit:iterationLimitReached';
        break;
    end
    
    % Adjust residuals from previous fit, then compute scale estimate
    radj = res .* adjfactor;
    sigma = cfrobsigma(robtype,radj,P);
    if (sigma==0), sigma=1; end
    
    % Compute new weights from these residuals, then re-fit
    tune = 4.685;
    bw = cfrobwts(robtype,radj/(sigma*tune));
    p0 = p;
    [p,S,J,wstr,optoutput,convmsg,lam,res,lev, warnid] = ...
        linearfit(X,y,bw,lowerbnd,upperbnd,fitopt,suppresserr); 
    res = y - X*p;
    
    % After 1st iteration for LAR, don't use adjusted residuals
    if iter==1 && isequal(robtype,'lar')
        adjfactor = 1;
    end
end
if OPT_STOP
    error('curvefit:fit:computationCancelled',...
          'Fitting computation cancelled.');
end

if (nargout>1)
    % Compute robust mse according to DuMouchel & O'Brien (1989)
    radj = res .* adjfactor;
    [mad_s,robust_s] = cfrobsigma(robtype,radj, P, tune, h);
    
    % Shrink robust value toward ols value if appropriate
    sigma = max(robust_s, sqrt((ols_s^2 * P^2 + robust_s^2 * N) / (P^2 + N)));
    s.normr = sigma * sqrt(dfe);
end


