function out = vertcat(varargin)
%VERTCAT Vertical concatenation of serial port objects.
%

%   MP 7-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.5.4.3 $  $Date: 2004/01/16 20:04:47 $

% Initialize variables.
c=[];

% Loop through each java object and concatenate.
for i = 1:nargin
    if ~isempty(varargin{i}),
        
        if isempty(c)
            % Must be an instrument object otherwise error.
            if ~isa(varargin{i},'instrument')
                error('MATLAB:serial:vertcat:nonInstrumentConcat', 'Instrument objects can only be concatenated with other instrument objects.')
            end
            c=varargin{i};
        else
          
            % Extract needed information.
            try
               info = struct(varargin{i});
               appendJObject = info.jobject;
               appendType = info.type;
               appendConstructor = info.constructor;
            catch
                % This will fail if not an instrument object.
                error('MATLAB:serial:vertcat:nonInstrumentConcat', 'Instrument objects can only be concatenated with other instrument objects.')
            end
            
            % Append the jobject field.
            try
                c.jobject = [c.jobject; appendJObject];
            catch
                rethrow(lasterror);
            end

            % Append the Type field.
            if ischar(c.type)
                if ischar(appendType)
                    c.type = {c.type appendType}';
                else
                    c.type = {c.type appendType{:}}';
                end
            else
                if ischar(appendType)
                    c.type = {c.type{:} appendType}';
                else
                    c.type = {c.type{:} appendType{:}}';
                end
            end
            
			% Append the Constructor field.
            if ischar(c.constructor)
                if ischar(appendConstructor)
                    c.constructor = {c.constructor appendConstructor}';
                else
                    c.constructor = {c.constructor appendConstructor{:}}';
                end
            else
                if ischar(appendConstructor)
                    c.constructor = {c.constructor{:} appendConstructor}';
                else
                    c.constructor = {c.constructor{:} appendConstructor{:}}';
                end
            end
        end 
    end
end

% Verify that a matrix of objects was not created.
if length(c.jobject) ~= numel(c.jobject)
    error('MATLAB:serial:vertcat:nonMatrixConcat', 'Only a row or column vector of instrument objects can be created.')
end

% Output the array of objects.
out = c;



