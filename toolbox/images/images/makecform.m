function c = makecform(varargin)
%MAKECFORM Create a color transformation structure.
%   C = MAKECFORM(TYPE) creates the color transformation structure, C,
%   that defines the color space conversion specified by TYPE.  To
%   perform the transformation, pass the color transformation structure
%   as an argument to the APPLYCFORM function.  TYPE should be one of
%   these strings:
%
%       'lab2lch'   'lch2lab'   'upvpl2xyz'   'xyz2upvpl'
%       'uvl2xyz'   'xyz2uvl'   'xyl2xyz'     'xyz2xyl'
%       'xyz2lab'   'lab2xyz'   'srgb2xyz'    'xyz2srgb'
%       'srgb2lab'  'lab2srgb'
%
%   (The color space table below defines these abbreviations.)
%
%   For the xyz2lab, lab2xyz, srgb2lab, and lab2srgb transforms, you can
%   optionally specify the value of the reference illuminant, known as
%   the white point.  Use the syntax C = MAKECFORM(TYPE,'WhitePoint',WP),
%   where WP is a 1-by-3 vector of XYZ values scaled so that Y = 1.  The
%   default is the CIE illuminant D50, which is also the default
%   illuminant specified in the International Color Consortium
%   specification ICC.1:2001-04.  You can use the WHITEPOINT function to
%   create the WP vector. 
%
%   C = MAKECFORM('icc', SRC_PROFILE, DEST_PROFILE) creates a color
%   transformation based on two ICC profiles.  SRC_PROFILE and
%   DEST_PROFILE are ICC profile structures returned by ICCREAD. 
%
%   C = MAKECFORM('icc', SRC_PROFILE, DEST_PROFILE,
%   'SourceRenderingIntent', SRC_INTENT, 'DestRenderingIntent',
%   DEST_INTENT) creates a color transformation based on two ICC color
%   profiles.  SRC_INTENT and DEST_INTENT specify the rendering intent
%   corresponding to the source and destination profiles.  SRC_INTENT and
%   DEST_INTENT must be one of these strings:
%
%       'AbsoluteColorimetric'  'Perceptual'  
%       'RelativeColorimetric'  'Saturation'
%
%   'Perceptual' is the default source and destination rendering intent.
%   See the MAKECFORM reference page for more information about rendering
%   intents.
%
%   CFORM = MAKECFORM('clut', PROFILE, LUTTYPE) creates a color transform
%   based on a Color Lookup Table (CLUT) contained in an ICC color
%   profile.  PROFILE is an ICC profile structure returned by ICCREAD.
%   LUTTYPE specifies which CLUT in the PROFILE structure is to be used.
%   It may be one of these strings: 
%
%       'AToB0'    'AToB1'    'AToB2'    'AToB3'    'BToA0'   
%       'BToA1'    'BToA2'    'BToA3'    'Gamut'    'Preview0'
%       'Preview1' 'Preview2'
%
%   CFORM = MAKECFORM('mattrc', MATTRC, 'Direction', DIR) creates a color
%   transform based on a Matrix/Tone Reproduction Curve (MatTRC) model
%   contained in an ICC color profile. DIRECTION is either 'forward' or
%   'inverse' and specifies whether the MatTRC is to be applied in the
%   forward or inverse direction. 
%
%   For more information about 'clut' transformations, see Section 6.5.7
%   of ICC.1:2001-4 (www.color.org).  For more information about 'mattrc'
%   transformations, see Section 6.3.1.2.
%
%   Color space abbreviations
%   -------------------------
%
%       Abbreviation   Description
%
%       xyz            1931 CIE XYZ tristimulus values
%       xyl            1931 CIE xyY chromaticity values
%       uvl            1960 CIE uvL values
%       upvpl          1976 CIE u'v'L values
%       lab            1976 CIE L*a*b* values
%       lch            Polar transformation of L*a*b* values; c = chroma
%                          and h = hue
%       srgb           Standard computer monitor RGB values 
%                          (IEC 61966-2-1)
%
%   Example
%   -------
%   Convert RGB image to L*a*b*, assuming input image is sRGB.
%
%       rgb = imread('peppers.png');
%       cform = makecform('srgb2lab');
%       lab = applycform(rgb, cform);
%
%   See also APPLYCFORM, LAB2DOUBLE, LAB2UINT8, LAB2UINT16, WHITEPOINT,
%            XYZ2DOUBLE, XYZ2UINT16.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2003/08/23 05:52:59 $
%   Author:  Scott Gregory, Toshia McCabe 10/18/02
%   Revised: Toshia McCabe 12/17/02 

