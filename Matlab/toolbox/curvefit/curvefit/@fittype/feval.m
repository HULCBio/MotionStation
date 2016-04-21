function varargout = feval(varargin)
%FEVAL  FEVAL a FITTYPE object.
%   F = FEVAL(FITOBJ,A,B,...,X) evaluates the function
%   value F of FITOBJ with coefficients A,B,... and data X.
%
%   [F, J] = FEVAL(FITOBJ,A,B,...,X) evaluates the function
%   value F and Jacobian J, with respect to the coefficients,
%   of FITOBJ with coefficients A,B,... and data X.

%   Some special syntaxes used by the FIT command:
%   [F,...] = FEVAL(FITOBJ,P,X,...,'optim') evaluates the function
%   value F of FITOBJ with the vector of coefficients P by transforming
%   P from a vector into a comma separated list of values matching
%   the syntax of FITOBJ and data X. This is used by optimization routines
%   that expect the coefficients to be gathered together into one vector
%   rather than some number of scalars.
%
%   [F,...] = FEVAL(FITOBJ,P,X,...,W,'optimweight') is the same as 'optim' 
%   but multiplies F and J by the weight vector W. 
%   This is used by optimization routines.
%
%   [F,...] = FEVAL(FITOBJ,P,X,Y,'separable',...) is for separable equations,
%   for use with the 'optim' or 'optimweight' flags.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.16.2.2 $  $Date: 2004/02/01 21:41:34 $

flag = varargin{end};
if isequal(flag,'optimweight')
    weight = varargin{end-1};
    varargin(end-1:end) = []; % leave out 'optimweight' and w arguments
elseif isequal(flag,'optim')
    varargin(end) = []; % leave out 'optim' argument
end

FITTYPE_OBJ_ = varargin{1};

if ~isa(FITTYPE_OBJ_,'fittype')
    % If any of the elements in varargin are fittype objects, then the
    %  overloaded fittype feval is called even if the first argument
    %  is a string.  In this case, we call the builtin feval.
    [varargout{1:max(1,nargout)}] = builtin('feval',varargin{:});
    return
end

if (isequal(flag,'optim') | isequal(flag,'optimweight')) 
    % Change a vector of coefficients into individual coefficient inputs
    coeffcells = mat2cell(varargin{2});
    % reorder so xdata is after probparams: optim code sends it in the wrong order
    xdata = varargin(3);
    probparams = varargin(4:end);
    FITTYPE_INPUTS_ = [coeffcells, probparams, xdata];
else
    FITTYPE_INPUTS_ = varargin(2:end);
end

if ~isequal(varargin{end},'separable') & ~isequal(varargin{end-1},'separable') 
    if (length(FITTYPE_INPUTS_) < FITTYPE_OBJ_.numArgs)
        error('curvefit:fittype:feval:notEnoughInputs', ...
              'Not enough inputs to FITTYPE function.');
    elseif (length(FITTYPE_INPUTS_) > FITTYPE_OBJ_.numArgs)
        error('curvefit:fittype:feval:tooManyInputs', ...
              'Too many inputs to FITTYPE function.');
    end
end

% Add constants. Only affects library functions potentially,
% but not a problem anyway.
% Do this after the .numArgs check as .numArgs doesn't include the constants.
FITTYPE_INPUTS_ = [FITTYPE_INPUTS_(1:end-1),FITTYPE_OBJ_.constants(:)',FITTYPE_INPUTS_(end)];

if FITTYPE_OBJ_.feval
    % feval a function
    try
        [varargout{1:max(1,nargout)}] = feval(FITTYPE_OBJ_.expr, FITTYPE_INPUTS_{:});
    catch
        error('curvefit:fittype:feval:evaluationError', ...
              'Error while trying to evaluate FITTYPE function %s:\n\n%s', ...
               inputname(1),lasterr);
    end
    
else % eval an expression
    
    if (isempty(FITTYPE_OBJ_.expr))
        if nargout==1
            varargout{1} = [];
        elseif nargout == 2
            varargout{1:2} = [];
        end
    else
        eval(FITTYPE_OBJ_.assignCoeff);
        eval(FITTYPE_OBJ_.assignProb);
        eval(FITTYPE_OBJ_.assignData);
        
        FITTYPE_OBJ_catch = ['error(''curvefit:fittype:feval:expressionError'',',...
                                 '''Error in fittype expression',...
                                 ' ==> %s\n??? %s'',FITTYPE_OBJ_.expr,lasterr)'];
                
                
        [varargout{1:max(1,nargout)}] = eval(FITTYPE_OBJ_.expr, FITTYPE_OBJ_catch);
    end
end

if isequal(flag,'optimweight') & ~isempty(weight)
    % Assumes that weight is a column vector
    sqrtwt = sqrt(weight);
    varargout{1} = sqrtwt.*varargout{1};
    if nargout >= 2
        varargout{2} = repmat(sqrtwt,1,size(varargout{2},2)) .* varargout{2};
    end
end

if isequal(flag,'optimweight') | isequal(flag,'optim')
    if any(isnan(varargout{1}))
        error('curvefit:fittype:feval:modelComputedNaN', ...
              'NaN computed by model function.');
    elseif any(isinf(varargout{1}))
        error('curvefit:fittype:feval:modelComputedInf', ...
              'Inf computed by model function.');
    elseif any(~isreal(varargout{1}))
        error('curvefit:fittype:feval:modelComputedComplex', ...
              'Complex value computed by model function.');
    elseif nargout==2 & any(isnan(varargout{2}))
        error('curvefit:fittype:feval:JacobianComputedNaN', ...
              'NaN computed by model Jacobian function.');
    elseif  nargout==2  & any(isinf(varargout{2}))
        error('curvefit:fittype:feval:JacobianComputedInf', ...
              'Inf computed by model Jacobian function.');
    elseif nargout==2 & any(~isreal(varargout{2}))
        error('curvefit:fittype:feval:JacobianComputedComplex', ...
              'Complex value computed by model Jacobian function.');
    end   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c = mat2cell(a)
% Convert a matrix to a cell array in column order
% (Simpler case than num2cell so much faster)

if isempty(a), c = {}; return, end
a = a(:);

for i=1:length(a)
    c{i}=a(i);
end
