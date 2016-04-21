% TLC2M Converts TLC argument to MATLAB variable
%
%       tlc2m(mlvar,tlcvar)
%
%       When called from Target Language Compiler (TLC), this function
%       creates mlvar in the MATLAB base workspace with the equivalent
%       M representation for the TLC variable tlcvar.  For example,
%       the following TLC call:
%
%       %<FEVAL("tlc2m", "foo", CompiledModel)>
%
%       creates foo in the base MATLAB workspace with the equivalent
%       M representation of CompiledModel.
%
%       returns 0 on success and 1 on failure.

%       Copyright 1994-2002 The MathWorks, Inc.
%       $Revision: 1.3 $

function status = tlc2m(mlvar,tlcvar)
  
  if ~iscvar(mlvar)
    warning(sprintf('%s must be a valid C variable.'))
    status = 0;
    return;
  end
  
  assignin('base',mlvar,tlcvar);
  status = 1;
