function [Names,clash] = mrgname(Names1,Names2)
%MRGNAME  Input/output name management.  
%
%   [NAMES,CLASH] = MRGNAME(NAMES1,NAMES2)  merges the two
%   sets of I/O names NAMES1 and NAMES2.  Empty entries of 
%   NAMES1 are overwritten by corresponding entries of NAMES2,
%   and the remaining entries are left untouched.
%
%   If both nonempty, NAMES1 and NAMES2 are assumed of the 
%   same length.

%       Author(s): P. Gahinet, 4-1-96
%       Copyright 1986-2001 The MathWorks, Inc.
%       $Revision: 1.5 $  $Date: 2001/04/06 14:22:10 $


% Get empty names
EmptyNames1 = strcmp(Names1,'');
EmptyNames2 = strcmp(Names2,'');

% Determine output
% RE: in case of name clash, NAMES1 should be left untouched
Names = Names1;  % default
clash = 0;

if all(EmptyNames1),
   Names = Names2;   
   
elseif ~all(EmptyNames2),
   % Both NAMES1 and NAMES2 have nonempty names
   Names1(EmptyNames1,1) = Names2(EmptyNames1,1);
   
   for i=find(~EmptyNames1 & ~EmptyNames2)',
      % Cycle through pair (Names1{i},Names2{i}) where
      % both names are nonempty
      if ~strcmp(Names1{i},Names2{i}),
         clash = 1;  return
      end
   end
   
   Names = Names1;
end

