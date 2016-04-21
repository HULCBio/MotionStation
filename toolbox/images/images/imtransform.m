function [B,xdata,ydata] = imtransform(varargin)
%IMTRANSFORM Apply 2-D spatial transformation to image.
%   B = IMTRANSFORM(A,TFORM) transforms the image A according to the 2-D
%   spatial transformation defined by TFORM, which is a tform structure
%   as returned by MAKETFORM or CP2TFORM.  If ndims(A) > 2, such as for
%   an RGB image, then the same 2-D transformation is automatically
%   applied to all 2-D planes along the higher dimensions.
%
%   When you use this syntax, IMTRANSFORM automatically shifts the origin of
%   your output image to make as much of the transformed image visible as
%   possible. If you are using IMTRANSFORM to do image registration, this syntax
%   is not likely to give you the results you expect; you may want to set
%   'XData' and 'YData' explicitly. See the description below of 'XData' and
%   'YData' as well as Example 3.
%
%   B = IMTRANSFORM(A,TFORM,INTERP) specifies the form of interpolation to
%   use.  INTERP can be one of the strings 'nearest', 'bilinear', or
%   'bicubic'.  Alternatively INTERP can be a RESAMPLER struct as returned
%   by MAKERESAMPLER.  This option allows more control over how resampling
%   is performed.  The default value for INTERP is 'bilinear'.
%
%   [B,XDATA,YDATA] = IMTRANSFORM(...) returns the location of the output
%   image B in the output X-Y space.  XDATA and YDATA are two-element
%   vectors.  The elements of XDATA specify the x-coordinates of the first
%   and last columns of B.  The elements of YDATA specify the y-coordinates
%   of the first and last rows of B.  Normally, IMTRANSFORM computes XDATA
%   and YDATA automatically so that B contains the entire transformed image
%   A.  However, you can override this automatic computation; see below.
%
%   [B,XDATA,YDATA] = IMTRANSFORM(...,PARAM1,VAL1,PARAM2,VAL2,...)
%   specifies parameters that control various aspects of the spatial
%   transformation. Parameter names can be abbreviated, and case does not
%   matter.
%
%   Parameters include:
%
%   'UData'      Two-element real vector.
%   'VData'      Two-element real vector.
%                'UData' and 'VData' specify the spatial location of the
%                image A in the 2-D input space U-V.  The two elements of
%                'UData' give the u-coordinates (horizontal) of the first
%                and last columns of A, respectively.  The two elements
%                of 'VData' give the v-coordinates (vertical) of the
%                first and last rows of A, respectively.  
%
%                The default values for 'UData' and 'VData' are [1
%                size(A,2)] and [1 size(A,1)], respectively.
%
%   'XData'      Two-element real vector.
%   'YData'      Two-element real vector.
%                'XData' and 'YData' specify the spatial location of the
%                output image B in the 2-D output space X-Y.  The two
%                elements of 'XData' give the x-coordinates (horizontal)
%                of the first and last columns of B, respectively.  The
%                two elements of 'YData' give the y-coordinates
%                (vertical) of the first and last rows of B,
%                respectively.  
%
%                If 'XData' and 'YData' are not specified, then
%                IMTRANSFORM estimates values for them that will
%                completely contain the entire transformed output image. 
%
%   'XYScale'    A one- or two-element real vector.
%                The first element of 'XYScale' specifies the width of
%                each output pixel in X-Y space.  The second element (if
%                present) specifies the height of each output pixel.  If
%                'XYScale' has only one element, then the same value is
%                used for both width and height.  
%
%                If 'XYScale' is not specified but 'Size' is, then
%                'XYScale' is computed from 'Size', 'XData', and 'YData'.
%                If neither 'XYScale' nor 'Size' is provided, then
%                the scale of the input pixels is used for 'XYScale'.
%
%   'Size'       A two-element vector of nonnegative integers.
%                'Size' specifies the number of rows and columns of the
%                output image B.  For higher dimensions, the size of B is
%                taken directly from the size of A.  In other words,
%                size(B,k) equals size(A,k) for k > 2.
%
%                If 'Size' is not specified, then it is computed from
%                'XData', 'YData', and 'XYScale'.
%
%   'FillValues' An array containing one or several fill values.
%                Fill values are used for output pixels when the
%                corresponding transformed location in the input image is
%                completely outside the input image boundaries.  If A is
%                2-D then 'FillValues' must be a scalar.  However, if A's
%                dimension is greater than two, then 'FillValues' can be
%                an array whose size satisfies the following constraint:
%                size(fill_values,k) must either equal size(A,k+2) or 1.
%                For example, if A is a uint8 RGB image that is
%                200-by-200-by-3, then possibilities for 'FillValues'
%                include:
%
%                    0                 - fill with black
%                    [0;0;0]           - also fill with black
%                    255               - fill with white
%                    [255;255;255]     - also fill with white
%                    [0;0;255]         - fill with blue
%                    [255;255;0]       - fill with yellow
%
%                If A is 4-D with size 200-by-200-by-3-by-10, then
%                'FillValues' can be a scalar, 1-by-10, 3-by-1, or
%                3-by-10.
%
%   Notes
%   -----
%   - When you do not specify the output-space location for B using
%     'XData' and 'YData', IMTRANSFORM estimates them automatically using
%     the function FINDBOUNDS.  For some commonly-used transformations,
%     such as affine or projective, for which a forward-mapping is easily
%     computable, FINDBOUNDS is fast.  For transformations that do not
%     have a forward mapping, such as the polynomial ones computed by
%     CP2TFORM, FINDBOUNDS can take significantly longer.  If you can
%     specify 'XData' and 'YData' directly for such transformations,
%     IMTRANSFORM may run noticeably faster.
%
%   - The automatic estimate of 'XData' and 'YData' using FINDBOUNDS is
%     not guaranteed in all cases to completely contain all the pixels of
%     the transformed input image.
%
%   - The output values XDATA and YDATA may not exactly equal the input
%     'XData and 'YData' parameters.  This can happen either because of
%     the need for an integer number or rows and columns, or if you
%     specify values for 'XData', 'YData', 'XYScale', and 'Size' that
%     are not entirely consistent.  In either case, the first element of
%     XDATA and YDATA always equals the first element of 'XData' and
%     'YData', respectively.  Only the second elements of XDATA and YDATA
%     might be different.
%
%   - IMTRANSFORM assumes spatial-coordinate conventions for the
%     transformation TFORM.  Specifically, the first dimension of the
%     transformation is the horizontal or x-coordinate, and the second
%     dimension is the vertical or y-coordinate.  Note that this is the
%     reverse of MATLAB's array subscripting convention.
%
%   - TFORM must be a 2-D transformation to be used with IMTRANSFORM.
%     For arbitrary-dimensional array transformations, see TFORMARRAY.
%
%   Class Support
%   -------------
%   A can be of any nonsparse numeric class, real or complex.  It can also be
%   logical.  The class of B is the same as the class of A.
%
%   Example 1
%   ---------
%   Apply a horizontal shear to an intensity image.
%
%       I = imread('cameraman.tif');
%       tform = maketform('affine',[1 0 0; .5 1 0; 0 0 1]);
%       J = imtransform(I,tform);
%       imview(I), imview(J)
%
%   Example 2
%   ---------
%   A projective transformation can map a square to a quadrilateral.  In
%   this example, set up an input coordinate system so that the input
%   image fills the unit square and then transform the image from the
%   quadrilateral with vertices (0 0), (1 0), (1 1), (0 1) to the
%   quadrilateral with vertices (-4 2), (-8 -3), (-3 -5), and (6 3).  Fill
%   with gray and use bicubic interpolation.  Make the output size the
%   same as the input size.
%
%       I = imread('cameraman.tif');
%       udata = [0 1];  vdata = [0 1];  % input coordinate system
%       tform = maketform('projective',[ 0 0;  1  0;  1  1; 0 1],...
%                                      [-4 2; -8 -3; -3 -5; 6 3]);
%       [B,xdata,ydata] = imtransform(I,tform,'bicubic','udata',udata,...
%                                                       'vdata',vdata,...
%                                                       'size',size(I),...
%                                                       'fill',128);
%       subplot(1,2,1), imshow(udata,vdata,I), axis on
%       subplot(1,2,2), imshow(xdata,ydata,B), axis on
%
%   Example 3
%   ---------  
%   Register an aerial photo to an orthophoto.
%  
%       unregistered = imread('westconcordaerial.png');
%       imview(unregistered)
%       imview('westconcordorthophoto.png')
%       load westconcordpoints % load some points that were already picked     
%       t_concord = cp2tform(input_points,base_points,'projective');
%       info = imfinfo('westconcordorthophoto.png');
%       registered = imtransform(unregistered,t_concord,...
%                                'XData',[1 info.Width], 'YData',[1 info.Height]);
%       imview(registered)                       
%
%   See also CP2TFORM, IMRESIZE, IMROTATE, MAKETFORM, MAKERESAMPLER, TFORMARRAY.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.18.4.3 $  $Date: 2003/08/01 18:09:11 $

