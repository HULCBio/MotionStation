function UID_details = dicom_uid_decode(UID_string)
%DICOM_UID_DECODE  Get information about a Unique Identifier (UID).
%   DETAILS = DICOM_UID_DECODE(UID) get DETAILS about the DICOM unique
%   identifier contained in the string UID.
%
%   DETAILS contains the Name of the UID and its type (SOP class,
%   transfer syntax, etc.).  If UID corresponds to a transfer syntax,
%   DETAILS also contains the endianness and VR necessary for reading the
%   image pixels and whether these pixels are compressed.
%
%   Note: Only UID's listed in PS 3.6-1999 are included here.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2003/08/23 05:54:01 $

if ((~ischar(UID_string)) || (numel(UID_string) ~= length(UID_string)))
    
    UID_details = struct([]);
    return
    
end

UID_details.Value = UID_string;
UID_details.Name = '';
UID_details.Type = '';
UID_details.Compressed = [];
UID_details.Endian = '';
UID_details.PixelEndian = '';
UID_details.VR = '';

switch (UID_string)
    % SOP classes
    
case '1.2.840.10008.1.1'
    UID_details.Name = 'Verification SOP Class';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.1.3.10' 
    UID_details.Name = 'Media Storage Directory Storage';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.1.9' 
    UID_details.Name = 'Basic Study Content Notification SOP Class';
    UID_details.Type = 'SOP Class';

