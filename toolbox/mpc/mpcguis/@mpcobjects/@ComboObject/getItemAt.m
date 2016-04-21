function javaString = getItemAt(this, Index)

% Copyright 2003 The MathWorks, Inc.

% Return java.lang.String corresponding to list item at specified index.

ListData = this.ListData;
Index = double(Index);
if Index > 0 && Index <= length(ListData)
    javaString = java.lang.String(ListData{Index});
else
    warning(sprintf(['@ComboObject/@getItemAt:  Attempt to access item at Index = %i.\n',...
                     '                         List contains %i items.'], ...
        Index,length(ListData)));
    javaString = java.lang.String('');
end