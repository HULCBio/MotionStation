function dlg_set( h, varargin )
%DLG_SET  Same as HG set except that a property set is preformed only if its value is different!

%   E.Mehran Mestchian
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.7.2.1 $  $Date: 2004/04/15 00:57:10 $

	if ~ishandle(h), return; end
	pvPairs = {};
   for i=1:2:length(varargin)
      property = varargin{i};
		newValue = varargin{i+1};
		oldValue = get(h,property);
      % normalize the data format before comparison: ensure cell arrays are column vector.
      if iscell(oldValue) & ~isempty(oldValue)
         oldValue = {oldValue{:}}';
      end
     	if iscell(newValue) & ~isempty(newValue)
         newValue = {newValue{:}}';
      end
         
		if ~isequal(oldValue,newValue)
         pvPairs{end+1} = property;
         pvPairs{end+1} = newValue;
      end
	end
	if ~isempty(pvPairs)
		set(h,pvPairs{:});
	end





