function metadata = dicom_prep_metadata(IOD_UID, metadata, X, map, txfr)
%DICOM_PREP_METADATA  Set the necessary metadata values for this IOD.
%   METADATA = DICOM_PREP_METADATA(UID, METADATA, X, MAP, TXFR) sets all
%   of the type 1 and type 2 metadata derivable from the image (e.g. bit
%   depths) or that must be unique (e.g. UIDs).  This function also
%   builds the image pixel data.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:10:48 $

switch (IOD_UID)
case '1.2.840.10008.5.1.4.1.1.2'
    metadata(1).(dicom_name_lookup('0008', '0060')) = 'CT';

    metadata = dicom_prep_ImagePixel(metadata, X, map, txfr);
    metadata = dicom_prep_FrameOfReference(metadata);
    metadata = dicom_prep_SOPCommon(metadata, IOD_UID);
    metadata = dicom_prep_FileMetadata(metadata, IOD_UID, txfr);
    metadata = dicom_prep_GeneralStudy(metadata);
    metadata = dicom_prep_GeneralSeries(metadata);
    metadata = dicom_prep_GeneralImage(metadata);
    
case '1.2.840.10008.5.1.4.1.1.4'
    metadata(1).(dicom_name_lookup('0008', '0060')) = 'MR';

    metadata = dicom_prep_ImagePixel(metadata, X, map, txfr);
    metadata = dicom_prep_FrameOfReference(metadata);
    metadata = dicom_prep_SOPCommon(metadata, IOD_UID);
    metadata = dicom_prep_FileMetadata(metadata, IOD_UID, txfr);
    metadata = dicom_prep_GeneralStudy(metadata);
    metadata = dicom_prep_GeneralSeries(metadata);
    metadata = dicom_prep_GeneralImage(metadata);
    
case '1.2.840.10008.5.1.4.1.1.7'
    name = dicom_name_lookup('0008', '0060');
    if (~isfield(metadata, name))
        metadata(1).(name) = 'OT';
    end
    
    metadata = dicom_prep_ImagePixel(metadata, X, map, txfr);
    metadata = dicom_prep_FrameOfReference(metadata);
    metadata = dicom_prep_SOPCommon(metadata, IOD_UID);
    metadata = dicom_prep_FileMetadata(metadata, IOD_UID, txfr);
    metadata = dicom_prep_GeneralStudy(metadata);
    metadata = dicom_prep_GeneralSeries(metadata);
    metadata = dicom_prep_GeneralImage(metadata);
    metadata = dicom_prep_SCImageEquipment(metadata);
    
otherwise
    error('Images:dicom_prep_metadata:unsupportedClass', 'Unsupported SOP class (%s)', IOD_UID)
    
end