case '1.2.840.10008.1.20.1' 
    UID_details.Name = 'Storage Commitment Push Model SOP Class';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.1.20.2' 
    UID_details.Name = 'Storage Commitment Pull Model SOP Class';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.3.1.2.1.1' 
    UID_details.Name = 'Detached Patient Management SOP Class';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.3.1.2.2.1' 
    UID_details.Name = 'Detached Visit Management SOP Class';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.3.1.2.3.1' 
    UID_details.Name = 'Detached Study Management SOP Class';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.3.1.2.3.2' 
    UID_details.Name = 'Study Component Management SOP Class';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.3.1.2.3.3' 
    UID_details.Name = 'Modality Performed Procedure Step SOP Class';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.3.1.2.3.4' 
    UID_details.Name = 'Modality Performed Procedure Step Retrieve SOP Class';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.3.1.2.3.5' 
    UID_details.Name = 'Modality Performed Procedure Step Notification SOP Class';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.3.1.2.5.1' 
    UID_details.Name = 'Detached Results Management SOP Class';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.3.1.2.6.1' 
    UID_details.Name = 'Detached Interpretation Management SOP Class';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.1.1' 
    UID_details.Name = 'Basic Film Session SOP Class';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.1.2' 
    UID_details.Name = 'Basic Film Box SOP Class';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.1.4' 
    UID_details.Name = 'Basic Grayscale Image Box SOP Class';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.1.4.1' 
    UID_details.Name = 'Basic Color Image Box SOP Class';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.1.4.2' 
    UID_details.Name = 'Referenced Image Box SOP Class';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.1.14' 
    UID_details.Name = 'Print Job SOP Class';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.1.15' 
    UID_details.Name = 'Basic Annotation Box SOP Class';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.1.16' 
    UID_details.Name = 'Printer SOP Class';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.1.22' 
    UID_details.Name = 'VOI LUT Box SOP Class';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.1.23' 
    UID_details.Name = 'Presentation LUT SOP Class';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.1.24' 
    UID_details.Name = 'Image Overlay Box SOP Class';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.1.24.1' 
    UID_details.Name = 'Basic Print Image Overlay Box SOP Class';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.1.26' 
    UID_details.Name = 'Print Queue Management SOP Class';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.1.27' 
    UID_details.Name = 'Stored Print Storage SOP Class';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.1.29' 
    UID_details.Name = 'Hardcopy Grayscale Image Storage SOP Class';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.1.30' 
    UID_details.Name = 'Hardcopy Color Image Storage SOP Class';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.1.31' 
    UID_details.Name = 'Pull Print Request SOP Class';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.1.1' 
    UID_details.Name = 'Computed Radiography Image Storage';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.1.1.1' 
    UID_details.Name = 'Digital X-Ray Image Storage - For Presentation';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.1.1.1.1' 
    UID_details.Name = 'Digital X-Ray Image Storage - For Processing';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.1.1.2' 
    UID_details.Name = 'Digital Mammography X-Ray Image Storage - For Presentation';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.1.1.2.1' 
    UID_details.Name = 'Digital Mammography X-Ray Image Storage - For Processing';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.1.1.3' 
    UID_details.Name = 'Digital Intra-oral X-Ray Image Storage - For Presentation';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.1.1.3.1' 
    UID_details.Name = 'Digital Intra-oral X-Ray Image Storage - For Processing';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.1.2' 
    UID_details.Name = 'CT Image Storage';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.1.3' 
    UID_details.Name = 'Ultrasound Multi-frame Image Storage';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.1.3.1' 
    UID_details.Name = 'Ultrasound Multi-frame Image Storage';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.1.4' 
    UID_details.Name = 'MR Image Storage';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.1.5' 
    UID_details.Name = 'Nuclear Medicine Image Storage';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.1.6' 
    UID_details.Name = 'Ultrasound Image Storage';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.1.6.1' 
    UID_details.Name = 'Ultrasound Image Storage';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.1.7' 
    UID_details.Name = 'Secondary Capture Image Storage';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.1.8' 
    UID_details.Name = 'Standalone Overlay Storage';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.1.9' 
    UID_details.Name = 'Standalone Curve Storage';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.1.10' 
    UID_details.Name = 'Standalone Modality LUT Storage';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.1.11' 
    UID_details.Name = 'Standalone VOI LUT Storage';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.1.12.1' 
    UID_details.Name = 'X-Ray Angiographic Image Storage';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.1.12.2' 
    UID_details.Name = 'X-Ray Radiofluoroscopic Image Storage';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.1.12.3' 
    UID_details.Name = 'X-Ray Angiographic Bi-Plane Image Storage';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.1.20' 
    UID_details.Name = 'Nuclear Medicine Image Storage';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.1.77.1' 
    UID_details.Name = 'VL Image Storage';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.1.77.2' 
    UID_details.Name = 'VL Multi-frame Image Storage';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.1.77.1.1' 
    UID_details.Name = 'VL Endoscopic Image Storage';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.1.77.1.2' 
    UID_details.Name = 'VL Microscopic Image Storage';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.1.77.1.3' 
    UID_details.Name = 'VL Slide-Coordinates Microscopic Image Storage';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.1.77.1.4' 
    UID_details.Name = 'VL Photographic Image Storage';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.1.128' 
    UID_details.Name = 'Positron Emission Tomography Image Storage';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.1.129' 
    UID_details.Name = 'Standalone PET Curve Storage';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.1.481.1' 
    UID_details.Name = 'RT Image Storage';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.1.481.2' 
    UID_details.Name = 'RT Dose Storage';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.1.481.3' 
    UID_details.Name = 'RT Structure Set Storage';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.1.481.4' 
    UID_details.Name = 'RT Beams Treatment Record Storage';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.1.481.5' 
    UID_details.Name = 'RT Plan Storage';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.1.481.6' 
    UID_details.Name = 'RT Brachy Treatment Record Storage';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.1.481.7' 
    UID_details.Name = 'RT Treatment Summary Record Storage';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.2.1.1' 
    UID_details.Name = 'Patient Root Query/Retrieve Information Model - FIND';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.2.1.2' 
    UID_details.Name = 'Patient Root Query/Retrieve Information Model - MOVE';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.2.1.3' 
    UID_details.Name = 'Patient Root Query/Retrieve Information Model - GET';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.2.2.1' 
    UID_details.Name = 'Study Root Query/Retrieve Information Model - FIND';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.2.2.2' 
    UID_details.Name = 'Study Root Query/Retrieve Information Model - MOVE';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.2.2.3' 
    UID_details.Name = 'Study Root Query/Retrieve Information Model - GET';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.2.3.1' 
    UID_details.Name = 'Patient/Study Only Query/Retrieve Information Model - FIND';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.2.3.2' 
    UID_details.Name = 'Patient/Study Only Query/Retrieve Information Model - MOVE';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.1.2.3.3' 
    UID_details.Name = 'Patient/Study Only Query/Retrieve Information Model - GET';
    UID_details.Type = 'SOP Class';
    
