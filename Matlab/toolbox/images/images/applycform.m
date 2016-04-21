function out = applycform(in,c)
%APPLYCFORM Apply color space transformation.
%   B = APPLYCFORM(A, C) converts the color values in A to the color
%   space specified in the color transformation structure, C.  The color
%   transformation structure specifies various parameters of the
%   transformation.  See MAKECFORM for details.
%
%   If A is two-dimensional, each row is interpreted as a color.  A
%   typically has either three or four columns, depending on the input 
%   color space.  B has the same number of rows and either three or
%   four columns, depending on the output color space.
%
%   If A is three-dimensional, each row-column location is interpreted as
%   a color, and SIZE(A,3) is typically either three or four, depending
%   on the input color space.  B has the same number of rows and
%   columns as A, and SIZE(B,3) is either three or four, depending on
%   the output color space.
%
%   Class Support
%   -------------
%   A must be a real, nonsparse array of class uint8, uint16, or
%   double.  B has the same class as A, unless the output color space
%   is XYZ.  Since there is no standard 8-bit representation of XYZ
%   values, so the B is of class uint16 if the input is of class uint8.
%
%   Example
%   -------
%   Convert RGB image to L*a*b*, assuming input image is sRGB.
%
%       rgb = imread('peppers.png');
%       cform = makecform('srgb2lab');
%       lab = applycform(rgb, cform);
%
%   See also MAKECFORM, LAB2DOUBLE, LAB2UINT8, LAB2UINT16, WHITEPOINT,
%            XYZ2DOUBLE, XYZ2UINT16.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2003/08/23 05:52:09 $
%   Author:  Scott Gregory, Toshia McCabe 10/18/02
%   Revised: Toshia McCabe 12/17/02

% Check the input arguments and get cforms and data
[in,c] = check_inputs(in,c);

% Reshape the input data into columns
columndata = check_dims_in(in);

% Check the encoding of the data against what's expected
% in the atomic functions and convert the data appropriately
% to the right encoding.
input_encoding = class(in);
columndata = encode_color(columndata,c.ColorSpace_in,...
                          input_encoding,c.encoding);

% Get arguments to atomic function from c.cdata
cdata = struct2cell(c.cdata)';

% Call the function with the argument list
str = warning('off','Images:encode_color:outputEncodingIgnored');
out = feval(c.c_func,columndata,cdata{:});
warning(str);

% Make sure encoding is the same as the data that went in.
% The only exception will be if uint8 data is given to an
% icc cform that results in PCS XYZ. In this case, the result
% will be uint16 XYZ values. There is no encoding defined
% for uint8 XYZ.

%out = encode_color(out,c.ColorSpace_out,c.encoding,input_encoding);
if ~strcmp(class(out), input_encoding)
    if strcmp(lower(c.ColorSpace_out),'xyz') & ~strcmp(lower(input_encoding),'double')
        out = encode_color(out,'xyz',lower(class(out)),'uint16');
    else
        out = encode_color(out,lower(c.ColorSpace_out),lower(class(out)),input_encoding);
    end
end

% Reshape the output data if needed
[nrows, ncols, nplanes] = size(in);
out = check_dims_out(out,nrows,ncols,nplanes);

%---------------------------------------
function [in,c] = check_inputs(in,c)

% Check the size of IN
[nrows,ncols,nplanes] = size(in);
if (nplanes == 1)
    if (ncols ~= 3) & (ncols ~= 4)
        eid = 'Images:applycform:wrongDataDimensions';
        msg = 'IN must be Px3, Px4, MxNx3, or MxNx4.';
        error(eid,'%s',msg);
    end
end

% Check to make sure IN is of correct class and attributes
checkinput(in,{'double','uint8','uint16'},{'real','nonsparse','finite'},...
           'applycform','IN',1);

% Check to make sure C is of correct class and attributes
if ~is_valid_cform(c)
    eid = 'Images:applycform:invalidCform';
    msg = 'Cform structure is invalid.';
    error(eid,'%s',msg);
end

%---------------------------------------
function out = check_dims_in(data)

% if more than 2D array, put data into columns
out = reshape(data,[],size(data,ndims(data)));

%---------------------------------------
function out = check_dims_out(data,nrows,ncols,nplanes)
% Reshape the data to original shape if needed

% The number of planes in OUT depends on whether or not
% the orginal data was planar as well as the number
% of output channels in DATA.
if nplanes > 1
    out  = reshape(data,nrows,ncols,size(data,2));
else
    out = data;
end

% ------------------------------------------
function out = is_valid_cform(c)

has_func = isfield(c,'c_func');
has_in = isfield(c,'ColorSpace_in');
has_out = isfield(c,'ColorSpace_out');
has_enc = isfield(c,'encoding');
has_cdata = isfield(c,'cdata');

if has_func & has_in & has_out & has_enc & has_cdata
    out = true;
    if isempty(c.c_func) | ~isa(c.c_func,'function_handle')
        out = false;
    elseif isempty(c.ColorSpace_in) | ~isstr(c.ColorSpace_in)
        out = false;
    elseif isempty(c.ColorSpace_out) | ~isstr(c.ColorSpace_out)
        out = false;
    elseif isempty(c.encoding) | ~isstr(c.encoding)
        out = false;
    elseif isempty(c.cdata) | ~isa(c.cdata,'struct')
        out = false;
    end
else
    out = false;
end
