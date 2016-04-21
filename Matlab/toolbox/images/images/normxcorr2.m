function C = normxcorr2(varargin)
%NORMXCORR2 Normalized two-dimensional cross-correlation.
%   C = NORMXCORR2(TEMPLATE,A) computes the normalized cross-correlation of
%   matrices TEMPLATE and A. The matrix A must be larger than the matrix
%   TEMPLATE for the normalization to be meaningful. The values of TEMPLATE
%   cannot all be the same. The resulting matrix C contains correlation
%   coefficients and its values may range from -1.0 to 1.0.
%
%   Class Support
%   -------------
%   The input matrices can be of class logical, uint8, uint16, or double.
%   The output matrix C is double.
%
%   Example
%   -------
%   template = .2*ones(11); % make light gray plus on dark gray background
%   template(6,3:9) = .6;   
%   template(3:9,6) = .6;
%   BW = template > 0.5;      % make white plus on black background
%   imview(BW), imview(template)
%   % make new image that offsets the template
%   offsetTemplate = .2*ones(21); 
%   offset = [3 5];  % shift by 3 rows, 5 columns
%   offsetTemplate( (1:size(template,1))+offset(1),...
%                   (1:size(template,2))+offset(2) ) = template;
%   imview(offsetTemplate)
%   
%   % cross-correlate BW and T_offset to recover offset  
%   cc = normxcorr2(BW,offsetTemplate); 
%   [max_cc, imax] = max(abs(cc(:)));
%   [ypeak, xpeak] = ind2sub(size(cc),imax(1));
%   corr_offset = [ (ypeak-size(T,1)) (xpeak-size(T,2)) ];
%   isequal(corr_offset,offset) % 1 means offset was recovered
%
%  See also CORRCOEF.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.12.4.4 $  $Date: 2003/08/23 05:53:05 $

%   Input-output specs
%   ------------------
%   T:    2-D, real, full matrix
%         logical, uint8, uint16, or double
%         no NaNs, no Infs
%         prod(size(T)) >= 2
%         std(T(:))~=0
%
%   A:    2-D, real, full matrix
%         logical, uint8, uint16, or double
%         no NaNs, no Infs
%         size(A,1) >= size(T,1)
%         size(A,2) >= size(T,2)
%
%   C:    double
%
[T, A] = ParseInputs(varargin{:});

%   We normalize the cross correlation to get correlation coefficients using
%   the definition of Haralick and Shapiro, Volume II (p. 317), generalized
%   to two-dimensions.

xcorr_TA = xcorr2_fast(T,A);

[m n] = size(T);
mn = m*n;

local_sum_A = local_sum(A,m,n);
local_sum_A2 = local_sum(A.*A,m,n);

denom_A = sqrt( ( local_sum_A2 - (local_sum_A.^2)/mn ) / (mn-1) );
denom_T = std(T(:));
denom = denom_T*denom_A;
numerator = (xcorr_TA - local_sum_A*sum(T(:))/mn ) / (mn-1);

% We know denom_T~=0 from input parsing;
% so denom is only zero where denom_A is zero, and in 
% these locations, C is also zero.
C = zeros(size(numerator));
i_nonzero = find(denom_A~=0);
C(i_nonzero) = numerator(i_nonzero) ./ denom(i_nonzero);

%-------------------------------
% Function  local_sum
%
function local_sum_A = local_sum(A,m,n)

% We thank Eli Horn for providing this code, used with his permission,
% to speed up the calculation of local sums. The algorithm depends on
% precomputing running sums as described in "Fast Normalized
% Cross-Correlation", by J. P. Lewis, Industrial Light & Magic.
% http://www.idiom.com/~zilla/Papers/nvisionInterface/nip.html

[mA,nA]=size(A);

B = [zeros(m,nA+2*n-1);
     zeros(mA,n) A zeros(mA,n-1);
     zeros(m-1,nA+2*n-1)];
s = cumsum(B,1);
c = s(1+m:end,:)-s(1:end-m,:);
s = cumsum(c,2);
local_sum_A = s(:,1+n:end)-s(:,1:end-n);


%-------------------------------
% Function  xcorr2_fast
%
function cross_corr = xcorr2_fast(T,A)

T_size = size(T);
A_size = size(A);
outsize = A_size + T_size - 1;

% figure out when to use spatial domain vs. freq domain
conv_time = time_conv2(T_size,A_size); % 1 conv2
fft_time = 3*time_fft2(outsize); % 2 fft2 + 1 ifft2

