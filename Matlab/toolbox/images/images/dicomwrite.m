function varargout = dicomwrite(X, varargin)
%DICOMWRITE   Write images as DICOM files.
%   DICOMWRITE(X, FILENAME) writes the binary, grayscale, or truecolor
%   image X to the file named in FILENAME.
%
%   DICOMWRITE(X, MAP, FILENAME) writes the indexed image X with colormap
%   MAP.
%
%   DICOMWRITE(..., PARAM1, VALUE1, PARAM2, VALUE2, ...) specifies
%   optional metadata to write to the DICOM file or parameters that
%   affect how the DICOM file is written.  PARAM1 is a string containing
%   the metadata attribute name or a DICOMWRITE-specific option.  VALUE1
%   is the corresponding value for the attribute or option.
%
%   Acceptable attribute names are listed in the data dictionary
%   dicom-dict.txt.  In addition, the following DICOM-specific options
%   are allowed:
%
%     'Endian'           The byte-ordering for the file: 'Big' or
%                        'Little' (default).  
%
%     'VR'               Whether the value representation should be
%                        written to the file: 'Explicit' or 'Implicit'
%                        (default). 
%
%     'CompressionMode'  The type of compression to use when storing the
%                        image: 'JPEG lossless', 'JPEG lossy', 'RLE', or
%                        'None' (default).
%
%     'TransferSyntax'   A DICOM UID specifying the Endian and VR mode.
%
%     'Dictionary'       DICOM data dictionary containing private data
%                        attributes.
%
%     'WritePrivate'     Logical value whether private data should be
%                        written to the file: true or false (default).
%
%     'CreateMode'       The method for creating the data to put in the
%                        new file. 'Create' (default) verifies input
%                        values and makes missing data values. 'Copy'
%                        simply copies all values from the input and does
%                        not generate missing values. 
%
%   Note: By default, DICOMWRITE will create files encoded with implicit
%   VR, little-endian byte-ordering, and no compression.  If one or more
%   of the options listed above are provided, DICOMWRITE will override
%   the default behavior.  If the TransferSyntax parameter is provided,
%   it is the only value that is used.  Otherwise, the CompressionMode
%   parameter is used, if present.  Finally, the VR and Endian parameters
%   are used.  Specifying an Endian value of 'Big' and a VR value of
%   'Implicit' is not allowed.
%
%   DICOMWRITE(..., 'ObjectType', IOD, ...) writes a file containing the
%   necessary metadata for a particular type of DICOM Information Object
%   (IOD).  Supported IODs are:
%
%     'Secondary Capture Image Storage' (default)
%     'CT Image Storage'
%     'MR Image Storage'
%
%   DICOMWRITE(..., 'SOPClassUID', UID, ...) provides an alternate method
%   for specifying the IOD to create.  UID is the DICOM unique identifier
%   corresponding to one of the IODs listed above.
%
%   DICOMWRITE(..., META_STRUCT, ...) specifies optional metadata or
%   options for the file via a structure.  The structure's fieldnames are
%   analogous to the parameter strings in the syntax shown above, and a
%   field's value is that parameter's value.
%
%   DICOMWRITE(..., INFO, ...) uses the metadata structure INFO produced
%   by DICOMINFO.
%
%   STATUS = DICOMWRITE(...) returns information about the metadata and
%   the descriptions used to generate the DICOM file.  STATUS is a
%   structure with the following fields:
%
%     'BadAttribute'      The attribute's internal description is bad.
%                         It may be missing from the data dictionary or
%                         have incorrect data in its description.
%
%     'MissingCondition'  The attribute is conditional but no condition
%                         has been provided about when to use it.
%
%     'MissingData'       No data was provided for an attribute that must
%                         appear in the file.
%
%     'SuspectAttribute'  Data in the attribute does not match a list of
%                         enumerated values in the DICOM spec.
%
%
%   Examples
%   --------
%
%   % Write a basic "secondary capture" image.
%   X = dicomread('CT-MONO2-16-ankle.dcm');
%   dicomwrite(X, 'sc_file.dcm');
%
%   % Write a CT image with metadata.
%   metadata = dicominfo('CT-MONO2-16-ankle.dcm');
%   dicomwrite(X, 'ct_file.dcm', metadata);
%
%   % Copy all metadata from one file to another.
%   dicomwrite(X, 'ct_copy.dcm', metadata, 'CreateMode', 'copy');
%
%
%   See also  DICOMDICT, DICOMINFO, DICOMREAD.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.4 $  $Date: 2003/08/23 05:52:15 $


