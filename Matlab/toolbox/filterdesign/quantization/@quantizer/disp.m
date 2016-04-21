function disp(q)
%DISP   Display quantizer object. 
%   DISP(Q) displays a quantizer object in the same way as leaving off the
%   semicolon, except that the name of the variable is not displayed.
%
%   Example:
%     q = quantizer;
%     disp(q)
%
%   See also QUANTIZER, QUANTIZER/DISPLAY.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.17 $  $Date: 2002/04/14 15:35:18 $

disp(['            Mode = ',mode(q)]);
switch mode(q)
  case 'double'
    disp(['          Format = [',num2str([64 11]),']']);
  case 'single'
    disp(['          Format = [',num2str([32 8]),']']);
  case 'float'
    disp(['       RoundMode = ',roundmode(q)]);
    disp(['          Format = [',num2str(format(q)),']']);
  case {'fixed','ufixed'}
    disp(['       RoundMode = ',roundmode(q)]);
    disp(['    OverflowMode = ',overflowmode(q)]);
    disp(['          Format = [',num2str(format(q)),']']);
end
disp(' ')
disp(['             Max = ',num2str(max(q))]);
disp(['             Min = ',num2str(min(q))]);
disp(['      NOverflows = ',num2str(noverflows(q))]);
disp(['     NUnderflows = ',num2str(nunderflows(q))]);
disp(['     NOperations = ',num2str(noperations(q))]);