if (conv_time < fft_time)
    cross_corr = conv2(rot90(T,2),A);
else
    cross_corr = freqxcorr(T,A,outsize);
end


%-------------------------------
% Function  freqxcorr
%
function xcorr_ab = freqxcorr(a,b,outsize)
  
% calculate correlation in frequency domain
Fa = fft2(rot90(a,2),outsize(1),outsize(2));
Fb = fft2(b,outsize(1),outsize(2));
xcorr_ab = real(ifft2(Fa .* Fb));


%-------------------------------
% Function  time_conv2
%
function time = time_conv2(obssize,refsize)

% time a spatial domain convolution for 10-by-10 x 20-by-20 matrices

% a = ones(10);
% b = ones(20);
% mintime = 0.1;

% t1 = cputime;
% t2 = t1;
% k = 0;
% while (t2-t1)<mintime
%     c = conv2(a,b);
%     k = k + 1;
%     t2 = cputime;
% end
% t_total = (t2-t1)/k;

% % convolution time = K*prod(size(a))*prod(size(b))
% % t_total = K*10*10*20*20 = 40000*K
% K = t_total/40000;

% K was empirically calculated by the commented-out code above.
K = 2.7e-8; 
            
% convolution time = K*prod(obssize)*prod(refsize)
time =  K*prod(obssize)*prod(refsize);


%-------------------------------
% Function  time_fft2
%
function time = time_fft2(outsize)

% time a frequency domain convolution by timing two one-dimensional ffts

R = outsize(1);
S = outsize(2);

% Tr = time_fft(R);
% K_fft = Tr/(R*log(R)); 

% K_fft was empirically calculated by the 2 commented-out lines above.
K_fft = 3.3e-7; 
Tr = K_fft*R*log(R);

if S==R
    Ts = Tr;
else
%    Ts = time_fft(S);  % uncomment to estimate explicitly
   Ts = K_fft*S*log(S); 
end

time = S*Tr + R*Ts;

%-------------------------------
% Function time_fft
%
function T = time_fft(M)

% time a complex fft that is M elements long

vec = complex(ones(M,1),ones(M,1));
mintime = 0.1; 

t1 = cputime;
t2 = t1;
k = 0;
while (t2-t1) < mintime
    dummy = fft(vec);
    k = k + 1;
    t2 = cputime;
end
T = (t2-t1)/k;


%-------------------------------
% Function  ParseInputs
%
function [T, A, msg] = ParseInputs(varargin)

% defaults
T = [];
A = [];

msgstruct = nargchk(2,2,nargin);
if ~isempty(msgstruct);
    eid = sprintf('Images:%s:invalidNumInputs',mfilename);
    error(eid,'%s',msgstruct.message);
end

T = varargin{1};
A = varargin{2};

if (~islogical(T) && ~isnumeric(T)) || ~isreal(T) || issparse(T) || ndims(T)~=2
    eid = sprintf('Images:%s:invalidTemplate',mfilename);
    msg = 'TEMPLATE must be a 2-D, real, full matrix.';
    error(eid,'%s',msg);
end

if (~islogical(A) && ~isnumeric(A)) || ~isreal(A) || issparse(A) || ndims(A)~=2  
    eid = sprintf('Images:%s:invalidA',mfilename);
    msg = 'A must be a 2-D, real, full matrix.';
    error(eid,'%s',msg);
end

T = double(T);
A = double(A);

if any(~isfinite(T(:))) || any(~isfinite(A(:)))
    eid = sprintf('Images:%s:containsNansOrInfs',mfilename);
    msg = 'TEMPLATE and A may not contain NaN or Inf.';
    error(eid,'%s',msg);
end

if numel(T) < 2
    eid = sprintf('Images:%s:invalidTemplate',mfilename);
    msg = 'TEMPLATE must contain at least 2 elements.';
    error(eid,'%s',msg);
end

if std(T(:)) == 0
    eid = sprintf('Images:%s:sameElementsInTemplate',mfilename);
    msg = 'The values of TEMPLATE cannot all be the same.';
    error(eid,'%s',msg);
end

if size(A,1)<size(T,1) || size(A,2)<size(T,2) 
    eid = sprintf('Images:%s:invalidSizeForA',mfilename);
    msg = 'A must be the same size or larger than TEMPLATE.';
    error(eid,'%s',msg);
end
