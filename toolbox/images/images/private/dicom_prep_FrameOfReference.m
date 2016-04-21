function metadata = dicom_prep_FrameOfReference(metadata)
%DICOM_PREP_FRAMEOFREFERENCE  Fill necessary values for Frame of Reference.
%
%   See PS 3.3 Sec C.7.4.1

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision $  $Date $

name = dicom_name_lookup('0020', '0052');
if (~isfield(metadata, name))
    metadata.(name) = dicomuid;
end
