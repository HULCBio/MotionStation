function obj = fittype(varargin)
%FITTYPE  Construct a fit type object.
%   FITTYPE(EXPR) constructs a FITTYPE function object from the
%   MATLAB expression contained in the string EXPR.  The input
%   arguments are automatically determined by searching EXPR
%   for variable names (see SYMVAR). In this case, 'x' is assumed
%   to be the independent variable, 'y' is the dependent variable, and
%   all other variables are assumed to be coefficients of the model.
%   If no variable exists, 'x' is used. All coefficients must be scalars.
%   EXPR will be treated as a nonlinear model.
%
%   A linear model, that is a model of the form
%      coeff1 * term1 + coeff2 * term2 + coeff3 * term3 + ...
%   (where no coefficient appears within any of term1, term2, etc)
%   can be specified by specifying EXPR as a cell array where
%   each term of the linear model, without coefficients, is specified in
%   a cell of EXPR. For example, the model 'a*x + b*sin(x) + c' is linear in 
%   'a', 'b' and 'c'. It has three terms 'x', 'sin(x)' and '1' (since c=c*1) 
%   and so EXPR would be a cell array of three cells: {'x','sin(x)','1'}.  
%
%   FITTYPE(TYPE) constructs a FITTYPE object that is of type TYPE.
%   Choices for TYPE are:
%                TYPE                   DESCRIPTION       
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
%   CFLIBHELP to see the names and descriptions of library models).
%
%   FITTYPE(EXPR,PARAM1,VALUE1,PARAM2,VALUE2,....) uses the PARAM-VALUE
%   pairs to specify other than the default values.
%   'independent'    specifies the independent variable name
%   'dependent'      specifies the dependent variable name
%   'coefficients'   specifies the coefficient names (in a cell array if
%                    there are two or more)
%   'problem'        specifies the problem-dependent (constant) names 
%                    (in a cell array if there are two or more)
%   'options'        specifies the default 'fitoptions' for this equation
%   Defaults: the independent variable is x
%             the dependent variable is y
%             there are no problem dependent variables
%             everything else is a coefficient name
%
%   Multicharacter symbol names may be used.
%
%   Examples:
%     g = fittype('a*x^2+b*x+c')
%     g = fittype('a*x^2+b*x+c','coeff',{'a','b','c'})
%     g = fittype('a*time^2+b*time+c','indep','time')
%     g = fittype('a*time^2+b*time+c','indep','time','depen','height')
%     g = fittype('a*x+n*b','problem','n')
%     g = fittype({'cos(x)','1'})                            % linear
%     g = fittype({'cos(x)','1'}, 'coefficients', {'a','b'}) % linear
%
%   See also CFLIBHELP, FIT.

%  Notes:
%  1. Coefficients must all be scalars:
%     g = fittype('w(1)*x^2+w(2)', 'coeff','w') will error because in SYMVAR, 'w'
%     won't be detected as a variable (it looks like a function).
%  2. Linear custom equations are created by passing in a cell array of
%     expressions as the first argument.  In this case, the 'coefficients'
%     param can be provided with a list of coefficient names in the order
%     corresponding to the expressions in the cell array.  If there is a
%     constant term, use '1' as the corresponding expression in the cell array.
%     Example:
%       g = fittype({'cos(x)','1'})
%       or
%       g = fittype({'cos(x)','1'}, 'coefficients', {'a','b'})
%     sets up the custom equation 'a*cos(x) + b', and will treat it as a
%     linear equation.
%  3. Library functions can have "hidden" constants that can be set.
%   See .constants below.
%   Example:
%     g = fittype('rat34')
%   will set up function handles to library functions that need to get the 3,
%   4 as constants to compute.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.25.2.2 $  $Date: 2004/02/01 21:41:37 $

