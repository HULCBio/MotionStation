function setArray(this,DSArray)
%SETARRAY  Writes data link value (array of data set handles).
%
%   SETARRAY(LinkArray,DSArray)

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/11 00:28:43 $
errmsg = sprintf('Invalid value for data link %s. Expects cell array of data set handles.',this.Alias.Name);
if isempty(DSArray)
   % Clearing the link array
   this.Links = {};
   this.LinkedVariables = [];
   this.Template = [];
   return
elseif ~isa(DSArray,'cell')
   error(errmsg)
end

% Find nonempty entries
idxDS = find(~cellfun('isempty',DSArray));
if isempty(idxDS)
   this.LinkedVariables = [];
   this.Template = [];
else
   DS = DSArray{idxDS(1)};
   if ~isa(DS,'hds.AbstractDataSet')
      error(errmsg)
   end
   [Vars,DependVars] = getvars(DS);
   for ct=2:length(idxDS)
      d = DSArray{idxDS(ct)};
      dv = getDependentVars(d);
      if ~isa(d,'hds.AbstractDataSet')
         error(errmsg)
      elseif ~hasMatchingVars(DS,d)
         error('All data sets in a data link must contain the same variables.')
      elseif ~isempty(dv)
         [ia,ib] = utIntersect(dv,DependVars);
         if length(ia)<length(dv)
            DependVars = unique([DependVars;dv]);
         end
      end
   end
   this.LinkedVariables = [Vars;DependVars];
   this.Template = DS;
end
this.Links = DSArray;
