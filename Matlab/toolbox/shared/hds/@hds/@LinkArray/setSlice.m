function setSlice(this,Section,Slice,GridSize,Vars)
%SETSLICE  Modifies multi-dimensional slice of data set array or
%          of some variable therein.
%
%   SETSLICE(LINKARRAY,SECTION,SLICE,GRIDSIZE) modifies a portion
%   of the link array LINKARRAY.  SLICE is a cell array of data
%   sets.
%
%   SETSLICE(LINKARRAY,SECTION,SLICE,GRIDSIZE,VARS) modifies the
%   values of the variable VARS in the specified portion of the 
%   link array LINKARRAY.  SLICE is a struct array containing the
%   new variable values.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/11 00:28:45 $
if nargin==4
   % Modifying slice of data set array (data link)
   if isempty(this.Links)
      DSArray = cell(GridSize);
   else
      DSArray = this.Links;
   end
   
   % Optimization: no-op for modifications of existing data sets
   if ~isequal(DSArray(Section{:}),Slice)
      DSArray(Section{:}) = Slice;
      if isscalar(Slice) && LocalIsMatchingTemplate(this.Template,Slice{1})
         % Optimized for single data set
         this.Links = DSArray;
      else
         % RE: Needed to merge dependent variables
         this.setArray(DSArray);
      end
   end
else
   % Modifying data in all dependent data sets in specified 
   % data link slice
   % RE: Data set array cannot be empty in this case
   DSArray = this.Links(Section{:});
   SectionSize = size(DSArray);
   for ct=1:prod(SectionSize)
      if isempty(DSArray{ct})
         DS = copy(this.Template,'DataCopy','off');
      else
         DS = DSArray{ct};
      end
      setContents(DS,Slice(ct),Vars);
   end
end

%--------------- Local Functions -------------------

function boo = LocalIsMatchingTemplate(Template,DS)
% Check if new sample is matching template signature
boo = ~isempty(Template) && (isempty(DS) || ...
   (hasMatchingVars(Template,DS) && ...
   isequal(getDependentVars(Template),getDependentVars(DS))));
