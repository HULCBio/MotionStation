function yout = fft(x,N,dim)
% Embedded MATLAB Library function.
%
% Limitations:
% 1) Only possible values for 'dim' are 1 and 2. 
% 2) Length of input vector has to be a power of 2. 

% $INCLUDE(DOC) toolbox/eml/lib/dsp/fft.m $
% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.6.4 $  $Date: 2004/03/21 22:07:28 $

eml_assert(nargin > 0, 'error', 'Not enough input arguments.');
eml_assert(isfloat(x), 'error', ['Function ''fft'' is not defined for values of class ''' class(x) '''.']);

RTN = 0;
eml_ignore([...
    'switch(nargin)',10 ...
    '   case 1, yout = builtin(''fft'',x);',10 ...
    '   case 2, yout = builtin(''fft'',x,N);',10 ...
    '   case 3, yout = builtin(''fft'',x,N,dim);',10 ...
    'end',10 ...
    'RTN=1;',10 ...
]);
if RTN, return; end

if isempty(x)
     yout = x;
     return;
end

lengthX = length(x(:));

if size(x,1) == 1 || size(x,2) == 1,
    lengthXPow = log(lengthX)/log(2);
else
    lengthXPow = log(size(x,1))/log(2);
end
if (lengthXPow - floor(lengthXPow)) > 1e-5,
    error('Input vector length must be a power of 2.');
end

    isInRow    = (lengthX > 1) && (size(x,1) == 1);
    isInCol    = (lengthX > 1) && (size(x,2) == 1);
    if ((nargin == 2) && (lengthX == 1)) || ((nargin == 3) && (((size(x,1) == 1) && (dim == 1)) || ((size(x,2) == 1) && (dim == 2)) ||  (lengthX == 1)))
        specialCase = 1;
    else
        specialCase = 0;
    end
    if (specialCase)
        %% Just repeat input one or more times to produce output
        if isempty(N)
            if nargin == 3,
	            Nused = 1;
            else
                Nused = lengthX;
            end
        else Nused = N;
        end
        if (isInCol) || ((nargin == 3) && (lengthX == 1) && (dim == 2)) || (nargin == 2) %column vector
            if (isreal(x))
                yout = zeros(lengthX, Nused, class(x));
            else
                yout = complex(zeros(lengthX, Nused, class(x)),zeros(lengthX, Nused, class(x)));
            end
            for m = 1:Nused
                yout(:,m)  = x;
            end
        else % row vector
            if (isreal(x))
                yout = zeros(Nused,lengthX, class(x));
            else
                yout = complex(zeros(Nused,lengthX, class(x)),zeros(Nused,lengthX, class(x)));
            end
            for m = 1:Nused
                yout(m,:) = x;
            end
        end
    else
        %% compute FFT using specialized run-time functions. 
	if nargin >= 2 && ~isempty(N),
            whatPow = log(N)/log(2);
            if (whatPow - floor(whatPow)) > 1e-5,
                error('Value of N must be a power of 2.');
            end
	end
        switch nargin
            case 3,
                if (dim < 1) || (dim > 2)
                    eml_assert(0,'error','Unsupported value of dim. ');
                end
                if (dim == 1)
                    xmod = x;
                else
                    xmod = x.';
                end
                if (~isempty(N))
                    xused = addZerosOrClip(xmod,N);
                else
                    xused = xmod;
                end
            case 2
                if (~isempty(N))
                    xused =  addZerosOrClip(x,N);    
                else
                    xused = x;
                end
            case 1
                if (isInRow)
                    xused = x.';
                else
                    xused = x;
                end
        end
        samps = size(xused,1);
        chans = size(xused,2);
        if (~isreal(xused)) % input is complex
            if (nargin == 1) && (length(xused(:)) == 1) 
                y = xused;
            else
                switch class(x)
                    case 'double'
                        eml_cdecl(y, 'double', 1, size(xused));
                        cc.MWDSP_R2BR_Z_OOP(eml_wref(y), xused, chans, samps, samps);
                        cc.MWDSP_R2DIT_TRIG_Z(eml_wref(y), chans, samps, samps, 0);
                    case 'single'
                        eml_cdecl(y, 'single', 1, size(xused));
                        cc.MWDSP_R2BR_C_OOP(eml_wref(y), xused, chans, samps, samps);
                        cc.MWDSP_R2DIT_TRIG_C(eml_wref(y), chans, samps, samps, 0);
                end
            end
        else %input is real
            if (nargin == 1) && (length(xused(:)) == 1) 
                y = xused;
            else
                switch class(x)
                    case 'double'
                        eml_cdecl(y, 'double', 1, size(xused));
                        cc.MWDSP_FFTInterleave_BR_D(eml_wref(y), xused, chans, samps);
                        if (chans > 1)
                            cc.MWDSP_R2DIT_TRIG_Z(eml_wref(y), chans/2, samps*2, samps, 0);
                            cc.MWDSP_DblSig_Z(eml_wref(y), chans,   samps);
                        end
                        if ((chans/2) ~= double(int32(chans/2)))
                            lastcol = y(:,chans);
                            cc.MWDSP_R2DIT_TRIG_Z( eml_wref(lastcol), 1, samps, samps/2, 0);
                            cc.MWDSP_DblLen_TRIG_Z(eml_wref(lastcol),    samps);
                            y(:,chans) = lastcol;
                        end
                    case 'single'
                        eml_cdecl(y, 'single', 1, size(xused));
                        cc.MWDSP_FFTInterleave_BR_R(eml_wref(y), xused, chans, samps);
                        if (chans > 1)
                            cc.MWDSP_R2DIT_TRIG_C(eml_wref(y), chans/2, samps*2, samps, 0);
                            cc.MWDSP_DblSig_C(eml_wref(y), chans,   samps);
                        end
                        if ((chans/2) ~= double(int32(chans/2)))
                            lastcol = y(:,chans);
                            cc.MWDSP_R2DIT_TRIG_C( eml_wref(lastcol), 1, samps, samps/2, 0);
                            cc.MWDSP_DblLen_TRIG_C(eml_wref(lastcol),    samps);
                            y(:,chans) = lastcol;
                        end
                end
            end
        end
        if (nargin == 3)
            if (dim == 2)
                yout = y.';
            else
                yout = y;
            end
        else
            if (size(x,1) == 1) 
                yout = y.';
            else
                yout = y;
            end
        end
    end
        
function xmod =  addZerosOrClip(x,N)

lengthX = length(x(:));

isInRow    = (lengthX > 1) && (size(x,1) == 1);
if ((size(x,1) == 1) || (size(x,2) == 1))
    if (N > lengthX)
        if isInRow
            xmod = [x ,  zeros(1,N-lengthX,class(x))].';
        else
            xmod = [x; zeros(N-lengthX, 1, class(x))];
        end
    elseif (N < lengthX)
        %% assert that N is a power of 2. 
        if isInRow
            xmod = x(1:N).';
        else
            xmod = x(1:N);
        end
    else
        if isInRow
            xmod = x.';
        else
            xmod = x;
        end
    end
else  %% x is a matrix
    if (N > size(x,1))
        xmod = zeros(N,size(x,2),class(x));
        diff_lt = N - size(x,1);
        for m = 1:size(x,2)
            xmod(:,m) = [x(:,m); zeros(diff_lt, 1,class(x))];
        end
    elseif (N < size(x,1))
        xmod = zeros(N,size(x,2),class(x));            
        for m = 1:size(x,2)
            xmod(:,m) = x(1:N,m);
        end
    else
        xmod = x;
    end
end

%%% EOF fft.m