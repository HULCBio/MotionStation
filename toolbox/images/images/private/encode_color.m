function out = encode_color(in,cspace, encode_in, encode_out)
% out = encode_color(IN,cspace, encode_in, encode_out)
%
% IN is the data
% cpsace can be 'lab','xyz', 'rgb' or 'cmyk'
% encode_in and encode_out can be 'double','uint8',or 'uint16'

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/01/26 05:59:23 $
%   Author:  Scott Gregory, Toshia McCabe 12/04/02
%   Revised: Toshia McCabe 12/04/02

cspace = lower(cspace);
encode_in = lower(encode_in);
encode_out = lower(encode_out);
check_input(cspace,encode_in);

if strcmp(encode_in,encode_out)
    out = in;
else
    persistent enctab;
    if isempty(enctab)
        enctab = {'lab',   'double', 'uint8',  @labdouble_to_labuint8;
                  'lab',   'uint8',  'double', @labuint8_to_labdouble;
                  'lab',   'double', 'uint16', @labdouble_to_labuint16;
                  'lab',   'uint16', 'double', @labuint16_to_labdouble;
                  'lab',   'uint8',  'uint16', @labuint8_to_labuint16;
                  'lab',   'uint16', 'uint8',  @labuint16_to_labuint8;
                  'xyz',   'double', 'uint16', @xyzdouble_to_xyzuint16;
                  'xyz',   'double', 'uint8',  @output_encoding_ignored;
                  'xyz',   'uint16', 'double', @xyzuint16_to_xyzdouble;
                  'xyz',   'uint16', 'uint8',  @output_encoding_ignored;
                  'rgb',   'double', 'uint8',  @double_to_uint8;
                  'rgb',   'uint8',  'double', @uint8_to_double;
                  'rgb',   'uint16', 'double', @uint16_to_double;
                  'rgb',   'double', 'uint16', @double_to_uint16;
                  'rgb',   'uint8',  'uint16', @uint8_to_uint16;
                  'rgb',   'uint16', 'uint8',  @uint16_to_uint8;
                  'cmyk',  'double', 'uint8',  @double_to_uint8;
                  'cmyk',  'uint8',  'double', @uint8_to_double;
                  'cmyk',  'uint16', 'double', @uint16_to_double;
                  'cmyk',  'double', 'uint16', @double_to_uint16;
                  'cmyk',  'uint8',  'uint16', @uint8_to_uint16;
                  'cmyk',  'uint16', 'uint8',  @uint16_to_uint8;
                  'lch',   'double', 'uint8',  @output_encoding_ignored;
                  'lch',   'double', 'uint16', @output_encoding_ignored;
                  'upvpl', 'double', 'uint8',  @output_encoding_ignored;
                  'upvpl', 'double', 'uint16', @output_encoding_ignored;
                  'uvl',   'double', 'uint8',  @output_encoding_ignored;
                  'uvl',   'double', 'uint16', @output_encoding_ignored;
                  'xyl',   'double', 'uint8',  @output_encoding_ignored;
                  'xyl',   'double', 'uint16', @output_encoding_ignored;  
                 };
    end
    
    % Populate a struct that maps the encoding function by indexing
    % colorspace, input encoding, and output encoding
    persistent enc;
    if isempty(enc)
        for k = 1:size(enctab,1)
            enc.(enctab{k,1}).(enctab{k,2}).(enctab{k,3}) = enctab{k,4};
        end
    end
    
    % Choose the encoding conversion function
    func = enc.(lower(cspace)).(encode_in).(encode_out);
    
    % Do the encoding conversion
    out = feval(func,in);
end

%-----------------------------------------
function out = labdouble_to_labuint8(in)

% Do the scale and offset and cast to uint8
out = uint8(round([(255 * (in(:,1)/100)) in(:,2)+128 in(:,3)+128]));

%-----------------------------------------
function out = labuint8_to_labdouble(in)

out = double(in);
out(:,1) = 100 * (out(:,1) / 255);
out(:,2) = out(:,2) - 128;
out(:,3) = out(:,3) - 128;

%-----------------------------------------
function out = labdouble_to_labuint16(in)

% Do the scale and offset and cast to uint16
out = in;
out(:,1) = round(65535 * out(:,1) / (100 + (25500/65280)));
out(:,2) = round(65535 * ((128 + out(:,2)) / (255 + (255/256))));
out(:,3) = round(65535 * ((128 + out(:,3)) / (255 + (255/256))));
out = uint16(out);

%-----------------------------------------
function out = labuint16_to_labdouble(in)

out = double(in);
out(:,1) = (out(:,1) * (100 + (25500/65280))) / 65535;
out(:,2) = ((out(:,2) * (255 + (255/256))) / 65535) - 128;
out(:,3) = ((out(:,3) * (255 + (255/256))) / 65535) - 128;

%-----------------------------------------
function out = xyzdouble_to_xyzuint16(in)

out = uint16(round(65535 * (in / (1 + (32767/32768)))));

%-----------------------------------------
function out = xyzuint16_to_xyzdouble(in)

out = (double(in)/65535) * (1 + (32767/32768));

%-----------------------------------------
function out = double_to_uint8(in)

out = uint8(round((in) * 255));

%-----------------------------------------
function out = uint8_to_double(in)

out = double(in) / 255;

%------------------------------------------
function out = double_to_uint16(in)

out = uint16(round((in) * 65535));

%-----------------------------------------
function out = uint16_to_double(in)

out = double(in) / 65535;

%-----------------------------------------
function out = labuint8_to_labuint16(in)

out = uint16(round(double(in)*256));

%-----------------------------------------
function out = labuint16_to_labuint8(in)

out = uint8(round(double(in)/256));

%-----------------------------------------
function out = uint8_to_uint16(in)

out = uint16(round((double(in) / 255) * 65535));

%-----------------------------------------
function out = uint16_to_uint8(in)

out = uint8(round((double(in) / 65535) * 255));

%-----------------------------------------
function out = output_encoding_ignored(in)

% This is just a fix for the situation such as one
% goes in as uint8, and comes out as XYZ. Since there
% is no defined encoding for 8 bit XYZ, the output must
% be uint16!

out = in;
wid = 'Images:encode_color:outputEncodingIgnored';
msg = 'Encoding for output colorspace will not match that of input data.';
warning(wid,'%s',msg);

%---------------------------------------------
function check_input(cspace,encode_in)

valid_cspaces = {'lab','xyz','lch','upvpl','uvl','xyl','rgb','cmyk'};
cspace = checkstrs(cspace, valid_cspaces, 'encode_color', ...
                   'COLORSPACE', 2);
switch cspace
  case 'lab'
    valid_encodings = {'double','uint8','uint16'};
  case 'xyz'
    valid_encodings = {'double','uint16'};
  case 'lch'
    valid_encodings = {'double'};
  case 'upvpl'
    valid_encodings = {'double'};
  case 'uvl'
    valid_encodings = {'double'};
  case 'xyl'
    valid_encodings = {'double'};
  case 'rgb'
    valid_encodings = {'double','uint8','uint16'};
  case 'cmyk'
    valid_encodings = {'double','uint8','uint16'};
end

encoding = checkstrs(encode_in, valid_encodings, 'encode_color','ENCODING_IN', 3);
