function s = filternorm(b,a,pnorm,tol)
%FILTERNORM �́A�f�W�^���t�B���^��2-�m�����A���邢�́A�����m������
%�v�Z���܂��B
%   FILTERNORM(B,A) �́A�x�N�g��B ����� A�ɂ����镪�q�̌W���ƕ����
%   �W���ɂ��^������A�f�W�^���t�B���^��2-�m������Ԃ��܂��B 
%
%   FILTERNORM(B,A,PNORM) �́A�t�B���^��2-�m�����A���邢�́A����-�m����
%   ��Ԃ��܂��B 
%   PNORM �́A2����邢�ͤinf�̂����ꂩ�ƂȂ�܂��B�f�t�H���g�ł́A
%   2-�m�������A�Ԃ���܂��B
%   IIR �t�B���^��2-�m�������v�Z����ꍇ�AFILTERNORM(...,TOL) �́A
%   ��荂���A���邢�́A���Ⴂ���x�̋��e�덷���w�肵�܂��B 
%   �f�t�H���g�ł́ATOL = 1e-8 �ł��B
%
%   ���:
%   % IIR �t�B���^�ɑ΂���1e-10�̋��e�덷������2-�m�����̌v�Z
%   [b,a] = butter(5,.5);
%   L2 = filternorm(b,a,2,1e-10); 
%
%   % FIR �t�B���^�ɑ΂��閳���m�����̌v�Z
%   b = firpm(30,[.1 .9],[1 1],'Hilbert');
%   Linf = filternorm(b,1,inf);    
%
%   �Q�l ZP2SOS, NORM.

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
