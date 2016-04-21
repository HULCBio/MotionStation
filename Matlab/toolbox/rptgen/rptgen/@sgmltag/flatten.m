function t=flatten(t,allFlat)
%FLATTEN removes unnecessary nested objects
%   FLATTEN(SGMLTAG) looks for child SGMLTAG objects
%   which have no tag.  If it finds any, it moves the
%   child's children up one level and deletes the
%   untagged object.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:33 $

if nargin<2
   allFlat=logical(0);
end

if ~iscell(t.data)
   d={t.data};
else
   d=t.data;
end

i=1;
while i<=length(d)
   if isempty(d{i})
      d=d([1:i-1,i+1:end]);
   elseif isa(d{i},'sgmltag')
      if isempty(d{i}.tag)
         d{i}=flatten(d{i},allFlat);
         numAdded=length(d{i}.data);
         d={d{[1:i-1]},d{i}.data{1:numAdded},d{[i+1:end]}};
         i=i+numAdded;
      else
         if allFlat
            d{i}=flatten(d{i},allFlat);
         end
         i=i+1;         
      end
   else
      i=i+1;
   end
end