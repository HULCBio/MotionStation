function [doc, id, linked] = rmreqs(reqsys, name, model, itemname)
%RMREQS gets all requirements available for an item.
%   [DOC, ID, LINKED] = RMREQS(REQSYS, MODEL, NAME, ITEMNAME) returns
%   all requirements for an item in the four same-sized vectors,
%   DOC, ID, LINKED.  NAME can be a Simulink block or
%   an M-file (fully qualified or on the path).  MODEL and ITEMNAME
%   are ignored for M-files but is required.  Use NAME only 
%   when calling in this case.
%
%   Assume that a Simulink system is open.  M-file must exist.
%
%   Returns: success = 4 vectors (can be empty) containing requirements,
%   failures = thrown.
%

%  Author(s): M. Greenstein, 10/23/98
%  Copyright 1998-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $   $Date: 2004/04/15 00:36:39 $

doc = {};
id = {};
linked = {};

% Validate input arguments.
if (~exist('reqsys') | isempty(reqsys))
   error('No requirements system was specified.');
end
if (~exist('name') | isempty(name))
   error('No name was specified.');
end
if (exist('itemname'))
   itemname = strrep(itemname, '//', '/');
end

% The name can be a block name or an M-file name.  If a block name, get
% the requirement string from the RequirementInfo field.  If a file name,
% it will have a ".m" at the end.  Use reqReadMfileReq in this case.
f = findstr(name(end-1:end), '.m');
if (isempty(f)), f = findstr(name(end-1:end), '.M'); end
if (isempty(f))
   % Simulink or Stateflow
   if (~exist('model') | isempty(model))
	   error('No model was specified.');
	end

	% If Simulink get_param fails try Stateflow.
	try
      reqstr = get_param(name, 'RequirementInfo');
   catch
      try
         if (exist('itemname'))
            reqstr = reqsf('get', model, name, itemname);
         else
            reqstr = reqsf('get', model, name); % Don't think this will ever be called.
			end
      catch
         error(lasterr);
      end
   end
else
   % M-file
   reqstr = reqmf('get', name);
end


% Get all the requirements into a cellarray and put them into respective
% cell arrays.
allreqs = reqinitstr(reqstr);
if (isempty(allreqs)), return; end
[allreqs, k] = sortrows(allreqs, 2);
[r, c] = size(allreqs);
j = 0;
for i = 1:r
   if (strcmp(reqsys, allreqs(i,1)))
      j = j + 1;
		doc(j) = allreqs(i,2);
		id(j) = allreqs(i,3);
      linked(j) = allreqs(i,4);
   end
end

% end function [reqsys, doc, id, linked] = rmreqs(reqsys, name, model)

