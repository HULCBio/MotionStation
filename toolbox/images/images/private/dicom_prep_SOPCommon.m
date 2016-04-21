function metadata = dicom_prep_SOPCommon(metadata, IOD_UID)
%DICOM_PREP_DICOM_PREP_SOPCOMMON  Fill necessary values for Frame of Reference.
%
%   See PS 3.3 Sec. C.12.1

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision $  $Date $

metadata.(dicom_name_lookup('0008', '0016')) = IOD_UID;
metadata.(dicom_name_lookup('0008', '0018')) = dicomuid;