% FITTYPE Object fields
% .type            string of type information
% .typename        string description for display of fittype
% .category        string of category information
% .defn            string containing function definition for display
% .feval           flag indicating if model is evaluated using feval or eval
% .expr            string expression to eval or function (handle) to feval
% .Adefn           cell array of strings to display A matrix for linear custom equations
% .Aexpr           cell array of strings to form A matrix for linear custom equations
% .linear          flag indicating if model is linear
% .derexpr         string expression or function (handle) of derivative
% .intexpr         string expression or function (handle) of integral
% .args            string matrix containing formal parameter names
% .isEmpty         flag indicating fittype called with no arguments
% .numArgs         number of formal parameters
% .numCoeffs       number of coefficients (unknowns)
% .assignData      eval string to assign inputs to independent (data) variable
% .assignCoeff     eval string to assign inputs to coefficients
% .assignProb      eval string to assign inputs to problem dependent parameters
% .indep           string matrix of independent parameter names (one name per row)
% .depen           string matrix of dependent parameter name
% .coeff           string matrix of coefficient parameter names (one name per row)
% .prob            string matrix of problem parameter names (one name per row)
% .constants       cell array of "hidden" constants that are passed
%                  to feval'd library function after problem parameters, but 
%                  are not counted in .numArgs (hidden from user).
% .nonlinearcoeff  index of nonlinear coefficients in separable equations
% .fitoptions      default options to use in fitting
% .startpt         function (handle) of starting point computer
% .version         object version
%

% Construct default object (for no inputs)
obj.type = '';
obj.typename = 'Model';
obj.category = '';
obj.defn = '';
obj.feval = 0;
obj.expr = '';
obj.Adefn = {};
obj.Aexpr = {};
obj.linear = 0;
obj.derexpr = '';
obj.intexpr = '';
obj.args = '';
obj.isEmpty = 1;
obj.numArgs = 0;
obj.numCoeffs = 0;
obj.assignCoeff= '';
obj.assignData= '';
obj.assignProb= '';
obj.indep = '';
obj.depen = '';
obj.coeff = '';
obj.prob = '';
obj.constants = {};
obj.nonlinearcoeffs = [];
obj.fitoptions = '';
obj.startpt = '';
obj.version = 1.0;

% return default object
if nargin==0 
    obj = class(obj, 'fittype');
    return
end

% Some error checking and early exit
if isa(varargin{1},'fittype') && nargin==1  % if fittype object, just return
    obj = varargin{1};
    return
elseif isa(varargin{1},'fittype') && nargin > 1
    error('curvefit:fittype:firstArgMustBeString', ...
          'First input argument must be a string if two or more inputs.');
elseif ~iscell(varargin{1}) && ~ischar(varargin{1}), % first argument must be a string or cell array
    error('curvefit:fittype:firstArgMustBeStringOrCell', ...
          'First input argument must be a string or cell array.'); 
end

if isidentifier(varargin{1}) % look for spline, interpolant or library function
    if nargin > 1
        error('curvefit:fittype:tooManyInputArgs', ...
              ['Only one input argument allowed when specifying spline, ', ...
               'interpolant or library type.'])
    end
    obj.isEmpty = 0;
    obj.indep = 'x';
    obj.depen = 'y';
    
        [fittypes,fitcateg,fitnames] = getfittypes; 
    ind = strmatch(lower(varargin{1}),fittypes);
    if length(ind) > 1
        error('curvefit:fittype:typeNotUnique', ...
              'Fit type: %s is not unique.\n',varargin{1});
    end
    if ~isempty(ind) && (2 <= ind)
        obj.category = deblank(fitcateg(ind,:)); 
        obj.type = deblank(fittypes(ind,:));
        obj.typename = deblank(fitnames(ind,:));
        % get defn, expr, derexpr, intexpr, feval, coeff, or error out 
        obj = liblookup(obj.type,obj);
    else
        error('curvefit:fittype:fcnNotFound', ...
              'Library function %s not found.',varargin{1});
    end

elseif isempty(varargin{1}) % fittype('',...)
    error('curvefit:fittype:emptyExpression', ...
          'Cannot create a FITTYPE from an empty expression.'); 
