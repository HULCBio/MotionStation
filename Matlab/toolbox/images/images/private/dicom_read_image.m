function [X, map, alpha, overlays, info, file] = dicom_read_image(file, info, frames)
%DICOM_READ_IMAGE  Read the image data from a DICOM file.
%   [X, MAP, ALPHA, INFO] = DICOM_READ_IMAGE(FILE, INFO, FRAMES) reads
%   the image pixels X, the colormap MAP, and transparency lookup table
%   ALPHA from FILE.  The metadata structure INFO is used as context for
%   reading the image data, and it is updated to include the list of
%   FRAMES which were read from the image.
%
%   For non-indexed images, map is empty.  For images with a Photometric
%   Interpretation value of other than "ARGB", ALPHA will be empty.
%
%   See also DICOMREAD, DICOM_READ_ENCAPSULATED, DICOM_READ_NATIVE.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.3 $  $Date: 2003/08/23 05:53:56 $


%
% Verify that file is at the beginning of (7FE0,0010) when called.
%

[group, element] = dicom_get_next_tag(file);

if ((group ~= 32736) || (element ~= 16))  % (7FE0,0010)
    
    file = dicom_close_msg(file);
    
    msg = 'DICOM_READ_IMAGE must be called at beginning of (7FE0,0010).';
    error('Images:dicom_read_image:fileLocation', msg);
    
end

%
% Verify that necessary metadata is present and correct.
%

invalid = verify_metadata(info, 'loose');

if (~isempty(invalid))
    
    file = dicom_close_msg(file);
    
    % Make a string of the invalid fields.
    fields = '';

    for p = 1:length(invalid)
        % char(9) is tab; char(10) is newline.
        fields = [fields, char(10) char(9) invalid{p}];
    end
        
    msg = sprintf('File "%s" is missing required fields:\n%s', ...
                  file.Messages{file.Current_Message}, fields(2:end));
            
    error('Images:dicom_read_image:missingFields', msg);
    
end

%
% Determine if transfer syntax is supported.
%

if (isfield(info, 'TransferSyntaxUID'))
    
    [supported, encapsulated, name] = dicom_supported_txfr_syntax(info.TransferSyntaxUID);

else
    
    % Assume Implicit VR, Little Endian.  See dicom_set_image_encoding.
    supported = 1;
    encapsulated = 0;
    name = 'Assumed syntax.';
    
end
    
if (~supported)
    
    file = dicom_close_msg(file);
    
    msg = sprintf('File "%s" contains unsupported format:\n  %s', ...
                file.Messages{file.Current_Message}, name);
    
    error('Images:dicom_read_image:format', msg);
    
end

%
% Process frame list.
%

flist = process_frame_list(file, info, frames);
info.SelectedFrames = flist;

%
% Read the pixels and overlays.
%

% Change transfer syntaxes, if necessary.
file = dicom_set_image_encoding(info, file);

if (encapsulated)
    
    [X, overlays, file] = dicom_read_encapsulated(file, info, flist);
    
else
    
    [X, overlays, file] = dicom_read_native(file, info, flist);
    
end

%
% Process Colormap.
%

map = process_colormap(info);

% Colormap will be n-by-3 array if colormap is present, empty if not an
% indexed image, and NaN if colormap should be present but is not.

if (isnan(map))
    
    file = dicom_close_msg(file);
    
    msg = sprintf('Missing colormap data in "%s".', ...
                  file.Messages{file.Current_Message});
    error('Images:dicom_read_image:missingColormap', msg)
    
end

%
% Process alpha channel.
%

if ((isfield(info, 'PhotometricInterpretation')) && ...
    (isequal(info.PhotometricInterpretation, 'ARGB')))

    % Create a container for the alpha channel.
    
    switch (class(X))
    case 'uint8'
        alpha = repmat(uint8(0), info.Height, info.Width, 1, size(X, 4));
        
    case 'uint16'
        alpha = repmat(uint16(0), info.Height, info.Width, 1, size(X, 4));
        
    case 'uint32'
        alpha = repmat(uint32(0), info.Height, info.Width, 1, size(X, 4));
        
    end        
    
    % Move alpha channel from image to alpha array.
    alpha(:,:,1,:) = X(:,:,1,:);
    X(:,:,1,:) = [];

else
    
    % No alpha channel.
    alpha = [];
    
end



%%%
%%% Function process_frame_list
%%%

function flist = process_frame_list(file, info, frames)
%PROCESS_FRAME_LIST  Create a list of frames to read

% Find number of frames.

% $$$ Doesn't consider cine runs to be mult-frame unless NumberOfFrames is
% $$$ set.
    
