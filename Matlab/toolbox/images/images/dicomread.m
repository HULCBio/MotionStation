function [X, map, alpha, overlays] = dicomread(msgname, varargin)
%DICOMREAD  Read a DICOM image.
%   X = DICOMREAD(FILENAME) reads the image data from the compliant DICOM
%   file FILENAME.  For single-frame grayscale images, X is an M-by-N
%   array.  For single-frame true-color images, X is an M-by-N-by-3 array.
%   Multiframe images are always 4-D arrays.
%
%   X = DICOMREAD(INFO) reads the image data from the message referenced
%   in the DICOM metadata structure INFO.  The INFO structure is produced
%   by the DICOMINFO function.
%
%   [X, MAP] = DICOMREAD(...) returns the colormap MAP for the image X.  If
%   X is a grayscale or true-color image, MAP is empty.
%
%   [X, MAP, ALPHA] = DICOMREAD(...) returns an alpha channel matrix for X.
%   The values of ALPHA are 0 if the pixel is opaque; otherwise they are row
%   indices into MAP.  The RGB value in MAP should be substituted for the
%   value in X to use ALPHA.  ALPHA has the same height and width as X and
%   is 4-D for a multiframe image.
%
%   [X, MAP, ALPHA, OVERLAYS] = DICOMREAD(...) also returns any overlays
%   from the DICOM file.  Each overlay is a 1-bit black and white image with
%   the same height and width as X.  If multiple overlays are present in the
%   file, OVERLAYS is a 4-D multiframe image.  If no overlays are in the
%   file, OVERLAYS is empty.
%
%   The first input argument, either FILENAME or INFO, can be followed by
%   a set of parameter name/value pairs:
%
%       [...] = DICOMREAD(FILENAME,PARAM1,VALUE1,PARAM2,VALUE2,...)
%       [...] = DICOMREAD(INFO,PARAM1,VALUE1,PARAM2,VALUE2,...)
%
%   Supported parameters names and values include:
%
%       'Frames', V        DICOMREAD reads only the frames in the vector
%                          V from the image.  V must be an integer
%                          scalar, a vector of integers, or the string
%                          'all'.  The default value is 'all'.
%
%       'Dictionary', D    DICOMREAD uses the data dictionary file
%                          whose filename is in the string D.  The
%                          default value is given by DICOMDICT.
%
%       'Raw', TF          DICOMREAD performs pixel-level
%                          transformations depending on whether TF is 1
%                          or 0.  If TF is 1 (the default), DICOMREAD
%                          reads the exact pixels from the image and no
%                          pixel-level transformations are performed.  If
%                          TF is 0, images are rescaled to use the full
%                          dynamic range, and color images are
%                          automatically converted to the RGB
%                          colorspace.
%
%                          Note 1: Because the HSV colorspace is
%                          inadequately defined in the DICOM standard,
%                          DICOMREAD does not automatically convert them
%                          to RGB.
%
%                          Note 2: DICOMREAD never rescales or changes
%                          the color spaces of images containing signed
%                          data.
%
%                          Note 3: Rescaling values and applying
%                          colorspace conversions does not change the
%                          metadata in any way.  Consequently, metadata
%                          values that refer to pixel values (such as
%                          window center/width or LUTs) may not be
%                          correct when pixels are scaled or converted.
%
%   Examples
%   --------
%   Use DICOMREAD to retrieve the data array, X, and colormap matrix,
%   MAP, needed to create a montage.
%
%      [X, map] = dicomread('US-PAL-8-10x-echo.dcm');
%      montage(X, map);
%
%   Call DICOMREAD with the information retrieved from the DICOM file
%   using DICOMINFO.  Display the image with IMVIEW using its autoscaling
%   syntax.
%
%      info = dicominfo('CT-MONO2-16-ankle.dcm');
%      Y = dicomread(info);
%      imview(Y,[]);
%
%   Class support
%   -------------
%   X can be uint8, int8, uint16, or int16.  MAP will be double.  ALPHA
%   has the same size and type as X.  OVERLAYS is a logical array.
%
%   See also DICOMINFO, DICOMWRITE, DICOMDICT.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.8.4.8 $  $Date: 2004/04/01 16:11:56 $


% This function (along with DICOMINFO) implements the M-READ service.


if (nargin < 1)
    
    eid = 'Images:dicomread:tooFewInputs';
    error(eid, '%s', 'DICOMREAD requires at least one argument.')
    
end

args = parse_inputs(varargin{:});
dicomdict('set_current', args.Dictionary);

try
    
    [X, map, alpha, overlays] = read_messages(args, msgname, varargin{:});

catch

    dicomdict('reset_current');
    rethrow(lasterror)
    
end

dicomdict('reset_current');



function [X, map, alpha, overlays] = read_messages(args, msgname, varargin)
%READ_MESSAGES  Read the DICOM messages.