else    % turn expression into a custom model: nonlinear or linear
    obj.category = 'custom';
    % Get input expression and formal parameters
    obj.isEmpty = 0;
    % we assume x and y unless other parameters change this
    obj.indep = 'x';
    obj.depen = 'y';
    
    % Parse param-value pairs
    obj = parseparams(obj,{varargin{2:end}});
    
    if ischar(varargin{1}) % nonlinear custom equation
        obj.type = 'customnonlinear';
        obj.defn = strtrim(varargin{1});
        if isempty(obj.fitoptions)
            obj.fitoptions = fitoptions('method','nonlinearleastsquares');
        end
    else % cell array: linear custom equation
        obj.linear = 1;
        if isempty(obj.fitoptions)
            obj.fitoptions = fitoptions('method','linearleastsquares');
        end
        obj.Adefn = varargin{1};
        for i=1:length(obj.Adefn)
            if ~isempty(obj.Adefn{i})
                if ~isempty( [strfind(obj.Adefn{i},'+'),strfind(obj.Adefn{i},'-')] )
                    % + or - in expression: add parens 
                    obj.Adefn{i} = ['(',obj.Adefn{i},')'];
                end
                obj.Aexpr{i} = vectorize(obj.Adefn{i});
            else
                error('curvefit:fittype:emptyLinearTerm', ...
                      'Empty linear terms are not permitted.');
            end
        end
        obj.type = 'customlinear';
        if isempty(obj.coeff)
            numcoeff = length(obj.Aexpr);
            % alphabet minus i and j
            coeffnames = ['a';'b';'c';'d';'e';'f';'g';'h';'k';'l';'m'; ...
                    'n';'o';'p';'q';'r';'s';'t';'u';'v';'w';'x';'y';'z'];
            coeffnames(strmatch(obj.indep,coeffnames)) = [];
            coeffnames(strmatch(obj.depen,coeffnames)) = [];
            for i = 1:size(obj.prob,1)
                coeffnames(strmatch(obj.prob(i,:),coeffnames)) = [];
            end
            if numcoeff > size(coeffnames,1)
                error('curvefit:fittype:tooManyCoeffNames', ...
                      ['Too many coefficient names to generate. ', ...
                       'Provide your own list.'])
            end
            obj.coeff = coeffnames(1:numcoeff,:);
            obj.numCoeffs = numcoeff;
        elseif size(obj.coeff,1) ~= length(obj.Aexpr)
            error('curvefit:fittype:numCoeffsAndTermsMustMatch', ...
              'Number of coefficients must match the number of linear terms.');
        end
     
        defn = '';
        A = obj.Adefn;
        c = obj.coeff;
        for i=1:length(A)
            if isequal(A{i},'1')
                defn = [defn, deblank(c(i,:)),' + '];
            else
                defn = [defn, deblank(c(i,:)),'*',A{i}, ' + '];
            end
        end
        obj.defn = defn(1:end-3); % trim off that last +
    end
    
    obj.expr = vectorize(obj.defn);
    obj.args = char(cfsymvar(obj.expr));
    % Take care of the case:  FITTYPE('2').
    if isempty(obj.args)
        obj.args = 'x';
    end
 
    % Use heuristics to get formal parameters
    if isempty(obj.coeff)
        obj = deducecoeff(obj);
    end
end % isidentifier(varargin{1})

% This reorders the arguments in the FITTYPE
obj.args = strvcat(obj.coeff, obj.prob, obj.indep);
obj.numArgs = size(obj.args,1);

if ~isempty(obj.coeff)
    for j = 1:size(obj.coeff,1)
        obj.assignCoeff = sprintf('%s %s = FITTYPE_INPUTS_{%d};', ...
            obj.assignCoeff, deblank(obj.coeff(j,:)), j);
    end
else
    j = 0;
end
if ~isempty(obj.prob)
    for m = 1:size(obj.prob,1)
        obj.assignProb = sprintf('%s %s = FITTYPE_INPUTS_{%d};', ...
            obj.assignProb, deblank(obj.prob(m,:)), j+m);
    end
else
    m = 0;
end
if ~isempty(obj.indep)
    for k = 1:size(obj.indep,1)
        obj.assignData = sprintf('%s %s = FITTYPE_INPUTS_{%d};',...
            obj.assignData, deblank(obj.indep(k,:)), j+m+k);
    end
