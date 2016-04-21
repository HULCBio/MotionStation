function varargout = swt(x,n,varargin)
%SWT Discrete stationary wavelet transform 1-D.
%   SWT performs a multilevel 1-D stationary wavelet decomposition
%   using either a specific orthogonal wavelet ('wname' see 
%   WFILTERS for more information) or specific orthogonal wavelet 
%   decomposition filters.
%
%   SWC = SWT(X,N,'wname') computes the stationary wavelet
%   decomposition of the signal X at level N, using 'wname'.
%   N must be a strictly positive integer (see WMAXLEV for more
%   information). 2^N must divide length(X).
%
%   SWC = SWT(X,N,Lo_D,Hi_D) computes the stationary wavelet
%   decomposition as above given these filters as input: 
%     Lo_D is the decomposition low-pass filter and
%     Hi_D is the decomposition high-pass filter.
%     Lo_D and Hi_D must be the same length.
%
%   Output matrix SWC contains the vectors of coefficients  
%   stored row-wise: 
%   for 1 <= i <= N, SWC(i,:) contains the detail 
%   coefficients of level i and
%   SWC(N+1,:) contains the approximation coefficients of 
%   level N.
%
%   [SWA,SWD] = SWT(...) computes approximations, SWA, and
%   details, SWD, stationary wavelet coefficients. 
%   The vectors of coefficients are stored row-wise: 
%   for 1 <= i <= N,
%   SWA(i,:) contains the approximation coefficients of level i,
%   SWD(i,:) contains the detail coefficients of level i.
%
%   See also DWT, WAVEDEC.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 02-Oct-95.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/03/15 22:41:47 $

% Check arguments.
nbIn = nargin;
if nbIn < 3
  error('Not enough input arguments.');
elseif nbIn > 4
  error('Too many input arguments.');
end
if errargt(mfilename,n,'int'), error('*'), end

% Use row vector.
x = x(:)';
s = length(x);
pow = 2^n;
if rem(s,pow)>0
    sOK = ceil(s/pow)*pow;
    msg = strvcat(...
            ['The level of decomposition ' int2str(n)],...
            ['and the length of the signal ' int2str(s)],...
            'are not compatible.',...
            ['Suggested length: ' int2str(sOK)],...
            '(see Signal Extension Tool)', ...
            ' ', ...
            ['2^Level has to divide the length of the signal.'] ...
            );
    errargt(mfilename,msg,'msg');
    varargout = {[] };
    return
end

% Compute decomposition filters.
if nargin==3
    [lo,hi] = wfilters(varargin{1},'d');
else
    lo = varargin{1};   hi = varargin{2};
end

% Set DWT_Mode to 'per'.
old_modeDWT = dwtmode('status','nodisp');
modeDWT = 'per';
dwtmode(modeDWT,'nodisp');

% Compute stationary wavelet coefficients.
evenoddVal = 0;
evenLEN    = 1;
swd = zeros(n,s);
swa = zeros(n,s);
for k = 1:n

    % Extension.
    lf = length(lo);
    x  = wextend('1D',modeDWT,x,lf/2);

    % Decomposition.
    swd(k,:) = wkeep1(wconv1(x,hi),s,lf+1);
    swa(k,:) = wkeep1(wconv1(x,lo),s,lf+1);

    % upsample filters.
    lo = dyadup(lo,evenoddVal,evenLEN);
    hi = dyadup(hi,evenoddVal,evenLEN);

    % New value of x.
    x = swa(k,:);

end

if nargout==1
    varargout{1} = [swd ; swa(n,:)];
elseif nargout==2
    varargout = {swa,swd};
end     

% Restore DWT_Mode.
dwtmode(old_modeDWT,'nodisp');
