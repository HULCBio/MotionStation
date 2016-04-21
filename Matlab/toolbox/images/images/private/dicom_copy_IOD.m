function [all_attrs, msg, status] = dicom_copy_IOD(X, map, metadata, options)
%DICOM_COPY_IOD  Copy attribtes from metadata to an arbitrary IOD.
%   [ATTRS, MSG, STATUS] = DICOM_COPY_IOD(X, MAP, METADATA, OPTIONS) creates
%   a structure array of DICOM attributes for an arbitrary SOP class
%   corresponding to the class contained in the metadata structure.  The
%   value of image pixel attributes are derived from the image X and the
%   colormap MAP.  Non-image attributes are derived from the METADATA
%   struct (typically given by DICOMINFO) and the transfer syntax UID
%   (OPTIONS.txfr).
%
%   NOTE: This routine does not verify that attributes in METADATA belong
%   in the information object.  A risk exists that invalid data passed to
%   this routine will lead to formally correct DICOM files that contain
%   incomplete or nonsensical data.
%
%   See also: DICOMWRITE, DICOM_CREATE_IOD.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/01 16:12:00 $

all_attrs = [];
msg = '';
status = [];

% A field containing the SOP Class UID is necessary for writing.
MediaStorageUID_name = dicom_name_lookup('0002', '0002');
SOPClassUID_name = dicom_name_lookup('0008', '0016');

if (isfield(metadata, MediaStorageUID_name))
    
    IOD_UID = metadata.(MediaStorageUID_name);
    
elseif (isfield(metadata, SOPClassUID_name))
    
    IOD_UID = metadata.(SOPClassUID_name);
    
else
    
    eid = 'Images:dicom_copy_IOD:missingSOPClassUID';
    msg = sprintf('Missing required attribute (0008,0016) "%s"', ...
                  SOPClassUID_name);
    error(eid, '%s', msg);
    
end

% Update the instance-specific and required metadata.
metadata = dicom_prep_SOPCommon(metadata, IOD_UID);
metadata = dicom_prep_FileMetadata(metadata, IOD_UID, options.txfr);
metadata = dicom_prep_ImagePixel(metadata, X, map, options.txfr);

% Get the metadata fields that need to be processed.
metadata_fields = fieldnames(metadata);
fields_to_write = remove_dicominfo_fields(metadata_fields);

% Process all of the remaining metadata
for p = 1:numel(fields_to_write)
    
    attr_name = fields_to_write{p};
    new_attr = dicom_convert_meta_to_attr(attr_name, metadata);
    all_attrs = cat(2, all_attrs, new_attr);
    
end



function fields_out = remove_dicominfo_fields(metadata_fields)
%REMOVE_DICOMINFO_FIELDS  Strip DICOMINFO-specific fields from metadata.

dicominfo_fields = get_dicominfo_fields;
fields_out = setdiff(metadata_fields, dicominfo_fields);



function fields = get_dicominfo_fields
%GET_DICOMINFO_FIELDS  Get a cell array of field names specific to DICOMINFO.

fields = {'Filename'
          'FileModDate'
          'FileSize'
          'Format'
          'FormatVersion'
          'Width'
          'Height'
          'BitDepth'
          'ColorType'
          'SelectedFrames'
          'FileStruct'
          'StartOfPixelData'};