% Input argument details
% ----------------------
% A              numeric nonsparse array, any dimension, real or complex
%                may be logical
%                may be empty
%                NaN's and Inf's OK
%                required
%
% TFORM          valid TFORM struct as returned by MAKETFORM
%                checked using private/istform
%                required
%
% INTERP         one of these strings: 'nearest', 'linear', 'cubic'
%                case-insensitive match
%                nonambiguous abbreviations allowed
%
%                OR a resampler structure as returned by makeresampler
%                checked using private/isresample
%
%                optional; defaults to 'linear'
%
% 'FillValues'   double real matrix
%                Inf's and NaN's allowed
%                may be []
%                optional; defaults to 0
%                
% 'UData'        2-element real double vector
%                No Inf's or NaN's
%                The two elements must be different unless A has only
%                    one column
%                optional; defaults to [1 size(A,2)]
%
% 'VData'        2-element real double vector
%                No Inf's or NaN's
%                The two elements must be different unless A has only
%                    one row
%                optional; defaults to [1 size(A,1)]
%
% 'XData'        2-element real double vector
%                No Inf's or NaN's
%                optional; if not provided, computed using findbounds
%
% 'YData'        2-element real double vector
%                No Inf's or NaN's
%                optional; if not provided, computed using findbounds
%
% 'XYScale'      1-by-2 real double vector
%                elements must be positive
%                optional; default is the horizontal and vertical
%                  scale of the input pixels.
%
% 'Size'         real double row-vector
%                elements must be nonnegative integers
%                Can be 1-by-2 or 1-by-numdims(A).  If it is
%                  1-by-numdims(A), sizeB(3:end) must equal
%                  sizeA(3:end).
%                optional; default computation:
%                  num_rows = ceil(abs(ydata(2) - ydata(1)) ./ xyscale(2)) + 1;
%                  num_cols = ceil(abs(xdata(2) - xdata(1)) ./ xyscale(1)) + 1;
%
% If Size is provided and XYScale is not provided, then the output xdata
% and ydata will be the same as the input XData and YData.  Otherwise,
% the output xdata and ydata must be modified to account for the fact
% that the output size is contrained to contain only integer values.
% The first elements xdata and ydata is left alone, but the second
% values may be altered to make them consistent with Size and XYScale.

