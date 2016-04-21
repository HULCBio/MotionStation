function th=thss2th(eta,iy,noises)
%THSS2TH Converts an internal TH(SS)-format to the standard multi-input-
%   single-output THETA-format. Auxiliary routine to th2ff and th2zp.
%   This function is obsolete and has been replaced by IDPOLGET.
%   
%   TH = thss2th(TH_SS,IY)
%
%   TH_SS: The model defined in the THETA(SS) format (See help thss)
%   IY:    The output number in TH_SS to be considered as the
%          output in TH (The THETA-format handles only single-
%          output models). Default IY=1
%   TH:    The corresponding model in the THETA-format including
%          the transformed covariance matrix (See help theta).
%
%   By default, a diagonal noise matrix (H) is assumed. To obtain models 
%   for all noise sources, use TH=thss2th(TH_SS,IY,'noises');   
%   Then the noise sources are treated and counted as additional inputs.
%
%   The transformation of the covariance matrix is carried out using
%   the Gauss' approximation formula with numerical differentiation.
%   The stepsize in the differentiation is decided by the
%   m-file nuderst.

%   L. Ljung 10-2-90,11-11-93
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.9 $ $Date: 2001/04/06 14:21:42 $

if nargin<3, noises='no';end

if nargin<2, iy=1;end
th = idpolget(eta,noises);
%th = th{iy};
 
