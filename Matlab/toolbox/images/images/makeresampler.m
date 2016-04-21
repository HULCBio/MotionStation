function r = makeresampler( varargin )
%MAKERESAMPLER Create resampling structure.
%   R = MAKERESAMPLER(INTERPOLANT,PADMETHOD) creates a separable
%   resampler structure for use with TFORMARRAY and IMTRANSFORM.
%   In its simplest form, INTERPOLANT can be one of these strings:
%   'nearest', 'linear', or 'cubic'.  INTERPOLANT specifies the
%   interpolating kernel that the separable resampler uses.  PADMETHOD
%   can be one of these strings: 'replicate', 'symmetric', 'circular',
%   'fill', or 'bound'.  PADMETHOD controls how the resampler to
%   interpolates or assigns values to output elements that map close
%   to or outside the edge of input array.
%
%   PADMETHOD options
%   -----------------
%   In the case of 'fill', 'replicate', 'circular', or 'symmetric',
%   the resampling performed by TFORMARRAY or IMTRANSFORM occurs in
%   two logical steps: (1) pad A infinitely to fill the entire input
%   transform space, then (2) evaluate the convolution of the padded
%   A with the resampling kernel at the output points specified by
%   the geometric map.  Each non-transform dimension is handled
%   separately.  The padding is virtual, (accomplished by remapping
%   array subscripts) for performance and memory efficiency.
%  
%   'circular', 'replicate', and 'symmetric' have the same meanings as
%   in PADARRAY as applied to the transform dimensions of A:
%   
%     'replicate' -- Repeats the outermost elements
%     'circular'  -- Repeats A circularly
%     'symmetric' -- Mirrors A repeatedly.
%   
%   'fill' generates an output array with smooth-looking edges (except
%   when using nearest neighbor interpolation) because for output points
%   that map near the edge of the input array (either inside or outside),
%   it combines input image and fill values .
%  
%   'bound' is like 'fill', but avoids mixing fill values and input image
%   values.  Points that map outside are assigned values from the fill
%   value array.  Points that map inside are treated as with 'replicate'. 
%   'bound' and 'fill' produce identical results when INTERPOLANT is
%   'nearest'.
% 
%   It is up to the user to implement these behaviors in the case of a
%   custom resampler.
% 
%   Advanced options for INTERPOLANT
%   --------------------------------
%   In general, INTERPOLANT can have one of these forms:
%
%       1. One of these strings: 'nearest', 'linear', 'cubic'
%
%       2. A cell array: {HALF_WIDTH, POSITIVE_HALF}
%          HALF_WIDTH is a positive scalar designating the half width of
%          a symmetric interpolating kernel.  POSITIVE_HALF is a vector
%          of values regularly sampling the kernel on the closed interval
%          [0 POSITIVE_HALF].
%
%       3. A cell array: {HALF_WIDTH, INTERP_FCN}
%          INTERP_FCN is a function handle that returns interpolating
%          kernel values given an array of input values in the interval 
%          [0 POSITIVE_HALF].
%
%       4. A cell array whose elements are one of the three forms above.
%
%   Forms 2 and 3 are used to interpolate with a custom interpolating
%   kernel.  Form 4 is used to specify the interpolation method
%   independently along each dimension.  The number of elements in the
%   cell array for form 4 must equal the number of transform dimensions.
%   For example, if INTERPOLANT is {'nearest', 'linear', {2
%   KERNEL_TABLE}}, then the resampler will use nearest-neighbor
%   interpolation along the first transform dimension, linear
%   interpolation along the second, and a custom table-based
%   interpolation along the third.
%
%   Custom resamplers
%   -----------------
%   The syntaxes described above construct a resampler structure that
%   uses the separable resampler function that ships with the Image
%   Processing Toolbox.  It is also possible to create a resampler
%   structure that uses a user-written resampler by using this syntax: 
%   R = MAKERESAMPLER(PropertyName,PropertyValue,...).  PropertyName can
%   be 'Type', 'PadMethod', 'Interpolant', 'NDims', 'ResampleFcn', or
%   'CustomData'.
%
%   'Type' can be either 'separable' or 'custom' and must always be
%   supplied.  If 'Type' is 'separable', the only other properties that can
%   be specified are 'Interpolant' and 'PadMethod', and the result is
%   equivalent to using the MAKERESAMPLER(INTERPOLANT,PADMETHOD) syntax.
%   If 'Type' is 'custom', then 'NDims' and 'ResampleFcn' are required
%   properties, and 'CustomData' is optional.  'NDims' is a positive
%   integer and indicates what dimensionality the custom resampler can
%   handle.  Use a value of Inf to indicate that the custom resampler can
%   handle any dimension.  The value of 'CustomData' is unconstrained.
%
%   'ResampleFcn' is a handle to a function that peforms the resampling.
%   The function will be called with the following interface:
%
%       B = RESAMPLE_FCN(A,M,TDIMS_A,TDIMS_B,FSIZE_A,FSIZE_B,F,R)
%
%   See the help for TFORMARRAY for information on the inputs A, TDIMS_A,
%   TDIMS_B, and F.
%
%   M is an array that maps the transform subscript space of B to the
%   transform subscript space of A.  If If A has N transform dimensions (N =
%   length(TDIMS_A)) and B has P transform dimensions (P = length(TDIMS_B)),
%   then NDIMS(M) = P + 1 if N > 1 and P if N == 1, and SIZE(M, P + 1) =
%   N.  The first P dimensions of M correspond to the output transform
%   space, permuted according to the order in which the the output
%   transform dimensions are listed in TDIMS_B.  (In general TDIMS_A and
%   TDIMS_B need not be sorted in ascending order, although such a
%   limitation may be imposed by specific resamplers.)  Thus the first P
%   elements of SIZE(M) determine the sizes of the transform dimensions of
%   B.  The input transform coordinates to which each point is mapped are
%   arrayed across the final dimension of M, following the order given in
%   TDIMS_A.  M must be double.
%
%   FSIZE_A and FSIZE_B are the full sizes of A and B, padded with 1s as
%   necessary to be consistent with TDIMS_A, TDIMS_B, and SIZE(A).
%
%   Example
%   -------
%   Stretch an image in the y-direction using separable resampler that
%   applies in cubic interpolation in the y-direction and nearest
%   neighbor interpolation in the x-direction. (This is equivalent to,
%   but faster than, applying bicubic interpolation.)
%
%       A = imread('moon.tif');
%       resamp = makeresampler({'nearest','cubic'},'fill');
%       stretch = maketform('affine',[1 0; 0 1.3; 0 0]);
%       B = imtransform(A,stretch,resamp);
%
%   See also IMTRANSFORM, TFORMARRAY.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $ $Date: 2003/08/01 18:09:24 $