case '1.2.840.10008.5.1.4.31' 
    UID_details.Name = 'Modality Worklist Information Model - FIND';
    UID_details.Type = 'SOP Class';
    
    % Well-known SOP Instances
case '1.2.840.10008.1.20.1.1' 
    UID_details.Name = 'Storage Commitment Push Model SOP Instance';
    UID_details.Type = 'Well-known SOP Instance';
    
case '1.2.840.10008.1.20.2.1' 
    UID_details.Name = 'Storage Commitment Pull Model SOP Instance';
    UID_details.Type = 'Well-known SOP Instance';
    
    
    
    % Application Context Names
case '1.2.840.10008.3.1.1.1' 
    UID_details.Name = 'DICOM Application Context Name';
    UID_details.Type = 'Application Context Name';
    
    % Meta SOP Classes
case '1.2.840.10008.3.1.2.1.4' 
    UID_details.Name = 'Detached Patient Management Meta SOP Class';
    UID_details.Type = 'Meta SOP Class';
    
case '1.2.840.10008.3.1.2.5.4' 
    UID_details.Name = 'Detached Results Management Meta SOP Class';
    UID_details.Type = 'Meta SOP Class';
    
case '1.2.840.10008.3.1.2.5.5' 
    UID_details.Name = 'Detached Study Management Meta SOP Class';
    UID_details.Type = 'Meta SOP Class';
    
case '1.2.840.10008.5.1.1.9' 
    UID_details.Name = 'Basic Grayscale Print Management Meta SOP Class';
    UID_details.Type = 'Meta SOP Class';
    
case '1.2.840.10008.5.1.1.9.1' 
    UID_details.Name = 'Referenced Grayscale Print Management Meta SOP Class';
    UID_details.Type = 'Meta SOP Class';
    
case '1.2.840.10008.5.1.1.18' 
    UID_details.Name = 'Basic Color Print Management Meta SOP Class';
    UID_details.Type = 'Meta SOP Class';
    
case '1.2.840.10008.5.1.1.18.1' 
    UID_details.Name = 'Referenced Color Print Management Meta SOP Class';
    UID_details.Type = 'Meta SOP Class';
    
case '1.2.840.10008.5.1.1.32' 
    UID_details.Name = 'Pull Stored Print Management Meta SOP Class';
    UID_details.Type = 'Meta SOP Class';
    
    % Well-known Printer SOP Instance
case '1.2.840.10008.5.1.1.16.376' 
    UID_details.Name = 'Printer Configuration Retrieval SOP Class';
    UID_details.Type = 'Well-known Printer SOP Instance';
    
case '1.2.840.10008.5.1.1.17' 
    UID_details.Name = 'Printer SOP Instance';
    UID_details.Type = 'Well-known Printer SOP Instance';
    
case '1.2.840.10008.5.1.1.17.376' 
    UID_details.Name = 'Printer Configuration Retrieval SOP Instance';
    UID_details.Type = 'Well-known Printer SOP Instance';
    
    
    % Well-known Print Queue SOP Instance
case '1.2.840.10008.5.1.1.25' 
    UID_details.Name = 'Print Queue SOP Instance';
    UID_details.Type = 'Well-known Print Queue SOP Instance';
    
    
    % Transfer Syntaxes
case '1.2.840.10008.1.2' 
    UID_details.Name = 'Implicit VR Little Endian';
    UID_details.Type = 'Transfer Syntax';
    UID_details.Compressed = 0;
    UID_details.Endian = 'ieee-le';
    UID_details.PixelEndian = 'ieee-le';
    UID_details.VR = 'Implicit';
    
case '1.2.840.10008.1.2.1' 
    UID_details.Name = 'Explicit VR Little Endian';
    UID_details.Type = 'Transfer Syntax';
    UID_details.Compressed = 0;
    UID_details.Endian = 'ieee-le';
    UID_details.PixelEndian = 'ieee-le';
    UID_details.VR = 'Explicit';
    
case '1.2.840.10008.1.2.2' 
    UID_details.Name = 'Explicit VR Big Endian';
    UID_details.Type = 'Transfer Syntax';
    UID_details.Compressed = 0;
    UID_details.Endian = 'ieee-be';
    UID_details.PixelEndian = 'ieee-be';
    UID_details.VR = 'Explicit';
    
