function out = vertcat(varargin)
%VERTCAT Vertical concatenation of data acquisition objects.
%

%    MP 12-22-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.6.2.4 $  $Date: 2003/08/29 04:39:56 $

% Initialize variables.
c=[];

% Concatenate field information.
for i = 1:nargin
   if ~isempty(varargin{i}),
      % Make sure we are only concatenating device objects.
      if ~isa(varargin{i},'daqdevice'),
          error('daq:vertcat:invalidobject', 'Device objects can only be concatenated with other device objects.')
      end

      if isempty(c),
         c=varargin{i};
      else
         try
            c.handle = [c.handle; daqgetfield(varargin{i},'handle')];
            c.version = [c.version; daqgetfield(varargin{i},'version')];
            c.info = [c.info; daqgetfield(varargin{i},'info')];
         catch
            error('daq:vertcat:unexpected', lasterr);
         end
      end 
   end
end

% Determine if a matrix of device objects was constructed if so error
% since only vectors are allowed.
if length(c.handle) ~= prod(size(c.handle))
   error('daq:vertcat:size', 'Only a row or column vector of device objects can be created.')
end

% Assign the new device object vector to the output.  
out = c;
