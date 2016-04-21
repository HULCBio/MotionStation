function new=copyfit(original)
%COPYFIT Copy constructor

%   $Revision: 1.1.6.2 $  $Date: 2004/01/24 09:32:42 $
% Copyright 2003-2004 The MathWorks, Inc.


% it may be coming in with a java bean wrapper
original=handle(original);

% Determine a new, unique name.
name = original.name;
taken = true;
i=1;

% keep from prepending multiple "copy x of"'s.
ind=findstr(name,' copy ');
if ~isempty(ind)
    name=name(1:(ind(end)-1));
end

% search for first unique name
fitdb = dfswitchyard('getfitdb');
while taken
   newName = sprintf('%s copy %i',name,i);
   a = down(fitdb);
   taken = false;
   while(~isempty(a))
      if isequal(a.name,newName)
         taken = true;
         break
      end
      a = right(a);
   end
   i=i+1;
end

new = initdistfit(stats.dffit,newName);

% copy all fields from the old to the new, but
% skip any of the ones on the toskip list.
fields = fieldnames(new);
toskip = {'listeners' 'name' 'plot' 'linehandle' 'ColorMarkerLine'};
for i=1:length(fields)
   if ~ismember(fields{i},toskip)
      set(new,fields{i},get(original,fields{i}));
   end
end

fitdb = dfswitchyard('getfitdb');
connect(new, fitdb,'up');

% restore other properties
if original.plot
   new.plot=1;
end

