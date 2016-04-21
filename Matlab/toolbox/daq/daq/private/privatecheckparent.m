function out = privatecheckparent(varargin)
%PRIVATECHECKPARENT Determine if data acquisition objects have same parent.
%
%    OUT = PRIVATECHECKPARENT(OBJ1, OBJ2,...) determines if data
%    acquisition objects OBJ1, OBJ2,... have the same parent and are
%    valid.
%
%    OUT is 2 if the object is invalid.
%    OUT is 1 if the object's don't have the same parent.
%    OUT is 0 of the object's do have the same parent and are value.
%
%    PRIVATECHECKPARENT is a helper function for HORZCAT and VERTCAT.
%

%    MP 6-03-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.11.2.4 $  $Date: 2003/08/29 04:42:25 $


% Initialize variables
out = 0;
handle=[];
chan = varargin{:};

% Obtain the handle of the parent of the first object passed.  Then compare 
% the remaining objects parent's handles to the first objects parent's handle.
for i = 1:length(chan)
   if ~isempty(chan{i})
      try
         if daqmex('IsValidHandle', chan{i})
            parent = daqmex(chan{i}, 'get', 'Parent');
            if isempty(handle)
               info = struct(parent);
               handle = info.handle;
            end
         else
            % Object is invalid.
            out = 2;  
            return;
         end
      catch
         % An error occured in the daqmex calls.
         out=1;   
         return;
      end
      
      % Determine if the objects have the same parent.
      info = struct(parent);
      if info.handle ~= handle
         out = 1;   
         return;
      end
   end
end