function Hd = dfiltloadobj(filtstruct,coefficients,connection)
%DFILTLOADOBJ  DFILT load object.
%   Hd = DFILTLOADOBJ(FILTSTRUCT,COEFFICIENTS,CONNECTION) constructs UDD
%   discrete-time filter object Hd of type in string FILTSTRUCT and cell array
%   COEFFICIENTS, and string CONNECTION where CONNECTION can be either 'cas' or
%   'par'.
%
%   This function is a helper function to provide
%   backward-compatibility to pre-R13 DFILT objects and may change or
%   be removed in the future.
%
%   Example:
%     The function sigtools/@df2/loadobj.m is defined as:
%       function Hd = loadobj(s)
%       Hd = dfiltloadobj('df2',s.dtf.dfilt.coefficients,s.dtf.dfilt.connection);

%   Thomas A. Bryan
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/11/21 15:36:29 $ 


Hd = feval(str2func(['dfilt.',filtstruct]),coefficients{1}{:});

% Continue if there are more sections
nsecs = length(coefficients);
if nsecs>1
  switch connection
    case 'cas'
     for k=2:nsecs
       Hd = cascade(Hd,feval(str2func(['dfilt.',filtstruct]),coefficients{k}{:}));
     end
   case 'par'
     for k=2:nsecs
       Hd = parallel(Hd,feval(str2func(['dfilt.',filtstruct]),coefficients{k}{:}));
     end
   otherwise
    error('Unrecognized connection')
  end
end