% Determine what to do based on message / info structure.

if (isstruct(msgname))

    %
    % Use output from DICOMINFO.
    %
    
    % Only handle single message structs.
    if (length(msgname) > 1)

        eid = 'Images:dicomread:nonscalarMessageStruct';
        error(eid, '%s', 'Info structure must contain only one message''s metadata.');
        
    end
    
    % Make sure it is a DICOM info struct.
    if ((~isfield(msgname, 'Format')) || ...
        ((~isequal(msgname.Format, 'DICOM')) && ...
         (~isequal(msgname.Format, 'ACR/NEMA'))))
        
        eid = 'Images:dicomread:invalidFirstInput';
        error(eid, '%s', 'First argument must be a file name or DICOM info structure.');

    end
    
    % Use previous message.
    file = msgname.FileStruct;

    % This takes the place of DICOM_GET_MSG.
    file.Messages = {file.Messages{file.Current_Message}};
    file.Current_Message = 0;
    
    % Reset number of warnings.
    file = dicom_warn('reset', file);

else
    
    %
    % Create File structure with uninitialized values.
    %
    
    file = dicom_create_file_struct;
    
    file.Messages = msgname;
    file.Location = args.Location;
    
    % Reset number of warnings.
    file = dicom_warn('reset', file);

    %
    % Get message to read.
    %
    
    file = dicom_get_msg(file);
    
    if (isempty(file.Messages))

        if (isequal(file.Location, 'Local'))
            msg = sprintf('File "%s" not found.', msgname);
        else
            msg = 'Query returned no matches.';
        end
        
        eid = 'Images:dicomread:noFileOrMessageFound';
        error(eid, '%s', msg)
        
    end

end  % isstruct.

numMessages = numel(file.Messages);

% Create containers for the output.
X = cell(1, numMessages);
info = cell(1, numMessages);
map = cell(1, numMessages);
alpha = cell(1, numMessages);
overlays = cell(1, numMessages);

%
% Read the metadata and image data for each message.
%

for p = 1:numMessages
    
    %
    % Open the message.
    %

    file = dicom_open_msg(file, 'r');
    
    %
    % Acquire metadata.
    %
    
    if (isstruct(msgname))
    
        % Use metadata from input argument.
        info{p} = msgname;
        
        % Move forward to beginning of pixel data.
        if (isequal(file.Location, 'Local'))

            fseek(file.FID, info{p}.StartOfPixelData, 'bof');
            
        end
        
        % Set encoding to reflect state of last read.
        file.Current_Endian = msgname.FileStruct.Current_Endian;
        file.Pixel_Endian = msgname.FileStruct.Pixel_Endian;
        
    else

        % Create container for metadata.
        info{p} = dicom_create_meta_struct(file);
        
        % Find the location of the required tags and the transfer
        % syntax.  After this step we'll be at the pixel data or EOF.
        [tags, pos, info{p}, file] = dicom_get_tags(file, info{p});
        fpos = ftell(file.FID);
        
        % Image tags (0028,xxxx).
        idx_1 = find(tags(:,1) == 40);
        
        % Overlay attributes (60xx,xxxx)
        idx_2 = find(((tags(:,1) >= 24576) + ...
                              (tags(:,1) <  24832)) == 2);
        
        image_attrs = [idx_1; idx_2];
        
        if (image_attrs(end) == (image_attrs(end-1)))
            image_attrs(end) = [];
        end
        
        for q = 1:length(image_attrs)
            
            idx = image_attrs(q);
            
            [info{p}, file] = dicom_read_attr_by_pos(file, ...
                                                pos(idx), ...
                                                info{p});
            
        end
        
        info{p} = dicom_set_imfinfo_values(info{p}, file);
        
        % Go to the beginning of the pixel data or EOF.
        fseek(file.FID, fpos, 'bof');
        
    end
        
    %
    % Extract the image data.
    %
    
    % Don't try to read past the end of the file.  Unfortunately, FEOF
    % doesn't register EOF until after you've driven off the end of the
    % highway.

    % See if we're at EOF.
    fread(file.FID, 1, 'uint8');
    
    if (feof(file.FID))
        
        % No image data present.
        X{p} = [];
        map{p} = [];
        alpha{p} = [];
        overlays{p} = logical([]);
        
    else
        
        % Rewind last read byte.
        fseek(file.FID, -1, 'cof');
        
        % Extract image data.
        [X{p} map{p} alpha{p} overlays{p} info{p} file] = dicom_read_image(file, ...
                                                  info{p}, ...
                                                  args.Frames);
    
    end
    
    %
    % Close the message.
    %
    
    file = dicom_close_msg(file);
    
    %
    % Apply transformations.
    %
    
    if (~isempty(X{p}))
        [X{p}, file] = dicom_xform_image(X{p}, info{p}, args.Raw, file);
    end
    
    %
    % Remove unwanted frames from native images.
    %
    
    if ((~isempty(X{p})) && (size(X{p}, 4) ~= length(info{p}.SelectedFrames)))

        % Native image.  Extra frames have not been removed yet.
        all_frames = 1:(info{p}.NumberOfFrames);
        
        % Find frames which are to be tossed.
        toss = setdiff(all_frames, info{p}.SelectedFrames);
        
        % Remove frames.
        if (~isempty(toss))
            X{p}(:,:,:,toss) = [];
        end
        
    end
    
    %
    % Store the overlays.
    %
    
    % Look for overlays in pixel cells (which are now in overlays{p}).
    if (isempty(overlays{p}))
        
        % Extraneous dimensions always have size >= 1.
        % Explicitly set it to 0.
        num_overlaycells = 0;
        
    else
        
        num_overlaycells = size(overlays{p}, 4);
        
    end
    
    % Look for overlays stored in metadata.
    fields = fieldnames(info{p});
    ol_data_fields = strmatch('OverlayData', fields);

    num_overlaydata = length(ol_data_fields);
    
    % Store the metadata overlays with the pixel cell overlays.
    if (num_overlaydata > 0)
        
        % Pad out the overlay array to accomodate all overlays.
        overlays{p}(info{p}.Height, info{p}.Width, 1, ...
                    (num_overlaydata + num_overlaycells)) = false;

        % Put each overlay in the output array.
        count = num_overlaycells;

        for q = ol_data_fields'

            plane = info{p}.(fields{q});
            
            if (~isempty(plane))
                
                count = count + 1;
                overlays{p}(:,:,:,count) = plane;
                
            end
            
        end
        
        % Remove unfilled overlay frames.
        if ((num_overlaycells + num_overlaydata) ~= count)
           
            overlays{p}(:,:,:,((count+1):end)) = [];
            
        end
        
    end

    % Collapse a 4-D empty array to 2-D for consistency.  This only
    % happens when the DICOM file contains bogus overlay data.
    if (isempty(overlays{p}))
        overlays{p} = [];
    end
    
