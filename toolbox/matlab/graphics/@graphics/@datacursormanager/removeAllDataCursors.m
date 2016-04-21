function removeAllDataCursors(hThis,hContainer)

% Copyright 2003 The MathWorks, Inc.

if nargin==1
  doCheck = false;
else
  doCheck = true;
end

if(hThis.Debug)
  disp('removeAllDatatips')
end

hList = get(hThis,'DataCursors');

% Destroy all datatips
for n = 1:length(hList)
   if ~doCheck || (doCheck && ischild(hList(n),hContainer))
     removeDataCursor(hThis,hList(n));     
   end
end

%------------------------------------------%
function [bool] = ischild(a,b)
% Return true if a is a child of b

kids = findall(b);
bool = any(find(kids==a));





