function setrtwoption(modelname,opt,val,create)
%SETRTWOPTION sets an RTW option for a Simulink model
%   OPT=SETRTWOPTION(MODELNAME, OPT, VALUE, CREATE) sets the RTW option OPT to VALUE for 
%   Simulink model MODELNAME. If CREATE = 1 the option is created if necessary, otherwise
%   an error is thrown if the option does note exist.
%
%   This function is now obsolete. Use uset_param instead.

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $
%   $Date: 2004/04/19 01:22:22 $

  warning(['The function ' mfilename ' is now obsolete. Use uset_param instead.']);
  uset_param(modelname,opt,val);
