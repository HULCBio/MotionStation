function m = spmethp(m)
%SPMETHP Component registry function for Spectrum Viewer.
% This function creates a structure array which the Spectrum Viewer uses
% to keep track of what methods are available and what
% parameters they have.
%
% The Spectrum Viewer finds all occurrences of 'spmeth' (without the
% appended 'p') on the path and, after calling spmethp,
% calls the others in the order they are on the path.  Each of
% these appends or alters the methods structure which is 
% input.

%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.13 $

% BURG METHOD
m = [];
m(1).methodName = 'Burg';
m(1).methodHelp = {
'Burg Method'
' '
'This method estimates the lattice reflection coefficients from the signal'
'and then fits an autoregressive (AR) model to that sequence.'
' '
'The spectrum is the magnitude response of the all-pole filter.'
};
m(1).label = {
       'Order' 
       'Nfft'};
m(1).type = {
       'edit'
       'edit'};
m(1).default = {
       '10'
       '1024'
       };
m(1).subordinates = {[] []};
m(1).confidenceFlag = 0;
m(1).popupString = {
       ''
       '' };
m(1).helpString = {
       {'Order of estimate'
       ' '
       'This method estimates the lattice reflection coefficients from the signal'
       'and then fits an autoregressive (AR) model of this order to that sequence.'}
       {'This is the FFT Length used for computing the spectrum.'
        'The spectrum is computed at Nfft evenly spaced frequencies'
        'around the unit circle.  The spectrum at negative frequencies'
        'is obtained by symmetry.'} };
m(1).computeFcn = 'svburg';

% Covariance AR
m(end+1) = m(1);
m(end).methodName = 'Covariance';
m(end).methodHelp = {
'Covariance AR'
' '
'This method estimates the autocovariace sequence of the signal'
'and then fits an all-pole IIR model to that sequence.' 
' '
'The spectrum is the magnitude response of the all-pole filter.'
};
m(end).label = {
       'Order' 
       'Nfft' };
m(end).type = {
       'edit'
       'edit' };
m(end).default = {
       '10'
       '1024'
       };
m(end).subordinates = {[] []};
m(end).confidenceFlag = 0;
m(end).popupString = {
       ''
       ''
       };
m(end).helpString = {
       {'Order of estimate'
       ' '
       'This method estimates the autocovariance sequence of the signal'
       'and then fits an all-pole IIR model of this order to that sequence.'}
       {'This is the FFT Length used for computing the spectrum.'
        'The spectrum is computed at Nfft evenly spaced frequencies'
        'around the unit circle.  The spectrum at negative frequencies'
        'is obtained by symmetry.'}
        }; 
m(end).computeFcn = 'svcov';
% FFT 
m(end+1) = m(1);
m(end).methodName = 'FFT';
m(end).methodHelp = {
   'FFT Method'
   ' '
   'FFT computes the discrete Fourier transform (DFT) of the input'
   'signal.  If the length of input signal is a power of two, a'
   'fast radix-2 fast-Fourier transform algorithm is used.  If the'
   'length of the input signal is not a power of two, a slower'
   'non-power-of-two algorithm is employed.  For arrays of signals'
   '(matrices), the FFT operation is applied to each column.'
   ' '
   'The spectrum is the squared magnitude of the complex FFT result,'
   'normalized by the transform length.'};
m(end).label = {
       'Nfft'  };
m(end).type = {
       'edit'
        };
m(end).default = {
       '1024'
        };
m(end).subordinates = {[]};
m(end).confidenceFlag = 0;
m(end).popupString = {
       ''
       };
m(end).helpString = {
       {'This is the FFT Length used for computing the spectrum.'
        'The spectrum is computed at Nfft evenly spaced frequencies'
        'around the unit circle.  The spectrum at negative frequencies'
        'is obtained by symmetry.'}
        }; 
m(end).computeFcn = 'svfft';

% Modified Covariance AR
m(end+1) = m(1);
m(end).methodName = 'Mod. Covar.';
m(end).methodHelp = {
'Modified Covariance AR'
' '
'This method estimates the modified autocovariace sequence of the signal'
'and then fits an all-pole IIR model to that sequence.' 
' '
'The spectrum is the magnitude response of the all-pole filter.'
};
m(end).label = {
       'Order' 
       'Nfft' };
m(end).type = {
       'edit'
       'edit' };
m(end).default = {
       '10'
       '1024'
       };
m(end).subordinates = {[] []};
m(end).confidenceFlag = 0;
m(end).popupString = {
       ''
       ''};
m(end).helpString = {
       {'Order of estimate'
       ' '
       'This method estimates the modified autocovariance sequence of the signal'
       'and then fits an all-pole IIR model of this order to that sequence.'}
       {'This is the FFT Length used for computing the spectrum.'
        'The spectrum is computed at Nfft evenly spaced frequencies'
        'around the unit circle.  The spectrum at negative frequencies'
        'is obtained by symmetry.'}
        }; 
