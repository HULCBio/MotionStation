function Slice = getSlice(this,Section,Vars)
%GETSLICE  Extracts multi-dimensional slice from link array.
%
%   SLICE = GETSLICE(LINKARRAY,SECTION,'cell') returns the specified
%   section of a link array LINKARRAY.
%
%   SLICE = GETSLICE(LINKARRAY,SECTION,VARS) returns a struct array
%   containing the values of the linked variables VARS across the
%   specified cross-section of the linked data set array.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/11 00:28:41 $
if nargin==2 || isa(Vars,'char')
   % Syntax SLICE = GETSLICE(LINKARRAY,SECTION,'cell')
   % Slice of data set array
   if isempty(this.Links)
      Slice = {};
   else
      Slice = this.Links(Section{:});
      if length(Section)==1
         Slice = reshape(Slice,length(Slice),1);
      end
   end
else
   % Construct struct array with one field per specified dependent
   % variable containing the variable values across the slice of
   % linked data sets
   % RE: Called only when this.Links is nonempty
   DSArray = this.Links(Section{:});
   SectionSize = size(DSArray);
   nelem = prod(SectionSize);
   idxDS = find(~cellfun('isempty',DSArray)); 
   if isempty(idxDS)
      Slice = cell2struct(cell([length(Vars) SectionSize]),get(Vars,{'Name'}),1);
   else
      for ct=length(idxDS):-1:1
         % Grab contents of data set #ct
         ict = idxDS(ct);
         Slice(ict,1) = getContents(DSArray{ict},Vars);
      end
      if length(Slice)<nelem
         Slice(nelem,1).(Vars(1).Name) = [];
      end
      Slice = reshape(Slice,SectionSize);
   end
end