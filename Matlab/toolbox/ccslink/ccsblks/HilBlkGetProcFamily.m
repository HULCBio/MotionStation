function procFamily = HilBlkGetProcFamily(CCS_Obj)
% Decipher the subfamily number and 
% determine the equivalent chip designation
% needed for Hil Block data type conversion.

% Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/08 20:44:24 $

subFamilyDigits = num2str(dec2hex(CCS_Obj.subfamily));
switch subFamilyDigits
    case {'67','64','62'},
        procFamily = 'c6xxx';
    case '54',
        procFamily = 'c54xx';
    case '55',
        procFamily = 'c55xx';
    case '28',
        procFamily = 'c28xx';
    otherwise,
        error(['The HIL Function Call Block does not support ' ...
                'this processor family.'])
end    

