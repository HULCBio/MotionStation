function save(this, nodes)
% SAVE Saves the project objects in a file.

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/06 01:10:51 $

filenames = get(nodes, {'SaveAs'});
SaveAs    = unique(filenames);

if length(SaveAs) > 1
  errmsg = 'Unique file name is required';
  uiwait( errordlg( errmsg, 'Save Error', 'modal' ) )
  return
end

if isempty(SaveAs)
  % Open 'Save...' dialog
  saveas(this, nodes)
else
  % Prepare before saving
  LocalPreSaveTasks(this, nodes)
  
  % Save data
  restoredFlags = get(nodes,{'Dirty'});
  try
    set(nodes, 'Dirty', false);
    Projects = nodes; % Used in next command as variable name
    save(SaveAs{1}, 'Projects')
  catch
    % Reset previous Dirty flags
    for k=1:length(nodes)
      nodes(k).Dirty = restoredFlags{k};
    end
    rethrow(lasterror)
  end
end

% --------------------------------------------------------------------------
function LocalPreSaveTasks(this, projects)
% Prepare task nodes before saving
for ct1 = 1:length(projects)
   projects(ct1).preSave(this);
   tasks = projects(ct1).getChildren;
   for ct2 = 1:length(tasks)
       % If the node is not a task node (c.f. MPC) do not call presave
       if isa(tasks(ct2),'explorer.tasknode')
           tasks(ct2).preSave(this);
       end
   end
end