if (isfield(info,'NumberOfFrames'))
    
    max_frame_count = info.NumberOfFrames;
    
else
    
    % Just one image.
    max_frame_count = 1;
    
end

% Make sure all frames are in the allowed range.

if (~isequal(lower(frames), 'all'))
    
    flist = unique(frames);
    
    if ((any(flist > max_frame_count)) || (any(flist < 1)))
        
        dicom_close_msg(file);
        
        txt1 = sprintf('Frame values must be between 1 and %d:', ...
                       max_frame_count);
        txt2 = sprintf('%d ', frames);
        msg = sprintf([txt1 '\n[' txt2(1:(end-1)) '].']);
        
        error('Images:dicom_read_image:frameValue', msg);
        
    end
    
else
    
    flist = 1:max_frame_count;
    
end



%%%
%%% Function process_colormap
%%%

function map = process_colormap(info)
%PROCESS_COLORMAP  Get the colormap for indexed and ARGB images

% See PS 3.3-2000 Sec. C.7.6.3.1.5 and C.7.6.3.1.6.

if ((isfield(info, 'PhotometricInterpretation')) && ...
    ((isequal(info.PhotometricInterpretation, 'PALETTE COLOR')) || ...
     (isequal(info.PhotometricInterpretation, 'ARGB'))))
    
    % Make sure all color components are present.
    if (~isempty(verify_metadata(info, 'colormap')))
    
        map = nan;
        return

    end
    
    % Find the maximum value of the data.
    red = info.RedPaletteColorLookupTableData ./ ...
          (2 ^ info.RedPaletteColorLookupTableDescriptor(3) - 1);
    
    green = info.GreenPaletteColorLookupTableData ./ ...
          (2 ^ info.GreenPaletteColorLookupTableDescriptor(3) - 1);
    
    blue = info.BluePaletteColorLookupTableData ./ ...
          (2 ^ info.BluePaletteColorLookupTableDescriptor(3) - 1);
    
    % Construct colormap from constituent colors.
    map = [red green blue];
    
else
    
    map = [];
    
end



%%%
%%% Function verify_metadata
%%%

function missing = verify_metadata(info, level)
%VERIFY_METADATA  Make sure that all necessary metadata is present

% PS 3.3-2000 Table C.7-9 gives all of the required Image Pixel Module
% attributes.  Technically we should fail if any Type 1 and required Type
% 1C attributes are missing.  We are going to be more permissive in
% general.
% 
% Setting "level" to 'strict' checks Type 1 and 1C fields.
% Setting "level" to 'colormap' checks Type 1C colormap fields only.

required_fields = {'Rows'
                   'Columns'
                   'BitsAllocated'
                   'BitsStored'
                   'HighBit'};

type1_fields = {'SamplesPerPixel'
                'PhotometricInterpretation'
                'PixelRepresentation'};

map_fields = {'RedPaletteColorLookupTableDescriptor'
              'GreenPaletteColorLookupTableDescriptor'
              'BluePaletteColorLookupTableDescriptor'
              'RedPaletteColorLookupTableData'
              'GreenPaletteColorLookupTableData'
              'BluePaletteColorLookupTableData'};
    
missing = struct([]);
count = 0;

% Look for must-have fields.  Don't check if just verifying colormap.
if (~isequal(level, 'colormap'))

    for p = 1:length(required_fields)
        
        if (~isfield(info, required_fields{p}))
            
            count = count + 1;
            missing{count} = required_fields{p};
            
        end
        
    end
    
end


if (isequal(level, 'loose'))
    return
end


% Look for other Type 1 fields.
if (isequal(level, 'strict'))
    
    for p = 1:length(type1_fields)
    
        if (~isfield(info, type1_fields{p}))
            
            count = count + 1;
            missing{count} = type1_fields{p};
            
        end
        
    end
    
    % Type 1C fields.
    
    if (((isfield(info, 'SamplesPerPixel')) && ...
         (info.SamplesPerPixel > 1)) && ...
        (~isfield(info, 'PlanarConfiguration')))
        
        count = count + 1;
        missing{count} = 'PlanarConfiguration';
        
    end

end

% Colormap fields (Type 1c)

if ((isequal(level, 'strict')) || (isequal(level, 'colormap')))
    
    if ((isfield(info, 'PhotometricInterpretation')) && ...
        (ismember(info.PhotometricInterpretation, ...
                  {'ARGB', 'PALETTE COLOR'})))
        
        miss_map = ismember(map_fields, fieldnames(info));
        
        for p = find(miss_map' == 0)
            
            count = count + 1;
            missing{count} = map_fields{p};
            
        end
        
    end
    
end
    