end  % For each message.



% Remove from cell arrays if only one message.
if (file.Current_Message == 1)
    
    if (~isempty(X))
        
        X = X{1};
        map = map{1};
        alpha = alpha{1};
        overlays = overlays{1};
        
    end
    
    info = info{1};
    
end


%%%
%%% Function parse_inputs
%%%
function args = parse_inputs(varargin)

% Set default values
args.Frames = 'all';
args.Dictionary = dicomdict('get_current');
args.Raw = 1;

% Determine if messages are local or network.
% Currently only local messages are supported.
args.Location = 'Local';

% Parse arguments based on their number.
if (nargin > 1)
    
    paramStrings = {'frames'
                    'dictionary'
                    'raw'};
    
    % For each pair
    for k = 1:2:length(varargin)
       param = lower(varargin{k});
       
            
       if (~ischar(param))
           eid = 'Images:dicomread:parameterNameNotString';
           msg = 'Parameter name must be a string';
           error(eid, '%s', msg);
       end

       idx = strmatch(param, paramStrings);
       
       if (isempty(idx))
           eid = 'Images:dicomread:unrecognizedParameterName';
           msg = sprintf('Unrecognized parameter name "%s"', param);
           error(eid, '%s', msg);
       elseif (length(idx) > 1)
           eid = 'Images:dicomread:ambiguousParameterName';
           msg = sprintf('Ambiguous parameter name "%s"', param);
           error(eid, '%s', msg);
       end
    
       switch (paramStrings{idx})
       case 'dictionary'

           if (k == length(varargin))
               eid = 'Images:dicomread:missingDictionary';
               msg = 'No data dictionary specified.';
               error(eid, '%s', msg);
           else
               args.Dictionary = varargin{k + 1};
           end

       case 'frames'

           if (k == length(varargin))
               eid = 'Images:dicomread:missingFrames';
               msg = 'No frames specified.';
               error(eid, '%s', msg);
           else
               frames = varargin{k + 1};
           end
           
           if (((~ischar(frames)) && (~isa(frames, 'double'))) || ...
               (length(frames) ~= numel(frames)) || ...
               ((ischar(frames)) && (~isequal(lower(frames), 'all'))) || ...
               ((isa(frames, 'double')) && (any(rem(frames, 1)))))
               
               eid = 'Images:dicomread:badFrameParameter';
               msg = 'Frames must be a vector of integers or ''All''';
               error(eid, '%s', msg);
               
           else
               
               args.Frames = frames;
               
           end
           
       case 'raw'
           args.Raw = varargin{k + 1};
           
       end  % switch
       
    end  % for
           
end