case '1.2.840.10008.1.2.4.50' 
    UID_details.Name = 'JPEG Baseline (Process 1)';
    UID_details.Type = 'Transfer Syntax';
    UID_details.Compressed = 1;
    UID_details.Endian = 'ieee-le';
    UID_details.PixelEndian = 'ieee-le';
    UID_details.VR = 'Explicit';
    
case '1.2.840.10008.1.2.4.51' 
    UID_details.Name = 'JPEG Extended (Process 2 & 4)';
    UID_details.Type = 'Transfer Syntax';
    UID_details.Compressed = 1;
    UID_details.Endian = 'ieee-le';
    UID_details.PixelEndian = 'ieee-le';
    UID_details.VR = 'Explicit';
    
case '1.2.840.10008.1.2.4.52' 
    UID_details.Name = 'JPEG Extended (Process 3 & 5)';
    UID_details.Type = 'Transfer Syntax';
    UID_details.Compressed = 1;
    UID_details.Endian = 'ieee-le';
    UID_details.PixelEndian = 'ieee-le';
    UID_details.VR = 'Explicit';
    
case '1.2.840.10008.1.2.4.53' 
    UID_details.Name = 'JPEG Spectral Selection, Non-Hierarchical (Process 6 & 8)';
    UID_details.Type = 'Transfer Syntax';
    UID_details.Compressed = 1;
    UID_details.Endian = 'ieee-le';
    UID_details.PixelEndian = 'ieee-le';
    UID_details.VR = 'Explicit';
    
case '1.2.840.10008.1.2.4.54' 
    UID_details.Name = 'JPEG Spectral Selection, Non-Hierarchical (Process 7 & 9)';
    UID_details.Type = 'Transfer Syntax';
    UID_details.Compressed = 1;
    UID_details.Endian = 'ieee-le';
    UID_details.PixelEndian = 'ieee-le';
    UID_details.VR = 'Explicit';
    
case '1.2.840.10008.1.2.4.55' 
    UID_details.Name = 'JPEG Full Progression, Non-Hierarchical (Process 10 & 12)';
    UID_details.Type = 'Transfer Syntax';
    UID_details.Compressed = 1;
    UID_details.Endian = 'ieee-le';
    UID_details.PixelEndian = 'ieee-le';
    UID_details.VR = 'Explicit';
    
case '1.2.840.10008.1.2.4.56' 
    UID_details.Name = 'JPEG Full Progression, Non-Hierarchical (Process 11 & 13)';
    UID_details.Type = 'Transfer Syntax';
    UID_details.Compressed = 1;
    UID_details.Endian = 'ieee-le';
    UID_details.PixelEndian = 'ieee-le';
    UID_details.VR = 'Explicit';
    
case '1.2.840.10008.1.2.4.57' 
    UID_details.Name = 'JPEG Lossless, Non-Hierarchical (Process 14)';
    UID_details.Type = 'Transfer Syntax';
    UID_details.Compressed = 1;
    UID_details.Endian = 'ieee-le';
    UID_details.PixelEndian = 'ieee-le';
    UID_details.VR = 'Explicit';
    
case '1.2.840.10008.1.2.4.58' 
    UID_details.Name = 'JPEG Lossless, Non-Hierarchical (Process 15)';
    UID_details.Type = 'Transfer Syntax';
    UID_details.Compressed = 1;
    UID_details.Endian = 'ieee-le';
    UID_details.PixelEndian = 'ieee-le';
    UID_details.VR = 'Explicit';
    
case '1.2.840.10008.1.2.4.59' 
    UID_details.Name = 'JPEG Extended, Hierarchical (Process 16 & 18)';
    UID_details.Type = 'Transfer Syntax';
    UID_details.Compressed = 1;
    UID_details.Endian = 'ieee-le';
    UID_details.PixelEndian = 'ieee-le';
    UID_details.VR = 'Explicit';
    
case '1.2.840.10008.1.2.4.60' 
    UID_details.Name = 'JPEG Extended, Hierarchical (Process 17 & 19)';
    UID_details.Type = 'Transfer Syntax';
    UID_details.Compressed = 1;
    UID_details.Endian = 'ieee-le';
    UID_details.PixelEndian = 'ieee-le';
    UID_details.VR = 'Explicit';
    
