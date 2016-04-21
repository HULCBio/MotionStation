function [X,map] = readgif(filename, varargin)
%READGIF Read an image from a GIF file.
%   [X,MAP] = READGIF(FILENAME) reads the first image from the
%   specified file.
%
%   [X,MAP] = READGIF(FILENAME, F, ...) reads just the frames in
%   FILENAME spacified by the integer vector F.
%
%   [X,MAP] = READGIF(..., 'Frames', F) reads just the specified
%   frames from the file.  F can be an integer scalar, a vector of
%   integers, or 'all'.
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 03:01:09 $

if (~usejava('mwt'))
    
    error('MATLAB:readgif:noJava', 'READGIF requires a Java Virtual Machine.');
    
end


if (nargin < 1)
    
    error('MATLAB:readgif:tooFewInputs', 'Too few inputs.');
    
elseif (nargin > 1)

    % Validate additional parameters.
    [params, msg] = parse_parameters(varargin{:});
    
    if (~isempty(msg))
        error('MATLAB:readgif:inputArguments', '%s', msg)
    end

    % If desired frame == 1.  Call this function again with only 1 input.
    if ((nargin <= 3) && (isequal(params.Frames, 1)))
        
        [X, map] = readgif(filename);
        return
        
    end
    
end


if (nargin == 1)
    
    % Do the reading in Java
    g = com.mathworks.util.GIFObject(filename);
    
    % Import the data from the Java object.  The "byte" data is returned as
    % INT8 and needs the negative values to be augmented appropriately.
    data = double(g.getPixels);
    data(data < 0) = data(data < 0) + 256;
    X = uint8(data);
    
    X = reshape(X,g.getWidth,g.getHeight)';
    map = double(g.getColorMap)./255;

else
    
    % Get colormap from Java.
    g = com.mathworks.util.GIFObject(filename);
    map = double(g.getColorMap)./255;
    
    % Get the pixels.
    [X, msg] = split_gif(filename);
    
    if (~isempty(msg))
        error('MATLAB:readgif:splitMultiframe', '%s', msg)
    end
    
    % Remove unwanted frames.
    if (~isequal(params.Frames, 'all'))
        
        if ((any(params.Frames < 1)) || (any(params.Frames > size(X, 4))))
            
            error('MATLAB:readgif:frameCount', ...
                  'Frames must be in the range 1 to %d.', ...
                  size(X,4));
            
        end
            
        X = X(:, :, :, params.Frames);
        
    end
    
end



%%%
%%% Function split_gif
%%%

function [X,msg] = split_gif(filename)
%SPLIT_GIF  Load all frames from a multiframe GIF.

% IMPORTANT NOTE:
% ---------------
% Java's GIF reader incorrectly imports frames where the top
% of the region and the top of the frame don't coincide.  In
% all cases, the first row of the region appears in the first
% row of the frame.  Other rows are loaded correctly.
%
% As of Java 1.4, this problem was fixed for disposal method 1
% but not for other methods.

msg = '';

% Treat frames as independent, by default.
disposal_method = 0;
transparent_color = 0;
base_frame = 0;
X = uint8([]);


%
% Open multiframe file.
%

[fid_read, m] = fopen(filename, 'r', 'ieee-le');
if (fid_read == -1)
    msg = m;
    return;
end


%
% Read in the Header, Logical Screen Descriptor, and (if present) the
% Global Color Table.  This will be the same for all subfiles.
%
preamble_data = read_preamble(fid_read);


%
% Generate subfiles for each frame.
%

tmpfile_base = tempname;
tmpfile_names = {};
subfile_no = 0;

separator = fread(fid_read,1,'uint8');

