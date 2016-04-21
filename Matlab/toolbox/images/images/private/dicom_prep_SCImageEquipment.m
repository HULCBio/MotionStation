function metadata = dicom_prep_SCImageEquipment(metadata)
%DICOM_PREP_SCIMAGEEQUIPMENT  Set necessary values for Image Pixel module
%
%   See PS 3.3 Sec C.8.1

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/23 05:53:50 $

name = dicom_name_lookup('0008', '0064');
if (~isfield(metadata, name))
    metadata(1).(name) = 'WSD';
end

name = dicom_name_lookup('0018', '1016');
if (~isfield(metadata, name))
    metadata.(name) = 'The MathWorks';
end

name = dicom_name_lookup('0018', '1018');
if (~isfield(metadata, name))
    metadata.(name) = 'MATLAB';
end