msgstruct = nargchk(2,10,nargin,'struct');
if ~isempty(msgstruct)
    error(msgstruct.identifier,'%s',msgstruct.message);
end

if mod(nargin,2) ~= 0
    eid = sprintf('Images:%s:invalidNumInputs',mfilename);
    msg = 'Invalid number of arguments.';
    error(eid,'%s',msg);
end
npairs = nargin / 2;

property_strings = ...
    {'type','padmethod','interpolant','ndims','resamplefcn','customdata'};

% Check for the shorthand syntax for separable resamplers.
if npairs == 1
    if ischar(varargin{1})
        if isempty(FindValue('type', property_strings, varargin{:}))
            r = MakeSeparable( varargin{1}, varargin{2} );
            return;
        end
    else
        r = MakeSeparable( varargin{1}, varargin{2} );
        return;
    end
end

% Parse property name/property value syntax.
type = FindValue('type', property_strings, varargin{:});
if isempty(type)
    eid = sprintf('Images:%s:missingTYPE',mfilename);
    msg = 'Missing ''Type'' property.';
    error(eid,'%s',msg);
end
switch GetCanonicalString(type,'Type',{'separable','custom'})
  case 'separable'
    [interpolant, padmethod] = ParseSeparable( property_strings, varargin{:} );   
    r = MakeSeparable( interpolant, padmethod );
  case 'custom'
    r = MakeCustom( property_strings, varargin{:} );
  otherwise
    eid = sprintf('Images:%s:internalError',mfilename);
    msg = 'Internal Error: ''Type'' must be ''separable'' or ''custom''.';
    error(eid,'%s',msg);
