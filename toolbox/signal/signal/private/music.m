function [music_data,msg] = music(x,p,varargin)
%MUSIC  Implements the heart of the MUSIC algorithm of line spectra estimation.
%   MUSIC is called by both PMUSIC and ROOTMUSIC.
%   
%   Inputs:
%     
%     x - vector or matrix. If vector it is a signal, if matrix it may be either a data
%         matrix such that x'*x=R, or a correlation matrix R.
%     p - scalar or two element vector. If scalar, it indicates the dimension of the 
%         signal subspace. If vector, p(2) is a threshold used to determine the 
%         aforementioned dimension.
%     nfft - (optional) to be used only with PMUSIC. A scalar indicating the number of
%            points used in the evaluation of the pseudospectrum.
%     Fs - (optional) a scalar specifying the sampling frequency. If omitted, we work
%          in rad/sample; if empty it defaults to 1 Hz.
%     nw - (optional) a scalar or vector indicating either the order of the correlation
%          matrix or (when a vector) a window whose length is the order of the matrix
%          and whose values are used to window each column of the data matrix.
%     noverlap - (optional) a integer indicating the number of samples to overlap from
%                column to column.
%     strings - Optional input strings are: 'corr', 'EV' and range ('half' or 'whole').
%
%   Outputs:
%
%     msg - a possible error message.
%
%     music_data - a structure with the following fields:
%          
%          noise_eigenvects - a matrix whose columns are the noise subspace eigenvectors.
%          signal_eigenvects - a matrix whose columns are the signal subspace eigenvectors.
%          eigenvals - the eigenvalues of the correlation matrix.
%          p_eff - the effective dimension of the signal subspace.
%          nfft - number of points used to evaluate the pseudospectrum (only used in PMUSIC).
%          Fs - sampling freq.
%          range - string indicating whether 'half' or the 'whole' pseudospectrum should be
%                  computed. (Only used in PMUSIC.)
%          EVFlag - flag, 0 = MUSIC method; 1 = EigenVector method.

%   Author(s): R. Losada
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.4 $  $Date: 2004/04/13 00:18:52 $ 

%   References:
%     [1] Petre Stoica and Randolph Moses, Introduction To Spectral
%         Analysis, Prentice-Hall, 1997, pg. 15
%     [2] S. J. Orfanidis, Optimum Signal Processing. An Introduction. 
%         2nd Ed., Macmillan, 1988.


xIsReal = isreal(x);
msg = '';
music_data = [];

if isempty(p),
   msg = 'The signal subspace dimension cannot be empty.';
   return
end

[opts,msg] = music_options(xIsReal,p,varargin{:});
if ~isempty(msg),
   return
end

% Compute the eigenvalues and eigenvectors of the correlation matrix
[eigenvals,eigenvects] = computeeig(x,opts.CorrFlag,opts.CorrMatrOrd,opts.nw,opts.noverlap,opts.window,opts.EVFlag);

% Determine the effective dimension of the signal subspace
p_eff = determine_signal_space(p,eigenvals);

% Separate the signal and noise eigenvectors
signal_eigenvects = eigenvects(:,1:p_eff);
noise_eigenvects = eigenvects(:,p_eff+1:end);

% Generate the output structure
music_data.noise_eigenvects = noise_eigenvects;
music_data.signal_eigenvects = signal_eigenvects;
music_data.eigenvals = eigenvals;
music_data.p_eff = p_eff;
music_data.nfft = opts.nfft;
music_data.Fs = opts.Fs;
music_data.EVFlag = opts.EVFlag;
music_data.range = opts.range;


