function FITTYPE_OUT_ = subsref(FITTYPE_OBJ_, FITTYPE_SUBS_)
%SUBSREF Evaluate FITTYPE object.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.5.2.2 $  $Date: 2004/02/01 21:42:59 $

if (FITTYPE_OBJ_.isEmpty)
    error('curvefit:fittype:subsref:fcnEmpty', ...
          'Can''t call an empty FITTYPE function.');
end

switch FITTYPE_SUBS_.type
case '()'
    FITTYPE_INPUTS_ = FITTYPE_SUBS_.subs;
    FITTYPE_OUT_ = feval(FITTYPE_OBJ_,FITTYPE_INPUTS_{:});
otherwise % case '{}', case '.'
    error('curvefit:fittype:subsref:noFieldAccess', ...
          'Cannot access fields of fittype using . notation')
end


