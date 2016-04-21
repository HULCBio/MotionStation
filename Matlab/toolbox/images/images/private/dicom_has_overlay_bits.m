function overlay_bits = dicom_has_overlay_bits(info)
%DICOM_HAS_OVERLAY_BITS  Return overlay bit positions in pixel cells.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2003/01/26 05:58:39 $

% Overlay data requires one or more OverlayBitsAllocated attributes to be
% set (60xx,0100).

info_fields = fieldnames(info);
overlay_fields = strmatch('OverlayBitsAllocated', info_fields);

% Determine if overlay data is with the pixel data.
if (~isempty(overlay_fields))
   
    % Overlay pixels are with Image pixels iff OverlayBitsAllocated and
    % BitsAllocated are the same.
    
    overlay_bits = [];
    count = 0;
    
    % Find overlay bit location for each overlay in pixel cell.
    for p = overlay_fields'
        
        OverlayBitsAllocated = info.(info_fields{p});

        if (isequal(OverlayBitsAllocated, info.BitsAllocated))

            % Find position in pixel cell: OverlayBitPosition (60xx,0102).
            
            count = count + 1;
            
            OBP_field = strrep(info_fields{p}, 'BitsAllocated', ...
                               'BitPosition');
            
            overlay_bits(count) = info.(OBP_field);
            
        end
        
    end
    
else
    
    % No overlays.
    overlay_bits = [];
    
end
