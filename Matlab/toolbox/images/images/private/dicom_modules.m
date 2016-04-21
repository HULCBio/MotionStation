function module_details = dicom_modules(module_name)
%DICOM_MODULES  Repository of DICOM module attributes and details.
%   DETAILS = DICOM_MODULES(NAME) returns a structure array of details
%   about the module NAME.  DETAILS is a structure with fields
%
%   - Name      The module's name.
%   - SpecPart  Where this module is defined in the DICOM spec.
%   - Attrs     The attributes that define a module.  A cell array with
%               the following meanings attributed to the columns:
%
%     (1) Depth in the module.  Nonzero indicates a sequence.
%     (2) Group
%     (3) Element
%     (4) Attribute type (see PS 3.3 Sec. 5.4)
%     (5) Enumerated values.  If this is present, an attribute's value
%         must be one or more of the items in the cell array (or empty if
%         type 2 or 2C).
%     (6) LISP-like condition if type 1C or 2C.
%  
%   See also DICOM_IODS, dicom-dict.txt.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision $  $Date $

switch (module_name)
case 'FileMetadata'
    module_details = build_FileMetadata;
case 'Patient'
    module_details = build_Patient;
case 'GeneralStudy'
    module_details = build_GeneralStudy;
case 'PatientStudy'
    module_details = build_PatientStudy;
case 'GeneralSeries'
    module_details = build_GeneralSeries;
case 'FrameOfReference'
    module_details = build_FrameOfReference;
case 'GeneralEquipment'
    module_details = build_GeneralEquipment;
case 'GeneralImage'
    module_details = build_GeneralImage;
case 'ImagePlane'
    module_details = build_ImagePlane;
case 'ImagePixel'
    module_details = build_ImagePixel;
case 'ContrastBolus'
    module_details = build_ContrastBolus;
case 'MRImage'
    module_details = build_MRImage;
case 'CTImage'
    module_details = build_CTImage;
case 'OverlayPlane'
    module_details = build_OverlayPlane;
case 'VOILUT'
    module_details = build_VOILUT;
case 'SOPCommon'
    module_details = build_SOPCommon;
case 'SCImageEquipment'
    module_details = build_SCImageEquipment;
case 'SCImage'
    module_details = build_SCImage;
otherwise
    module_details = [];
end



function details = build_FileMetadata

details.Name = 'FileMetadata';
details.SpecPart = 'PS 3.10 Sec. 7.1';
details.Attrs = {
        0, '0002', '0001', '1',  {}, {uint8([0 1])}, {}
        0, '0002', '0002', '1',  {}, {}, {}
        0, '0002', '0003', '1',  {}, {}, {}
        0, '0002', '0010', '1',  {}, {}, {}
        0, '0002', '0012', '1',  {}, {}, {}
        0, '0002', '0013', '3',  {}, {}, {}
        0, '0002', '0016', '3',  {}, {}, {}
        0, '0002', '0100', '3',  {}, {}, {}
        0, '0002', '0102', '1C', {}, {}, {'present', '(0002,0100)'}
        };


function details = build_Patient

details.Name = 'Patient';
details.SpecPart = 'PS 3.3 Sec. C.7.1.1';
details.Attrs = {
        0, '0010', '0010', '2',  {}, {}, {}
        0, '0010', '0020', '2',  {}, {}, {}
        0, '0010', '0030', '2',  {}, {}, {}
        0, '0010', '0040', '2',  {}, {'M' 'F' '0'}, {}
        0, '0008', '1120', '3',  {}, {}, {}
        1, '0008', '1150', '1C', {}, {}, {'present', '(0008,1120)'}
        1, '0008', '1155', '1C', {}, {}, {'present', '(0008,1120)'}
        0, '0010', '0032', '3',  {}, {}, {}
        0, '0010', '1000', '3',  {}, {}, {}
        0, '0010', '1001', '3',  {}, {}, {}
        0, '0010', '2160', '3',  {}, {}, {}
        0, '0010', '4000', '3',  {}, {}, {}
        };
       

function details = build_GeneralStudy

