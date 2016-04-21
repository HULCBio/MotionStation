function INLINE_OUT_ = subsref(INLINE_OBJ_, INLINE_SUBS_)
%SUBSREF Evaluate INLINE object.

%   Steven L. Eddins, August 1995
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.13 $  $Date: 2002/04/15 04:21:08 $

if (INLINE_OBJ_.isEmpty)
    error('Can''t call an empty inline function.');
end

INLINE_INPUTS_ = INLINE_SUBS_.subs;
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

