function attr_str = dicom_add_item(attr_str, group, element, varargin)
%DICOM_ADD_ITEM   Add an item/delimiter to a structure of attributes.
%   OUT = DICOM_ADD_ITEM(IN, GROUP, ELEMENT)
%   OUT = DICOM_ADD_ITEM(IN, GROUP, ELEMENT, DATA)
%   
%   This function is similar to DICOM_ADD_ATTR, but it doesn't allow
%   specifying VR values and can only be used for attributes of group
%   FFFE.
%
%   See also DICOM_ADD_ATTR, DICOM_ADD_PIXEL_DATA.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2003/08/01 18:10:25 $


% See PS-3.5 Sec. 7.5 for details on sequence and item encoding.


% Get group and element.
tmp.Group = get_group_or_element(group);
tmp.Element = get_group_or_element(element);

% Get data value.
if (nargin > 4)
    eid = sprintf('Images:%s:tooManyInputArgs',mfilename);    
    error(eid,'%s','Too many input arguments.');
elseif (nargin == 3)
    tmp.Data = [];
else
    tmp.Data = varargin{1};
end

tmp.VR = 'UN';

% Check the group and element values.
if (tmp.Group ~= 65534)  % 0xFFFE == 65534
    eid = sprintf('Images:%s:groupNotAccepted',mfilename);    
    error(eid,'This function does not accept group "%X".', tmp.Group)
end

switch (tmp.Element)
case {57344}         % 0xE000 == 57344
    
    % Data is okay for (FFFE,E000).
    
case {57357, 57565}  % 0xE00D == 57357,  0XE0DD == 57565
    
    if (~isempty(tmp.Data))
        eid = sprintf('Images:%s:AttributeCannotHaveData',mfilename);    
        error(eid,'Attribute (%04X,%04X) cannot have data.', ...
              tmp.Group, tmp.Element)
    end
    
otherwise
    eid = sprintf('Images:%s:attributeNotSupported',mfilename);        
    error(eid,'Attribute (%04X,%04X) is not supported.', ...
          tmp.Group, tmp.Element)
                  
end

% Pad the data to an even byte boundary.
if (rem(numel(tmp.Data), 2) == 1)
    tmp.Data(end + 1) = uint8(0);
end

% Store the data.
attr_str = cat(2, attr_str, tmp);



function val = get_group_or_element(in)

eid = sprintf('Images:%s:groupElementNotHexOrInt',mfilename);                    
msg = 'Group and Element values must be hexadecimal strings or integers.';

if (isempty(in))
    
    error(eid,'%s',msg)
    
elseif (ischar(in))

    val = sscanf(in, '%x');
    
elseif (isnumeric(in))
    
    val = in;
    
else
    
    error(eid,'%s',msg)
    
end
