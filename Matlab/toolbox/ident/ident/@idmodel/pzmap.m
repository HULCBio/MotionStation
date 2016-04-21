function pzmap(varargin)
%PZMAP Plots zeros and poles.
%
%   PZMAP(M) 
%   
%   where M is an IDMODEL object, like IDPOLY, IDSS, IDARX or
%   IDGREY.
%   To plot the zeros and poles for several models use
%   PZMAP(M1,M2,...,Mn)
%   To select the color associated with each model use
%   PZMAP(M1,'b',M2,'m',M3,'r')
%
%   To also display confidence regions, corresponding to SD
%   standard deviations, use PZMAP(M1,..Mn,'SD',SD). Here SD is a
%   positive real scalar.
%
%   The zeros and poles  are plotted with 'o' denoting zeros and 'x' poles.
%   Poles and zeros associated with the same input/output pair,
%   but different models are always plotted in the same diagram. 
%
%   To consider specific input/output channels, use PZMAP(M(ky,ku)).
%   To include also the transfer functions from the noise sources,
%   use PZMAP(noisecnv(M)), and for noise sources only PZMAP(M('noise')).
%
%   When M contains information about several different input/output channels
%   these will be sorted according to the channel names. Default is that
%   each input/output channel is plotted separately in a split plot.
%   With PZMAP(M1,...Mn,'mode',MODE) some alternatives are given:
%   MODE = 'sub' (The default value) splits the screen into several plots.
%   MODE = 'same' gives all plots in the same diagram. Use 'ENTER' to advance.
%   MODE = 'sep' erases the previous plot before the next channel pair is
%   treated.
%
%   PZMAP(M1,..Mn,..,'axis',AXIS) gives access to the axis scaling:
%   AXIS = [x1 x2 y1 y2] fixes the axes scaling. AXIS = x is the same as
%   AXIS = [-m m -m m]. Default is autoscaling.
% 
 

%   L. Ljung 10-1-86, revised 7-3-87,8-27-94
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.2 $ $Date: 2001/04/06 14:22:13 $

zpplot(varargin{:})
    