end

%--------------------------------------------------------------------------

function r = MakeCustom( property_strings, varargin )

CheckPropertyNames('Custom',...
  {'type','padmethod','ndims','resamplefcn','customdata'}, varargin{:});

padmethod = FindValue('padmethod', property_strings, varargin{:});
if isempty(padmethod)
    padmethod = 'replicate';
end
padmethod = GetCanonicalString( padmethod, 'PadMethod', ...
                  {'fill','bound','replicate','circular','symmetric'});

n_dimensions = FindValue('ndims', property_strings, varargin{:});
eid = sprintf('Images:%s:invalidNDims',mfilename);
if isempty(n_dimensions)
    msg = 'The ''NDims'' property must be specified.';
    error(eid,'%s',msg);
end
if length(n_dimensions) ~= 1
    msg = '''NDims'' must have a scalar value.';
    error(eid,'%s',msg);
end
if ~isa(n_dimensions,'double') || ~isreal(n_dimensions)
    msg = '''NDims'' must have numeric, real value.';
    error(eid,'%s',msg);
end
if n_dimensions ~= floor(n_dimensions) || n_dimensions < 1
    msg = '''NDims'' must have a positive integer value.';
    error(eid,'%s',msg);
end

resample_fcn = FindValue('resamplefcn', property_strings, varargin{:});

if isempty(resample_fcn)
    eid = sprintf('Images:%s:resampleFcnNotSpecified',mfilename);
    msg = 'The ''ResampleFcn'' property must be specified.';
    error(eid,'%s',msg);
end

eid = sprintf('Images:%s:invalidResampleFcn',mfilename);
if length(resample_fcn) ~= 1
    msg = '''ResampleFcn'' must have a scalar value.';
    error(eid,'%s',msg);
