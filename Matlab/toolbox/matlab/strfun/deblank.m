
%DEBLANK Remove trailing blanks.
%   R = DEBLANK(S) removes any trailing whitespace characters from string S.  
%   A whitespace is any character for which the ISSPACE function returns
%   TRUE.
%
%   S can also be a cell array of strings.  In this case, DEBLANK removes
%   trailing whitespace from each element of the cell arrray.
%
%   INPUT PARAMETERS:
%       S: any one of a char row vector, char array, or a cell array of strings.
%
%   RETURN PARAMETERS:
%       R: any one of a char vector, char array or a cell array of strings.
%
%   EXAMPLES:
%   A{1,1} = 'MATLAB    ';
%   A{1,2} = 'SIMULINK    ';
%   A = deblank(A)
%   A = 
%      'MATLAB'    'SIMULINK'
%       
%   See also ISSPACE, CELLSTR, STRTRIM.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.22.4.7 $  $Date: 2004/04/16 22:08:37 $
%==============================================================================

