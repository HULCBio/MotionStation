function newdata = mergeObjects(this, olddata, newdata, property)
% MERGEOBJECTS Merges two arrays of objects with respect to the string
% content of a given PROPERTY.

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:32:16 $

% These may be arrays
oldvalue = get( olddata, {property} );
newvalue = get( newdata, {property} );

[dummy, iold, inew] = intersect( oldvalue, newvalue );

% Keep old array only if Dimensions match.
for ct = 1:length(inew)
  olddims = olddata( iold(ct) ).Dimensions;
  newdims = newdata( inew(ct) ).Dimensions;
  
  if isequal( olddims, newdims )
    newdata( inew(ct) ) = olddata( iold(ct) );
  end
end