m(end).computeFcn = 'svmcov';

% MULTIPLE TAPER METHOD
m(end+1) = m(1);
m(end).methodName = 'MTM';
m(end).methodHelp = {
'Multitaper Method (MTM)'
' '
'The multitaper method uses orthogonal windows (or "tapers") to obtain'
'approximately independent estimates of the power spectrum which, when'
'combined, yield an estimate which exhibits more degrees of freedom'
'and allows easier quantification of the bias and variance trade-off'
'as compared to Welch''s method.'
' '
'See the User''s Manual for more details.'
};
m(end).label = {
       'NW' 
       'Nfft'
       xlate('Weights') };
m(end).type = {
       'edit'
       'edit'
       'popupmenu' };
m(end).default = {
       '4'
       '1024'
       1
       };
m(end).subordinates = {[] [] []};
m(end).confidenceFlag = 1;
m(end).popupString = {
       ''
       ''
       {'adapt' 'unity' 'eigen'} };
m(end).helpString = {
       {'Time-bandwidth Product NW'
       ' '
'This parameter is a "resolution" parameter directly related to the number'
'of tapers (windows) used to compute the spectrum.  There are always 2*NW-1'
'tapers used to form the estimate.  This means as you increase NW, you have'
'more estimates of the power spectrum, and hence the variance of the estimate'
'decreases.  However, the bandwidth of each taper is also proportional to'
'NW, so as NW is increased, each estimate exhibits more spectral leakage'
'(i.e., wider peaks) and the overall spectral estimate is more biased.'
' '
'For each data set, there is usually a value of NW which allows an optimal'
'trade-off between bias and variance.'
       }
       {'This is the FFT Length used for computing the spectrum.'
        'The spectrum is computed at Nfft evenly spaced frequencies'
        'around the unit circle.  The spectrum at negative frequencies'
        'is obtained by symmetry.'}
       {'Method used for combining tapers together:'
        '   ''adapt'' = adaptive weights, optimize to reduce spectral leakage'
        '   ''unity'' = simple sum'
        '   ''eigen'' = weight sum by eigen values of Slepian sequences'} }; 
m(end).computeFcn = 'svmtm';

%  MUSIC METHOD
m(end+1) = m(1);
m(end).methodName = 'MUSIC';
m(end).methodHelp = {
'MUSIC Method: Multiple Signal Classification'
' '
'This method performs eigen analysis of the correlation matrix of the'
'input signal.'
' '
'For a single signal input, the eigenvectors and eigenvalues'
'of an estimate of the signal''s correlation matrix are found.'
'The eigenvectors are assigned either to the signal + noise'
'subspace, or the noise only subspace, based on the magnitude of '
'their corresponding eigenvalues and the inputs Signal Dim. and '
'Threshold.  The MUSIC spectral estimate is the reciprocal of a'
'weighted sum of the magnitude squared of the FFTs of the'
'eigenvectors in the noise subspace.'
' '
'In MUSIC, the weights in the sum are unity. Optionally, by checking'
'the "Eigenvector Weights" box, you can weight the sum by the eigenvalues'
'in the noise subspace.  This is known as the "EV" (eigenvector) method.'
};
m(end).label = {
       xlate('Signal Dim.')
       xlate('Threshold')
       xlate('Nfft') 
       xlate('Nwind')
       xlate('Window') 
       {'' '' '' 'Chebwin R' '' '' 'Beta' ''}
       xlate('Overlap')
       xlate('Corr. Matrix')
       xlate('Eigenvector Weights') };
m(end).type = {
       'edit'
       'edit'
       'edit'
       'edit'
       'popupmenu'
       {'edit' 'edit' 'edit' 'edit' 'edit' 'edit' 'edit' 'edit'}
       'edit'
       'checkbox'
       'checkbox' };
m(end).default = {
       '4'
       '[ ]'
       '1024'
       '[ ]'
       3
       {'' '' '' '40' '' '' '5' ''}
       '[ ]'
       0
       0 };
m(end).subordinates = {[] [] [] [] 6 [] [] [] []};
m(end).confidenceFlag = 0;
m(end).popupString = {
       ''
       ''
       ''
       ''
       {'bartlett' 'blackman' 'boxcar' 'chebwin' ...
        'hamming' 'hanning' 'kaiser' 'triang'}
       {'' '' '' '' '' '' '' ''}
       ''
       ''
       '' };
