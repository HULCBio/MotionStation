function resetPropertyFactoryValue(h, propList)
% RESETPROPERTYFACTORYVALUE
%   This will set an UDD object's property value.
%

%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:32:19 $
  
for i=1:length(propList)
  p = h.findprop(propList{i});
  fVal = p.FactoryValue;
  if isnumeric(fVal)
    eval(['h.' propList{i} '=' num2str(fVal) ';']);
  else
    eval(['h.' propList{i} '= ''' fVal ''';']);
  end
end

% end resetPropertyFactoryValue