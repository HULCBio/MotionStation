function [str] = getDataCursorText(hThis,hgObject,hDataCursorInfo,varargin)

% Copyright 2002-2003 The MathWorks, Inc.


if nargin>3
  hDatatip = varargin{1};
else
  hDatatip = [];
end


% This should be a static function, therefore, ignore "hThis"

str = [];

% invoke UpdateFcn defined through behavior object 
if ~isempty(get(hDataCursorInfo,'UpdateFcnCache'))
  str = hgfeval(get(hDataCursorInfo,'UpdateFcnCache'),...
                hDatatip,hDataCursorInfo);
     
% else invoke class method
elseif get(hDataCursorInfo,'TargetHasGetDatatipTextMethod')
   str = getDatatipText(hgObject,hDataCursorInfo);
  
% else do default
else
   [str] = hThis.default_getDatatipText(hgObject,hDataCursorInfo);
end