details.Name = 'GeneralStudy';
details.SpecPart = 'PS 3.3 Sec. C.7.2.1';
details.Attrs = {
        0, '0020', '000D', '1',  {}, {}, {}
        0, '0008', '0020', '2',  {}, {}, {}
        0, '0008', '0030', '2',  {}, {}, {}
        0, '0008', '0090', '2',  {}, {}, {}
        0, '0020', '0010', '2',  {}, {}, {}
        0, '0008', '0050', '2',  {}, {}, {}
        0, '0008', '1030', '3',  {}, {}, {}
        0, '0008', '1048', '3',  {}, {}, {}
        0, '0008', '1060', '3',  {}, {}, {}
        0, '0008', '1110', '3',  {}, {}, {}
        1, '0008', '1150', '1C', {}, {}, {'present', '(0008,1110)'}
        1, '0008', '1155', '1C', {}, {}, {'present', '(0008,1110)'}
        0, '0008', '1032', '3',  {}, {}, {}
%        0, % Code sequence macro "No baseline context."
        };


function details = build_PatientStudy

details.Name = 'PatientStudy';
details.SpecPart = 'PS 3.3 Sec. C.7.2.2';
details.Attrs = {
        0, '0008', '1080', '3',  {}, {}, {}
        0, '0010', '1010', '3',  {}, {}, {}
        0, '0010', '1020', '3',  {}, {}, {}
        0, '0010', '1030', '3',  {}, {}, {}
        0, '0010', '2180', '3',  {}, {}, {}
        0, '0010', '21B0', '3',  {}, {}, {}
        };


function details = build_GeneralSeries

details.Name = 'GeneralSeries';
details.SpecPart = 'PS 3.3 Sec. C.7.3.1';
details.Attrs = {
        0, '0008', '0060', '1',  {}, modalityTerms, {}
        0, '0020', '000E', '1',  {}, {}, {}
        0, '0020', '0011', '2',  {}, {}, {}
        0, '0020', '0060', '2C', {}, {'L', 'R'}, {'not', ...
                 {'present', '(0020,0060)'}}
        0, '0008', '0021', '3',  {}, {}, {}
        0, '0008', '0031', '3',  {}, {}, {}
        0, '0008', '1050', '3',  {}, {}, {}
        0, '0018', '1030', '3',  {}, {}, {}
        0, '0008', '103E', '3',  {}, {}, {}
        0, '0008', '1070', '3',  {}, {}, {}
        0, '0008', '1111', '3',  {}, {}, {}
        1, '0008', '1150', '1C', {}, {}, {'present', '(0008,1111)'}
        1, '0008', '1155', '1C', {}, {}, {'present', '(0008,1111)'}
        0, '0018', '0015', '3',  {}, bodyPartTerms, {}
        0, '0018', '5100', '2C', {}, patientPositionTerms, {'or', ...
                 {'equal', '(0008,0016)', '1.2.840.10008.5.1.4.1.1.4'} ...
                 {'equal', '(0008,0016)', '1.2.840.10008.5.1.4.1.1.2'}}
        0, '0028', '0108', '3',  {}, {}, {}
        0, '0028', '0109', '3',  {}, {}, {}
        0, '0040', '0275', '3',  {}, {}, {}
        1, '0040', '1001', '1C', {}, {}, {'present', '(0040,0275)'}
        1, '0040', '0009', '1C', {}, {}, {'present', '(0040,0275)'}
        1, '0040', '0007', '3',  {}, {}, {}
        1, '0040', '0008', '3',  {}, {}, {}
%        1, % Code sequence macro "No baseline context."
        0, '0040', '0253', '3',  {}, {}, {}
        0, '0040', '0244', '3',  {}, {}, {}
        0, '0040', '0245', '3',  {}, {}, {}
        0, '0040', '0254', '3',  {}, {}, {}
        0, '0040', '0260', '3',  {}, {}, {}
%        0, % Code sequence macro "No baseline context."
        };


function details = build_FrameOfReference

details.Name = 'FrameOfReference';
details.SpecPart = 'PS 3.3 Sec. C.7.4.1';
details.Attrs = {
        0, '0020', '0052', '1',  {}, {}, {}
        0, '0020', '1040', '2',  {}, {}, {}
        };


function details = build_GeneralEquipment

details.Name = 'GeneralEquipment';
details.SpecPart = 'PS 3.3 Sec. C.7.5.1';
details.Attrs = {
        0, '0008', '0070', '2',  {}, {}, {}
        0, '0008', '0080', '3',  {}, {}, {}
        0, '0008', '0081', '3',  {}, {}, {}
        0, '0008', '1010', '3',  {}, {}, {}
        0, '0008', '1040', '3',  {}, {}, {}
        0, '0008', '1090', '3',  {}, {}, {}
        0, '0018', '1000', '3',  {}, {}, {}
        0, '0018', '1020', '3',  {}, {}, {}
        0, '0018', '1050', '3',  {}, {}, {}
        0, '0018', '1200', '3',  {}, {}, {}
        0, '0018', '1201', '3',  {}, {}, {}
        0, '0028', '0120', '3',  {'(0028,0103)', {0, 'US'}, {1, 'SS'}}, {}, {}
        };