while (separator ~= 59)  % 59 == EOS indicator.
    
    % Subfiles contain
    %
    %   (1) preamble from above,
    %   (2) any extensions which preceed the next image block,
    %   (3) one or more image blocks,
    %   (4) Trailing end-of-stream byte (59).
    
    subfile_no = subfile_no + 1;
    
    % Keep track of beginning of current image's extensions/data.
    pos_data_begin = ftell(fid_read) - 1;

    more_data = 1;
    seen_image_data = 0;

    % Process a group of extensions/data.
    while (more_data && ~feof(fid_read))
    
        if (separator == 33)  % Extension.
            
            blockLabel = fread(fid_read,1,'uint8');
            
            switch (blockLabel)
            case 249  % Graphics Control Extension
                
                fseek(fid_read, 1, 'cof');
                
                packed_info = fread(fid_read, 1, 'uint8');
                transparent_flag = bitget(packed_info, 1);
                disposal_method = sum(bitget(packed_info, 3:5) .* [1 2 4]);
                
                if (transparent_flag)
                    
                    fseek(fid_read, 2, 'cof');
                    transparent_color = fread(fid_read, 1, 'uint8');
                    fseek(fid_read, 1, 'cof');
                    
                else
                    
                    transparent_color = [];
                    fseek(fid_read, 4, 'cof');
                    
                end
                
                
            case 1  % Plain Text Extension
                
                fseek(fid_read,13,'cof');
                countByte = fread(fid_read,1,'uint8');
                
                while (countByte ~=0)
                    fseek(fid_read,countByte+1,'cof');
                    countByte = fread(fid_read,1,'uint8');
                end
                
            case 255 % Application Extension
                
                fseek(fid_read,12,'cof');
                countByte = fread(fid_read,1,'uint8');
                
                while (countByte ~= 0)
                    fseek(fid_read,countByte,'cof');
                    countByte = fread(fid_read,1,'uint8');
                end
                
            case 254 % Comment Extension
                
                fread(fid_read,1);
                letter = fread(fid_read,1);
                
                while (letter ~= 0)
                    letter = fread(fid_read,1);
                end
                
            otherwise
                
                msg = 'Corrupt GIF file';
                fclose(fid_read);
                return;
                
            end
            
        elseif (separator == 44)  % Local Image Descriptor and Color Table.
            
            % Image Descriptor.
            LocalID = fread(fid_read, 4, 'uint16');
            region_left   = LocalID(1);
            region_top    = LocalID(2);
            region_width  = LocalID(3);
            region_height = LocalID(4);
            
            % Local Color Table.
            LocalPacked = fread(fid_read, 1, 'uint8');
            fseek(fid_read, 1, 'cof');
            LCTbool = (bitget(LocalPacked,8) == 1);

            if (LCTbool)
                
                Localbitdepth = bitget(LocalPacked, 1:3);
                Localbitdepth = sum(Localbitdepth .* [1 2 4]) + 1; 
                fseek(fid_read, (3 * bitshift(1, Localbitdepth)), 'cof');
                
            end

            % Image data follows Local data.
            num_bytes = fread(fid_read, 1, 'uint8');
            
            while (num_bytes ~= 0)
                
                % Set seen_image_data inside loop, just in case no image
                % data is present.
                seen_image_data = 1;
                
                fseek(fid_read, num_bytes, 'cof');
                num_bytes = fread(fid_read, 1, 'uint8');
                
            end
            
            more_data = 0;
            
        elseif (separator == 59)  % EOF marker.
            
            more_data = 0;
            
        else

            msg = 'Corrupt GIF file';
            return
            
        end  % if (separator == value)
        
        separator = fread(fid_read, 1, 'uint8');
        
    end  % while (more_data)


    %
    % Write the temporary file.
    %

    % Don't do anything if there was no image data.
    if (~seen_image_data)
        continue;
    end
    
    % Open output file.
    tmp_file = [tmpfile_base '_' sprintf('%03d', subfile_no) '.gif'];
    tmpfile_names{subfile_no} = tmp_file;

    [fid_write, m] = fopen(tmp_file, 'w', 'ieee-le');

    if (fid_write == -1)
        
        fclose(fid_read);
        msg = m;
        return;
        
    end

    % Rewind to beginning of data.
    pos_data_end = ftell(fid_read) - 1;
    fseek(fid_read, pos_data_begin, 'bof');
    
    % Write preamble, data, and EOF marker.
    fwrite(fid_write, preamble_data, 'uint8');
    fwrite(fid_write, ...
           fread(fid_read, (pos_data_end - pos_data_begin), ...
                 'uint8=>uint8'), ...
           'uint8');
    fwrite(fid_write, 59, 'uint8');
    
    % Close output file.
    fclose(fid_write);

    % Move input file pointer past separator.
    fseek(fid_read, 1, 'cof');

    
    %
    % Determine current frame's appearance based on disposal method.
    %
    % Disposal methods:
    %
    % 0 - Unspecified: Replace previous frame's region with this frame's
    %     region.
    %
    % 1 - Do Not Dispose: Previous frame shows through transparent
    %     pixels.
    %
    % 2 - Restore to Background: transparent color shows through
    %     transparent pixels.
    %
    % 4 - Restore to Previous: Revert to last "Do Not Dispose" or
    %     "Unspecified" then apply new frame, displaying "previous"
    %     through transparent pixels.
    %
    % Pixels which are outside of the frame's region are not affected.
    %
    
    % Get region's row and column indices.
    region_left   = region_left + 1;  % (0,0) is upper left.
    region_top    = region_top + 1;   % (0,0) is upper left.
    region_right  = region_left + region_width - 1;
    region_bottom = region_top  + region_height - 1;
    
    switch (disposal_method)
    case {2}
        
        % Previous pixels don't show through transparent pixels.

        if (base_frame < 1)
            
            % First frames don't dispose any pixels.

            tmp = readgif(tmp_file);
            
            % Fix Java bug.
            if (disposal_method ~= 1)
                tmp = swap_top(tmp, region_top, region_left, region_right);
            end
                
            X(:, :, :, subfile_no) = tmp;
            
        else
            
            tmp_1 = readgif(tmp_file);
            tmp_2 = X(:, :, :, (subfile_no - 1));
            
            % Fix Java bug.
            tmp_1 = swap_top(tmp_1, region_top, region_left, region_right);
            
            % Replace the previous frame's region with the new region.
            tmp_2(region_top:region_bottom, region_left:region_right) = ...
                tmp_1(region_top:region_bottom, region_left:region_right);
            
            X(:, :, :, subfile_no) = tmp_2;
            
        end    
        
        base_frame = subfile_no;
        
    case {0, 1, 4}
        
        % Previous/base image pixels show through transparent pixels.
        % Technically, disposal mode 0 shouldn't use transparency
        % settings, but most rederers and writers don't make this
        % distinction.
        
        if (base_frame < 1)

            % First frame might be "Do Not Dispose," though no previous
            % frame exists.

            tmp = readgif(tmp_file);
            
            % Fix Java bug.
            if (disposal_method ~= 1)
                tmp = swap_top(tmp, region_top, region_left, region_right);
            end

            X(:, :, :, subfile_no) = tmp;

            base_frame = subfile_no;
            
        else
            
            tmp_1 = readgif(tmp_file);
            tmp_2 = X(:, :, :, base_frame);
            
            % Fix Java bug.
            if (disposal_method ~= 1)
                tmp_1 = swap_top(tmp_1, region_top, region_left, region_right);
            end
            
            % Find transparent pixels.  For Simplicity, use the whole
            % frame.  
            if (~isempty(transparent_color))
                
                transparent_pixels = find(tmp_1 == transparent_color);
                
                % Replace transparent pixels from new frame with pixels
                % from old frame.
                tmp_1(transparent_pixels) = tmp_2(transparent_pixels);
                
            end
            
            tmp_2(region_top:region_bottom, region_left:region_right) = ...
                tmp_1(region_top:region_bottom, region_left:region_right);
            
            X(:, :, :, subfile_no) = tmp_2;
            
            % Set the current to be the base if "Do Not Dispose."
            if (disposal_method ~= 4)
                base_frame = subfile_no;
            end
            
        end
        
    end  % switch(disposal_method)