args = parse_inputs(varargin{:});

args.tform = make_composite_tform(args);

% imtransform uses x-y convention for ordering dimensions.
tdims_a = [2 1];
tdims_b = [2 1];

tsize_b = args.size([2 1]);
tmap_b = [];

B = tformarray(args.A, args.tform, args.resampler, tdims_a, tdims_b, ...
               tsize_b, tmap_b, args.fill_values);

xdata = args.xdata;
ydata = args.ydata;

%--------------------------------------------------
function [xdata,ydata] = recompute_output_bounds(args)

% For the purpose of this computation, change any 0's in out_size
% to 1's.
out_size = max(args.size, 1);

xdata = args.xdata;
ydata = args.ydata;

xdata(2) = args.xdata(1) + (out_size(2) - 1) .* args.xyscale(1) .* ...
    sign(args.xdata(2) - args.xdata(1));

ydata(2) = args.ydata(1) + (out_size(1) - 1) .* args.xyscale(2) .* ...
    sign(args.ydata(2) - args.ydata(1));

%--------------------------------------------------
function xyscale = compute_xyscale(args)

size_A = size(args.A);
xscale = compute_scale(args.udata, size_A(2));
yscale = compute_scale(args.vdata, size_A(1));

% If the output size would otherwise be twice the input size
% (in both dimensions), then multiply the output scale by a
% factor greater than 1.  This makes the output pixels larger
% (as measured in the output transform coordinates) and limits
% the size of the output image.

minscale = min(abs(args.xdata(2) - args.xdata(1)) / (2*size_A(2)),...
               abs(args.ydata(2) - args.ydata(1)) / (2*size_A(1)));

if xscale > minscale && yscale > minscale
  xyscale = [xscale yscale];
else
  xyscale = [xscale yscale] * minscale / max(xscale,yscale);
end

%--------------------------------------------------
function scale = compute_scale(udata, N)

