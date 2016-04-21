function [cid, id] = rmsfid(modelname, name, itemname)
%RMSFID get requirements management chart id and item id.
%   [CID, ID] = RMSFID(MODELNAME, NAME) returns the current
%   (volatile) Stateflow chart id, CID, and item id, ID, for
%   model MODELNAME and block NAME.
%
%   Returns: success = ID or zero (if not found); errors = thrown.
%

%  Author(s): M. Greenstein, 11/24/98
%  Copyright 1998-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $   $Date: 2004/04/15 00:36:41 $

id = 0;
cid = 0;
if (~rmsfinst)
   error('Stateflow is not installed.');
end

machine = sf('find', 'all', 'machine.name', modelname);
if isempty(machine)         % Model contains no Stateflow.
   return;
elseif length(machine) > 1  % Should never see two machines with same name.
   error(['Expected only one machine named ''' modelname '''.']);
end

% Remove the itemname part, if it is available to remove.
s = name;
if(exist('itemname'))
   s = name(1 : (length(name) - length(itemname) - 1));
end

% Collect all the charts and find the chart.
charts = sf('get', machine, 'machine.charts');
if (isempty(charts)), return; end
for i = 1:length(charts)
    cname = rmsfnamefull(charts(i));
    c = findstr(s, cname);
    if (~isempty(c))
        nextChar = '';
        try
            nextChar = s(length(cname) + c);
        catch
        end
        if (isempty(nextChar) | strcmp(nextChar, '/'))
            cid = charts(i);
            break;
        end
    end
end

if (cid == 0)
   error(['No cid or id found for name ' name ' with itemname ' itemname]);
end
% Remove the chart name from name.
%%s = name(c + length(cname) + 1 : end);
s = s(c + length(cname) + 1 : end);
id = cid;
%%%%if (isempty(s)), return; end

% Work down the path as far as possible.
[tok1, s] =  strtok(s, '/');
while (1)
   match = [];
   children = sf('AllSubstatesOf',id);
   if (~isempty(tok1))
   	match = sf('find', children, '.name', tok1);
   elseif (exist('itemname'))% Now use the itemname.
   	match = sf('find', children, '.name', itemname);
   end

   if (exist('itemname') & isempty(tok1) & isempty(match))
      % Try as a transition.
      match = sf('TransitionsOf', id);
      if (~isempty(match))
         try
            match = sf('find', match, '.labelString', itemname);
         catch
         end
      end
      if (~isempty(match)), match = min(match); end
   end

	if(~isempty(match))
   	id = min(match);
   end

   if (isempty(s))
      %%if (isempty(match) & ~isempty(tok1) & exist('itemname'))
      if (~isempty(match) & ~isempty(tok1) & exist('itemname'))
         tok1 = [];
      else
         if (cid == id), id = 0; end
	      return;
      end
   end
	[tok1, s] =  strtok(s, '/');

end

% end function [cid, id] = rmsfid(modelname, name, itemname)