%--------------------------------------------------------------------------------------
function [options,msg] = music_options(xIsReal,p,varargin)
%MUSIC_OPTIONS   Parse the optional inputs to the MUSIC function.
%   MUSIC_OPTIONS returns a structure, OPTIONS, with the following fields:
%
%   options.nfft         - number of freq. points at which the psd is estimated
%   options.Fs           - sampling freq. if any
%   options.range        - 'onesided' or 'twosided' pseudospectrum (they correspond to
%                          'half' and 'whole' respectively, but are returned as is by
%                          psdoptions.m
%   options.nw           - number of columns in the data matrix 
%   options.noverlap     - number of samples to overlap
%   options.window       - a vector with window coefficients
%   options.CorrFlag     - a flag indicating whether the input is a correlation matrix
%   options.EVFlag       - flag, 0 = MUSIC method ; 1 = EigenVector method
%   options.CorrMatrOrd  - order of the correlation matrix to be used in computations



% Assign Defaults
msg = '';
options.nw = [];
options.noverlap = [];
options.window = [];
options.nfft = 256;
options.Fs = [];
options.CorrFlag = 0;
options.EVFlag = 0;
if xIsReal,
   options.range = 'onesided';
else
   options.range = 'twosided';
end

[options,msg] = psdoptions(xIsReal,options,varargin{:});

% psdoptions doesn't handle this field, assign it separetely
options.CorrMatrOrd = 2*p(1);

%-----------------------------------------------------------------------------------------
function [eigenvals,eigenvects] = computeeig(x,CorrFlag,CorrMatrOrd,nw,noverlap,window,EVFlag)
%COMPUTEEIG  Compute eigenvalues and eigenvectors of correlation matrix.
%
%   Inputs:
%      
%     x        - input vector or matrix
%     CorrFlag - (flag) indicates whether x is a correlation matrix
%     nw       - (integer) length of the rows of the data matrix 
%                (only used if x is vector)
%     noverlap - (integer) overlap between the rows of the data matrix
%                (used in conjunction with nw) 
%     window   - (vector) window to be applied to each column of data
%                 matrix  (not used if x is a correlation matrix)
%     EVFlag   -  True if eigenvector method, false if MUSIC.
%   
%
%   Outputs:
%    
%     eigenvals
%     eigenvects
%
%     If x is a matrix,  
%          If CorrFlag = 1, input x is a correlation matrix, we compute the
%          eigendecomposition and order the eigenvalues and eigenvectors.
%
%     If x is a vector,
%          a data matrix is formed by calling corrmtx unless a custom nw
%          and noverlap are specified. In that case, we use buffer to form
%          the data matrix. 
%
%     If window is not empty, each row of the data matrix will be
%     multiplied by the window.

% Determine if the input is a matrix
xIsMatrix = ~any(size(x)==1);

if xIsMatrix && CorrFlag,
    % Input is Correlation matrix

    % Compute the eigenvectors and eigenvalues
    [E,D] = eig((x+x')/2); % Ensure hermitian
    [eigenvals,indx] = sort(diag(D),'descend');
    eigenvects = E(:,indx);

else
    if xIsMatrix
        % Input is already a data matrix
        [Mx,Nx] = size(x); % Determine size of data matrix
        if EVFlag && (Nx > Mx),
            errmsg = 'The number of columns in the data matrix cannot exceed the number of rows.';
            error(generatemsgid('invalidDataMatrix'),errmsg);
        end

    else
        % x is a vector
        x = x(:); % Make it a column
        if isempty(nw),
            x = corrmtx(x,CorrMatrOrd-1,'cov');
        else
            if EVFlag && nw > (ceil((length(x)-nw)/(nw-noverlap))+1),
                errmsg = sprintf(['The segment length and overlap specified result in\n',...
                    'a data matrix with more columns than rows.']);
                error(generatemsgid('invalidDataMatrix'),errmsg);
            end
            Lx = length(x);
            x = buffer(x,nw,noverlap,'nodelay');
            if Lx <= nw,
                error(generatemsgid('invalidSegmentLength'),'The segment length, NW, must be smaller than the signal length.');
            end
            x = x'./sqrt(Lx-nw); % Scale appropriately such that X'*X is a scaled estimate of R
        end
    end
    if ~isempty(window),
        % Apply window to each row of data matrix
        if length(window) ~= size(x,2),
            error('Window length must equal the number of columns in the data matrix.');
        end
        window = repmat(window(:).',size(x,1),1);
        x = x.*window;
    end

    % Compute the eigenvectors and eigenvalues via the SVD
    [U,S,eigenvects] = svd(x,0);
    eigenvals = diag(S).^2; % We need to square the singular values here
end


%--------------------------------------------------------------------------------------------
function p_eff = determine_signal_space(p,eigenvals)
%DETERMINE_SIGNAL_SPACE   Determines the effective dimension of the signal subspace.
%   
%   Inputs:
%
%     p         - (scalar or vector) signal subspace dimension 
%                 (but may contain a desired threshold).
%     eigenvals - (vector) contains the eigenvalues (sorted in decreasing order)
%                 of the correlation matrix
%
%   Outputs:
%
%     p_eff - The effective dimension of the signal subspace. If a threshold
%             is given as p(2), the signal subspace will be equal to the number
%             of eigenvalues, NEIG, greater than the threshold times the smallest
%             eigenvalue. However, the dimension of the signal subspace is at most
%             p(1), so that if NEIG is greater than p(1), p_eff will be equal to
%             p(1). If the threshold criteria results in an empty signal subspace,
%             once again we make p_eff = p(1).


% Use the signal space dimension or the threshold to separate the noise subspace eigenvectors
if length(p) == 2,
   % The threshold will be the input threshold times the smallest eigenvalue
   thresh = p(2)*eigenvals(end); 
   indx = find(eigenvals > thresh);
   if ~isempty(indx)
      p_eff = min( p(1), length(indx) );
   else
      p_eff = p(1);
   end
else
   p_eff = p;
end

% [EOF] - music.m