checknargin(1,Inf,nargin,'makecform');

valid_strings = {'lab2lch','lch2lab', 'upvpl2xyz', 'xyz2upvpl',...
                 'uvl2xyz', 'xyz2uvl', 'xyl2xyz', 'xyz2xyl','xyz2lab',...
                 'lab2xyz','srgb2xyz','xyz2srgb', 'srgb2lab', 'lab2srgb', ...
                 'clut','mattrc', 'icc','makeabsolute'};

transform_type = checkstrs(varargin{1}, valid_strings, 'makecform', ...
                           'TRANSFORMTYPE', 1);

switch lower(transform_type)
  case {'lab2lch', 'lch2lab', 'upvpl2xyz', 'xyz2upvpl',...
        'uvl2xyz', 'xyz2uvl', 'xyl2xyz', 'xyz2xyl'}
    c = make_simple_cform(varargin{:});
  case {'xyz2lab', 'lab2xyz'}
    c = make_xyz_labcform(varargin{:});
  case 'clut'
    c = make_clutcform(varargin{2:end});
  case 'mattrc'
    c = make_mattrc_cform(varargin{2:end});
  case 'icc'
    c = make_icc_cform(varargin{2:end});
  case 'makeabsolute'
    c = make_absolute_cform(varargin{2:end});
  case {'srgb2xyz', 'xyz2srgb'}
    c = make_srgb_xyz_cform(varargin{:});
  case 'srgb2lab'
    c = make_srgb2lab_cform(varargin{:});
  case 'lab2srgb'
    c = make_lab2srgb_cform(varargin{:});
end

%------------------------------------------------------------
function c = make_simple_cform(varargin)
% build an simple cform structure

% Check for valid input
msg = nargchk(1,1,nargin);
if ~isempty(msg)
    eid = 'Images:makecform:incorrectNargin';
    error(eid,'%s',msg);
end  
checkinput(varargin{1},{'char'},{'nonempty'},'applycform','TRANSFORMTYPE',1);
xform = varargin{1};

% Construct a look up table for picking atomic functions
cinfo = {'lab2lch', @lab2lch, 'lab','lch';
         'lch2lab', @lch2lab,'lch','lab';
         'upvpl2xyz', @upvpl2xyz,'upvpl','xyz';
         'xyz2upvpl',@xyz2upvpl,'xyz','upvpl';
         'uvl2xyz', @uvl2xyz, 'uvl', 'xyz';
         'xyz2uvl', @xyz2uvl,'xyz','uvl';
         'xyl2xyz', @xyl2xyz,'xyl','xyz';
         'xyz2xyl', @xyz2xyl,'xyz','xyl'};

persistent function_table;
if isempty(function_table)
    for k = 1:size(cinfo,1)
        s.function = cinfo{k,2};
        s.in_space = cinfo{k,3};
        s.out_space = cinfo{k,4};
        function_table.(cinfo{k,1}) = s;
    end
end

t = function_table.(xform);
c = assigncform(t.function,t.in_space,t.out_space,'double',struct);

%----------------------------------------------------------
function c = make_xyz_labcform(varargin)
% build an xyz2lab cform structure

msg = nargchk(1,3,nargin);
if ~isempty(msg)
    eid = 'Images:makecform:incorrectNargin';
    error(eid, '%s', msg);
end  

