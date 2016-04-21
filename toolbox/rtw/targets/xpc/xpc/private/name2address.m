function address=name2address(arg)

% NAME2ADDRESS - xPC Target private function

% Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/03/25 04:21:19 $
% $Revision: 

str=arg;
isaddress=1;
[token,str]=strtok(str,'.');
while ~isempty(token)
   if isempty(str2num(token))
      isaddress=0;
      break;
   end;
   [token,str]=strtok(str,'.');
end;
if ~isaddress
   address=name2addressex(arg);
else
   address=arg;
end;