%
% Parse input arguments. 
%

if (nargin < 2)
    eid = 'Images:dicomwrite:tooFewInputs';
    error(eid, '%s', 'At least two input arguments required.')
elseif (nargout > 1)
    eid = 'Images:dicomwrite:tooManyOutputs';
    error(eid, '%s', 'Too many output arguments.')
end

[filename, map, metadata, options] = parse_inputs(varargin{:});


%
% Register SOP classes, dictionary etc.
%

dicomdict('set_current', options.dictionary);


%
% Write the DICOM file.
%

try
    
    status = write_message(X, filename, map, metadata, options);

    if (nargout == 1)
        varargout{1} = status;
    end
    
catch
    
    dicomdict('reset_current');
    rethrow(lasterror)
    
end

dicomdict('reset_current');



function varargout = write_message(X, filename, map, metadata, options)
%WRITE_MESSAGES  Write the DICOM message.

%
% Abstract syntax negotiation.
% (SOP class and transfer syntax)
%

if (isequal(options.createmode, 'create'))
    SOP_UID = determine_IOD(options, metadata);
end
options.txfr = determine_txfr_syntax(options, metadata);


%
% Construct, encode, and write SOP instance.
%

num_frames = size(X, 4);
for p = 1:num_frames
    
    % Construct the SOP instance's IOD.
    if (isequal(options.createmode, 'create'))
        
        [attrs, msg, status] = dicom_create_IOD(SOP_UID, X(:,:,:,p), map, ...
                                                metadata, options);
        
    elseif (isequal(options.createmode, 'copy'))
        
        [attrs, msg, status] = dicom_copy_IOD(X(:,:,:,p), map, ...
                                              metadata, options);
        
    else
        
        eid = 'Images:dicomwrite:badCreateMode';
        error(eid, '%s', 'Unsupported value for CreateMode');
        
    end
    
    if (~isempty(msg))
        eid = 'Images:dicomwrite:iodCreationError';
        error(eid, '%s', msg);
    end
    
    attrs = sort_attrs(attrs);
    attrs = remove_duplicates(attrs);
    
    % Encode the attributes.
    data_stream = dicom_encode_attrs(attrs, options.txfr);
    
    % Write the SOP instance.
    destination = get_filename(filename, p, num_frames);
    msg = write_stream(destination, data_stream);
    if (~isempty(msg))
        eid = 'Images:dicomwrite:streamWritingError';
        error(eid, '%s', msg);
    end
    
end

varargout{1} = status;



function [filename, map, metadata, options] = parse_inputs(varargin)
%PARSE_INPUTS   Obtain filename, colormap, and metadata values from input.

map = [];
metadata = struct([]);
options.writeprivate = false;  % Don't write private data by default.
options.createmode = 'create';  % Create/verify data by default.
options.dictionary = dicomdict('get_current');

% Filename and colormap.
if (ischar(varargin{1}))
    
    filename = varargin{1};
    current_arg = 2;
    
elseif (isnumeric(varargin{1}))
    
    map = varargin{1};
    
    if ((nargin > 1) && (ischar(varargin{2})))
        filename = varargin{2};
    else
        eid = 'Images:dicomwrite:filenameMustBeString';
        msg = 'Filename must be a string.';
        error(eid, '%s', msg);
    end
    
    current_arg = 3;
    
else
    
    % varargin{1} is second argument to DICOMWRITE.
    eid = 'Images:dicomwrite:expectedFilenameOrColormap';
    msg = 'Second argument must be a filename or colormap.';
    error(eid, '%s', msg);
    
end

% Process metadata.
if (current_arg > nargin)
    return
end

% Structures containing multiple values can occur anywhere in the
% metadata information as long as they don't split a parameter-value
% pair.  Any number of structures can appear.

dicomwrite_fields = {'colorspace'
                     'vr'
                     'endian'
                     'compressionmode'
                     'transfersyntax'
                     'objecttype'
                     'sopclassuid'
                     'dictionary'
                     'writeprivate'
                     'createmode'};

total_args  = nargin;

