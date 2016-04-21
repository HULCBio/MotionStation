function obj = loadobj(obj)
%LOADOBJ Method to post-process CFIT objects after loading

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.2.2.1 $  $Date: 2004/02/01 21:39:30 $

% If this is a struct, make a new object and assign its fields
if isstruct(obj)
   outobj = cfit;
   fnames = fields(obj);
   for j=1:length(fnames)
      eval(['outobj.' fnames{j} '=obj.' fnames{j} ';']);
   end
   obj = outobj;
end

% Restore function handles that had to be removed during save
if ~isequal(category(obj),'custom')
   obj.fittype = loadobj(obj.fittype);
end