end  % while (separator ~= 59)

    
%
% Delete temporary files.
%

for p = 1:length(tmpfile_names)
    
    try
        
        delete(tmpfile_names{p});
        
    catch
        
        warning('MATLAB:readgif:deleteTempFile', ...
                'Could not delete temporary file "%s".', tmpfile_names{p})
        
    end
    
end

fclose(fid_read);



%%%
%%% Function read_preamble
%%%

function preamble_data = read_preamble(fid)
%READ_PREAMBLE  Read the GIF preamble for later use.

% Beginning of standard GIF preamble.
pos_begin = ftell(fid);

fseek(fid, 6, 'cof');  % GIF header.
fseek(fid, 4, 'cof');  % Screen size.

% Logical Screen Descriptor and Global Color Table (if present)
LogicalScreenDescriptor = fread(fid, 3, 'uint8')';

PackedByte = LogicalScreenDescriptor(1);
GCTbool = bitget(PackedByte,8) == 1;

if (GCTbool)
    
    sizeGCT = bitget(PackedByte, 1:3);
    bitdepth = sum(sizeGCT .* [1 2 4]) + 1;
    fseek(fid, (3 * bitshift(1, bitdepth)), 'cof');
    
end

% End of GIF preamble.
pos_end = ftell(fid);

% Reread preamble as undifferentiated data.
fseek(fid, pos_begin, 'bof');
preamble_data = fread(fid, (pos_end - pos_begin), ...
                      'uint8=>uint8');