function details = build_GeneralImage

details.Name = 'GeneralImage';
details.SpecPart = 'PS 3.3 Sec. C.7.6.1';
details.Attrs = {
        0, '0020', '0013', '2',  {}, {}, {}
        0, '0020', '0020', '2C', {}, {}, {'or', {'not', {'present', '(0020,0037)'}} ...
                                            {'not', {'present', '(0020,0032)'}}}
        0, '0008', '0023', '2C', {}, {}, {'true'}
        0, '0008', '0033', '2C', {}, {}, {'true'}
        0, '0008', '0008', '3',  {}, {}, {}
        0, '0020', '0012', '3',  {}, {}, {}
        0, '0008', '0022', '3',  {}, {}, {}
        0, '0008', '0032', '3',  {}, {}, {}
        0, '0008', '002A', '3',  {}, {}, {}
        0, '0008', '1140', '3',  {}, {}, {}
        1, '0008', '1150', '1C', {}, {}, {'present', '(0008,1140)'}
        1, '0008', '1155', '1C', {}, {}, {'present', '(0008,1140)'}
        1, '0008', '1160', '3',  {}, {}, {}
        0, '0008', '2111', '3',  {}, {}, {}
        0, '0008', '2112', '3',  {}, {}, {}
        1, '0008', '1150', '1C', {}, {}, {'present', '(0008,2112)'}
        1, '0008', '1155', '1C', {}, {}, {'present', '(0008,2112)'}
        1, '0008', '1160', '3',  {}, {}, {}
        0, '0020', '1002', '3',  {}, {}, {}
        0, '0020', '4000', '3',  {}, {}, {}
        0, '0028', '0300', '3',  {}, {'YES' 'NO'}, {}
        0, '0028', '0301', '3',  {}, {'YES' 'NO'}, {}
        0, '0028', '2110', '3',  {}, {0 1}, {}
        0, '0028', '2112', '3',  {}, {}, {}
        };


function details = build_ImagePlane

details.Name = 'ImagePlane';
details.SpecPart = 'PS 3.3 Sec. C.7.6.2';
details.Attrs = {
        0, '0028', '0030', '1',  {}, {}, {}
        0, '0020', '0037', '1',  {}, {}, {}
        0, '0020', '0032', '1',  {}, {}, {}
        0, '0018', '0050', '2',  {}, {}, {}
        0, '0020', '1041', '3',  {}, {}, {}
        };


function details = build_ImagePixel

details.Name = 'ImagePixel';
details.SpecPart = 'PS 3.3 Sec. C.7.6.3';
details.Attrs = {
        0, '0028', '0002', '1',  {}, {}, {}
        0, '0028', '0004', '1',  {}, {}, {}
        0, '0028', '0010', '1',  {}, {}, {}
        0, '0028', '0011', '1',  {}, {}, {}
        0, '0028', '0100', '1',  {}, {}, {}
        0, '0028', '0101', '1',  {}, {}, {}
        0, '0028', '0102', '1',  {}, {}, {}
        0, '0028', '0103', '1',  {}, {0 1}, {}
        0, '7FE0', '0010', '1',  {}, {}, {}
        0, '0028', '0006', '1C', {}, {}, {'not', {'equal', '(0028,0002)', 1}}
        0, '0028', '0034', '1C', {}, {}, {'present', '(0028,0034)'}
        0, '0028', '0106', '3',  {'(0028,0103)', {0, 'US'}, {1, 'SS'}}, {}, {}
        0, '0028', '0107', '3',  {'(0028,0103)', {0, 'US'}, {1, 'SS'}}, {}, {}
        0, '0028', '1101', '1C', {'(0028,0103)', {0, 'US'}, {1, 'SS'}}, {}, ...
                 {'or', ...
                    {'equal', '(0028,0004)', 'PALETTE COLOR'} ...
                    {'equal', '(0028,0004)', 'ARGB'}}
        0, '0028', '1102', '1C', {'(0028,0103)', {0, 'US'}, {1, 'SS'}}, {}, ...
                 {'or', ...
                    {'equal', '(0028,0004)', 'PALETTE COLOR'} ...
                    {'equal', '(0028,0004)', 'ARGB'}}
        0, '0028', '1103', '1C', {'(0028,0103)', {0, 'US'}, {1, 'SS'}}, {}, ...
                 {'or', ...
                    {'equal', '(0028,0004)', 'PALETTE COLOR'} ...
                    {'equal', '(0028,0004)', 'ARGB'}}
        0, '0028', '1201', '1C', {}, {}, {'or', ...
                    {'equal', '(0028,0004)', 'PALETTE COLOR'} ...
                    {'equal', '(0028,0004)', 'ARGB'}}
        0, '0028', '1202', '1C', {}, {}, {'or', ...
                    {'equal', '(0028,0004)', 'PALETTE COLOR'} ...
                    {'equal', '(0028,0004)', 'ARGB'}}
        0, '0028', '1203', '1C', {}, {}, {'or', ...
                    {'equal', '(0028,0004)', 'PALETTE COLOR'} ...
                    {'equal', '(0028,0004)', 'ARGB'}}
        };


