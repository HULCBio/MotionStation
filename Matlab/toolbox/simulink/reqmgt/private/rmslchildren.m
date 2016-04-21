function [children, linked, descendents, blktypes] = rmslchildren(parent)
%RMSLCHILDREN requirements management children of a Simulink subsystem.
%   [CHILDREN, LINKED, DESCENDENTS, BLKTYPES] = RMSLCHILDREN(PARENT)
%   returns all the children, whether the children have requirements
%   links, how many descendents, and the block type.  For example, try
%   [c, l, d, b] = rmslchildren('f14');
%   Returns: success = 4 cell arrays of strings; errors = all thrown.
%   Used for populating tree navigation controls.
%

%  Author(s): M. Greenstein, 10/23/98
%  Copyright 1998-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $   $Date: 2004/04/15 00:36:45 $

% Validate input arguments.
if (~exist('parent') | isempty(parent))
   error('No system specified.');
end

% Open system if it's not opened.  Assumes that the user
% starts with the root.
a = findstr(parent, '/');
if (~length(a))
   a = find_system(0, 'blockdiagramtype', 'model');
   b = get_param(a, 'name');
   c = strcmp(parent, b);
   if (~sum(c))
      try
         open_system(parent);
      catch
      end
   end
end

try
   temp = find_system(parent, 'searchdepth', 1, 'LookUnderMasks', 'all');
catch
   error('Invalid system.');
end

reqsys = reqmgropts;
children = {};
linked = {};
descendents = {};
blktypes = {};
n = length(temp);
if (~n), return; end

% Loop through all the blocks at this level, noting which
% have valid requirements links in them.
for i = 2:n
   str = '';
   blktype = '';
   des = {};
   ndes = 0;
   masktype = '';

   % Look at the value in the RequirementInfo field for the requirement data.
   blk = temp{i};
   r = 'false';
   try
      str = get_param(blk, 'RequirementInfo');
   catch
   end
   if(length(str))
      req = reqinitstr(str);
      res = reqget(req, reqsys);
      % Look through all the items in the res cell array for at least one true.
      [rows, cols] = size(res);
		for j = 1:rows      
         if (strcmp(res{j, 2}, 'true')) 
            r = 'true'; 
            break;
         end
      end
   end
   
   % See if there are descendents.
   try
      blktype = get_param(blk, 'blocktype');
   catch
   end
   if (length(blktype))
      if (strcmp(blktype, 'SubSystem'))
         % Are there children?  How many?
         des = find_system(blk, 'searchdepth', 1, 'LookUnderMasks', 'all');
         ndes = length(des);
         if (ndes), ndes = ndes - 1; end
      end
      
      % Check for a Stateflow Subsystem.
   	try
      	masktype = get_param(blk, 'Masktype');
   	catch
   	end
   	if (length(masktype))
         if (strcmp(masktype, 'Stateflow'))
            blktype = 'StateflowSubsystem';
            ndes = 1; % There will be at least one descendent.  Actual number doesn't matter.
         end
    	end
      
   end
   
   
   % Put all the info into a cell array row.
   s = get_param(temp{i}, 'name');
   s = strrep(s, '/', '//'); % Quote real slashes.
   %%%%s = char(strrep(temp(i), char(10), ' ')); % Replace line feeds with spaces.
   %%%%s = strrep(s, '//', '~~'); % Replace double slashes with tildas temporarily.

   %%%%j = findstr(s, '/');
   %%%%if (~isempty(j))
      %%%%b = max(j) + 1;
      %%%%s = s(b:end);
      %%%%s = strrep(s, '~~', '/');
      %%%%s = strrep(s, '~~', '//'); % Restore double slashes.
      children{i - 1} = s;
      linked{i - 1} = r;
      descendents{i - 1} = num2str(ndes);
   	blktypes{i - 1} = blktype;  
   %%%%end
end

% end function children = rmslchildren(parent)