scale_numerator = udata(2) - udata(1);
scale_denominator = max(N - 1, 0);
if scale_denominator == 0
    if scale_numerator == 0
        scale = 1;
    else
        eid = sprintf('Images:%s:unclearSpatialLocation',mfilename);
        msg = '''UData'' or ''VData'' is inconsistent with size(A).';
        error(eid,'%s',msg);
    end
else
    scale = scale_numerator / scale_denominator;
end

%--------------------------------------------------
function new_tform = make_composite_tform(args)

reg_b = maketform('box', fliplr(args.size(1:2)), ...
                  [args.xdata(1) args.ydata(1)], ...
                  [args.xdata(2) args.ydata(2)]);

in_size = size(args.A);
in_size = in_size(1:2);

reg_a = maketform('box', fliplr(in_size), ...
                  [args.udata(1) args.vdata(1)], ...
                  [args.udata(2) args.vdata(2)]);

new_tform = maketform('composite', fliptform(reg_b), args.tform, reg_a);

%--------------------------------------------------
function args = parse_inputs(varargin)

checknargin(2,Inf,nargin,mfilename);

args.resampler = [];
args.fill_values = 0;
args.udata = [];
args.vdata = [];
args.xdata = [];
args.ydata = [];
args.size = [];
args.xyscale = [];

args.A = check_A(varargin{1});
args.tform = check_tform(varargin{2});

if rem(nargin,2) == 1
    % IMTRANSFORM(A,TFORM,INTERP,<<prop/value pairs>>)
    args.resampler = check_resampler(varargin{3});
    first_prop_arg = 4;
else
    % IMTRANSFORM(A,TFORM,<<prop/value pairs>>)
    args.resampler = makeresampler('linear', 'fill');
    first_prop_arg = 3;
end

for k = first_prop_arg:2:nargin
    prop_string = check_property_string(varargin{k});
    switch prop_string
      case 'fillvalues'
        args.fill_values = check_fill_values(varargin{k+1},args.A,args.tform);
        
      case 'udata'
        args.udata = check_udata(varargin{k+1}, args.A);
        
      case 'vdata'
        args.vdata = check_vdata(varargin{k+1}, args.A);
        
      case 'xdata'
        args.xdata = check_xydata(varargin{k+1});
        
      case 'ydata'
        args.ydata = check_xydata(varargin{k+1});
        
      case 'size'
        args.size = check_size(varargin{k+1}, args.A);
        
      case 'xyscale'
        args.xyscale = check_xyscale(varargin{k+1});
        
      otherwise
        eid = sprintf('Images:%s:internalError',mfilename);
        msg = sprintf('Internal problem: unrecognized property string: %s', ...
                      prop_string);
        error(eid,'%s',msg);
    end
end

%
% Provide default values that require calculation.
%
if isempty(args.udata)
    args.udata = [1 size(args.A, 2)];
end

if isempty(args.vdata)
    args.vdata = [1 size(args.A, 1)];
end

if (isempty(args.xdata) + isempty(args.ydata) == 1)
    eid = sprintf('Images:%s:missingXDataAndYData',mfilename);
    msg1 = 'If either ''XData'' or ''YData'' is specified, ';
    msg2 = 'then both must be specified.';
    error(eid,'%s%s',msg1,msg2);
end

if isempty(args.xdata)
    % Output bounds not provided - estimate them.
    input_bounds = [args.udata(1) args.vdata(1);
                    args.udata(2) args.vdata(2)];
    try
        output_bounds = findbounds(args.tform, input_bounds);
        args.xdata = [output_bounds(1,1) output_bounds(2,1)];
        args.ydata = [output_bounds(1,2) output_bounds(2,2)];
    catch
        eid = sprintf('Images:%s:unestimableOutputBounds',mfilename);
        msg1 = 'XData and YData could not be automatically determined.';
        msg2 = 'Try specifying XData and YData explicitly in the call';
        msg3 = ' to IMTRANSFORM.';
        error(eid,'%s%s%s',msg1,msg2,msg3);
    end
end

if ~isempty(args.size)
    % Output size was provided.
    if ~isempty(args.xyscale)
        % xy_scale was provided; recompute bounds.
        [args.xdata,args.ydata] = recompute_output_bounds(args);
    else
        % Do nothing.  Scale was not provided but it is not needed.
    end

else
    % Output size was not provided.
    if isempty(args.xyscale)
        % Output scale was not provided.  Use the scale of the input
        % pixels.
        args.xyscale = compute_xyscale(args);
    end
    
    % Compute output size.
    num_rows = ceil(abs(args.ydata(2) - args.ydata(1)) ./ args.xyscale(2)) + 1;
    num_cols = ceil(abs(args.xdata(2) - args.xdata(1)) ./ args.xyscale(1)) + 1;
    args.size = [num_rows, num_cols];
    
    [args.xdata,args.ydata] = recompute_output_bounds(args);
end

%--------------------------------------------------
function A = check_A(A)

if (~isnumeric(A) && ~islogical(A)) || issparse(A)
    eid = sprintf('Images:%s:invalidImage',mfilename);
    msg = 'A must be a nonsparse numeric array.';
    error(eid,'%s',msg);
end

%--------------------------------------------------
function tform = check_tform(tform)

if ~istform(tform)
    eid = sprintf('Images:%s:invalidTFORM',mfilename);
    msg = 'Second input argument must be a valid TFORM structure.';
    error(eid,'%s',msg);
end

%--------------------------------------------------
function r = check_resampler(r)

if ischar(r)
    valid_strings = {'nearest','linear','cubic','bilinear','bicubic'};

    idx = strmatch(lower(r), valid_strings);
    switch length(idx)
      case 0
        eid = sprintf('Images:%s:unknownINTERP',mfilename);
        msg = sprintf('Unrecognized interpolation option: ''%s''', r);
        error(eid,'%s',msg);
      case 1
        r = valid_strings{idx};
        if strcmp(r,'bicubic')
            r = 'cubic';
        end
        if strcmp(r,'bilinear')
            r = 'linear';
        end
                
      otherwise
        eid = sprintf('Images:%s:ambiguousINTERP',mfilename);
        msg = sprintf('Ambiguous interpolation option: ''%s''', r);
        error(eid,'%s',msg); 
    end
    
    r = makeresampler(r, 'fill');
