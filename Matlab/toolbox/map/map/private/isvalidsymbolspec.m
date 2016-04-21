function b = isvalidsymbolspec(spec)
%ISVALIDSYMBOLSPEC Check Symbol Spec
%
% ISVALIDSYMBOLSPEC(SPEC) returns true if the Symbol Spec is valid, false
% otherwise.  This function in undocumented and is only used as a helper
% function to documented features.  The interface and existence of this
% function is likely to change in future releases.
%
% This functions does not check that the rules are in the correct format.
%
% See also MAKESYMBOLSPEC.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:52:38 $

b = false;
pointProperties = {'marker','color','markeredgecolor','markerfacecolor', ...
                   'markersize','visible'};
lineProperties = {'color','linestyle','linewidth','visible'};
polygonProperties = {'facecolor','facealpha','edgealpha','linestyle', ...
                    'linewidth','edgecolor','visible'};

if isstruct(spec) && (length(spec) == 1)
  fnames = fieldnames(spec);
  idx = strmatch('shapetype',lower(fnames),'exact');
  if ~isempty(idx)
    shapetype = spec.(fnames{idx});
    fnames(idx) = [];
    switch lower(shapetype)
     case 'point'
      for i=1:length(fnames)
        idx = strmatch(lower(fnames{i}),pointProperties,'exact');
        if isempty(idx)
          b = false;
        else
          b = true;
        end
      end
     case 'line'
      for i=1:length(fnames)
        idx = strmatch(lower(fnames{i}),lineProperties,'exact');
        if isempty(idx)
          b = false;
        else
          b = true;
        end
      end
     case 'polygon'
      for i=1:length(fnames)
        idx = strmatch(lower(fnames{i}),polygonProperties,'exact');
        if isempty(idx)
          b = false;
        else 
          b = true;
        end
      end
    end
  end
end

