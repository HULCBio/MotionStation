function file = dicom_set_image_encoding(info, file)
%DICOM_SET_MMETA_ENCODING  Prepare for reading the image pixel data.
%   FILE = DICOM_SET_IMAGE_ENCODING(FILE,INFO) uses the transfer syntax
%   in INFO to prepare for reading the image pixel data from FILE.  If
%   INFO does not contain a transfer syntax, the current encoding is
%   used.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.3 $  $Date: 2003/08/23 05:53:59 $

%
% Determine what to do based on existence of file metadata.
%

if (isfield(info, 'TransferSyntaxUID'))  % (0002,0010)
    % There was file metadata.
    
    UID = dicom_uid_decode(info.TransferSyntaxUID);
    
    if ((isempty(UID.Value) || (~isequal(UID.Type, 'Transfer Syntax'))))
        
        file = dicom_close_msg(file);
        
        msg = sprintf('Invalid transfer syntax "%s".', UID.Value);
        error('Images:dicom_set_image_encoding:invalidTransferSyntax', msg);
        
    end

    file.Current_Endian = UID.Endian;
    file.Pixel_Endian = UID.PixelEndian;
    
    if (UID.Compressed)
        % Image data of compressed files is always Explicit VR.
        file.Current_VR = 'Explicit';
    else
        % Uncompressed messages usually use the same settings as their
        % metadata.  Some private transfer syntaxes have different
        % byte-ordering.
        file.Current_VR = UID.VR;
    end
    
else
    % Pre-DICOM files have no good way of determining encoding.
    % Use current settings.

    msg = 'Assuming uncompressed data in fragmentary DICOM message.';
    file = dicom_warn(msg, file);
    
end
