function S = append(S,A)
% APPEND  Add segments to partition(s)
%   SA=APPEND(S,PSTR) - returns a new partition object SA that has the
%    segements described by PSTR is added to each partition.  
%   SA=APPEND(S,POBJ) Same as above, expect POBJ is a partition object.
%    
%  Note - to add a new partition that is NOT appended to the existing
%  partitions, use horzcat(A,B) or [A B].
%
% See also SMPARTITION

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2004/01/22 18:34:36 $

if isa(A,'smpartition'),
    A = getstruct(A);
end
if isa(A,'struct'),
    nA = numel(A);  % Array of structures
    nS = numel(S);  % Array of partitions
    for inxS = 1:nS
        for inxA = 1:nA,  %Accept arrays of structures
            % For an array, append this to each entry...
            sin = A(inxA);
            if isempty(S(inxS).Address), %% Indicates FIRST location
                if isfield(sin,'Address') && ischar(sin.Address) && ~isempty(sin.Address),
                    baseAddress = addressconvert(S,sin.Address);
                elseif isfield(sin,'Address')&& isnumeric(sin.Address) && ~isempty(sin.Address),
                    baseAddress= round(sin.Address);
                else
                    baseAddress = 0;  % Default Address
                end
                 S(inxS).Address(1) = baseAddress;      
            else
                S(inxS).Address(end+1) = -1;  % ignore address on append                            
            end
            if isfield(sin,'Type') && ~isempty(sin.Type),
                if ~ischar(sin.Type),
                   error(['Type parameter must be a string indicating the data type: ''double'',''int8'', etc']);
                end                    
                dtype = typeconvert(S,sin.Type);
                S(inxS).Type(end+1) = dtype;
            else
                S(inxS).Type(end+1) = typeconvert(S,'uint32');  % Default Type
            end
            if isfield(sin,'Alignment') && ~isempty(sin.Alignment),
               if ischar(sin.Alignment),
                   xalign = eval([sin.Alignment,';']);
               elseif isnumeric(sin.Alignment),
                   xalign = round(sin.Alignment);
                   if xalign <0,
                        error('Alignment must be a positive integer value');                       
                   end
               else
                   error('Alignment must be an integer value');
               end
               S(inxS).Alignment(end+1) = xalign;
            else
               S(inxS).Alignment(end+1) = 4; % Default Alignment
            end
            if isfield(sin,'Size') && ~isempty(sin.Size),
                if ischar(sin.Size),
                    xsize = round(eval([sin.Size,';']));
                elseif isnumeric(sin.Size),
                    xsize = round(sin.Size);
                else
                    error('Size must be a string or numeric description or the signal dimenions');
                end
                if numel(xsize) == 1,
                   S(inxS).Size = horzcat(S(inxS).Size,[xsize; 0]);
                elseif numel(xsize) == 2,
                   S(inxS).Size = horzcat(S(inxS).Size,reshape(xsize,2,1));
                else
                    error('Simulink Signals are limited to scalars,vectors or matrices.  Therefore, the SIZE parameter is limited to 2 entries');               
                end
                if prod(xsize) <= 0,  
                    error('SIZE parameter is limited to positive integers');
                end                
            else
                S(inxS).Size = horzcat(S(inxS).Size,[1; 0]); 
            end
        end
    end
else
    error('Append requires a partition definition structure or smpartition object');
end
S = adjustaddress(S);
 
