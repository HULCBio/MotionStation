function s = iccread(filename)
%ICCREAD(FILENAME) Read ICC color profile.
%   P = ICCREAD(FILENAME) reads the International Color Consortium (ICC)
%   color profile data from the file specified by FILENAME.  The file can
%   be either an ICC profile file or a TIFF file containing an embedded
%   ICC profile.  ICCREAD returns the profile information in the
%   structure P.  P can be used by MAKECFORM and APPLYCFORM to compute
%   color space transformations. 
%
%   The reference page for ICCREAD has additional information about the
%   fields of the structure P.  For complete details, see the
%   specification ICC.1:2001-04 (www.color.org).
%
%   Example
%   -------
%   Read in the sRGB profile.
%
%       P = iccread('sRGB.icm');
%
%   See APPLYCFORM, MAKECFORM.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2003/08/01 18:08:57 $
%   Original authors: Scott Gregory, Toshia McCabe 10/18/02

% Check input argument
checknargin(1,1,nargin,'iccread');
checkinput(filename,{'char'},{'nonempty'},'iccread','FILENAME',1);

% Check to see that FILENAME is actually a file that exists
if exist(filename,'file') ~= 2
    eid = 'Images:iccread:fileNotFound';
    msg = 'The profile was not found. Check the file or path name.';
    error(eid,'%s',msg);
end

if istif(filename)
    info = imfinfo(filename);
    if ~isfield(info,'ICCProfileOffset')
        eid = 'Images:iccread:noProfileInTiffFile';
        msg = 'No ICC profile found in TIFF file.';
        error(eid,'%s',msg);
    end
    start = info.ICCProfileOffset;
    
elseif isiccprof(filename)
    start = 0;
    
else
    eid = 'Images:iccread:unrecognizedFileType';
    msg = 'Input file not recognized as an ICC profile or a TIFF file.';
    error(eid, '%s', msg);
end

% "All profile data must be encoded as big-endian."  Clause 6
[fid,msg] = fopen(filename,'r','b');
if (fid < 0)
    eid = 'Images:iccread:errorReadingProfile';
    error(eid,'%s',msg);
end

s = iccread_embedded(fid, start);
fclose(fid);

s.Filename = filename;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = isiccprof(filename)

tf = false;

fid = fopen(filename, 'r', 'b');
if (fid < 0)
    fclose(fid);
    return;
end

[words, count] = fread(fid, 3, 'uint32');
if count ~= 3
    fclose(fid);
    return;
end

[device_class_code, count] = fread(fid, 4, 'uchar');
if count ~= 4
    fclose(fid);
    return;
end

valid_device_class_codes = {'scnr', 'mntr', 'prtr', 'link', 'spac', 'abst', 'nmcl'};

