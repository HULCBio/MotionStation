function [info, file] = dicom_read_attr_by_pos(file, pos, info)
%DICOM_READ_ATTR_BY_POS  Read a DICOM attribute at a particular location.
%   [INFO, FILE] = DICOM_READ_ATTR_BY_POS(FILE, POS, INFO) reads the next
%   attribute from FILE at location POS.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2003/08/01 18:10:50 $

% Go to beginning of attribute.

fseek(file.FID, pos, 'bof');

% Read the attribute.
[attr, data, file] = dicom_read_attr(file, info);

% Place the attribute in the info structure.
info.(attr.Name) = data;