function details = build_ContrastBolus

details.Name = 'ContrastBolus';
details.SpecPart = 'PS 3.3 Sec. C.7.6.4';
details.Attrs = {
        0, '0018', '0010', '2',  {}, {}, {}
        0, '0018', '0012', '3',  {}, {}, {}
%        1, % Code sequence macro "Baseline context id is 12"
        0, '0018', '1040', '3',  {}, {}, {}
        0, '0018', '0014', '3',  {}, {}, {}
%        1, % Code sequence macro "Baseline context id is 11"
        1, '0018', '002A', '3',  {}, {}, {}
%        2, % Code sequence macro "No baseline context."
        0, '0018', '1041', '3',  {}, {}, {}
        0, '0018', '1042', '3',  {}, {}, {}
        0, '0018', '1043', '3',  {}, {}, {}
        0, '0018', '1044', '3',  {}, {}, {}
        0, '0018', '1046', '3',  {}, {}, {}
        0, '0018', '1047', '3',  {}, {}, {}
        0, '0018', '1048', '3',  {}, {'IODINE'
                                  'GADOLINIUM'
                                  'CARBON DIOXIDE'
                                  'BARIUM'}, {}
        0, '0018', '1049', '3',  {}, {}, {}
        };


function details = build_MRImage

details.Name = 'MRImage';
details.SpecPart = 'PS 3.3 Sec. C.8.3.1';
details.Attrs = {
        0, '0008', '0008', '1',  {}, {}, {}
        0, '0028', '0002', '1',  {}, {1}, {}
        0, '0028', '0004', '1',  {}, {'MONOCHROME1' 'MONOCHROME2'}, {}
        0, '0028', '0100', '1',  {}, {16}, {}
        0, '0018', '0020', '1',  {}, {'SE' 'IR' 'GR' 'EP' 'RM'}, {}
        0, '0018', '0021', '1',  {}, {'SK' 'MTC' 'SS' 'TRSS' 'SP' ...
                                  'MP' 'OSP' 'NONE'}, {}
        0, '0018', '0022', '1',  {}, {'PER' 'RG' 'CG' 'PPG' 'FC' ...
                                  'PFF' 'PFP' 'SP' 'FS'}, {}
        0, '0018', '0023', '1',  {}, {'2D' '3D'}, {}
        0, '0018', '0080', '2C', {}, {}, {'not', {'and', ...
                                        {'equal', '(0018,0020)', 'EP'}, ...
                                        {'equal', '(0018,0021)', 'SK'}}}
        0, '0018', '0081', '2',  {}, {}, {}
        0, '0018', '0091', '2',  {}, {}, {}
        0, '0018', '0082', '2C', {}, {}, {'equal', '(0018,0020)', 'IR'}
        0, '0018', '1060', '2C', {}, {}, {'or', ...
                                        {'equal', '(0018,0022)', 'RG'}, ...
                                        {'equal', '(0018,0022)', 'CG'}, ...
                                        {'equal', '(0018,0022)', 'PPG'}}
        0, '0018', '0024', '3',  {}, {}, {}
        0, '0018', '0025', '3',  {}, {'Y' 'N'}, {}
        0, '0018', '0083', '3',  {}, {}, {}
        0, '0018', '0084', '3',  {}, {}, {}
        0, '0018', '0085', '3',  {}, {}, {}
        0, '0018', '0086', '3',  {}, {}, {}
        0, '0018', '0087', '3',  {}, {}, {}
        0, '0018', '0088', '3',  {}, {}, {}
        0, '0018', '0089', '3',  {}, {}, {}
        0, '0018', '0093', '3',  {}, {}, {}
        0, '0018', '0094', '3',  {}, {}, {}
        0, '0018', '0095', '3',  {}, {}, {}
        0, '0018', '1062', '3',  {}, {}, {}
        0, '0018', '1080', '3',  {}, {'Y' 'N'}, {}
        0, '0018', '1081', '3',  {}, {}, {}
        0, '0018', '1082', '3',  {}, {}, {}
        0, '0018', '1083', '3',  {}, {}, {}
        0, '0018', '1084', '3',  {}, {}, {}
        0, '0018', '1085', '3',  {}, {}, {}
        0, '0018', '1086', '3',  {}, {}, {}
        0, '0018', '1088', '3',  {}, {}, {}
        0, '0018', '1090', '3',  {}, {}, {}
        0, '0018', '1094', '3',  {}, {}, {}
        0, '0018', '1100', '3',  {}, {}, {}
        0, '0018', '1250', '3',  {}, {}, {}
        0, '0018', '1251', '3',  {}, {}, {}
        0, '0018', '1310', '3',  {}, {}, {}
        0, '0018', '1312', '3',  {}, {}, {}
        0, '0018', '1314', '3',  {}, {}, {}
        0, '0018', '1316', '3',  {}, {}, {}
        0, '0018', '1315', '3',  {}, {'Y' 'N'}, {}
        0, '0018', '1318', '3',  {}, {}, {}
        0, '0020', '0100', '3',  {}, {}, {}
        0, '0020', '0105', '3',  {}, {}, {}
        0, '0020', '0110', '3',  {}, {}, {}
        };