end

if isequal('custom',obj.category)
    % Check that all coeff are in an expression and that extra variables are not coeffs
    vars = cfsymvar(obj.defn);
    % obj.coeff and obj.prob are char arrays possibly with trailing blanks.
    % Convert to cell arrays without blanks to make exact comparison
    % possible.
    if ~isempty(obj.coeff)
        coeffcell = deblank(cellstr(obj.coeff));
    else 
        coeffcell = {};
    end
    if ~isempty(obj.prob)
        probcell = deblank(cellstr(obj.prob));
    else
        probcell = {};
    end
    if ~any(strmatch(obj.indep,vars,'exact'))
        error('curvefit:fittype:noIndependentVar', ...
              ['Independent variable %s does not appear in the ',...
               'equation expression.\n'],obj.indep);
    end
    for i=1:length(coeffcell)
        if ~any(strmatch((coeffcell{i}),vars,'exact'))
            error('curvefit:fittype:noCoeff', ...
              'Coefficient %s does not appear in the equation expression.\n',...
               coeffcell{i});
        end
    end
    for i=1:length(probcell)
        if ~any(strmatch(probcell{i},vars,'exact'))
            error('curvefit:fittype:noProbParam', ...
                 ['Problem parameter %s does not appear in the equation ', ...
                  'expression.\n'],probcell{i});
        end
        % compare prob and coeff
        if any(strmatch(probcell{i},coeffcell,'exact'))
            error('curvefit:fittype:SameNameCoeffAndProb', ...
                 ['The name %s cannot be used for both a coefficient and ', ...
                  'a problem parameter.\n'],probcell{i});
        end
    end
    if any(strmatch(obj.indep,coeffcell,'exact'))
        error('curvefit:fittype:SameNameCoeffAndIndVar', ...
             ['The name %s cannot be used for both a coefficient and the ', ...
              'independent variable.\n'],obj.indep);
    end
    if any(strmatch(obj.indep,probcell,'exact'))
        error('curvefit:fittype:SameNameProbParamAndIndVar', ...
             ['The name %s cannot be used for both a problem parameter and ',...
              'the independent variable.\n'],obj.indep);
    end
    if any(strmatch(obj.depen,coeffcell,'exact'))
        error('curvefit:fittype:SameNameCoeffAndDepenVar', ...
             ['The name %s cannot be used for both a coefficient and the ', ...
              'dependent variable.\n'],obj.depen);
    end
    if any(strmatch(obj.depen,probcell,'exact'))
        error('curvefit:fittype:SameNameProbParamAndDepenVar', ...
             ['The name %s cannot be used for both a problem parameter and ',...
              'the dependent variable.\n'],obj.depen);
    end
    if any(strmatch(obj.depen,obj.indep,'exact'))
        error('curvefit:fittype:SameNameIndAndDepenVars', ...
             ['The name %s cannot be used for both the independent and ', ...
              'the dependent variables.\n'],obj.indep);
    end
    
    % Checking if coeffs appear in linear terms for linear custom 
    if obj.linear
        linearvars = {};
        for i=1:length(obj.Adefn)
            linearvars = vertcat(linearvars,cfsymvar(obj.Adefn{i}));
        end
        for i=1:size(obj.coeff,1)
            if any(strmatch(obj.coeff(i,:),linearvars,'exact'))
                error('curvefit:fittype:linearTermContainsCoeff', ...
                     ['Coefficient ''%s'' appears in a linear term.\n' ...
                      'Try creating equation as a general (nonlinear) ', ...
                      'equation instead.\n'], obj.coeff(i,:));
            end
        end
    end
end