if any(strcmp(char(device_class_code'), valid_device_class_codes))
    tf = true;
end

fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = istif(filename)

fid = fopen(filename, 'r', 'ieee-le');
if (fid < 0)
    tf = false;
else
    sig = fread(fid, 4, 'uint8');
    fclose(fid);
    tf = isequal(sig, [73; 73; 42; 0]) | isequal(sig, [77; 77; 0; 42]);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s = iccread_embedded(fid, start)
%   ICCREAD_EMBEDDED(FID, START) reads ICC profile data using the file
%   identifier FID, starting at byte offset location START, as measured
%   from the beginning of the file.

fseek_check(fid, start, 'bof');

% s.Filename = filename;
s.Header = read_header(fid);

% Skip past 44 reserved bytes (Clause 6.1)
fseek_check(fid, 44, 'cof');

% Read the Tag Table
tag_count = fread_check(fid, 1, 'uint32'); 
tag_table = cell(tag_count,3);
for k = 1:tag_count
    tag_table{k,1} = char(fread_check(fid, 4, 'char'))';
    tag_table{k,2} = fread_check(fid, 1, 'uint32');
    tag_table{k,3} = fread_check(fid, 1, 'uint32');
end
s.TagTable = tag_table;

% Build up a list of defined public tags
public_tagnames = {'A2B0', 'AToB0'; 'A2B1', 'AToB1'; 'A2B2', 'AToB2';...
                   'B2A0', 'BToA0'; 'B2A1', 'BToA1'; 'B2A2', 'BToA2';'bfd','UcrBg';...
                   'bkpt','MediaBlackPoint'; 'calt','CalibrationDate'; 'chad',...
                   'ChromaticAdaptation'; 'chrm','ChromaticityTag';'cprt','Copyright';...
                   'crdi','CRDInfo'; 'desc','Description'; 'dmdd','DeviceModelDesc';...
                   'dmnd','DeviceMfgDesc'; 'gamt','Gamut'; 'kTRC','GrayTRC'; 'lumi','Luminance';...
                   'meas','Measurement'; 'ncol','NamedColor';'ncl2','NamedColor2'; ...
                   'pre0','Preview0'; 'pre1','Preview1'; 'pre2','Preview2'; 'pseq','ProfileSequence';...
                   'psd0','ps2CRD0'; 'psd1','ps2CRD1'; 'psd2','ps2CRD2';'psd3','ps2CRD3';...
                   'ps2s','ps2CSA'; 'ps2i','ps2Renderingintent'; 'resp','outputResponse';...
                   'scrd','ScreeningDesc'; 'scrn','Screening';'targ','CharTarget';...
                   'tech','Technology'; 'vued','ViewingCondDesc'; 'view','ViewingConditions';...
                   'wtpt', 'MediaWhitePoint'};

mattrc_tagnames = {'bTRC', 'BlueTRC'; 'bXYZ','BlueColorant'; 'gTRC', 'GreenTRC';...
                   'gXYZ','GreenColorant'; 'rTRC', 'RedTRC'; 'rXYZ','RedColorant'};

private_tags = cell(0,0);
has_mattrc = false;

% Go through each tag in the tag table
for k = 1:size(s.TagTable,1)
    signature = deblank(s.TagTable{k,1});
    offset = s.TagTable{k,2};
    data_size = s.TagTable{k,3};
    
    pub_idx = strmatch(signature,public_tagnames,'exact');
    mattrc_idx = strmatch(signature,mattrc_tagnames,'exact');

    % Check to see if the tag is public, a mattrc tag, or private
    if ~isempty(pub_idx)
        % A public tag is found
        s.(public_tagnames{pub_idx,2}) = get_public_tag(fid,signature,offset+start,data_size);
    elseif ~isempty(mattrc_idx)
        % A Mattrc element is found... and the MatTRC struct will
        % now be generated or appended.
        has_mattrc = true;
        MatTRC.(mattrc_tagnames{mattrc_idx,2}) = get_public_tag(fid,signature,offset+start,data_size);
    else
        % The tag is a private tag
        data = get_private_tag(fid,offset+start,data_size);
        current_row = size(private_tags,1)+1;
        private_tags{current_row,1} = signature;
        private_tags{current_row,2} = data;
    end
end

% Generate the MatTRC field
if has_mattrc
    s.MatTRC = MatTRC;
end

% Populate the private tags
s.PrivateTags = private_tags;

%------------------------------------------
function header = read_header(fid)

header.Size = fread_check(fid, 1, 'uint32');
header.CMMType = fread_check(fid, 1, 'uint32');

% Clause 6.1.3 - Profile Version
% Byte 0:  Major Revision in BCD
% Byte 1:  Minor Revision & Bug Fix Revision in each nibble in BCD
% Byte 2:  Reserved; expected to be 0
% Byte 3:  Reserved; expected to be 0

version_bytes = fread_check(fid, 4, 'uint8');
major_version = version_bytes(1);

% Minor version and bug fix version are in the two nibbles
% of the second version byte.
minor_version = bitshift(version_bytes(2), -4);
bugfix_version = bitand(version_bytes(2), 15);
header.Version = sprintf('%d.%d.%d', major_version, minor_version, ...
                         bugfix_version);

% Clause 6.1.4 - Profile/Device Class signature
% Device Class             Signature
% ------------             ---------
% Input Device profile     'scnr'
% Display Device profile   'mntr'
% Output Device profile    'prtr'

device_class_char = char(fread_check(fid, 4, 'char'))';
device_class_codes = {'scnr', 'mntr', 'prtr', 'link', 'spac', 'abst', 'nmcl'};
device_class_strings = {'input', 'display', 'output', 'device link', ...
                    'colorspace conversion', 'abstract', 'named color'};
idx = strmatch(device_class_char, device_class_codes, 'exact');
if isempty(idx)
    fclose(fid);
    msg = 'Unrecognized Profile/Device Class; see ICC.1:1998-09 Clause 6.1.4.';
    eid = 'Images:iccread:invalidProfileClass';
    error(eid,'%s',msg);
end
header.DeviceClass = device_class_strings{idx};

% Clause 6.1.5 - Color Space signature
% Four-byte string, although some of the color space codes use only three
% bytes, which complicates things just a bit.  First we'll check to see
% if the first three bytes matches one of the three-byte codes.  If not,
% we'll check the four byte codes.
colorspace_bytes = char(fread_check(fid, 4, 'char'))';
size_cs = size(deblank(colorspace_bytes),2);
colorspace_string = '';
if size_cs==3
    colorspace_codes_3 = {'XYZ', 'Lab', 'Luv', 'Yxy', 'RGB', 'HSV', ...
                        'HLS', 'CMY'};
    colorspace_strings_3 = {'XYZ', 'Lab', 'Luv', 'Yxy', 'RGB', ...
                        'HSV', 'HLS', 'CMY'};
    idx = strmatch(colorspace_bytes(1:3), colorspace_codes_3);
    if ~isempty(idx)
        colorspace_string = colorspace_strings_3{idx};
    end
else
    colorspace_codes_4 = {'Ycbr', 'GRAY', 'CMYK', '2CLR', '3CLR', ...
                        '4CLR', '5CLR', '6CLR', '7CLR', '8CLR', '9CLR', ...
                        'ACLR', 'BCLR', 'CCLR', 'DCLR', 'ECLR', 'FCLR'};
    colorspace_strings_4 = {'YCbCr', 'gray', 'CMYK', '2 color', '3 color', ...
                        '4 color', '5 color', '6 color', '7 color', '8 color', ...
                        '9 color', '10 color', '11 color', '12 color', ...
                        '13 color', '14 color', '15 color'};
    idx = strmatch(colorspace_bytes, colorspace_codes_4);
    if ~isempty(idx)
        colorspace_string = colorspace_strings_4{idx};
    end
end
if isempty(colorspace_string)
    fclose(fid);
    eid = 'Images:iccread:invalidColorspaceSignature';
    msg = 'Unrecognized Color Space Signature; see ICC.1:1998-09 Clause 6.1.5.';
    error(eid,'%s',msg);
end
header.ColorSpace = colorspace_string;

% Clause 6.1.6 - Profile connection space signature
% Either 'XYZ' or 'Lab'.  However, if the profile is a DeviceLink
% profile, the connection space signature is taken from the
% colorspace signatures table.  The connection space signature
% takes up four bytes even though all the codes have three bytes.
signature = char(fread_check(fid, 4, 'char'))';
if strcmp(header.DeviceClass, 'device link')
    s.ConnectionSpace = s.ColorSpace;
else
    switch signature(1:3)
      case 'XYZ'
        header.ConnectionSpace = 'XYZ';
      case 'Lab';
        header.ConnectionSpace = 'Lab';
      otherwise
        fclose(fid);
        eid = 'Images:iccread:invalidConnectionSpaceSignature';
        msg = 'Unrecognized Connection Space Signature; see ICC.1:1998-09 Clause 6.1.6.';
        error(eid,'%s',msg);
    end
end

date_time_num = read_date_time_number(fid);
n = datenum(date_time_num(1), date_time_num(2), date_time_num(3), ...
            date_time_num(4), date_time_num(5), date_time_num(6));
header.CreationDate = datestr(n,0);

header.Signature = char(fread_check(fid, 4, 'char'))';
if ~strcmp(header.Signature, 'acsp')
    fclose(fid);
    eid = 'Images:iccread:invalidFileSignature';
    msg = 'Unrecognized file signature; see ICC.1:1998-09 Clause 6.1.';
    error(eid,'%s',msg);
end

% Clause 6.1.7 - Primary platform signature
% Four characters, though one code ('SGI') uses only three characters.
% Zeros if there is no primary platform.
signature = char(fread_check(fid, 4, 'char'))';
if isequal(double(signature), [0 0 0 0])
    header.PrimaryPlatform = 'none';
else
    if strcmp(signature(1:3), 'SGI')
        header.PrimaryPlatform = 'SGI';
    else
        switch signature
          case 'APPL'
            header.PrimarPlatform = 'Apple';
          case 'MSFT'
            header.PrimaryPlatform = 'Microsoft';
          case 'SUNW'
            header.PrimaryPlatform = 'Sun';
          case 'TGNT'
            header.PrimaryPlatform = 'Taligent';
          otherwise
            fclose(fid);
            eid = 'Images:iccread:invalidPrimaryPlatform';
            msg = 'Unrecognized Primary Platform Signature; see ICC.1:1998-09 Clause 6.1.7.';
            error(eid,'%s',msg);
        end
    end
end

% Clause 6.1.8 - Profile flags
% Flags containing CMM hints.  The least-significant 16 bits are reserved
% by ICC, which currently defines position 0 as "0 if not embedded profile,
% 1 if embedded profile" and position 1 as "1 if profile cannot be used
% independently of embedded color data, otherwise 0."
header.Flags = fread_check(fid, 1, 'uint32');
header.IsEmbedded = bitget(header.Flags, 1) == 1;
header.IsIndependent = bitget(header.Flags, 2) == 0;

header.DeviceManufacturer = char(fread_check(fid, 4, 'char'))';
header.DeviceModel = char(fread_check(fid, 4, 'char'))';

% Clause 6.1.10 - Attributes
% Device setup attributes, such as media type.  The least-significant 32
% bits of this 64-bit value are reserved for ICC, which currently defines
% bit positions 0 and 1.  

%% UPDATE FOR ICC:1:2001-04 Clause 6.1.10 -- Bit positions 2 and 3 
%% POSITION 2: POSITIVE=0, NEGATIVE=1
%% POSITION 3: COLOR=0, BLACK AND WHT=1

fseek_check(fid, 4, 'cof');
header.Attributes = fread_check(fid, 1, 'uint32')';
header.IsTransparency = bitget(header.Attributes, 1) == 1;
header.IsMatte = bitget(header.Attributes, 2) == 1;
header.IsNegative = bitget(header.Attributes,3) == 1;
header.IsBlackandWhite = bitget(header.Attributes,4) == 1;

% Clause 6.1.11 - Rendering intent
value = fread_check(fid, 1, 'uint32');
% Only check the first two bits.
value = bitand(value, 3);
switch value
  case 0
    header.RenderingIntent = 'perceptual';
  case 1
    header.RenderingIntent = 'relative colorimetric';
  case 2
    header.RenderingIntent = 'saturation';
  case 3
    header.RenderingIntent = 'absolute colorimetric';
end

header.Illuminant = read_xyz_number(fid);
header.Creator = char(fread_check(fid, 4, 'char'))';

%------------------------------------------
% Read public Tags

function out = get_public_tag(fid,signature,offset,data_size)
out =[];
lut_types = {'A2B0','A2B1','A2B2','B2A0','B2A1','B2A2',...
             'gamt','pre0','pre1','pre2'};

xyz_types = {'bkpt','bXYZ','gXYZ','lumi','rXYZ','wtpt'};
curve_types = {'bTRC','gTRC','kTRC','rTRC'};
text_desc_types = {'desc','dmdd','dmnd','scrd','vued'};

non_interpreted_types = {'bfd','chad','chrm','meas','ncol',...
                    'ncl2','pseq','psd0','psd1','psd2','psd3',...
                    'ps2s','ps2i','resp','scrn','tech'};

text_types = {'cprt','targ'};

switch signature
  case lut_types
    % See Clauses 6.4.*
    out = read_lut_type(fid, offset, data_size);
    
  case xyz_types
    % Clauses 6.4.*
    out = read_xyz_type(fid, offset, data_size);
    
  case curve_types
    % Clauses 6.4.*
    out = read_curve_type(fid, offset, data_size);
    
  case text_desc_types
    % Clauses 6.4.*
    out = read_text_description_type(fid, offset, data_size);
    
  case text_types
    % Clauses 6.4.*
    out = read_text_type(fid, offset, data_size);
    
  case non_interpreted_types
    % Clauses 6.4.*
    fseek_check(fid,offset+8,'bof');
    out = fread_check(fid, data_size-8, '*uint8');
    
  case 'calt'
    % Clause 6.4.9
    out = read_date_time_type(fid, offset, data_size);
    
  case 'crdi'
    % Clause 6.4.14 ICC 1:2001-04
    out = read_crd_info_type(fid, offset, data_size);
    
  case 'view'
    % viewingConditionsTag clause 6.4.47 in ICC-1:2001-04
    out = read_viewing_conditions(fid,offset,data_size);   
end

%------------------------------------------
% Read private tags

function out = get_private_tag(fid,offset,data_size)
fseek_check(fid, offset + 8, 'bof');
out = fread_check(fid, data_size-8, '*uint8');

%------------------------------------------
% read_xyz_number

function out = read_xyz_number(fid)

% Clause 5.3.10
% 0-3  CIE X    s15Fixed16Number
% 4-7  CIE Y    s15Fixed16Number
% 8-11 CIE Z    s15Fixed16Number

out = fread_check(fid, 3, 'int32')' / 65536;

%------------------------------------------
%%% read_xyz_type

function out = read_xyz_type(fid, offset, data_size)

% Clause 6.5.26 in ICC-1:2001-04
% 0-3  'XYZ '
% 4-7  reserved, must be 0
% 8-n  array of XYZ numbers

fseek_check(fid, offset + 8, 'bof');
num_values = (data_size - 8) / 4;
if rem(num_values,3) ~= 0
    eid = 'Images:iccread:invalidTagSize';
    msg = 'Unexpected tag data size in XYZType tag (Clauses 5.3.10, 6.5.25).';
    error(eid,'%s',msg);
end
out = fread_check(fid, num_values, 'int32') / 65536;
out = reshape(out, 3, num_values/3)';

%------------------------------------------
%%% read_curve_type

function out = read_curve_type(fid, offset, data_size)

% Clause 6.5.2
% 0-3    'curv'
% 4-7    reserved, must be 0
% 8-11   count value, uint32
% 12-end curve values, uint16

fseek_check(fid, offset + 8, 'bof');
count = fread_check(fid, 1, 'uint32');
out = fread_check(fid, count, '*uint16');
if count==1,
    out = (double(out)/256);
elseif count == 0
    out = 1.0;
end

%------------------------------------------
%%% Read viewingConditionsType

function out = read_viewing_conditions(fid,offset,data_size)

% Clause 6.5.25 ICC:1-2001-04
% 0-3 'view'
% 4-7 reserved, must be 0
% 8-19 absolute XYZ for illuminant in cd/m^2
% 20-31 absolute XYZ for surround in cd/m^2
% 32-35 illuminant type

fseek_check(fid, offset + 8, 'bof');
out.IlluminantXYZ = read_xyz_number(fid);
out.SurroundXYZ = read_xyz_number(fid);
illum_idx = fread_check(fid,1,'uint32');
illuminant_table = {'Unknown','D50','D65','D93','F2',...
                    'D55','A','EquiPower','F8'};
out.IlluminantType = illuminant_table{illum_idx+1};



%------------------------------------------
%%% read_lut_type

function out = read_lut_type(fid, offset, data_size)

% Clause 6.5.6, 6.5.7
% 0-3   'mft2'
% 4-7   reserved, must be 0
% 8     number of input channels, uint8
% 9     number of output channels, uint8
% 10    number of CLUT grid points, uint8
% 11    reserved for padding, must be 0
% 12-47 3-by-3 E matrix, stored row-major, each value s15Fixed16Number

% 16-bit LUT type:
% 48-49 number of input table entries, uint16
% 50-51 number of output table entries, uint16
% 52-n  input tables, uint16
%       CLUT values, uint16
%       output tables, uint16

% 8-bit LUT type:
% 48-   input tables, uint8
%       CLUT values, uint8
%       output tables, uint8

fseek_check(fid,offset,'bof');
% Check for mft1 or mft2 info
luttype = char(fread_check(fid,4,'char'))';
if strcmp(luttype,'mft1')
    out.MFT = 1;
elseif strcmp(luttype,'mft2')
    out.MFT = 2;
else
    fclose(fid);
    eid = 'Images:iccread:invalidLutType';
    msg = 'Unrecognized LutType. Must be "mft1" or "mft2"; See Clauses 6.5.6 and 6.5.7.';
    error(eid,'%s',msg);
end

% Skip past reserved padding bytes (Clauses 6.5.6 and 6.5.7)
fseek_check(fid, 4, 'cof');
num_input_channels = fread_check(fid, 1, 'uint8');
num_output_channels = fread_check(fid, 1, 'uint8');
num_clut_grid_points = fread_check(fid, 1, 'uint8');
fseek_check(fid, 1, 'cof');  % skip padding byte
out.E = reshape(fread_check(fid, 9, 'int32')/65536,3,3)';

switch out.MFT 
  case 2 % Means 16 bit CLUT
    num_input_table_entries = fread_check(fid, 1, 'uint16');
    num_output_table_entries = fread_check(fid, 1, 'uint16');                 
    out.InputTables = reshape(fread_check(fid, num_input_channels * ...
                                          num_input_table_entries, ...
                                          '*uint16'), ...
                              num_input_table_entries, ...
                              num_input_channels);
    
    clut_size = ones(1,num_input_channels)*num_clut_grid_points;
    num_clut_elements = prod(clut_size);
    ndims_clut = num_output_channels;
    
    out.CLUT = [reshape(fread_check(fid, num_clut_elements * ndims_clut, '*uint16'), ...
                        ndims_clut,num_clut_elements)]';
    out.CLUT = reshape( out.CLUT, [ clut_size ndims_clut ]);
    
    out.OutputTables = reshape(fread_check(fid, num_output_channels * ...
                                           num_output_table_entries, ...
                                           '*uint16'), ...
                               num_output_table_entries, ...
                               num_output_channels);
    

  case 1 %Means 8 bit CLUT
    out.InputTables = reshape(fread_check(fid, num_input_channels * 256, ...
                                          '*uint8'), 256, num_input_channels);
    
    clut_size = ones(1,num_input_channels)*num_clut_grid_points;
    
    num_clut_elements = prod(clut_size);
    ndims_clut = num_output_channels;
    out.CLUT = [reshape(fread_check(fid, num_clut_elements * ndims_clut, '*uint8'), ...
                        ndims_clut,num_clut_elements)]';
    out.CLUT = reshape( out.CLUT, [ clut_size ndims_clut ]);
    out.OutputTables = reshape(fread_check(fid, num_output_channels * 256, ...
                                           '*uint8'), 256, num_output_channels);
    
end


%------------------------------------------
%%% read_text_description_type

function out = read_text_description_type(fid, offset, data_size)

% Clause 6.5.16
% 0-3   'desc'
% 4-7   reserved, must be 0
% 8-11  ASCII invariant description count, including terminating NULL
% 12-   ASCII invariant description
% followed by optional Unicode and ScriptCode descriptions, which we
% ignore.

fseek_check(fid, offset + 8, 'bof');
count = fread_check(fid, 1, 'uint32');
% count includes the trailing NULL, which we don't need.
out = char(fread_check(fid, count-1, 'char'))';

%------------------------------------------
%%% read_text_type

function out = read_text_type(fid, offset, data_size)

% Clause 6.5.17
% 0-3 'text'
% 4-7 reserved, must be 0
% 8-  string of (data_size - 8) 7-bit ASCII characters, including NULL

fseek_check(fid, offset + 8, 'bof');
out = char(fread_check(fid, data_size-9, 'char'))';

%------------------------------------------
%%% read_date_time_type

function out = read_date_time_type(fid, offset, data_size)

% Clause 6.5.4
% 0-3   'dtim'
% 4-7   reserved, must be 0
% 8-19  DateTimeNumber

fseek_check(fid, offset + 8, 'bof');
out = read_date_time_number(fid);

%------------------------------------------
%%% read_crd_info_type

function out = read_crd_info_type(fid, offset, data_size)

% Clause 6.5.1
% 0-3   'crdi'
% 4-7   reserved, must be 0
% 8-11  PostScript product name character count, uint32
%       PostScript product name, 7-bit ASCII
%       Rendering intent 0 CRD name character count, uint32
%       Rendering intent 0 CRD name, 7-bit ASCII
%       Rendering intent 1 CRD name character count, uint32
%       Rendering intent 1 CRD name, 7-bit ASCII
%       Rendering intent 2 CRD name character count, uint32
%       Rendering intent 2 CRD name, 7-bit ASCII
%       Rendering intent 3 CRD name character count, uint32
%       Rendering intent 3 CRD name, 7-bit ASCII

fseek_check(fid, offset + 8, 'bof');
count = fread_check(fid, 1, 'uint32');
name = char(fread_check(fid, count, 'char'))';
out.PostScriptProductName = name(1:end-1);
out.RenderingIntentCRDNames = cell(4,1);
for k = 1:4
    count = fread_check(fid, 1, 'uint32');
    name = char(fread_check(fid, count, 'char'))';
    out.RenderingIntentCRDNames{k} = name(1:end-1);
end

%------------------------------------------
%%% read_date_time_number

function out = read_date_time_number(fid)

% Clause 5.3.1
out = fread_check(fid, 6, 'uint16');

%------------------------------------------
%%% fread_check

function out = fread_check(fid, n, precision)

[out,count] = fread(fid, n, precision);
if count ~= n
    pos = ftell(fid) - count;
    fclose(fid);
    eid = 'Images:iccread:fileReadFailed';
    msg = sprintf('File read failed: %d bytes at position %d.\n', n, pos);
    error(eid,'%s',msg);
end 

%------------------------------------------
%%% fseek_check

function fseek_check(fid, n, origin)
if fseek(fid, n, origin) < 0
    pos = ftell(fid);
    fclose(fid);
    eid = 'Images:fseekFailed';
    msg = sprintf('Fseek failed: %d bytes at position %d\.n', n, pos);
    error(eid,'%s',msg);
end
