function cfdeletefits(fits)
%CFDELETEFITS Helper function to delete Curve Fitting fits

%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 21:39:43 $ 
%   Copyright 2001-2004 The MathWorks, Inc.


delete([fits{:}]);
cfupdatelegend(cfgetset('cffig'));