while (current_arg <= total_args)

    if (ischar(varargin{current_arg}))
        
        % Parameter-value pair.
        
        if (current_arg == total_args)

            eid = 'Images:dicomwrite:missingValue';
            msg = sprintf('Parameter %s must have an associated value.', ...
                          varargin{current_arg});
            error(eid, '%s', msg);
            
        else

            param = varargin{current_arg};
            idx = find(strcmp(lower(param), dicomwrite_fields));
            
            if (numel(idx) > 1)
                eid = 'Images:dicomwrite:ambiguousParameter';
                error(eid, 'Ambiguous parameter "%s" specified.', param);
            end
            
            if (~isempty(idx))

                % It's a DICOMWRITE field.
                
                if (isequal(dicomwrite_fields{idx}, 'transfersyntax'))
                    
                    % Store TransferSyntax in both options and metadata.
                    metadata(1).TransferSyntax = varargin{current_arg + 1};
                    options(1).(dicomwrite_fields{idx}) = ...
                        varargin{current_arg + 1};
                    
                else
                    
                    options(1).(dicomwrite_fields{idx}) = ...
                        varargin{current_arg + 1};
                    
                end
                
            else
                
                metadata(1).(param) = varargin{current_arg + 1};
                
            end
            
        end
        
        current_arg = current_arg + 2;
        
    elseif (isstruct(varargin{current_arg}))
        
        % Structure of parameters and values.
        
        str = varargin{current_arg};
        fields = fieldnames(str);
        
        for p = 1:numel(fields)
            
            param = fields{p};
            idx = find(strcmp(lower(param), dicomwrite_fields));
            
            if (numel(idx) > 1)
                eid = 'Images:dicomwrite:ambiguousParameter';
                error(eid, 'Ambiguous parameter "%s" specified.', param);
            end
            
            if (~isempty(idx))

                % It's a DICOMWRITE field.
                
                if (isequal(dicomwrite_fields{idx}, 'transfersyntax'))
                
                    % Store TransferSyntax in both options and metadata.
                    options(1).(dicomwrite_fields{idx}) = str.(param);
                    metadata(1).TransferSyntax = str.(param);
                    
                else
                    
                    options(1).(dicomwrite_fields{idx}) = str.(param);
                    
                end
                
            else
                
                metadata(1).(param) = str.(param);
                
            end
            
        end
        
        current_arg = current_arg + 1;
        
    else
        
        eid = 'Images:dicomwrite:expectedFilenameOrColormapOrMetadata';
        msg = 'Argument must be filename, colormap, or metadata parameter.';
        error(eid, '%s', msg);
        
    end

end



function SOP_UID = determine_IOD(options, metadata)
%DETERMINE_IOD   Pick the DICOM information object to create.
  
if (isfield(options, 'objecttype'))
  
    switch (lower(options.objecttype))
    case 'ct image storage'
      
        SOP_UID = '1.2.840.10008.5.1.4.1.1.2';

    case 'mr image storage'
      
        SOP_UID = '1.2.840.10008.5.1.4.1.1.4';
     
    case 'secondary capture image storage'
      
        SOP_UID = '1.2.840.10008.5.1.4.1.1.7';
        
    otherwise
        
        eid = 'Images:dicomwrite:unsupportedObjectType';
        error(eid, 'Unsupported ObjectType ("%s")', options.objecttype);
     
    end
    
elseif (isfield(options, 'sopclassuid'))

    SOP_UID = options.sopclassuid;
    
elseif (isfield(metadata, 'SOPClassUID'))

    SOP_UID = metadata.SOPClassUID;
  
elseif ((isfield(metadata, 'Modality')) && (isequal(metadata.Modality, 'CT')))
      
    SOP_UID = '1.2.840.10008.5.1.4.1.1.2';
    
elseif ((isfield(metadata, 'Modality')) && (isequal(metadata.Modality, 'MR')))
      
    SOP_UID = '1.2.840.10008.5.1.4.1.1.4';
    
else
  
    % Create SC Storage objects by default.
    SOP_UID = '1.2.840.10008.5.1.4.1.1.7';
    
end



function txfr = determine_txfr_syntax(options, metadata)
%DETERMINE_TXFR_SYNTAX   Find the transfer syntax from user-provided options.
%
% The rules for determining transfer syntax are followed in this order:
%
% (1) Use the command line option 'TransferSyntax'.
%
% (2) Use the command line option 'CompressionMode'.
%
% (3) Use a combination of the command line options 'VR' and 'Endian'.
%
% (4) Use the metadata's 'TransferSyntaxUID' field.
%
% (5) Use the default implicit VR, little-endian transfer syntax.


