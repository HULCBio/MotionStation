function s = filternorm(b,a,pnorm,tol)
%FILTERNORM は、デジタルフィルタの2-ノルム、あるいは、無限ノルムを
%計算します。
%   FILTERNORM(B,A) は、ベクトルB および Aにおける分子の係数と分母の
%   係数により与えられる、デジタルフィルタの2-ノルムを返します。 
%
%   FILTERNORM(B,A,PNORM) は、フィルタの2-ノルム、あるいは、無限-ノルム
%   を返します。 
%   PNORM は、2､あるいは､infのいずれかとなります。デフォルトでは、
%   2-ノルムが、返されます。
%   IIR フィルタの2-ノルムを計算する場合、FILTERNORM(...,TOL) は、
%   より高い、あるいは、より低い精度の許容誤差を指定します。 
%   デフォルトでは、TOL = 1e-8 です。
%
%   例題:
%   % IIR フィルタに対する1e-10の許容誤差をもつ2-ノルムの計算
%   [b,a] = butter(5,.5);
%   L2 = filternorm(b,a,2,1e-10); 
%
%   % FIR フィルタに対する無限ノルムの計算
%   b = firpm(30,[.1 .9],[1 1],'Hilbert');
%   Linf = filternorm(b,1,inf);    
%
%   参考 ZP2SOS, NORM.

%   Reference:
%     Leland B. Jackson, Digital Filters and Signal Processing, 3rd Ed.
%     Kluwer Academic Publishers, 1996, Chapter 11.

%   Author(s): R. Losada 

error(nargchk(2,4,nargin));
if nargin == 2, pnorm = 2; end

% Form a df2t filter object
f = df2t(b,a);

% Check for stability
if ~isstable(f),
    error('The filter must be stable.');
end

if isinf(pnorm),
    % inf-norm is simply given by the max of the magnitude response
    h = freqz(f,1024);
    s = max(abs(h));
    return
end

if pnorm == 2,
    % Convert f to transfer function.
    [b,a] = tf(f);
    
    if isfir(f),
        % For a FIR filter, compute 2-norm by simply summing up the 
        % square of the impulse response.        
        s = norm(b);
        if nargin == 4,
            warning('Tolerance is only used when computing the 2-norm of an IIR filter.');
        end
    else
        % Default tolerance
        if nargin < 4, tol = 1e-8; end
        
        % For a IIR filter, compute 2-norm by approximating the impulse response
        % as finite, alternatively use residues to compute contour integral
        maxradius = max(abs(roots(a)));
        
        % Include an extra check for stability in case numerical roundoff problems
        if maxradius >= 1,
            error('Filter is unstable within numerical precision.');
        end
        
        % Determine the number of impulse response points
        N = impzlength(b,a,tol);
        H = impz(b,a,N);
        s = norm(H);
    end
end

% [EOF]


%   Copyright 1988-2002 The MathWorks, Inc.