else
    if ~isresampler(r)
        eid = sprintf('Images:%s:invalidResampler',mfilename);
        msg1 = 'INTERP must be ''nearest'', ''linear'', ''cubic'',';
        msg2 = 'or a valid resampler as returned by MAKERESAMPLER.';
        error(eid,'%s%s', msg1, msg2);
    end
end


%--------------------------------------------------
function prop_string = check_property_string(prop_string)

if ~ischar(prop_string)
    eid = sprintf('Images:%s:invalidPropertyName',mfilename);
    msg = 'Property names must be strings.';
    error(eid,'%s',msg);
end

valid_strings = {'fillvalues'
                 'udata'
                 'vdata'
                 'xdata'
                 'ydata'
                 'xyscale'
                 'size'};

idx = strmatch(lower(prop_string), valid_strings);
switch length(idx)
 case 0
    eid = sprintf('Images:%s:unknownPropertyName',mfilename);
    msg = sprintf('Unrecognized property name: ''%s''', prop_string);
    error(eid,'%s',msg);
    
  case 1
    prop_string = valid_strings{idx};
    
  otherwise
    eid = sprintf('Images:%s:ambiguousPropertyName',mfilename);
    msg = sprintf('Ambiguous property name: ''%s''', prop_string);
    error(eid,'%s',msg);

end

%--------------------------------------------------
function fill_values = check_fill_values(fill_values, A, tform)

N = tform.ndims_in;
size_F = size(fill_values);
size_A = size(A);
osize = size_A(N+1:end);
size_diff = length(osize) - length(size_F);
if size_diff < 0
    osize = [osize ones(1, -size_diff)];
else
    size_F = [size_F ones(1, size_diff)];
end

idx = find(size_F ~= osize);
if ~isempty(idx)
    if ~all(size_F(idx) == 1)
        eid = sprintf('Images:%s:invalidFillValues',mfilename);
        msg = 'Invalid size for ''FillValues''.';
        error(eid,'%s',msg);
    end
end

%--------------------------------------------------
function udata = check_udata(udata, A)


[m,n] = size(udata);

if ~(ndims(udata) == 2) || ~isa(udata,'double') || ...
        (m ~= 1) || (n ~= 2) || ~isreal(udata)
    eid = sprintf('Images:%s:invalidUData',mfilename);
    msg = '''UData'' must be a real, double, 1-by-2 vector.';
    error(eid,'%s',msg);
end

if any(~isfinite(udata(:)))
    eid = sprintf('Images:%s:uDataContainsNansOrInfs',mfilename);
    msg = '''UData'' must not contain NaN''s or Inf''s.';
    error(eid,'%s',msg);