% Rule (1): 'TransferSyntax' option.
if (isfield(options, 'transfersyntax'))
    
    txfr = options.transfersyntax;
    return
    
end

% Rule (2): 'CompressionMode' option.
if (isfield(options, 'compressionmode'))
    
    switch (lower(options.compressionmode))
    case 'none'
        
        % Pick transfer syntax below.
        
    case 'rle'
        
        txfr = '1.2.840.10008.1.2.5';
        return
    
    case 'jpeg lossless'
        
        txfr = '1.2.840.10008.1.2.4.70';
        return
        
    case 'jpeg lossy'

        txfr = '1.2.840.10008.1.2.4.50';
        return
    
    otherwise
        
        eid = 'Images:dicomwrite:unrecognizedCompressionMode';
        error(eid, 'Unrecognized compression mode (%s).', options.compressionmode);
        
    end
    
end

% Handle rules (3), (4), and (5) together.
if ((isfield(options, 'vr')) || (isfield(options, 'endian')))
    
    override_txfr = true;
    
else
    
    override_txfr = false;
    
end

if (~isfield(options, 'vr'))
    options(1).vr = 'implicit';
end

    
if (~isfield(options, 'endian'))
    options(1).endian = 'ieee-le';
end
        
switch (options.vr)
case 'explicit'
    
    switch (lower(options.endian))
    case 'ieee-be'
        txfr = '1.2.840.10008.1.2.2';
    case 'ieee-le'
        txfr = '1.2.840.10008.1.2.1';
    otherwise
        eid = 'Images:dicomwrite:invalidEndianValue';
        error(eid, '%s', 'Endian value must be ''ieee-be'' or ''ieee-le''.');
    end
    
case 'implicit'
    
    switch (lower(options.endian))
    case 'ieee-be'
        eid = 'Images:dicomwrite:invalidVREndianCombination';
        error(eid, '%s', 'Implicit VR and ieee-be endian is an invalid combination.')
    case 'ieee-le'
        txfr = '1.2.840.10008.1.2';
    otherwise
        eid = 'Images:dicomwrite:invalidEndianValue';        
        error(eid, '%s', 'Endian value must be ''ieee-be'' or ''ieee-le''.');
    end

end

if (override_txfr)
    
    % Rule (3): 'VR' and/or 'Endian' options provided.
    return
    
else
    
    if (isfield(metadata, 'TransferSyntaxUID'))
        
        % Rule (4): 'TransferSyntaxUID' metadata field.
        txfr = metadata.TransferSyntaxUID;
        return
        
    else
        
        % Rule (5): Default transfer syntax.
        return
        
    end
    
end



function out = sort_attrs(in)
%SORT_ATTRS   Sort the attributes by group and element.

attr_pairs = [[in(:).Group]', [in(:).Element]'];
[tmp, idx_elt] = sort(attr_pairs(:, 2));
[tmp, idx_grp] = sort(attr_pairs(idx_elt, 1));

out = in(idx_elt(idx_grp));



function out = remove_duplicates(in)
%REMOVE_DUPLICATES   Remove duplicate attributes.
  
attr_pairs = [[in(:).Group]', [in(:).Element]'];
delta = sum(abs(diff(attr_pairs, 1)), 2);

out = [in(1), in(find(delta ~= 0) + 1)];



function status = write_stream(destination, data_stream)
%WRITE_STREAM   Write an encoded data stream to the output device.

% NOTE: Currently local only.
file = dicom_create_file_struct;
file.Location = 'Local';
file.Messages = {destination};
    
file = dicom_open_msg(file, 'w');
    
[file, status] = dicom_write_stream(file, data_stream);

dicom_close_msg(file);



function filename = get_filename(file_base, frame_number, max_frame)
%GET_FILENAME   Create the filename for this frame.

if (max_frame == 1)
    filename = file_base;
    return
end

% Create the file number.
num_length = ceil(log10(max_frame + 1));
format_string = sprintf('%%0%dd', num_length);
number_string = sprintf(format_string, frame_number);

% Look for an extension.
idx = strfind(file_base, '.');

if (~isempty(idx))
    
    base = file_base(1:(idx - 1));
    ext  = file_base(idx:end);  % Includes '.'
    
else
    
    base = file_base;
    ext  = '';
    
end

% Put it all together.
filename = sprintf('%s_%s%s', base, number_string, ext);
