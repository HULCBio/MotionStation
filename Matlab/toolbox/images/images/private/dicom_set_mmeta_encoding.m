function file = dicom_set_mmeta_encoding(file, info)
%DICOM_SET_MMETA_ENCODING  Prepare for reading the message metadata.
%   FILE = DICOM_SET_IMAGE_ENCODING(FILE,INFO) uses the transfer syntax
%   in INFO (if one is present) or other file details to prepare for
%   reading the image pixel data from FILE.  If INFO does not contain a
%   transfer syntax, Implicit Value Representation is used.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2003/08/01 18:10:59 $

%
% Determine what to do based on existence of file metadata.
%

if (isfield(info, 'TransferSyntaxUID'))  % (0002,0010)
    % There was file metadata.
    
    UID = dicom_uid_decode(info.TransferSyntaxUID);
    
    if (isempty(UID.Value))
        
        file = dicom_close_msg(file);
        msg = sprintf('Invalid transfer syntax UID "%s".', ...
                      info.TransferSyntaxUID);
        error('Images:dicom_set_mmeta_encoding:invalidTransferSyntax', msg);
        
    end
    
    if  (~isequal(UID.Type, 'Transfer Syntax'))
        
        file = dicom_close_msg(file);
        msg = sprintf('Invalid transfer syntax "%s".', UID.Name);
        error('Images:dicom_set_mmeta_encoding:invalidTransferSyntax', msg);
        
    end

    file.Current_VR = UID.VR;
    file.Current_Endian = UID.Endian;
    file.Pixel_Endian = UID.PixelEndian;
    
else
    % No file metadata.  Usually Implicit VR.
    
    file.Current_VR = 'Implicit';

    % Assume little endian and then refine.
    file.Current_Endian = 'ieee-le';

    % Determine endianness.
    %
    % Next group should be 0x0008.
    group = dicom_get_next_tag(file);
    
    if (group == 8)
        file.Current_Endian = 'ieee-le';
    
    elseif (group == 2048)  % 0x0800
        file.Current_Endian = 'ieee-be';
    
    else
        file = dicom_close_msg(file);
        error('Images:dicom_set_mmeta_encoding:fileEncoding', ...
              'Could not determine file encoding.')
    
    end

    file.Pixel_Endian = file.Current_Endian;
end

    
