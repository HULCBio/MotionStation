function out = privateSaveUserData(input)
%PRIVATESAVEUSERDATA Saves the UserData when it is a cell or structure.
%
%    PRIVATESAVEUSERDATA(INPUT) recursively goes through cell array, INPUT,  
%    or structure, INPUT, and calls saveobj on INPUTs members.
%

%    This is a helper function for private\privatesavecell which is used
%    by saveobj.
%
%    MP 9-22-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.7.2.4 $  $Date: 2003/08/29 04:42:21 $

% Initialize output variable.
out = [];

% If the input is a cell array loop through each element of the cell array
% and either call privateSaveUserData if the element is a cell or a structure
% or call saveobj.  If saveobj fails (saveobj(5) fails) just return the element.
if iscell(input)
   for i = 1:size(input,1)
      for j = 1:size(input,2)
         if iscell(input{i,j}) || isstruct(input{i,j})
            out{i,j} = privateSaveUserData(input{i,j});
         else
            try
               if isa(input{i,j}, 'daqdevice')
                  out{i,j} = helpersaveobj(input{i,j});
               else
                  out{i,j} = saveobj(input{i,j});
               end
            catch
               out{i,j} = input{i,j};
            end
         end
      end
   end
% If the input is a structure, loop through each field of the structure
% and either call privateSaveUserData if the field data is a cell array
% or a structure or call saveobj.
elseif isstruct(input)
   names = fieldnames(input);
   for i = 1:length(names)
      value = getfield(input, names{i});
      if iscell(value) || isstruct(value)
         out = setfield(out, names{i},privateSaveUserData(value));
      else
         try
            if isa(value, 'daqdevice')
               out = setfield(out, names{i}, helpersaveobj(value));
            else
               out = setfield(out, names{i}, saveobj(value));
            end
         catch
            out = setfield(out, names{i}, value);
         end
      end
   end
end