end

if (udata(1) == udata(2)) && (size(A,2) ~= 1)
    eid = sprintf('Images:%s:uDataContainsInvalidElements',mfilename);
    msg = '''UData'' elements cannot be equal unless A has only one column.';
    error(eid,'%s',msg);
end

%--------------------------------------------------
function vdata = check_vdata(vdata, A)

[m,n] = size(vdata);

if ~(ndims(vdata) == 2) || ~isa(vdata,'double') || ...
        (m ~= 1) || (n ~= 2) || ~isreal(vdata)
    eid = sprintf('Images:%s:invalidVData',mfilename);
    msg = '''VData'' must be a real, double, 1-by-2 vector.';
    error(eid,'%s',msg);
end

if any(~isfinite(vdata(:)))
    eid = sprintf('Images:%s:vDataContainsNansOrInfs',mfilename);
    msg = '''VData'' must not contain NaN''s or Inf''s.';
    error(eid,'%s',msg);
end

if (vdata(1) == vdata(2)) && (size(A,1) ~= 1)
    eid = sprintf('Images:%s:vDataContainsInvalidElements',mfilename);
    msg = '''VData'' elements cannot be equal unless A has only one row.';
    error(eid,'%s',msg);
end

%--------------------------------------------------
function xdata = check_xydata(xdata)

[m,n] = size(xdata);
if ~(ndims(xdata) == 2) || ~isa(xdata,'double') || ...
        (m ~= 1) || (n ~= 2) || ~isreal(xdata)
    eid = sprintf('Images:%s:invalidXDataYData',mfilename);
    msg = '''XData'' and ''YData'' must be real, double, 1-by-2 vectors.';
    error(eid,'%s',msg);
end

if any(~isfinite(xdata(:)))
    eid = sprintf('Images:%s:xDataYDataContainsNansOrInfs',mfilename);
    msg = '''XData'' and ''YData'' must not contain NaN''s or Inf''s.';
    error(eid,'%s',msg);
end

%--------------------------------------------------
function output_size = check_size(output_size, A)
  
[m,n] = size(output_size);
size_A = size(A);
if ~isa(output_size,'double') || (m ~= 1) || ~isreal(output_size)
    eid = sprintf('Images:%s:invalidOutputSize',mfilename);
    msg = '''Size'' must be real double row vector.';
    error(eid,'%s',msg);
end

if (n ~= 2) && n ~= ndims(A)
    eid = sprintf('Images:%s:invalidNumElementsInOutputSize',mfilename);
    msg = '''Size'' must have either 2 or ndims(A) elements.';
    error(eid,'%s',msg);
end

if (n > 2) && ~isequal(output_size(3:end), size_A(3:end))
    eid = sprintf('Images:%s:invalidOutputSizeGreaterThan2D',mfilename);
    msg = '''Size'' must equal size(A) in the 3rd and higher dimensions.';
    error(eid,'%s',msg);
end

if any(~isfinite(output_size(:)))
    eid = sprintf('Images:%s:outputSizeContainsNansOrInfs',mfilename);
    msg = '''Size'' must not contain NaN''s or Inf''s.';
    error(eid,'%s',msg);
end

if any(floor(output_size(:)) ~= output_size(:)) || any(output_size(:) < 0)
    eid = sprintf('Images:%s:outputSizeContainsInvalidElements',mfilename);
    msg = '''Size'' must contain nonnegative integers.';
    error(eid,'%s',msg);
end

%--------------------------------------------------
function xyscale = check_xyscale(xyscale)

[m,n] = size(xyscale);

if ~isa(xyscale,'double') || (m ~= 1) || ((n ~= 1) && (n ~= 2)) || ...
        ~isreal(xyscale)
    eid = sprintf('Images:%s:invalidXYScale',mfilename);
    msg = '''XYScale'' must be a real, double, 1-by-1 or 1-by-2 vector.';
    error(eid,'%s',msg);
end

if any(~isfinite(xyscale(:)))
    eid = sprintf('Images:%s:xyScaleContainsNansOrInfs',mfilename);
    msg = '''XYScale'' must not contain NaN''s or Inf''s.';
    error(eid,'%s',msg);
end

if any(xyscale(:) <= 0)
    eid = sprintf('Images:%s:xyScaleHasNegativeValues',mfilename);
    msg = '''XYScale'' must contain positive values.';
    error(eid,'%s',msg);
end

if length(xyscale) == 1
    xyscale = [xyscale xyscale];
end
