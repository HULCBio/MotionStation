function varargout = swt2(x,n,varargin)
%SWT2 Discrete stationary wavelet transform 2-D.
%   SWT2 performs a multilevel 2-D stationary wavelet analysis
%   using either a specific orthogonal wavelet ('wname' see 
%   WFILTERS for more information) or specific orthogonal wavelet 
%   decomposition filters.
%
%   SWC = SWT2(X,N,'wname') or [A,H,V,D] = SWT2(X,N,'wname') 
%   compute the stationary wavelet decomposition of the 
%   matrix X at level N, using 'wname'.
%   N must be a strictly positive integer (see WMAXLEV for more
%   information). 2^N must divide size(X,1) and size(X,2).
%
%   Outputs [A,H,V,D] are 3-D Arrays which contain the 
%   coefficients: for 1 <= i <= N,
%   A(:,:,i) contains the coefficients of approximation 
%   of level i. 
%   H(:,:,i), V(:,:,i) and D(:,:,i) contain the coefficients 
%   of details of level i, (Horiz., Vert., Diag.). 
%   SWC = [H(:,:,1:N) ; V(:,:,1:N); D(:,:,1:N); A(:,:,N)].
%
%   SWC = SWT2(X,N,Lo_D,Hi_D) or  [A,H,V,D] = SWT2(X,N,Lo_D,Hi_D)
%   compute the stationary wavelet decomposition as above,
%   given these filters as input: 
%     Lo_D is the decomposition low-pass filter and
%     Hi_D is the decomposition high-pass filter.
%     Lo_D and Hi_D must be the same length.
%
%   See also DWT2, WAVEDEC2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 02-Oct-95.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2004/03/15 22:41:48 $

% Check arguments.
nbIn = nargin;
if nbIn < 3
  error('Not enough input arguments.');
elseif nbIn > 4
  error('Too many input arguments.');
end
if errargt(mfilename,n,'int'), error('*'), end

% Preserve initial size.
s = size(x);
pow = 2^n;
if any(rem(s,pow))
    sOK = ceil(s/pow)*pow;
    oriStr = ['(' int2str(s(1))   ',' int2str(s(2)) ')'];
    sugStr = ['(' int2str(sOK(1)) ',' int2str(sOK(2)) ')'];
    msg = strvcat(...
        ['The level of decomposition ' int2str(n)],...
        ['and the size of the image ' oriStr],...
        'are not compatible.',...
        ['Suggested size: ' sugStr],...
        '(see Image Extension Tool)', ...
        ' ', ...
        ['2^Level has to divide the size of the image.'] ...
            );
    errargt(mfilename,msg,'msg');
    varargout = {[] };
    return
end        

% Compute decomposition filters.
if ischar(varargin{1})
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
a = zeros(s(1),s(2),n);
h = zeros(s(1),s(2),n);
v = zeros(s(1),s(2),n);
d = zeros(s(1),s(2),n);
for k = 1:n

    % Extension.
    lf = length(lo);
    x  = wextend('2D',modeDWT,x,[lf/2,lf/2]);

    % Decomposition.
    y = wconv2('row',x,lo);    
    a(:,:,k) = wkeep2(wconv2('col',y,lo),s,[lf+1,lf+1]);
    h(:,:,k) = wkeep2(wconv2('col',y,hi),s,[lf+1,lf+1]);
    y = wconv2('row',x,hi);
    v(:,:,k) = wkeep2(wconv2('col',y,lo),s,[lf+1,lf+1]);
    d(:,:,k) = wkeep2(wconv2('col',y,hi),s,[lf+1,lf+1]);

    % upsample filters.
    lo = dyadup(lo,evenoddVal,evenLEN);
    hi = dyadup(hi,evenoddVal,evenLEN);

    % New value of x.
    x = a(:,:,k);

end
if nargout==4
    varargout = {a,h,v,d};

elseif nargout==1
    varargout{1} = cat(3,h,v,d,a(:,:,n));   
end

% Restore DWT_Mode.
dwtmode(old_modeDWT,'nodisp');
