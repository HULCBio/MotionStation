function [fr,w,covfr] = nyquist(varargin)
%NYQUIST Plots a Nyquist diagram of a frequency function.
%   NYQUIST(M)  or  NYQUIST(M,'SD',SD) or NYQUIST(M,W) or NYQUIST(M,'SD',SD,W)
%
%   where M is an IDMODEL or IDFRD object, like IDPOLY, IDSS, IDARX or
%   IDGREY, obtained by any of the estimation routines, including 
%   ETFE and SPA. No plot is given if M is a time series model.
%
%   CONFIDENCE REGIONS: NYQUIST(M,'SD',SD)
%   If SD is a number larger than zero, confidence regions corresponding 
%   to SD standard deviations will be marked by ellipses at every 10th
%   frequency (marked by a '*').
%   To affect how many confidence ellipses are plotted, use instead of 'SD'
%   'SDmN' where N means that every Nth frequency point is used for
%   drawing the confidence region and 'm' is the marker for these points. 
%   Example; 'SD+25'.
%
%   SPECIFY FREQUENCIES: NYQUIST(M,W)
%   W specifies the frequencies for IDMODELs. If W is a vector, the
%   frequency functions will be plotted for the values in W. If
%   W = {WMIN,WMAX} (note the curly brackets), the frequency interval between
%   WMIN and WMAX will be covered using a linear frequency grid. With
%   W = {WMIN,WMAX,NP} this will be done using NP points.
%
%   SEVERAL MODELS:
%   To plot the frequency functions for several models use
%   NYQUIST(M1,M2,...,Mn). To specify colors, lines and markers, do as in
%   NYQUIST(M1,'r',M2,'y--',M3,'gx'). See HELP PLOT for markers.
%
%   MIMO MODELS:
%   The default mode is that the Nyquist plots for all models are shown simul-
%   taneously, for each input - output pair present in the models Mi.
%   The models' InputName and OutputName will be used for the sorting.
%   ENTER will advance the plot from on input-output pair to the next (if any). 
%   Typing CTRL-C aborts the plotting in an orderly fashion.
%   To obtain all plots in the same diagram use NYQUIST(M,'Mode','same').
%
%   NO PLOT, COMPUTE FREQUENCY FUNCTION:
%   When NYQUIST is called with a single system and output arguments
%   H = NYQUIST(M,W) or [H,W,COVH] = NYQUIST(M)
%   no plot is drawn on the screen. 
%   If M has NY outputs and NU inputs, and W contains NW frequencies, 
%   then H is an NY-by-NU-by-NW array such that H(ky,ku,k) gives 
%   the complex-valued frequency response from input ku to output ky at the 
%   frequency W(k). For a SISO model, use H(:) to obtain a vector of the 
%   frequency response.
%   The uncertainty information COVH is a 5D-array where 
%   COVH(KY,KU,k,:,:)) is the 2-by-2 covariance matrix of the response
%   from input KU to output KY at frequency  W(k). The 1,1 element
%   is the variance of the real part, the 2,2 element the variance
%   of the imaginary part and the 1,2 and 2,1 elements the covariance
%   between the real and imaginary parts. SQUEEZE(COVH(KY,KU,k,:,:))
%   gives the covariance matrix of the corresponding response.
%
%   If M is a time series (no input), H is returned as the (power) 
%   spectrum of the outputs; an NY-by-NY-by-NW array. Hence H(:,:,k) 
%   is the spectrum matrix at frequency W(k). The element H(K1,K2,k) is
%   the the cross spectrum between outputs K1 and K2 at frequency W(k).
%   When K1=K2, this is the real-valued power spectrum of output K1. 
%   DH is then the covariance of the spectrum H, so that COVH(K1,K1,k) is
%   the variance of the power spectrum out output K1 at frequency W(k).
%   No information about the variance of the cross spectra is normally
%   given. (That is, COVH(K1,K2,k) = 0 for K1 not equal to K2.)
%
%   If the model M is not a time series, use H = NYQUIST(M('n')) to obtain
%   the spectrum information of the noise (output disturbance) signals.
%
%   See also IDMODEL/BODE, FFPLOT.

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.10 $  $Date: 2001/04/06 14:22:13 $
try
   if nargout == 0
      nyqaux(varargin{:});
   elseif nargout <= 2
      [fr,w] = nyqaux(varargin{:});
   else
      [fr,w,covfr] = nyqaux(varargin{:});
   end
catch
   error(lasterr)
end