%%%
%%% Function parse_parameters
%%%

function [param_str, msg] = parse_parameters(varargin)
%PARSE_PARAMETERS  Validate optional parameters.

param_str = struct([]);
msg = '';

% Handle possibility of numeric index as first argument.
if (isnumeric(varargin{1}))

    % Special case for consistency with TIFF, ICO, and CUR.
    param_str(1).Frames = varargin{1};

    first_arg = 2;
    
elseif (nargin == 1)
    
    % Other parameters must be paired with a value.
    msg = sprintf('Invalid single parameter "%s".', varargin{1});
    return;
    
else
    
    first_arg = 1;
    
end


% Handle all other pairs.
if (nargin > 1)
    
    % Parameter value pairs
    paramStrings = {'frames'};
    
    for k = first_arg:2:length(varargin)
        
        param = lower(varargin{k});
   
        if (~ischar(param))
            
            msg = sprintf('Parameter name "%s" must be a string.', ...
                          param);
            return;
            
        end

        % Look for the parameter among the allowable values.
        idx = strmatch(param, paramStrings);
        if (isempty(idx))
            
            msg = sprintf('Unrecognized parameter name "%s".', param);
            return;
            
        elseif (length(idx) > 1)
            
            msg = sprintf('Ambiguous parameter name "%s".', param);
            return
            
        end
        
        % Process the parameter.
        param = paramStrings{idx};
    
        switch (param)
        case 'frames'
            
            frames = varargin{k+1};
            
            if (ischar(frames))
                
                frames = lower(deblank(frames));
                
                if (~isequal(frames, 'all'))
                
                    msg = ['''Frames'' must be a vector of' ...
                           ' integers or ''all''.'];
                    return;
                    
                end
            
            elseif (isnumeric(frames))
                
                if (numel(frames) ~= length(frames))
                    
                    msg = ['Value for ''Frames'' must be a vector of' ...
                           ' integers or ''all''.'];
                    return;
                    
                end
                
            else
                
                msg = ['Value for ''Frames'' must be a vector of' ...
                           ' integers or ''all''.'];
                return;
                
            end
            
            param_str(1).Frames = frames;
            
        end  % switch (param)
        
    end  % for k = ...

end  % if (nargin > 1)



%%%
%%% Function swap_top
%%%

function out = swap_top(in, region_top, region_left, region_right)
%SWAP_TOP  Replace the top line of the region with the top line of the frame.

% Java's GIF reader incorrectly imports frames where the top
% of the region and the top of the frame don't coincide.  In
% all cases, the first row of the region appears in the first
% row of the frame.  Other rows are loaded correctly.

out = in;

out(region_top, region_left:region_right) = ...
    in(1, region_left:region_right);
