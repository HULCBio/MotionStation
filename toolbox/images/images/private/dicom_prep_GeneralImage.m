function metadata = dicom_prep_GeneralImage(metadata)
%DICOM_PREP_GENERALIMAGE  Set necessary values for General Image module
%
%   See PS 3.3 Sec C.7.6.1

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision $  $Date $

image_time = now;
metadata.(dicom_name_lookup('0008', '0023')) = convert_date(image_time, 'DA');
metadata.(dicom_name_lookup('0008', '0033')) = convert_date(image_time, 'TM');



function dicomDate = convert_date(ML_date, formatString)
%CONVERT_DATE   Convert a MATLAB datenum to a DICOM date/time string
%
%   See PS 3.5 Sec. 6.2 for DICOM date/time formats.

vec = datevec(ML_date);

switch (formatString)
case 'DA'
    % YYYYMMDD
    dicomDate = sprintf('%04d%02d%02d', vec(1:3));
case 'DT'
    % YYYYMMDDHHMMSS.FFFFFF
    dicomDate = sprintf('%04d%02d%02d%02d%02d%09.6f', vec);
case 'TM'
    %HHMMSS.FFFFFF
    dicomDate = sprintf('%02d%02d%09.6f', vec(4:6));
end
