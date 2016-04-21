function [amp,phas,w,sdamp,sdphas] = bode(varargin)
%IDMODEL/BODE Plots the Bode diagram of a transfer function or spectrum.
%   BODE(M)  or  BODE(M,'SD',SD) or BODE(M,W)
%
%   where M is an IDMODEL or IDFRD object, like IDPOLY, IDSS, IDARX or
%   IDGREY, obtained by any of the estimation routines, including 
%   ETFE and SPA.
%
%   CONFIDENCE REGIONS: BODE(M,'SD',SD)
%   If SD is a number larger than zero, confidence regions corresponding 
%   to SD standard deviations will be marked by dash-dotted lines.
%   Add the argument 'FILL' after the models to show the confidence region(s)
%   as a band instead: BODE(M,'sd',3,'fill').
%
%   SPECIFY FREQUENCIES: BODE(M,W)
%   W specifies the frequencies for IDMODELs. If W is a vector, the
%   frequency functions will be plotted for the values in W. If
%   W ={WMIN,WMAX} (note the curly brackets), the frequency interval between
%   WMIN and WMAX will be covered with logarithmically spaced points. 
%   With W = {WMIN,WMAX,NP} this is done using NP points. 
%   The unit of W is rad/s. 
%
%   SEVERAL MODELS:
%   To plot the frequency functions for several models use
%   BODE(M1,M2,...,Mn). To specify colors, lines and markers, do as in
%   BODE(M1,'r',M2,'y--',M3,'gx'). See HELP PLOT for markers.
%  
%   DISTURBANCE SPECTRA:
%   To plot the additive disturbance spectra, use BODE(M('noise')).
%
%   MIMO MODELS: 
%   For multi-channel models each input/output channel pair is shown in a
%   separate plot. The sorting is based on the models' InputName and
%   OutputName, and all models need not have teh same number of channels.
%   Press ENTER to advance from one pair to the next one. Typing CTRL-C
%   will abort the plotting in an orderly fashion. To have all plots in
%   same diagram, use BODE(M,'Mode','same')  arguments. The channels pairs
%   are still plotted one at a time.  To access a particular input/output 
%   response use BODE(M(ky,ku)).
%
%   AMPLITUDE/PHASE ONLY:
%   The default mode is that amplitude and phase plots are shown simul-
%   taneously. For spectra the phase plots are omitted.  To show amplitude
%   or phase plots only use BODE(M,'AP','A') and BODE(M,'AP,'P'), respectively. 
%
%   The Property/Value pairs ('AP',ap), ('SD',SD) and ('MODE','Same') can be
%   used in any order and together with multiple models.
%
%   NO PLOT, CALCULATION of MAGNITUDE and PHASE:
%   When BODE is called with a single system and output arguments
%   [MAG,PHASE] = BODE(M,W) and [MAG,PHASE,W,SDMAG,SDPHASE] = BODE(M)
%   no plot is drawn on the screen. 
%   If M has NY outputs and NU inputs, and W contains NW frequencies, 
%   then MAG and PHASE are NY-by-NU-by-NW arrays such that MAG(ky,ku,k) gives 
%   the response from input ku to output ky at the frequency W(k).
%   SDMAG and SDPHASE are the estimated standard deviations of the
%   magnitude and phase. W is always given in rad/s. Note that W cannot be
%   specified when M is an IDFRD object. Then the response for the frequencies
%   in M.Frequency is returned.
%
%   If M describes a time series, MAG is returned as its power spectrum and
%   PHASE will be identically zero.
%   Both discrete and continuous time models are handled.
%   
%   See also FFPLOT, and IDMODEL/NYQUIST.


%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.13.4.1 $ $Date: 2004/04/10 23:17:18 $

 try
   if nargout == 0
      bodeaux(1,varargin{:});
   elseif nargout <= 3
      [amp,phas,w] = bodeaux(1,varargin{:});
   else
      [amp,phas,w,sdamp,sdphas] = bodeaux(1,varargin{:});
   end
catch
   error(lasterr)
end 