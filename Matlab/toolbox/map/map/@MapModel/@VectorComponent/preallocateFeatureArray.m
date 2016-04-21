function preallocateFeatureArray(this,numFeatures)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/08/01 18:14:05 $


% Preallocate the features array.  Set the elements to be handles to the root
% element.  It is expected that ALL elements of Features are overwritten.

this.Features(numFeatures) = handle(0);
