function Index = getIndexOf(this, Item)

% Copyright 2003 The MathWorks, Inc.

% Search for the Item in the list.  Return its index if it exists.
% Otherwise, return [].

ListData = this.ListData;
for i=1:length(ListData)
    ListItem = ListData{i};
    if length(ListItem) == length(Item) && strcmp(ListItem,Item)
        % Match, so return
        Index = i;
        return
    end
end
% Comes here if there was no match.
Index = [];