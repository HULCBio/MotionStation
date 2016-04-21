function rmedit(reqsys, item, olddoc, newdoc, oldid, newid, itemname)
%RMEDIT requirements manager add/update a requirement in a file.
%   RMEDIT(REQSYS, ITEM, OLDDOC, NEWDOC, OLDID, NEWID, ITEMNAME) adds a 
%   requirement entry if OLDDOC is empty. ITEM is an M-file, a completely
%   specified Simulink block, or a completely specified Stateflow state. 
%   If OLDDOC is not empty, modifies an existing item.
%   If NEWDOC is empty and OLDID is supplied, the entry is deleted.
%
%   Duplicates are not allowed.
%   All errors are thrown.
%

%  Author(s): M. Greenstein, 12/14/98
%  Copyright 1998-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $   $Date: 2004/04/15 00:36:33 $

% Some validation here.
if (nargin < 6)
   error('Insufficient number of arguments.  6 are required.');
end
if (strcmp(reqsys, 'DOORS'))
   error('DOORS not supported by this function.');
end
if (~strcmp(reqsys, 'OTHERS'))
   error('Unsupported requirements system.');
end

reqstr = '';

% M-file, Simulink model, or Stateflow?
itemtype = 0; % Default itemtype is M-file.
item_lower = lower(item);
l = length(item_lower);
if (strcmp('.m', item_lower(l - 1: l)))
   % Check for validity of filename.
   f = which(item);
   if (~length(f))
      error('Invalid filename.');
   end
else
   itemtype = 1; % Simulink.  (Stateflow = 2)
end

% Get the requirements item (reqstr) first or create a new one.
switch (itemtype)
   case 0
      % M-file.
      reqstr = reqmf('get', f); % Attempt to get the reqstr from the file.
   case { 1 , 2 }
      % Simulink or Stateflow.  Try Simulink first.
      try
         reqstr = get_param(item, 'RequirementInfo');
      catch
         modelname = localgetmodelname(item);
         try
            [cid, sid] = rmsfid(modelname, item, itemname);
         catch
            error(lasterr);
         end
         reqstr = sf('get', sid, '.requirementInfo');
         itemtype = 2;
      end
   otherwise
      error('Invalid itemtype.');
end % switch (itemtype)

% Get a requirements cell array from the requirements string or create one.
if (~length(reqstr))
   req = reqinit;
else
   req = reqinitstr(reqstr);
end

if (length(olddoc))
   % Operate on an existing requirement.
   % Create a cell array of requirements from the requirement string.
   % Get all those corresponding to olddoc.
   exreq = reqget(req, reqsys, olddoc);
   if (isempty(exreq))
      error(['Requirement for ' olddoc ' does not exist.']); 
   end

   % See if there's an old id or an empty one.
   v = strcmp(oldid, exreq(:,1));
   id = '';
   if (~sum(v))
      % Find the first empty id field with the same docname.
      v = strcmp('', exreq(:,1));
   end
   vpos = find(v);
   if (vpos)
      % Update this one. (Delete and then add below.)
      vpos = min(vpos); % Should never be more than one.
      id = exreq(vpos, 1);
   end

   % Delete this requirement before re-adding.
   req = reqdel(req, reqsys, olddoc, id);

end % if (length(olddoc))

% Add the requirement to the requirements cell array.  An empty
% newdoc will act as a delete.
if (length(newdoc))
   req = reqadd(req, reqsys, newdoc, newid, 'true');
end

% Write the requirements back appropriately.
reqstr = reqgetstr(req);
if (~length(reqstr)), return; end
switch (itemtype)
   case 0
      % M-file.
      reqmf('set', f, reqstr);

   case 1
      % Simulink.
      modelname = localgetmodelname(item);
      try
         set_param(item, 'RequirementInfo', reqstr);
			save_system(modelname);
      catch
      end
      
   case 2
      % Stateflow. (Won't get here if Stateflow is not installed.)
      modelname = localgetmodelname(item);
      [cid, sid] = rmsfid(modelname, item, itemname);
      if (sid)
      	sf('set', sid, '.requirementInfo', reqstr);
         save_system(modelname);
      end
end % switch (itemtype)

% end function rmedit(reqsys, item, olddoc, newdoc, oldid, newid)


function lname = localgetmodelname(name)
%LOCALGETMODELNAME makes a model name from a path.

l = findstr(name, '/');
if (isempty(l))
   l = length(name);
else
   l = min(l) - 1;
end
%%%%lname = [name(1:l) '.mdl'];
lname = name(1:l);

%end function lname = localgetmodelname(name)

