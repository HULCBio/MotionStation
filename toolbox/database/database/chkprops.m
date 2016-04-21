function prps = chkprops(x,p,kp)
%CHKPROPS Database object properties.
%   PRPS = CHKPROPS(X,P) validates and returns the given set of properties, P,
%   for the database object, X.  KP is the set of known properties for the
%   given object.

%   Copyright (c) 1984-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $   $Date: 2003/01/30 21:30:33 $

if ischar(p)   %Convert string input to cell array
  p = {p};
end

for i = 1:length(p)  %Validate each given property
  try
    c(i) = find(strcmp(upper(p(i)),upper(kp)));
  catch
    error('database:chkprops:invalidDatabaseObjectProperty','Invalid %s property: '' %s ''.',class(x),p{i})
  end
end

prps = kp(c);   %Return properties converted from given to known props (case sen)