obj = class(obj, 'fittype');
% try to feval it to see if it works for custom models: linear and nonlinear
if isequal('custom',category(obj))
    try
        xtemp = rand(2,1); % create data
        probparams = num2cell(rand(1, numargs(obj)-obj.numCoeffs-1));
        if islinear(obj) % Also eval to get coefficient matrix
            A = getcoeffmatrix(obj,probparams{:},xtemp);
        end
        if ~isempty(findprop(obj.fitoptions, 'StartPoint')) && ...
                isequal(length(obj.fitoptions.startpoint),obj.numCoeffs)
            vals = num2cell(obj.fitoptions.startpoint);
        else
            vals = num2cell(rand(1, obj.numCoeffs));
        end
        temp = feval(obj,vals{:},probparams{:},xtemp);
      
    catch
        error('curvefit:fittype:invalidExpression', ...
             ['Expression %s is not a valid MATLAB expression,\n has ', ...
              'non-scalar coefficients, or cannot be evaluated.'],obj.defn);
    end
end
%------------------------------------------
function s1 = strtrim(s)
%STRTRIM Trim spaces from string.

if isempty(s)
    s1 = s;
else
    % remove leading and trailing blanks (including nulls)
    c = find(s ~= ' ' & s ~= 0);
    s1 = s(min(c):max(c));
end

%------------------------------------------
function obj = parseparams(obj,arglist)
%PARSEPARAMS parse param value pairs.

% Note: NO error checking on invalid parameter names!
% You can give parameters that don't exist, and leave out ones that do.

n = length(arglist);
coeffset = 0;  % flag
for i = 1:floor(n/2)
    param = arglist{1};
    value = arglist{2};
    arglist = {arglist{3:end}};
    switch param(1)
    case 'i'
        if strncmpi(param,'independent',length(param))
            obj.indep = strvcat(value);
        else
            error('curvefit:fittype:invalidParam', ...
                  'The parameter "%s" is not valid.\n',param);
        end
    case 'd'
        if strncmpi(param,'dependent',length(param))
            obj.depen = strvcat(value);
        else
            error('curvefit:fittype:invalidParam', ...
                  'The parameter "%s" is not valid.\n',param);
        end
    case 'c'
        if strncmpi(param,'coefficients',length(param))
            obj.coeff = strvcat(value);
            coeffset = 1;
        else
            error('curvefit:fittype:invalidParam', ...
                  'The parameter "%s" is not valid.\n',param);
        end
    case 'p'
        if strncmpi(param,'problem',length(param))
            obj.prob = strvcat(value);
        else
            error('curvefit:fittype:invalidParam', ...
                  'The parameter "%s" is not valid.\n',param);
        end
    case 'o'
        if strncmpi(param,'options',length(param))
            obj.fitoptions = value;
        else
            error('curvefit:fittype:invalidParam', ...
                  'The parameter "%s" is not valid.\n',param);
        end
    otherwise
            error('curvefit:fittype:invalidParam', ...
                  'The parameter "%s" is not valid.\n',param);
    end % switch
end % for

%------------------------------------------
function obj = deducecoeff(obj)
%DEDUCECOEFF Figure out coeff names from obj.args and obj.indep

index = logical(ones(1,size(obj.args,1)));
i = strmatch(obj.indep, obj.args, 'exact');

if isempty(i)
    error('curvefit:fittype:missingIndVar', ...
          ['The independent variable %s does not appear in the equation ', ...
           'expression.\nUse %s in the expression or indicate another ', ...
           'variable as the independent variable.'], obj.indep,obj.indep);
else
    index(i) = 0;
end 

for j = 1:size(obj.prob,1)
    i = strmatch(obj.prob(j,:), obj.args, 'exact');
    if isempty(i)
        error('curvefit:fittype:invalidProbParam', ...
          'A problem parameter name was given that is not in the expression.')
    else
        index(i) = 0;
    end 
    
    index(i) = 0;
end

if all(index==0)
    error('curvefit:fittype:noCoeffs', ...
          'This expression has no coefficients or non-scalar coefficients.');
end
obj.coeff = obj.args(index,:);
obj.numCoeffs = nnz(index);

%-------------------------------------------
function tf = isidentifier(str)

tf = 0;
if ~ischar(str)
    return;
end

if ~isempty(str)
    first = str(1);
    if (isletter(first))
        letters = isletter(str);
        numerals = (48 <= str) & (str <= 57);
        underscore = (95 == str);
        if (all(letters | numerals | underscore))
            tf = 1;
        end
    end
end

tf = logical(tf);



