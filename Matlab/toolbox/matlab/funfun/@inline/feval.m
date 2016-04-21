function varargout = feval(varargin)
%FEVAL  FEVAL an INLINE object.

%   Steven L. Eddins, August 1995
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.17 $  $Date: 2002/04/15 04:20:56 $

INLINE_OBJ_ = varargin{1};
INLINE_INPUTS_ = varargin(2:end);

% We only want to call the @inline/feval if the first argument is
% actually an inline. Otherwise, defer to the builtin feval.
if ~isa(INLINE_OBJ_, 'inline')
    % If any of the elements in varargin are inline objects, then the
    %  overloaded inline feval is called even if the first argument
    %  is not an inline (such as a string or a function handle).  
    %  In this case, we call the builtin feval.
    % varargout is needed here, although inline's only have one output,
    %  since it could have been called with any number of outputs.
    [varargout{1:max(1,nargout)}] = builtin('feval',varargin{:});
else
    if (length(INLINE_INPUTS_) < INLINE_OBJ_.numArgs)
        error('Not enough inputs to inline function.');
    elseif (length(INLINE_INPUTS_) > INLINE_OBJ_.numArgs)
        error('Too many inputs to inline function.');
    end
    
    if (isempty(INLINE_OBJ_.expr))
        INLINE_OUT_ = [];
    else
        % Need to evaluate expression in a function outside the @inline directory
        % so that f(x), where f is an inline in the expression, will call the
        % overloaded subsref.
        INLINE_OUT_ = inlineeval(INLINE_INPUTS_, INLINE_OBJ_.inputExpr, INLINE_OBJ_.expr);
    end
    varargout{1} = INLINE_OUT_;
end