function details = build_OverlayPlane

details.Name = 'OverlayPlane';
details.SpecPart = 'PS 3.3 Sec. C.9.2';
details.Attrs = {
        0, '60XX', '0010', '1',  {}, {}, {}
        0, '60XX', '0011', '1',  {}, {}, {}
        0, '60XX', '0040', '1',  {}, {'G' 'R'}, {}
        0, '60XX', '0050', '1',  {}, {}, {}
        0, '60XX', '0100', '1',  {}, {1}, {}
        0, '60XX', '0102', '1',  {}, {0}, {}
        0, '60XX', '3000', '1C', {}, {}, {'equal', '(60XX,0100)', 1}
        0, '60XX', '0022', '3',  {}, {}, {}
        0, '60XX', '0045', '3',  {}, {'USER' 'AUTOMATED'}, {}
        0, '60XX', '1500', '3',  {}, {}, {}
        0, '60XX', '1301', '3',  {}, {}, {}
        0, '60XX', '1302', '3',  {}, {}, {}
        0, '60XX', '1303', '3',  {}, {}, {}
        };


function details = build_VOILUT

details.Name = 'VOILUT';
details.SpecPart = 'PS 3.3 Sec. C.11.2';
details.Attrs = {
        0, '0028', '3010', '3',  {}, {}, {}
        1, '0028', '3002', '1C', {}, {}, {'present', '(0028,3010)'}
        1, '0028', '3003', '3',  {}, {}, {}
        1, '0028', '3006', '1C', {}, {}, {'present', '(0028,3010)'}
        0, '0028', '1050', '3',  {}, {}, {}
        0, '0028', '1051', '1C', {}, {}, {'present', '(0028,1050)'}
        };


function details = build_SOPCommon

details.Name = 'SOPCommon';
details.SpecPart = 'PS 3.3 Sec. C.12.1';
details.Attrs = {
        0, '0008', '0016', '1',  {}, {}, {}
        0, '0008', '0018', '1',  {}, {}, {}
        0, '0008', '0005', '1C', {}, {}, {'false'}  % No extended charsets.
        0, '0008', '0012', '3',  {}, {}, {}
        0, '0008', '0013', '3',  {}, {}, {}
        0, '0008', '0014', '3',  {}, {}, {}
        0, '0008', '0201', '3',  {}, {}, {}
        0, '0020', '0013', '3',  {}, {}, {}
        0, '0100', '0410', '3',  {}, {'NS' 'OR' 'AO' 'AC'}, {}
        0, '0100', '0420', '3',  {}, {}, {}
        0, '0100', '0424', '3',  {}, {}, {}
        0, '0100', '0426', '3',  {}, {}, {}
        };


function details = build_CTImage