m(end).helpString = {
       {
  'This is the dimension of signal subspace.  This number should be equal'
  'to the number of complex sinusoids in the signal, in theory.'
       }
       {'Subspace threshold. Use ''[ ]'' to leave unspecified.'
       ' '
       'When specified, this number serves as a cutoff for signal and'
       'noise subspace separation.  All eigenvalues greater than Threshold'
       'times the smallest eigenvalue are designated as signal eigenvalues.'
       'In this case, the signal subspace dimension might be smaller than'
       'the Signal Dim. specified but no greater.'}
       {'This is the FFT Length used for computing the spectrum.'
        'The spectrum is computed at Nfft evenly spaced frequencies'
        'around the unit circle.  The spectrum at negative frequencies'
        'is obtained by symmetry.'}
       {'This is the Window Length in samples.'
       ' '
       'The signal is sectioned into overlapping sections of length Nwind'
       'and these windowed sections are concatenated as columns of a matrix.'
       'The correlation matrix is determined from this signal matrix.'
       ' '
       'To get the default value, equal to "Signal Dim.", use ''[ ]''.'}
       {'Window Type'
       ' '
       'See the functions ''bartlett'', ''blackman'', ''boxcar'', ''chebwin'','
        '''hamming'', ''hanning'', ''kaiser'', and ''triang'' for details.'
       }
       { {''} {''} {''} {'Sidelobe height for Chebyshev window, in dB'} ...
         {''} {''} {'Beta parameter for Kaiser window'} {''} }
       {'Window Overlap, in samples'
       ' '
       'To get the default value, equal to Nwind-1, use ''[ ]''.'}
       {'Check this box if the input signal is a square correlation matrix.'
       ' '
       'If this is the case, no sectioning or windowing will be performed.'
       'The eigenvectors and values of the input matrix itself are used'
       'to get the MUSIC estimate.'}
       {'Check this box to get the ''Eigen analysis'' method.'} }; 
m(end).computeFcn = 'svmusic';

%  WELCH'S METHOD
m(end+1) = m(1);
m(end).methodName = 'Welch';
m(end).methodHelp = {
'Welch''s method of averaged, overlapped, modified periodograms.'
' '
'The signal is sectioned into overlapping segments, each of length'
'Nwind.  The Window is applied to each section and the FFT is taken.'
'The results are averaged together and scaled to get the final spectrum.'
' '
};
m(end).label = {
       xlate('Nfft') 
       xlate('Nwind')
       xlate('Window') 
       {'' '' '' 'Chebwin R' '' '' 'Beta' ''}
       xlate('Overlap')};
m(end).type = {
       'edit'
       'edit'
       'popupmenu'
       {'edit' 'edit' 'edit' 'edit' 'edit' 'edit' 'edit' 'edit'}
       'edit'};
m(end).default = {
       '1024'
       '256'
       6
       {'' '' '' '40' '' '' '5' ''}
       '0'};
m(end).subordinates = {[] [] 4 [] []};

m(end).popupString = {
       ''
       ''
       {'bartlett' 'blackman' 'boxcar' 'chebwin' ...
        'hamming' 'hanning' 'kaiser' 'triang'}
       {'' '' '' '' '' '' '' ''}
       '' };
m(end).helpString = {
       {'This is the FFT Length used for computing the spectrum.'
        'The spectrum is computed at Nfft evenly spaced frequencies'
        'around the unit circle.  The spectrum at negative frequencies'
        'is obtained by symmetry.'
        ' '
        'Nfft must be no less than the Window Length, Nwind.'}
       {'This is the Window Length in samples.'}
       {'Window Type'
       ' '
       'See the functions ''bartlett'', ''blackman'', ''boxcar'', ''chebwin'','
        '''hamming'', ''hanning'', ''kaiser'', and ''triang'' for details.'
       }
       { {''} {''} {''} {'Sidelobe attenuation for Chebyshev window, in dB.'} ...
         {''} {''} {'Beta parameter for Kaiser window.'} {''} }
       {'Window Overlap, in samples.'}
              }; 
m(end).computeFcn = 'svwelch';




% Yule-Walker AR
m(end+1) = m(1);
m(end).methodName = 'Yule AR';
m(end).methodHelp = {
'Yule-Walker AR'
' '
'This method estimates the autocorrelation sequence of the signal'
'and then fits an all-pole IIR model to that sequence.' 
' '
'The spectrum is the magnitude response of the all-pole filter.'
};
m(end).label = {
       'Order' 
       'Nfft' };
m(end).type = {
       'edit'
       'edit' };
m(end).default = {
       '10'
       '1024' };
m(end).subordinates = {[] []};
m(end).confidenceFlag = 0;
m(end).popupString = {
       ''
       ''};
m(end).helpString = {
       {'Order of estimate'
       ' '
       'This method estimates the autocorrelation sequence of the signal'
       'and then fits an all-pole IIR model of this order to that sequence.'}
       {'This is the FFT Length used for computing the spectrum.'
        'The spectrum is computed at Nfft evenly spaced frequencies'
        'around the unit circle.  The spectrum at negative frequencies'
        'is obtained by symmetry.'}}; 
m(end).computeFcn = 'svyulear';



