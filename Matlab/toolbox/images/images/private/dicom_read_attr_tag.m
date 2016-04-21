function attr = dicom_read_attr_tag(file, attr)
%DICOM_READ_ATTR_TAG  Read the group and element values of the attribute.
%   ATTR = DICOM_READ_ATTR_TAG(FILE, ATTR) updates the attribute ATTR by
%   reading the ordered pair (group, element) from FILE.
%
%   See also DICOM_REAT_ATTR_METADATA.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2003/08/23 05:53:52 $


attr.Group = fread(file.FID, 1, 'uint16', file.Current_Endian);
attr.Element = fread(file.FID, 1, 'uint16', file.Current_Endian);