switch nargin
  case 1
    cdata.whitepoint = whitepoint;
  case 2
    eid = 'Images:makecform:paramValueIncomplete';
    msg = 'Property/PropertyValue pair expected.';
    error(eid,'%s',msg');
  case 3
    valid_strings = {'whitepoint'};
    checkstrs(varargin{2}, valid_strings, 'makecform', 'PROPERTYNAME', 2);
    checkinput(varargin{3},{'double'},{'real','2d','nonsparse','finite','row',...
                        'positive'},'xyz2lab','WP',2);
    if size(varargin{3},2) ~= 3
        eid = 'Images:makecform:invalidWhitePointData';
        msg = 'Incorrect number of columns in WP.';
        error(eid,'%s',msg);
    end
    cdata.whitepoint = varargin{3};
end

% Construct a look up table for picking atomic functions
cinfo = {'lab2xyz', @lab2xyz, 'lab','xyz';
         'xyz2lab', @xyz2lab,'xyz','lab'};

persistent labxyz_function_table;
if isempty(labxyz_function_table)
    for k = 1:size(cinfo,1)
        s.function = cinfo{k,2};
        s.in_space = cinfo{k,3};
        s.out_space = cinfo{k,4};
        labxyz_function_table.(cinfo{k,1}) = s;
    end
end

xform = varargin{1};
t = labxyz_function_table.(xform);

c = assigncform(t.function,t.in_space,t.out_space,'double',cdata);

%----------------------------------------------------------
function c = make_srgb2lab_cform(varargin)
% build an srgb2lab cform structure

msg = nargchk(1,3,nargin);
if ~isempty(msg)
    eid = 'Images:makecform:incorrectNargin';
    error(eid,'%s',msg);
end  

switch nargin
  case 1
    wp = whitepoint;
    % cdata.whitepoint = whitepoint;
  case 2
    eid = 'Images:makecform:paramValueIncomplete';
    msg = 'Property/PropertyValue pair expected.';
    error(eid,'%s',msg');
  case 3
    valid_strings = {'whitepoint'};
    checkstrs(varargin{2}, valid_strings, 'makecform', 'PROPERTYNAME', 2);
    wp = varargin{3};
    checkinput(wp,{'double'},{'real','2d','nonsparse','finite','row',...
                        'positive'},'xyz2lab','WP',2);
    if size(wp,2) ~= 3
        eid = 'Images:makecform:invalidWhitePointData';
        msg = 'Incorrect number of columns in WP.';
        error(eid,'%s',msg);
    end
end

cdata.cforms = {makecform('srgb2xyz'), ...
                makecform('xyz2lab', 'WhitePoint', wp)};

c = assigncform(@applycformsequence, 'rgb', 'lab', cdata.cforms{1}.encoding, cdata);

%----------------------------------------------------------
function c = make_lab2srgb_cform(varargin)
% build an lab2srgb cform structure

msg = nargchk(1,3,nargin);
if ~isempty(msg)
    eid = 'Images:makecform:incorrectNargin';
    error(eid,'%s',msg);
end  

switch nargin
  case 1
    wp = whitepoint;
    % cdata.whitepoint = whitepoint;
  case 2
    eid = 'Images:makecform:paramValueIncomplete';
    msg = 'Property/PropertyValue pair expected.';
    error(eid,'%s',msg');
  case 3
    valid_strings = {'whitepoint'};
    checkstrs(varargin{2}, valid_strings, 'makecform', 'PROPERTYNAME', 2);
    wp = varargin{3};
    checkinput(wp,{'double'},{'real','2d','nonsparse','finite','row',...
                        'positive'},'xyz2lab','WP',2);
    if size(wp,2) ~= 3
        eid = 'Images:makecform:invalidWhitePointData';
        msg = 'Incorrect number of columns in WP.';
        error(eid,'%s',msg);
    end
end

cdata.cforms = {makecform('lab2xyz', 'WhitePoint', wp), ...
                makecform('xyz2srgb')};

c = assigncform(@applycformsequence, 'lab', 'rgb', cdata.cforms{1}.encoding, cdata);

%------------------------------------------------------------
function c = make_clutcform(profile,luttype)

msg = nargchk(2,2,nargin);
if ~isempty(msg)
    eid = 'Images:makecform:incorrectNargin';
    error(eid,'%s',msg);
end

% Check for valid input arguments
if ~is_valid_profile(profile)
    eid = 'Images:makecform:invalidProfile';
    msg = 'Invalid profile structure.';
    error(eid,'%s',msg);
end
valid_luttag_strings = {'AToB0','AToB1','AToB2','AToB3','BToA0','BToA1','BToA2',....
                    'BToA3','Gamut','Preview0','Preview1','Preview2'};

luttype = checkstrs(luttype, lower(valid_luttag_strings), 'makecform','LUTTYPE', 3);

% Since absolute rendering uses the rel. colorimetric tag, re-assign
% luttype and set a flag.
is_a2b3 = false;
is_b2a3 = false;
if strmatch(lower(luttype),'atob3')
    luttype = 'atob1';
    is_a2b3 = true;
elseif strmatch(lower(luttype),'btoa3')
    luttype = 'btoa1';
    is_b2a3 = true;
end

% Get case sensistive luttag string
luttype_idx = strmatch(luttype,lower(valid_luttag_strings),'exact');
luttype = valid_luttag_strings{luttype_idx};

% Check that the profile actually has the luttag
if ~isfield(profile,luttype)
    eid = 'Images:makecform:invalidLutTag';
    msg = 'Profile does not contain the given luttag.';
    error(eid,'%s',msg);
end

c_fcn = @applyclut;
luttag = profile.(luttype);
cdata.luttag = luttag;

% Figure out input/output colorspaces based on the name of the luttag

starts_in_pcs = {'BToA0','BToA1','BToA2','BToA3','Gamut'};
starts_in_device_space = {'AToB0','AToB1','AToB2','AToB3'};
starts_and_ends_in_pcs = {'Preview0','Preview1','Preview2'};

switch luttype
  case starts_in_pcs
    inputcolorspace = profile.Header.ConnectionSpace;
    outputcolorspace = profile.Header.ColorSpace;
  case starts_in_device_space
    inputcolorspace = profile.Header.ColorSpace;
    outputcolorspace = profile.Header.ConnectionSpace;
  case starts_and_ends_in_pcs
    inputcolorspace = profile.Header.ConnectionSpace;
    outputcolorspace = inputcolorspace;
end

if strcmpi(inputcolorspace,'xyz')
    cdata.isxyz = true;
else
    cdata.isxyz = false;
end

% set up encoding based on whether the CLUT is mft1 or mft2
islut16 = luttag.MFT==2;
if islut16,
    encoding = 'uint16';   
else
    encoding = 'uint8';  
end

% Make a sequence of cforms if they ask for absolute rendering
if is_a2b3
    % First insert the clut
    clut_cform = assigncform(c_fcn,inputcolorspace, outputcolorspace,encoding,cdata);
    seq_cdata.sequence.clut_cform = clut_cform;
    
    % Then insert the makeabsolute cform
    absolute_cform = makecform('makeabsolute',profile.Header.ConnectionSpace,'double',...
                               profile.MediaWhitePoint,whitepoint);
    seq_cdata.sequence.convert_absolute = absolute_cform;
    
    % Make an icc sequence
    c = assigncform(@applyiccsequence,inputcolorspace,outputcolorspace,encoding,seq_cdata);
elseif is_b2a3
    % First insert the makeabsolute cform
    clut_cform = assigncform(c_fcn,inputcolorspace, outputcolorspace,encoding,cdata);
    absolute_cform = makecform('makeabsolute',profile.Header.ConnectionSpace,'double',...
                               whitepoint,profile.MediaWhitePoint);
    seq_cdata.sequence.convert_absolute = absolute_cform;
    
    % Then insert the clut
    seq_cdata.sequence.clut_cform = clut_cform;
    
    % Make an icc sequence
    c = assigncform(@applyiccsequence,inputcolorspace,outputcolorspace,encoding,seq_cdata);
else
    % Just make a clut cform
    c = assigncform(c_fcn,inputcolorspace, outputcolorspace,encoding,cdata);
end

% ------------------------------------------------------------

function c = make_mattrc_cform(varargin)

msg = nargchk(3,3,nargin);
if ~isempty(msg)
    eid = 'Images:makecform:incorrectNargin';
    error(eid,'%s',msg);
end

if ~is_valid_mattrc(varargin{1})
    eid = 'Images:makecform:invalidMattrc';
    msg = 'MatTRC structure is invalid.';
    error(eid,'%s',msg);
end

% Check for valid input arguments
valid_propname_strings = {'direction'};
valid_propvalue_strings = {'forward','inverse'};
checkstrs(varargin{2}, valid_propname_strings, 'makecform', 'PARAM', 2);
direction = checkstrs(varargin{3}, valid_propvalue_strings,'makecform',...
                      'PARAM',3);

% Assign correct atomic function and color spaces
% depending on direction.
if strcmp(direction,'forward')
    c_fcn = @applymattrc_fwd;
    space_in = 'rgb';
    space_out ='xyz';
else
    c_fcn = @applymattrc_inv;
    space_in = 'xyz';
    space_out = 'rgb';
end

cdata.MatTRC = varargin{1};
c = assigncform(c_fcn,space_in,space_out,'uint16',cdata);
%------------------------------------------------------------
function c = make_icc_cform(varargin)

msg = nargchk(2,6,nargin);
if ~isempty(msg)
    eid = 'Images:makecform:incorrectNargin';
    error(eid,'%s',msg);
end

% Set default rendering intents
args.sourcerenderingintent ='perceptual';
args.destrenderingintent = 'perceptual';

% Get Rendering intent information if it's given
valid_property_strings = {'sourcerenderingintent','destrenderingintent'};
valid_value_strings = {'perceptual','relativecolorimetric', 'saturation',...
                    'absolutecolorimetric'};
if nargin > 2
    for k=3:2:nargin
        prop_string = checkstrs(varargin{k}, valid_property_strings, 'makecform', ...
                                'PARAM', k);
        value_string = checkstrs(varargin{k+1}, valid_value_strings, 'makecform', ...
                                 'PARAM', k+1);
        args.(prop_string) = value_string;
    end
end

source_intent_num = int2str(strmatch(args.sourcerenderingintent,valid_value_strings)-1);
dest_intent_num = int2str(strmatch(args.destrenderingintent,valid_value_strings)-1);

% Get the source profile
source_pf = varargin{1};
if ~is_valid_profile(source_pf)
    eid = 'Images:makecform:invalidSourceProfile';
    msg = 'Invalid source profile.';
    error(eid,'%s',msg);
end

% Get the destination profile
dest_pf = varargin{2};
if ~is_valid_profile(dest_pf)
    eid = 'Images:makecform:invalidDestinationProfile';
    msg = 'Invalid destination profile.';
    error(eid,'%s',msg);
end

% Flags that are used later in determining absolute rendering
source_absolute = false;
dest_absolute = false;
path_is_absolute = false;

% Get Transform form Source Profile. Although the absolute Mattrc
% is ignored here, the absolute path will still be constructed as long
% as the destination rendering is absolute.
first_try = strcat('AToB', source_intent_num);
second_try = strcat('MatTRC');
if isfield(source_pf,first_try)
    source_cform = makecform('clut',source_pf, first_try);
elseif strcmp(first_try,'AToB3') && isfield(source_pf,'AToB1')
    source_cform = makecform('clut',source_pf, 'AToB1');
    source_absolute = true;
elseif isfield(source_pf,second_try) 
    if strmatch(args.sourcerenderingintent,'absolutecolorimetric');
        source_absolute = true;
    end
    source_cform = makecform('mattrc',source_pf.(second_try),'Direction','forward');
else
    eid = 'Images:makecform:invalidProfile';
    msg = 'Invalid source profile. No Luttag nor MatTRC found.';
    error(eid,'%s',msg);
end

% Get Transform from Destination Profile
first_try = strcat('BToA', dest_intent_num);
second_try = strcat('MatTRC');
if isfield(dest_pf,first_try)
    dest_cform = makecform('clut',dest_pf, first_try);
elseif strcmp(first_try,'BToA3') && isfield(dest_pf,'BToA1')
    dest_cform = makecform('clut',dest_pf, 'BToA1');
    dest_absolute = true;
elseif isfield(dest_pf,second_try) 
    if strmatch(args.destrenderingintent,'absolutecolorimetric');
        dest_absolute = true;
    end
    dest_cform = makecform('mattrc',dest_pf.(second_try),'Direction','inverse');
else
    eid = 'Images:makecform:invalidProfile';
    msg = 'Invalid destination profile. No Luttag nor MatTRC found.';
    error(eid,'%s',msg);
end

% Make sure the user didn't ask for absolute on the source and relative on
% the destination profile. In any event, if the destination is absolute,
% the entire path is absolute.
if source_absolute && ~dest_absolute
    eid = 'Images:makecform:invalidRenderingIntents';
    msg = 'Destination rendering intent must be absolute if source is absolute.';
    error(eid,'%s',msg);
else
    path_is_absolute = dest_absolute;
end

% Check to see if PCS's match. If not the PCS's will have to be
% reconciled with a third cform that connects the two. 
source_pcs_is_xyz = strcmp(deblank(lower(source_pf.Header.ConnectionSpace)),'xyz');
dest_pcs_is_xyz = strcmp(deblank(lower(dest_pf.Header.ConnectionSpace)),'xyz');
needs_gendermender = ~(source_pcs_is_xyz == dest_pcs_is_xyz);

% Now construct the sequence of cforms to be packed into the cdata
% of this main cform. The sequence might require some xyz2lab or lab2xyz
% cforms to accomodate a mismatch in PCSs between the profiles. In
% addition, a 'makeabsolute' cform may be inserted if the users asks for
% the absolute rendering intent.

% Put the source profile first in the sequence. It's always first.
cdata.sequence.source = source_cform;

% Figure out the encoding needed for the first profile.
if source_pcs_is_xyz
    source_encoding = 'uint16';
else
    encoding_types = {'uint8','uint16'};
    source_encoding = encoding_types{source_cform.cdata.luttag.MFT};
end

% Insert a cform to convert to absolute if needed. Converting to absolute
% in XYZ space is much cleaner than in LAB.
if path_is_absolute && source_pcs_is_xyz
    absolute_cform = makecform('makeabsolute','xyz','double',...
                               source_pf.MediaWhitePoint,dest_pf.MediaWhitePoint);
    cdata.sequence.convert_absolute = absolute_cform;
end

% Insert a lab2xyz or xyz2lab if needed
if needs_gendermender
    if source_pcs_is_xyz
        fix_pcs_cform = makecform('xyz2lab','whitepoint',whitepoint); 
    else  
        fix_pcs_cform = makecform('lab2xyz','whitepoint',whitepoint);
    end
    cdata.sequence.fix_pcs = fix_pcs_cform;
    
    % Insert a cform to convert to absolute if needed. Converting to absolute
    % in XYZ space is much cleaner than in LAB.
    if path_is_absolute && dest_pcs_is_xyz
        absolute_cform = makecform('makeabsolute','xyz','double',...
                                   source_pf.MediaWhitePoint,dest_pf.MediaWhitePoint);
        cdata.sequence.convert_absolute = absolute_cform;
    end       
end

% If the path is absolute, but neither pcs is XYZ, then resort to this.
if path_is_absolute && ~source_pcs_is_xyz && ~dest_pcs_is_xyz
    absolute_cform = makecform('makeabsolute','lab','double',...
                               source_pf.MediaWhitePoint,dest_pf.MediaWhitePoint);
    cdata.sequence.convert_absolute = absolute_cform;
end

% Insert the destination profile into the sequence.
cdata.sequence.destination = dest_cform;

% Assign c_fcn
c_fcn = @applyiccsequence;

% Make the main cform
c = assigncform(c_fcn,source_pf.Header.ColorSpace,dest_pf.Header.ColorSpace,...
                source_encoding,cdata);
%------------------------------------------------------------
function c = make_absolute_cform(cspace,encoding,source_wp,dest_wp)
% This is a private cform. It is only constructed under the hood. No doc for
% this type of cform needed.

cdata.colorspace = cspace;
cdata.source_whitepoint = source_wp;
cdata.dest_whitepoint = dest_wp;
c = assigncform(@applyabsolute,cspace,cspace,encoding,cdata);

%------------------------------------------------------------
function c = make_srgb_xyz_cform(varargin)
% Make an srgb2xyz or xyz2srgb cform.

msg = nargchk(1,1,nargin);
if ~isempty(msg)
    eid = 'Images:makecform:incorrectNargin';
    error(eid,'%s',msg);
end  

persistent sRGB_profile
if isempty(sRGB_profile)
    sRGB_profile = iccread('sRGB.icm');
end

if strcmp(varargin{1}, 'srgb2xyz')
    direction = 'forward';
else
    direction = 'inverse';
end

c = makecform('mattrc', sRGB_profile.MatTRC, 'Direction', direction);


% ------------------------------------------------------------

function c = assigncform(c_func,space_in,space_out,encoding,cdata)

% make the cform struct

c.c_func = c_func;
c.ColorSpace_in = space_in;
c.ColorSpace_out = space_out;
c.encoding = encoding;
c.cdata = cdata;

% ------------------------------------------------------------
function out = is_valid_profile(pf)

has_filename = isfield(pf,'Filename');
has_header = isfield(pf,'Header');
has_tagtable = isfield(pf,'TagTable');
has_private = isfield(pf,'PrivateTags');

if (has_filename && has_header && has_tagtable && has_private)
    out = true;
    if isempty(pf.Filename) || ~ischar(pf.Filename)
        out = false;
    elseif isempty(pf.Header) || ~isstruct(pf.Header)
        out = false;
    elseif isempty(pf.TagTable) || ~iscell(pf.TagTable)
        out = false;
    elseif ~iscell(pf.PrivateTags)
        out = false;
    end
else
    out = false;
end

% ------------------------------------------------------------
function out = is_valid_mattrc(mattrc)

has_redc = isfield(mattrc,'RedColorant');
has_greenc = isfield(mattrc,'GreenColorant');
has_bluec = isfield(mattrc,'BlueColorant');
has_redtrc = isfield(mattrc,'RedTRC');
has_greentrc = isfield(mattrc,'GreenTRC');
has_bluetrc = isfield(mattrc,'BlueTRC');

if (has_redc && has_greenc && has_bluec && has_redtrc && has_greentrc ...
    && has_bluetrc)
    out = true;
    if isempty(mattrc.RedColorant) || ~isa(mattrc.RedColorant,'double')
        out = false;
    elseif isempty(mattrc.GreenColorant) || ~isa(mattrc.GreenColorant,'double')
        out = false;
    elseif isempty(mattrc.BlueColorant) || ~isa(mattrc.BlueColorant,'double')
        out = false;
    elseif isempty(mattrc.RedTRC) || (~isa(mattrc.RedTRC,'uint16') && ~isa(mattrc.RedTRC,'double'))
        out = false;
    elseif isempty(mattrc.GreenTRC) || (~isa(mattrc.GreenTRC,'uint16') && ~isa(mattrc.GreenTRC,'double'))
        out = false;
    elseif isempty(mattrc.BlueTRC) || (~isa(mattrc.BlueTRC,'uint16') && ~isa(mattrc.BlueTRC,'double'))
        out = false;
    end
else
    out = false;
end

