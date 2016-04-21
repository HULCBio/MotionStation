function b = imfilter(varargin)
%IMFILTER Multidimensional image filtering.
%   B = IMFILTER(A,H) filters the multidimensional array A with the
%   multidimensional filter H.  A can be logical or it can be a 
%   nonsparse numeric array of any class and dimension.  The result, 
%   B, has the same size and class as A.
%
%   Each element of the output, B, is computed using double-precision
%   floating point.  If A is an integer or logical array, then output 
%   elements that exceed the range of the given type are truncated, 
%   and fractional values are rounded.
%
%   B = IMFILTER(A,H,OPTION1,OPTION2,...) performs multidimensional
%   filtering according to the specified options.  Option arguments can
%   have the following values:
%
%   - Boundary options
%
%       X            Input array values outside the bounds of the array
%                    are implicitly assumed to have the value X.  When no
%                    boundary option is specified, IMFILTER uses X = 0.
%
%       'symmetric'  Input array values outside the bounds of the array
%                    are computed by mirror-reflecting the array across
%                    the array border.
%
%       'replicate'  Input array values outside the bounds of the array
%                    are assumed to equal the nearest array border
%                    value.
%
%       'circular'   Input array values outside the bounds of the array
%                    are computed by implicitly assuming the input array
%                    is periodic.
%
%   - Output size options
%     (Output size options for IMFILTER are analogous to the SHAPE option
%     in the functions CONV2 and FILTER2.)
%
%       'same'       The output array is the same size as the input
%                    array.  This is the default behavior when no output
%                    size options are specified.
%
%       'full'       The output array is the full filtered result, and so
%                    is larger than the input array.
%
%   - Correlation and convolution
%
%       'corr'       IMFILTER performs multidimensional filtering using
%                    correlation, which is the same way that FILTER2
%                    performs filtering.  When no correlation or
%                    convolution option is specified, IMFILTER uses
%                    correlation.
%
%       'conv'       IMFILTER performs multidimensional filtering using
%                    convolution.
%
%   Notes
%   -----
%   On Intel Architecture processors, IMFILTER can take advantage of 
%   the Intel Performance Primitives Library (IPPL), thus accelerating
%   its execution time. IPPL is activated only if A and H are both
%   two dimensional and A is uint8, int16 or single.
%
%   Example 
%   -------------
%       originalRGB = imread('peppers.png'); 
%       h = fspecial('motion',50,45); 
%       filteredRGB = imfilter(originalRGB,h); 
%       imview(originalRGB), imview(filteredRGB)
%       boundaryReplicateRGB = imfilter(originalRGB,h,'replicate'); 
%       imview(boundaryReplicateRGB)
%
%   See also FSPECIAL, CONV2, CONVN, FILTER2, IPPL. 

%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.9.4.3 $  $Date: 2003/08/23 05:52:31 $

% Testing notes
% Syntaxes
% --------
% B = imfilter(A,H)
% B = imfilter(A,H,Option1, Option2,...)
%
% A:       numeric, full, N-D array.  May not be uint64 or int64 class. 
%          May be empty. May contain Infs and Nans. May be complex. Required.
%         
% H:       double, full, N-D array.  May be empty. May contain Infs and Nans.
%          May be complex. Required.
%
% A and H are not required to have the same number of dimensions. 
%
% OptionN  string or a scalar number. Not case sensitive. Optional.  An
%          error if not recognized.  While there may be up to three options
%          specified, this is left unchecked and the last option specified
%          is used.  Conflicting or inconsistent options are not checked.
%
%        A choice between these options for boundary options
%        'Symmetric' 
%        'Replicate'
%        'Circular'
%         Scalar #  - Default to zero.
%       A choice between these strings for output options
%        'Full'
%        'Same'  - default
%       A choice between these strings for functionality options
%        'Conv' 
%        'Corr'  - default       
%
% B:   N-D array the same class as A.  If the 'Same' output option was
%      specified, B is the same size as A.  If the 'Full' output option was
%      specified the size of B is size(A)+size(H)-1, remembering that if
%      size(A)~=size(B) then the missing dimensions have a size of 1.
%
% 
% IMFILTER should use a significantly less amount of memory than CONVN. 

[a,h,boundary,flags] = parse_inputs(varargin{:});
  
rank_a = ndims(a);
rank_h = ndims(h);

% Pad dimensions with ones if filter and image rank are different
size_h = [size(h) ones(1,rank_a-rank_h)];
size_a = [size(a) ones(1,rank_h-rank_a)];

if bitand(flags,8)
  %Full output
  im_size = size_a+size_h-1;
  pad = [size(h)-1 ones(1,rank_a-rank_h)];
else
  %Same output
  im_size = size(a);
  %Calculate the number of pad pixels
  filter_center = floor((size(h)+1)/2);
  pad = [size(h)-filter_center ones(1,rank_a-rank_h)];
end

