function [reqitems, blktypes, itemnames] = rmlinked(reqsys, doc, modelname)
%RMLINKED requirements management Simulink and Stateflow linked requirements.
%   [REQITEMS, BLKTYPES, ITEMNAMES] = RMLINKED(REQSYS, DOC, MODELNAME)
%   returns all blocks that have requirements links in MODELNAME.  REQITEMS,
%   BLKTYPES, and ITEMNAMES are same-sized vectors.  MODELNAME must be
%   in the current default directory or on the path.
%
%   Returns: success = 3 vectors (can be empty) containing linked
%   items, failures = thrown.
%

%  Author(s): M. Greenstein, 11/13/98
%  Copyright 1998-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $   $Date: 2004/04/15 00:36:38 $

% Validate input arguments.
if (nargin ~= 3)
   error('Insufficient number of arguments.  3 required.');
end
if (~exist('reqsys') | isempty(reqsys))
   error('No requirements system (reqsys) specified.');
end
if (~exist('doc') | isempty(doc))
   error('No document specified.');
end
if (~exist('modelname') | isempty(modelname))
   error('No model specified.');
end

% Create cell array containing all blocks.
reqitems = {};
blktypes = {};
itemnames = {};
j = 1;
try
   blocks = find_system(modelname, 'LookUnderMasks', 'all');
catch
   error('No model is opened.');
end
n = length(blocks);
typ = '';
havesf = 0;

% Loop through all the Simulink blocks on the list and keep
% all those with a 'true' link.
j = 1;
for i = 1:n
   reqstr = '';
   
   % Get the requirement string, if there is one.
   try
      reqstr = get_param(blocks{i}, 'RequirementInfo');
   catch
   end
   
   % See if Stateflow is in this model.  Note it if so.
   if (~havesf)
      try
         btype = get_param(blocks{i}, 'MaskType');
         if (strcmp(btype, 'Stateflow'))
            havesf = 1;
         end 
   	catch
      end
   end
   
   if (~isempty(reqstr))
      allreqs = reqinitstr(reqstr);
      r = reqget(allreqs, reqsys);
      
      % Look through all the items in the res cell array for at least one true.
      x = 0;
      [rows, cols] = size(r);
		for k = 1:rows      
         if (strcmp(r{k, 2}, 'true')) 
            x = 1; 
            break;
         end
      end
      
      if (x) % Got one.
         %%%%s = strrep(blocks{i}, char(10), ' '); % Replace LFs with spaces.
         %%%%reqitems{j} = s;
         reqitems{j} = blocks{i};
         s = get_param(blocks{i}, 'name');
			s = strrep(s, '/', '//');
         itemnames{j} = s;
         try
            blktypes{j} = get_param(blocks{i}, 'blocktype');
         catch
            blktypes{j} = 'block_diagram';
         end
         j = j + 1;
      end
  end % if (~isempty(reqstr))
end % for i = 1:n

% Get the Stateflow linked reqs.
if (havesf)
	try
   	[r, b, k] = rmsflinked(reqsys, doc, modelname);
   	% Concatenate Simulink and Stateflow.
   catch
   	error(lasterr);   
   end   

  	reqitems = [reqitems r];
   blktypes = [blktypes b];
   itemnames = [itemnames k];  
end

% end function [reqitems, blktypes, itemnames] = rmlinked(reqsys, doc, modelname)