end
if ~isa(resample_fcn,'function_handle')
    msg = '''ResampleFcn'' must have function handle value.';
    error(eid,'%s',msg);
end

rdata = FindValue('customdata', property_strings, varargin{:});
    
r = AssignResampler(n_dimensions, padmethod, resample_fcn, rdata);

%--------------------------------------------------------------------------

function [interpolant, padmethod] = ParseSeparable(property_strings, varargin)

CheckPropertyNames('Separable',...
  {'type','interpolant','padmethod'}, varargin{:});

interpolant = FindValue('interpolant', property_strings, varargin{:});
if isempty(interpolant)
    interpolant = 'linear';
end 
           
padmethod = FindValue('padmethod', property_strings, varargin{:});
if isempty(padmethod)
    padmethod = 'replicate';
end

%--------------------------------------------------------------------------

function r = MakeSeparable( interpolant, padmethod )

standardFrequency = 1000;  % Standard number of samples per unit 
n_dimensions = inf;
              
if isa(interpolant,'cell')
    if HasCustomTable(interpolant)
        rdata.K = interpolant;
    elseif HasCustomFunction(interpolant)
        rdata.K = CustomKernel(interpolant, standardFrequency);
    else
        n_dimensions = length(interpolant);
        rdata.K = MultipleKernels(interpolant, standardFrequency);
    end
else
    rdata.K = StandardKernel(interpolant, standardFrequency);
end

padmethod = GetCanonicalString( padmethod, 'PadMethod', ...
                  {'fill','bound','replicate','circular','symmetric'});

r = AssignResampler(n_dimensions, padmethod, @resampsep, rdata);

%--------------------------------------------------------------------------

function q = HasCustomTable(interpolant)

q = isa(interpolant,'cell');

if q
    q = length(interpolant) == 2;
end

if q
    q = isa(interpolant{1},'double') ...
        & length(interpolant{1}) == 1 ...
        & isreal(interpolant{1}) ...
        & isa(interpolant{2},'double') ...
        & isreal(interpolant{2});
end

if q
    q = interpolant{1} > 0;
end

%--------------------------------------------------------------------------

function q = HasCustomFunction(interpolant)

q = isa(interpolant,'cell');

if q
    q = length(interpolant) == 2;
end

if q
    q = isa(interpolant{1},'double') ...
        & length(interpolant{1}) == 1 ...
        & isreal(interpolant{1}) ...
        & isa(interpolant{2},'function_handle');
end

if q
    q = interpolant{1} > 0;
end

%--------------------------------------------------------------------------

function K = MultipleKernels( interpolant, frequency )

K = cell(1,length(interpolant));

for i = 1:length(interpolant)
    if HasCustomTable(interpolant{i})
        K{i} = interpolant{i};
    elseif HasCustomFunction(interpolant{i})
        K{i} = CustomKernel(interpolant{i}, frequency);
    else
        K{i} = StandardKernel(interpolant{i}, frequency);
    end
end

%--------------------------------------------------------------------------

function K = CustomKernel( interpolant, frequency )

halfwidth  = interpolant{1};
kernel_fcn = interpolant{2};
positiveHalf = SampleKernel(kernel_fcn, halfwidth, frequency);
K = {halfwidth, positiveHalf};

%--------------------------------------------------------------------------

function K = StandardKernel( interpolant, frequency )

interpolant = GetCanonicalString( interpolant, 'Interpolant', ...
                                  {'nearest','linear','cubic'});
switch interpolant
  case 'nearest'
    K = [];
    
  case 'linear' 
    halfwidth = 1.0;
    positiveHalf = SampleKernel(@LinearKernel, halfwidth, frequency);
    K = {halfwidth, positiveHalf};

  case 'cubic'
    halfwidth = 2.0;
    positiveHalf = SampleKernel(@CubicKernel, halfwidth, frequency);
    K = {halfwidth, positiveHalf};
    
 otherwise
    eid = sprintf('Images:%s:invalidInterpolant',mfilename);
    msg1 = 'Internal Error: INTERPOLANT must be ''nearest'', ''linear'', ';
    msg2 = 'or ''cubic''.';
    error(eid,'%s%s',msg1,msg2);
end

%--------------------------------------------------------------------------

function positiveHalf = SampleKernel( kernel, halfwidth, frequency )

if length(kernel) ~= 1 || ~isa(kernel,'function_handle')
   eid = sprintf('Images:%s:invalidKernel',mfilename);
   msg = 'kernel must be a function handle.';
   error(eid,'%s',msg);
end
n = floor(halfwidth * frequency);
positiveHalf = feval( kernel, (halfwidth / n) * (0:n) ); 

%--------------------------------------------------------------------------

function y = LinearKernel( x )

y = zeros(1,length(x));
reshape(y,size(x));
x(x < 0) = -x(x < 0);
q = (x <= 1);
y(q) = 1 - x(q);

%--------------------------------------------------------------------------

function y = CubicKernel( x )

% There is a whole family of "cubic" interpolation kernels. The 
% particular kernel used here is described in the article Keys,
% "Cubic Convolution Interpolation for Digital Image Processing,"
% IEEE Transactions on Acoustics, Speech, and Signal Processing,
% Vol. ASSP-29, No. 6, December 1981, p. 1155.

y = zeros(1,length(x));
reshape(y,size(x));
x(x < 0.0) = -x(x < 0.0);

q = (x <= 1);            % Coefficients: 1.5, -2.5, 0.0, 1.0
y(q) = ((1.5 * x(q) - 2.5) .* x(q)) .* x(q) + 1.0;

q = (1 < x & x <= 2);    % Coefficients: -0.5, 2.5, -4.0, 2.0
y(q) = ((-0.5 * x(q) + 2.5) .* x(q) - 4.0) .* x(q) + 2.0;

%--------------------------------------------------------------------------

function r = AssignResampler(n_dimensions, padmethod, resamp_fcn, rdata)

% Use this function to ensure consistency in the way we assign
% the fields of each resampling struct. Note that r.ndims = Inf
% is used to denote that the resampler supports an arbitrary
% number of dimensions.

r.ndims      = n_dimensions;
r.padmethod  = padmethod;
r.resamp_fcn = resamp_fcn;
r.rdata      = rdata;

%--------------------------------------------------------------------------

function value = FindValue( property_name, property_strings, varargin )

value = [];
for i = 1:((nargin-2)/2)
    current_name = varargin{2*i-1};
    if ischar(current_name)
        imatch = strmatch(lower(current_name),property_strings);
        nmatch = length(imatch);
        if nmatch > 1
            eid = sprintf('Images:%s:ambiguousPropertyName',mfilename);
            msg = sprintf('Ambiguous property name %s.',current_name);
            error(eid,'%s',msg);
        end
        if nmatch == 1
            canonical_name = property_strings{imatch};
            if strcmp(canonical_name, property_name)
                if isempty(value)
                    if isempty(varargin{2*i})
                        eid = sprintf('Images:%s:emptyPropertyName',mfilename);
                        msg = sprintf('Empty value for %s.',property_name);
                        error(eid,'%s',msg);
                    end
                    value = varargin{2*i};
                else
                    eid = sprintf('Images:%s:redundantPropertyName',mfilename);
                    msg = sprintf('Property %s is specified more than once.',...
                                  property_name);
                    error(eid,'%s',msg);
                end
            end
        end
    end
end

%--------------------------------------------------------------------------

function canonical_string = GetCanonicalString(...
               input_string, property_name, canonical_strings)

if ~ischar(input_string)
    eid = sprintf('Images:%s:invalidPropertyName',mfilename);
    msg = sprintf('%s must be a string.', property_name);
    error(eid,'%s',msg);
end

imatch = strmatch(lower(input_string),canonical_strings);
nmatch = length(imatch);

if nmatch == 0
    eid = sprintf('Images:%s:unknownPropertyName',mfilename);
    msg = sprintf('Unrecognized %s %s.',property_name, input_string);
    error(eid,'%s',msg);
end

if nmatch > 1
    eid = sprintf('Images:%s:ambiguousPropertyName',mfilename);
    msg = sprintf('Ambiguous %s %s.',property_name, input_string);
    error(eid,'%s',msg);
end

canonical_string = canonical_strings{imatch};

%--------------------------------------------------------------------------

function CheckPropertyNames( type, valid_property_names, varargin )

for i = 1:((nargin-2)/2)
    current_name = varargin{2*i-1};
    if ischar(current_name)
        nmatch = length(strmatch(lower(current_name),valid_property_names));
        if nmatch == 0
            wid = sprintf('Images:%s:ignoredPropertyName',mfilename);
            msg = sprintf('Property name %s ignored with type %s.', ...
                          current_name, type);
            warning(wid,'%s',msg);
        end
        if nmatch > 1
            eid = sprintf('Images:%s:ambiguousPropertyName',mfilename);
            msg = sprintf('Ambiguous property name %s.', current_name);
            error(eid,'%s',msg);
        end
    else
        eid = sprintf('Images:%s:invalidPropertyName',mfilename);
        msg = 'Non-character property name.';
        error(eid,'%s',msg);
    end
end
