function [attr, file] = dicom_read_attr_vr(file, attr, info)
%DICOM_READ_ATTR_VR  Read the VR from file or data dictionary.
%   [ATTR, FILE] = DICOM_READ_ATTR_VR(FILE, ATTR, INFO)
%   updates the attribute ATTR by reading its value representation (VR)
%   from FILE (in explicit value representation transfer syntaxes) or the
%   data dictionary (in implicit VR syntaxes).  If the VR contains more
%   than one possibile value, the previously read metadata INFO is used
%   to pick the correct VR.  FILE is updated to include any warning
%   information which may have changed.
%
%   See also DICOM_REAT_ATTR_METADATA, DICOM_DICT_LOOKUP.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.3 $  $Date: 2003/08/23 05:53:53 $

if ((isequal(file.Current_VR, 'Explicit')) && (attr.Group ~= 65534)) % 0xFFFE.
    
    % Explicit VR.
    attr.VR = char(fread(file.FID, 2, 'uchar')');

elseif (((attr.Group >= 20480) && (attr.Group < 20736)) && ...
        (attr.Element == 12288))

    % (50XX,3000) - Attribute's VR is determined by (50XX,0103)
    %
    % See PS 3.3 C.10.2, C.10.2.1.2, and C.10.2.1.4.
    switch (info.(sprintf('DataValueRepresentation_%X', ...
                          (attr.Group - 20480))))
    case 0
        attr.VR = 'US';
    case 1
        attr.VR = 'SS';
    case 2
        attr.VR = 'FL';
    case 3
        attr.VR = 'FD';
    case 4
        attr.VR = 'SL';
    otherwise
        msg = sprintf(['Unknown Data Value representation for curve (' ...
                       ' %04X,XXXX)'], attr.Group);
        file = dicom_warn(msg, file);
        
        attr.VR = 'US';
    end
    
else
    
    % Implicit VR or Items/Delimiters: (FFFE,E000), (FFFE,E00D), (FFFE,E0DD).
    
    try
        
        % Look VR up in dictionary, which must be valid.
        attr_dict = dicom_dict_lookup(attr.Group, attr.Element);

    catch
        
        % find_attr_details calls dicom_dict_lookup which can error but
        % doesn't have the file structure to close the message.
        
        file = dicom_close_msg(file);
        error('Images:dicom_read_attr_vr:dictionaryLookup', lasterr)
    
    end

    
    % Special case for private attributes.
    if (isempty(attr_dict))
        
        attr.VR = 'UN';
        return
        
    end
    
    % Make sure VR is a singleton.
    if (iscell(attr_dict.VR))

        attr_dict.Group = attr.Group;
        attr_dict.Element = attr.Element;
        
        [attr.VR, file] = find_vr(attr_dict, info, file);
        
    else
        
        attr.VR = attr_dict.VR;
        
    end
    
end




%%%
%%% Function find_vr
%%%
function [vr, file] = find_vr(attr, info, file)
%FIND_VR  Determine the attribute's VR for implicit VR messages.

% This function should only be called for attributes with multiple
% potential value representations.

% Most of these rules are listed in PS 3.5-2000 Annex A.  The remainder
% of the rules are from David Clunie.

group = attr.Group;
element = attr.Element;

%
% Convert attribute to text string for easier processing.
%

if ((group >= 20480) && (group < 20735))

    % 0x5000 - 0x50ff
    tag = upper(sprintf('(50XX,%04x)', element));
    
elseif ((group >= 24576) && (group < 24831))

    % 0x6000 - 0x60ff
    tag = upper(sprintf('(60XX,%04x)', element));
    
else

    % Non-repeated group.
    tag = upper(sprintf('(%04x,%04x)', group, element));

end

%
% Determine VR based on attribute, etc.
%

switch (tag)
case {'(0028,1201)','(0028,1202)','(0028,1203)', ...
      '(0028,1221)','(0028,1222)','(0028,1223)', ...
      '(5400,1010)','(60XX,3000)','(7FE0,0010)'}
    
    vr = 'OW';
    
case {'(50XX,3000)'}
    
    vr = 'OB';
    
case {'(50XX,200C)'}
    
    % Find the value of (50xx,2002) for this particular group.
    base = hex2dec('5000');
    offset = group - base;
    
    field = ['AudioSampleFormat_' num2str(offset)];
    
    if (isfield(info, field))
        
        value = info.(field);
        
    else
        
        if isfield(info, 'AudioSampleFormat_0')
            value = info.AudioSampleFormat_0;
        else
            vr = 'UN';
            return
        end
        
    end
    
    % Set VR based on AudioSampleFormat.
    if (value == 8)
        vr = 'OB';
    elseif (value == 16)
        vr = 'OW';
    else
        vr = 'UN';
    end
    
case {'(0028,0071)','(0028,0106)','(0028,0107)','(0028,0108)', ...
      '(0028,0109)','(0028,0110)','(0028,0111)','(0028,0120)', ...
      '(0028,1101)','(0028,1102)','(0028,1103)'}
    
    % Find the value of (0028,0103).
    if isfield(info, 'PixelRepresentation')
        value = info.PixelRepresentation;
        
    else
        msg = sprintf(['Could not determine VR for attribute %s.\n', ...
                       'Assuming VR of US.'], tag);
        file = dicom_warn(msg, file);
        
        vr = 'US';
        return
        
    end
    
    % Set VR based on this attribute's value.
    if (value == 0)
        vr = 'US';
    elseif (value == 1)
        vr = 'SS';
    else
        vr = 'UN';
    end
    
otherwise

    % Try to handle the attribute using US/SS rules.  Or use UN.

    if ((strmatch('SS', attr.VR)) && (strmatch('US', attr.VR)))
    
        % Find the value of (0028,0103).
        if isfield(info, 'PixelRepresentation')
            value = info.PixelRepresentation;
            
        else
            msg = sprintf(['Could not determine VR for attribute %s.\n', ...
                           'Assuming VR of US.'], tag);
            file = dicom_warn(msg, file);
            
            vr = 'US';
            return
            
        end
        
        % Set VR based on this attribute's value.
        if (value == 0)
            vr = 'US';
        elseif (value == 1)
            vr = 'SS';
        else
            vr = 'UN';
        end
    else
        
        % No explicit rule for handling this ambiguous VR.
        
        msg = sprintf(['Could not determine VR for attribute %s.\n', ...
                       'Assuming VR of UN.'], tag);
        file = dicom_warn(msg, file);
        
        vr = 'UN';
        return
        
    end
    
end
