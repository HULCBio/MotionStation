function sf_profile( globalProfileVariableName, flag )
%SF_PROFILE  Adds the appropriate flag field to the global profile variable
%            name.

%   E.Mehran Mestchian
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.6.2.1 $  $Date: 2004/04/15 00:59:44 $

eval(['global ',globalProfileVariableName,';',globalProfileVariableName,'.',flag,'=0;']);

