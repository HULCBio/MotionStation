## Copyright (c) 2010 Andrew V. Knyazev <andrew.knyazev@ucdenver.edu>
## Copyright (c) 2010 Merico .E. Argentati <Merico.Argentati@ucdenver.edu>
## All rights reserved.
##
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions are met:
##
##     1 Redistributions of source code must retain the above copyright notice,
##       this list of conditions and the following disclaimer.
##     2 Redistributions in binary form must reproduce the above copyright
##       notice, this list of conditions and the following disclaimer in the
##       documentation and/or other materials provided with the distribution.
##     3 Neither the name of the author nor the names of its contributors may be
##       used to endorse or promote products derived from this software without
##       specific prior written permission.
##
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ''AS IS''
## AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
## IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
## ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
## ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
## DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
## SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
## CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
## OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
## OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

%MAJLE	(Weak) Majorization check
%    S = MAJLE(X,Y) checks if the real part of X is (weakly) majorized by
%    the real part of Y, where X and Y must be numeric (full or sparse)
%    arrays. It returns S=0, if there is no weak majorization of X by Y,
%    S=1, if there is a weak majorization of X by Y, or S=2, if there is a
%    strong majorization of X by Y. The shapes of X and Y are ignored.
%    NUMEL(X) and NUMEL(Y) may be different, in which case one of them is
%    appended with zeros to match the sizes with the other and, in case of
%    any negative components, a special warning is issued.  
%
%    S = MAJLE(X,Y,MAJLETOL) allows in addition to specify the tolerance in
%    all inequalities [S,Z] = MAJLE(X,Y,MAJLETOL) also outputs a row vector
%    Z, which appears in the definition of the (weak) majorization. In the
%    traditional case, where the real vectors X and Y are of the same size,
%    Z = CUMSUM(SORT(Y,'descend')-SORT(X,'descend')). Here, X is weakly
%    majorized by Y, if MIN(Z)>0, and strongly majorized if MIN(Z)=0, see
%    http://en.wikipedia.org/wiki/Majorization
%
%    The value of MAJLETOL depends on how X and Y have been computed, i.e.,
%    on what the level of error in X or Y is. A good minimal starting point
%    should be MAJLETOL=eps*MAX(NUMEL(X),NUMEL(Y)). The default is 0. 
%
%    % Examples:
%    x = [2 2 2]; y = [1 2 3]; s = majle(x,y)
%    % returns the value 2.
%    x = [2 2 2]; y = [1 2 4]; s = majle(x,y)
%    % returns the value 1.
%    x = [2 2 2]; y = [1 2 2]; s = majle(x,y)
%    % returns the value 0.
%    x = [2 2 2]; y = [1 2 2]; [s,z] = majle(x,y)
%    % also returns the vector z = [ 0 0 -1].
%    x = [2 2 2]; y = [1 2 2]; s = majle(x,y,1)
%    % returns the value 2.
%    x = [2 2]; y = [1 2 2]; s = majle(x,y)
%    % returns the value 1 and warns on tailing with zeros
%    x = [2 2]; y = [-1 2 2]; s = majle(x,y)
%    % returns the value 0 and gives two warnings on tailing with zeros
%    x = [2 -inf]; y = [4 inf]; [s,z] = majle(x,y)
%    % returns s = 1 and z = [Inf   Inf].
%    x = [2 inf]; y = [4 inf]; [s,z] = majle(x,y)
%    % returns  s = 1 and z = [NaN NaN] and a warning on NaNs in z.
%    x=speye(2); y=sparse([0 2; -1 1]); s = majle(x,y) 
%    % returns the value 2.
%    x = [2 2; 2 2]; y = [1 3 4]; [s,z] = majle(x,y) %and 
%    x = [2 2; 2 2]+i; y = [1 3 4]-2*i; [s,z] = majle(x,y)
%    % both return s = 2 and z = [2 3 2 0]. 
%    x = [1 1 1 1 0]; y = [1 1 1 1 1 0 0]'; s = majle(x,y)
%    % returns the value 1 and warns on tailing with zeros
%
%    % One can use this function to check numerically the validity of the
%    Schur-Horn,Lidskii-Mirsky-Wielandt, and Gelfand-Naimark theorems: 
%    clear all; n=100; majleTol=n*n*eps;
%    A = randn(n,n); A = A'+A; eA = -sort(-eig(A)); dA = diag(A);
%    majle(dA,eA,majleTol) % returns the value 2
%    % which is the Schur-Horn theorem; and 
%    B=randn(n,n); B=B'+B; eB=-sort(-eig(B)); 
%    eAmB=-sort(-eig(A-B));
%    majle(eA-eB,eAmB,majleTol) % returns the value 2 
%    % which is the Lidskii-Mirsky-Wielandt theorem; finally
%    A = randn(n,n); sA = -sort(-svd(A)); 
%    B = randn(n,n); sB = -sort(-svd(B));
%    sAB = -sort(-svd(A*B));
%    majle(log2(sAB)-log2(sA), log2(sB), majleTol) % retuns the value 2
%    majle(log2(sAB)-log2(sB), log2(sA), majleTol) % retuns the value 2
%    % which are the log versions of the Gelfand-Naimark theorems

%   Tested in MATLAB 7.9.0.529 (R2009b) and Octave 3.2.3. 
function [s,z]=majle(x,y,majleTol)

    if (nargin < 2)
        error('MAJORIZATION:majle:NotEnoughInputs',...
            'Not enough input arguments.');
    end
    if (nargin > 3)
        error('MAJORIZATION:majle:TooManyInputs',...
            'Too many input arguments.');
    end
    if (nargout > 2)
        error('MAJORIZATION:majle:TooManyOutputs',...
            'Too many output arguments.');
    end

    % Assign default values to unspecified parameters
    if (nargin == 2)
        majleTol = 0;
    end

    % transform into real (row) vectors
    x=real(x); xc=reshape(x,1,numel(x)); clear x;
    y=real(y); yc=reshape(y,1,numel(y)); clear y;

    % sort both vectors in descending order
    xc=-sort(-xc); yc=-sort(-yc);

    % tail with zeros the shorter vector to make vectors of the same length
    if size(xc,2)~=size(yc,2)
        checkForNegative = (xc(end) < -majleTol) || (yc(end) < -majleTol);
        warning('MAJORIZATION:majle:ResizeVectors', ...
            'The input vectors have different sizes. Tailing with zeros.');
        yc=[yc zeros(size(xc,2)-size(yc,2),1)'];
        xc=[xc zeros(size(yc,2)-size(xc,2),1)'];
        % but warn if negative
        if checkForNegative
            warning('MAJORIZATION:majle:ResizeNegativeVectors', ...
                sprintf('%s%s\n%s\n%s', ...
                'At least one of the input vectors ',...
                'has negative components.',...
                '         Tailing with zeros is most likely senseless.',...
                '         Make sure that you know what you are doing.'));
            % sort again both vectors in descending order
            xc=-sort(-xc); yc=-sort(-yc);
        end
    end
    z=cumsum(yc-xc);

    %check for NaNs in z
    if any(isnan(z))
        warning('MAJORIZATION:majle:NaNsInComparisons', ...
            sprintf('%s%s\n%s\n%s', ...
            'At least one of the input vectors ',...
            'includes -Inf, Inf, or NaN components.',...
            '         Some comparisons could not be made. ',...
            '         Make sure that you know what you are doing.'));
    end

    if min(z) < -majleTol
        s=0;  % no majorization
    elseif abs(z(end)) <= majleTol
        s=2;   % strong majorization
    else
        s=1; % weak majorization
    end
endfunction