details.Name = 'CTImage';
details.SpecPart = 'PS 3.3 Sec. C.8.2.1';
details.Attrs = {
        0, '0008', '0008', '1',  {}, {}, {}
        0, '0028', '0002', '1',  {}, {1}, {}
        0, '0028', '0004', '1',  {}, {'MONOCHROME1' 'MONOCHROME2'}, {}
        0, '0028', '0100', '1',  {}, {16}, {}
        0, '0028', '0101', '1',  {}, {16}, {}
        0, '0028', '0102', '1',  {}, {15}, {}
        0, '0028', '1052', '1',  {}, {}, {}
        0, '0028', '1053', '1',  {}, {}, {}
        0, '0018', '0060', '2',  {}, {}, {}
        0, '0020', '0012', '2',  {}, {}, {}
        0, '0018', '0022', '3',  {}, {}, {}
        0, '0018', '0090', '3',  {}, {}, {}
        0, '0018', '1100', '3',  {}, {}, {}
        0, '0018', '1110', '3',  {}, {}, {}
        0, '0018', '1111', '3',  {}, {}, {}
        0, '0018', '1120', '3',  {}, {}, {}
        0, '0018', '1130', '3',  {}, {}, {}
        0, '0018', '1140', '3',  {}, {'CW', 'CC'}, {}
        0, '0018', '1150', '3',  {}, {}, {}
        0, '0018', '1151', '3',  {}, {}, {}
        0, '0018', '1152', '3',  {}, {}, {}
        0, '0018', '1153', '3',  {}, {}, {}
        0, '0018', '1160', '3',  {}, {}, {}
        0, '0018', '1170', '3',  {}, {}, {}
        0, '0018', '1190', '3',  {}, {}, {}
        0, '0018', '1210', '3',  {}, {}, {}
        };



function details = build_SCImageEquipment

details.Name = 'SCImageEquipment';
details.SpecPart = 'PS 3.3 Sec. C.8.6.1';
details.Attrs = {
        0, '0008', '0064', '1',  {}, conversionTerms, {}
        0, '0008', '0060', '3',  {}, modalityTerms, {}
        0, '0018', '1010', '3',  {}, {}, {}
        0, '0018', '1016', '3',  {}, {}, {}
        0, '0018', '1018', '3',  {}, {}, {}
        0, '0018', '1019', '3',  {}, {}, {}
        0, '0018', '1022', '3',  {}, {}, {}
        0, '0018', '1023', '3',  {}, {}, {}
        };



function details = build_SCImage

details.Name = 'SCImage';
details.SpecPart = 'PS 3.3 Sec. C.8.6.2';
details.Attrs = {
        0, '0018', '1012', '3',  {}, {}, {}
        0, '0018', '1014', '3',  {}, {}, {}
        };



function terms = modalityTerms
%MODALITYDEFINEDTERMS   Modality defined terms
%
%   See PS 3.3 Sec. C.7.3.1.1.1

terms = {'CR', 'MR', 'US', 'BI', 'DD', 'ES', 'MA', 'PT', 'ST', 'XA', ...
         'RTIMAGE', 'RTSTRUCT', 'RTRECORD', 'DX', 'IO', 'GM', 'XC', 'AU', ...
         'EPS', 'SR', 'CT', 'NM', 'OT', 'CD', 'DG', 'LS', 'MS', 'RG', 'TG', ...
         'RF', 'RTDOSE', 'RTPLAN', 'HC', 'MG', 'PX', 'SM', 'PR', 'ECG', ...
         'HD'};



function terms = bodyPartTerms
%BODYPARTTERMS  Body part defined terms
%
%   See PS 3.3 Sec. C.7.3.1

terms = {'SKULL', 'CSPINE', 'TSPINE', 'LSPINE', 'SSPINE', 'COCCYX', 'CHEST', ...
         'CLAVICLE', 'BREAST', 'ABDOMEN', 'PELVIS', 'HIP', 'SHOULDER', ...
         'ELBOX', 'KNEE', 'ANKLE', 'HAND', 'FOOT', 'EXTREMITY', 'HEAD', ...
         'HEART', 'NECK', 'LEG', 'ARM', 'JAW'};



function terms = patientPositionTerms
%PATIENTPOSITIONTERMS  Patient position defined terms
%
%   See PS 3.3 Sec. C.7.3.1.1.2

terms = {'HFP', 'HFS', 'HFDR', 'HFDL', 'FFDR', 'FFDL', 'FFP', 'FFS'};



function terms = conversionTerms
%CONVERSIONTERMS  Secondary Capture conversion type defined terms
%
%   See PS 3.3 Sec. C.8.6.1

terms = {'DV', 'DI', 'DF', 'WSD', 'SD', 'SI', 'DRW', 'SYN'};
