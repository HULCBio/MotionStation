function [allfcns,msg] = prefcnchk(funstr,caller,lenVarIn)
%PREFCNCHK Pre- and post-process function expression for FUNCHK.
%   [ALLFCNS,MSG] = PREFUNCHK(FUNSTR,CALLER,lenVarIn) takes
%   the expression FUNSTR from CALLER with LenVarIn extra arguments,
%   parses it according to what CALLER is, then returns a string or inline
%   object in ALLFCNS.  If an error occurs, this message is put in MSG.
%
%   ALLFCNS is a cell array: the first cell contains the objective function
%   (either inline object or string), the next contains the constraint 
%   function (as an inline object or string), and the last contains a flag 
%   that says if the objective and constraints are together in one function 
%   (strtype==1) or in two functions (strtype==2).  The fourth cell contains
%   the string CALLER.
%

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.8 $
%   Mary Ann Branch 9-1-96

% Initialize
msg='';
allfcns = {};
funfcn = [];
confcn = [];
strtype = 1;

switch caller
  case {'ncdtoolbox','trim'}
    [funfcn, msg] = fcnchk(funstr,lenVarIn);
    if ~isempty(msg)  % return error msg
      return
    end
    confcn = [];
    if isa(funfcn,'inline')
      msg = ('Expression syntax not supported for ncdtoolbox or trim.');
      return
    end
    allfcns{1} = funfcn;
    allfcns{4} = caller;
    allfcns{3} = strtype;
    allfcns{2} = confcn;
  otherwise
    disp('Unknown caller in prefcnchk call.')
end