%Empty Inputs
% 'Same' output then size(b) = size(a)
% 'Full' output then size(b) = size(h)+size(a)-1 
if isempty(a)
  if bitand(flags,4) %Same
    b = a;
  else %Full
    if all(im_size>0)
      b = a;
      b = b(:);
      b(prod(im_size)) = 0;
      b = reshape(b,im_size);
    elseif all(im_size>=0)
      b = feval(class(a),zeros(im_size));
    else
      eid = sprintf('Images:%s:negativeDimensionBadSizeB',mfilename);
      msg = ['Error in size of B.  At least one dimension is negative. ',...
             '\n''Full'' output size calculation is: size(B) = size(A) ',...
             '+ size(H) - 1.'];
      error(eid,msg);
    end
  end
  return;
end

if  isempty(h)
  if bitand(flags,4) %Same
    b = a;
    b(:) = 0;
  else %Full
    if all(im_size>0)
      b = a;
      if im_size<size_a  %Output is smaller than input
        b(:) = [];
      else %Grow the array, is this a no-op?
        b(:) = 0;
        b = b(:);
      end
      b(prod(im_size)) = 0;
      b = reshape(b,im_size);
    elseif all(im_size>=0)
      b = feval(class(a),zeros(im_size));
    else
      eid = sprintf('Images:%s:negativeDimensionBadSizeB',mfilename);
      msg = ['Error in size of B.  At least one dimension is negative. ',...
             '\n''Full'' output size calculation is: size(B) = size(A) +',...
             ' size(H) - 1.'];
      error(eid,msg);
    end
  end
  return;
end

im_size = int32(im_size);

%Starting point in padded image, zero based.
start = int32(pad);

%Pad image
a = padarray(a,pad,boundary,'both');

%Create connectivity matrix.  Only use nonzero values of the filter.
conn_logical = h~=0;
conn = double( conn_logical );  %input to the mex file must be double

nonzero_h = h(conn_logical);

% Seperate real and imaginary parts of the filter (h) in the M-code and
% filter imaginary and real parts of the image (a) in the mex code. 
checkMexFileInputs(a,im_size,real(h),real(nonzero_h),conn,start,flags);
b1 = imfilter_mex(a,im_size,real(h),real(nonzero_h),conn,start,flags);

if ~isreal(h)
  checkMexFileInputs(a,im_size,imag(h),imag(nonzero_h),conn,start,flags);
  b2 = imfilter_mex(a,im_size,imag(h),imag(nonzero_h),conn,start,flags);
end

%If input is not complex, the output should not be complex. COMPLEX always
%creates an imaginary part even if the imaginary part is zeros.
if isreal(h)
  % b will always be real
  b = b1;
elseif isreal(a)
  % b1 and b2 will always be real. b will always be complex
  b = complex(b1,b2);
else
  % b1 and/or b2 may be complex.  b will always be complex
  b = complex(imsubtract(real(b1),imag(b2)),imadd(imag(b1),real(b2)));
end

%======================================================================

function [a,h,boundary,flags ] = parse_inputs(a,h,varargin)

checknargin(2,5,nargin,mfilename);

checkinput(a,{'numeric' 'logical'},{'nonsparse'},mfilename,'A',1);
checkinput(h,{'double'},{'nonsparse'},mfilename,'H',2);

%Assign defaults
flags = 0;
boundary = 0;  %Scalar value of zero
output = 'same';
do_fcn = 'corr';

allStrings = {'replicate', 'symmetric', 'circular', 'conv', 'corr', ...
              'full','same'};

for k = 1:length(varargin)
  if ischar(varargin{k})
    string = checkstrs(varargin{k}, allStrings,...
                       mfilename, 'OPTION',k+2);
    switch string
     case {'replicate', 'symmetric', 'circular'}
      boundary = string;
     case {'full','same'}
      output = string;
     case {'conv','corr'}
      do_fcn = string;
    end
  else
    checkinput(varargin{k},{'numeric'},{'nonsparse'},mfilename,'OPTION',k+2);
    boundary = varargin{k};
  end %else
end

if strcmp(output,'full')
  flags = bitor(flags,8);
elseif strcmp(output,'same');
  flags = bitor(flags,4);
end

if strcmp(do_fcn,'conv')
  flags = bitor(flags,2);
elseif strcmp(do_fcn,'corr')
  flags = bitor(flags,0);
end


%--------------------------------------------------------------
function checkMexFileInputs(varargin)
% a
a = varargin{1};
checkinput(a,{'numeric' 'logical'},{'nonsparse'},mfilename,'A',1);

% im_size
im_size = varargin{2};
if ~strcmp(class(im_size),'int32') || issparse(im_size)
  displayInternalError('im_size');
end

% h
h = varargin{3};
if ~isa(h,'double') || ~isreal(h) || issparse(h)
  displayInternalError('h');
end

% nonzero_h
nonzero_h = varargin{4};
if ~isa(nonzero_h,'double') || ~isreal(nonzero_h) || ...
      issparse(nonzero_h)
  displayInternalError('nonzero_h');
end

% start
start = varargin{6};
if ~strcmp(class(start),'int32') || issparse(start)
  displayInternalError('start');
end

% flags
flags = varargin{7};
if ~isa(flags,'double') ||  any(size(flags) ~= 1)
  displayInternalError('flags');
end

%--------------------------------------------------------------
function displayInternalError(string)

eid = sprintf('Images:%s:internalError',mfilename);
msg = sprintf('Internal error: %s is not valid.',upper(string));
error(eid,'%s',msg);