case '1.2.840.10008.1.2.4.61' 
    UID_details.Name = 'JPEG Spectral Selection, Hierarchical (Process 20 & 22)';
    UID_details.Type = 'Transfer Syntax';
    UID_details.Compressed = 1;
    UID_details.Endian = 'ieee-le';
    UID_details.PixelEndian = 'ieee-le';
    UID_details.VR = 'Explicit';
    
case '1.2.840.10008.1.2.4.62' 
    UID_details.Name = 'JPEG Spectral Selection, Hierarchical (Process 21 & 23)';
    UID_details.Type = 'Transfer Syntax';
    UID_details.Compressed = 1;
    UID_details.Endian = 'ieee-le';
    UID_details.PixelEndian = 'ieee-le';
    UID_details.VR = 'Explicit';
    
case '1.2.840.10008.1.2.4.63' 
    UID_details.Name = 'JPEG Full Progression, Hierarchical (Process 24 & 26)';
    UID_details.Type = 'Transfer Syntax';
    UID_details.Compressed = 1;
    UID_details.Endian = 'ieee-le';
    UID_details.PixelEndian = 'ieee-le';
    UID_details.VR = 'Explicit';
    
case '1.2.840.10008.1.2.4.64' 
    UID_details.Name = 'JPEG Full Progression, Hierarchical (Process 25 & 27)';
    UID_details.Type = 'Transfer Syntax';
    UID_details.Compressed = 1;
    UID_details.Endian = 'ieee-le';
    UID_details.PixelEndian = 'ieee-le';
    UID_details.VR = 'Explicit';
    
case '1.2.840.10008.1.2.4.65' 
    UID_details.Name = 'JPEG Lossless, Hierarchical (Process 28)';
    UID_details.Type = 'Transfer Syntax';
    UID_details.Compressed = 1;
    UID_details.Endian = 'ieee-le';
    UID_details.PixelEndian = 'ieee-le';
    UID_details.VR = 'Explicit';
    
case '1.2.840.10008.1.2.4.66' 
    UID_details.Name = 'JPEG Lossless, Hierarchical (Process 29)';
    UID_details.Type = 'Transfer Syntax';
    UID_details.Compressed = 1;
    UID_details.Endian = 'ieee-le';
    UID_details.PixelEndian = 'ieee-le';
    UID_details.VR = 'Explicit';
    
case '1.2.840.10008.1.2.4.70' 
    UID_details.Name = 'JPEG Lossless, Non-Hierarchical, First-Order Prediction (Process 14 [Selection Value 1])';
    UID_details.Type = 'Transfer Syntax';
    UID_details.Compressed = 1;
    UID_details.Endian = 'ieee-le';
    UID_details.PixelEndian = 'ieee-le';
    UID_details.VR = 'Explicit';

case '1.2.840.10008.1.2.4.80'
    UID_details.Name = 'JPEG-LS Lossless';
    UID_details.Type = 'Transfer Syntax';
    UID_details.Compressed = 1;
    UID_details.Endian = 'ieee-le';
    UID_details.PixelEndian = 'ieee-le';
    UID_details.VR = 'Explicit';
    
case '1.2.840.10008.1.2.4.81'
    UID_details.Name = 'JPEG-LS Lossy (Near-Lossless)';
    UID_details.Type = 'Transfer Syntax';
    UID_details.Compressed = 1;
    UID_details.Endian = 'ieee-le';
    UID_details.PixelEndian = 'ieee-le';
    UID_details.VR = 'Explicit';
    
case '1.2.840.10008.1.2.5' 
    UID_details.Name = 'RLE Lossless';
    UID_details.Type = 'Transfer Syntax';
    UID_details.Compressed = 1;
    UID_details.Endian = 'ieee-le';
    UID_details.PixelEndian = 'ieee-le';
    UID_details.VR = 'Explicit';
    
case '1.2.840.113619.5.2'
    UID_details.Name = 'GE Implicit VR Little Endian Except Big Endian Pixels';
    UID_details.Type = 'Transfer Syntax';
    UID_details.Compressed = 0;
    UID_details.Endian = 'ieee-le';
    UID_details.PixelEndian = 'ieee-be';
    UID_details.VR = 'Implicit';
    
otherwise
    
    UID_details.Value = '';
    
end
