function ymod = impulse(varargin)
%IMPULSE  Impulse response of IDMODELs and direct estimation from IDDATA/IDFRD sets.
%
%   IMPULSE(MOD) plots the impulse response of the IDMODEL model MOD (either 
%   IDPOLY, IDARX, IDSS or IDGREY).  
%
%   IMPULSE(DAT) estimates and plots the impulse response from the data set 
%   DAT given as an IDDATA or IDFRD object. This does not apply to time series data.
%   To study subchannels, use IR = IMPULSE(DAT); IMPULSE(IR(INPUTS,OUTPUTS)).
%
%   For multi-input models, independent impulse commands are applied to each 
%   input channel.   
%
%   IMPULSE(MOD,'sd',K) also plots the confidence regions corresponding to
%   K standard deviations as a region around zero. Any response
%   outside this region is thus "significant". Add the argument
%   'FILL' after the models to show  the confidence region(s) as a
%   band instead: IMPULSE(M,'sd',3,'fill').
%
%   IMPULSE uses a stem plot by default. To change that into a regular plot
%   add the argument 'PLOT' after the models: IMPULSE(M,'plot'). In
%   this case, the uncertainty region is shown as a strip around
%   the response.
%
%   The time span of the plot is determined by the argument T: IMPULSE(MOD,T).
%   If T is a scalar, the time from -T/4 to T is covered. For an
%   impulse response estimated directly from data, this will also show feedback
%   effects in the data (response prior to t=0). 
%   If T is a 2-vector, [T1 T2], the time span from T1 to T2 is covered.
%   For a continuous time model, T can be any vector with equidistant values:
%   T = [T1:ts:T2] thus defining the sampling interval. For discrete time models
%   only max(T) and min(T) determine the time span. The time interval is modified to
%   contain the time t=0, where the input impulse occurs. The initial state vector
%   is taken as zero, even when specified to something else in MOD.
%
%   NOTE: The pulse is normalized w.r.t. the sampling interval T so that
%   u(t) = 1/T for 0<t<T ans zero otherwise.
%
%   IMPULSE(MOD1,MOD2,..,DAT1,..,T) plots the impulse responses of multiple
%   IDMODEL models and IDDATA sets MOD1,MOD2,...,DAT1,... on a single plot. 
%   The time vector T is optional.  You can also specify a color, line style,
%   and markers for each system, as in  
%      IMPULSE(MOD1,'r',MOD2,'y--',MOD3,'gx').
%
%   When invoked with left-hand arguments and a model input argument
%      [Y,T,YSD] = IMPULSE(MOD) 
%   returns the output response Y and the time vector T used for 
%   simulation.  No plot is drawn on the screen.  If MOD has NY
%   outputs and NU inputs, and LT=length(T), Y is an array of size
%   [LT NY NU] where Y(:,:,j) gives the impulse response of the 
%   j-th input channel. YSD contains the standard deviations of Y.
%   
%   For a DATA input MOD = IMPULSE(DAT),  returns the model of the 
%   impulse response, as an IDARX object. This can of course be plotted
%   using IMPULSE(MOD).
%
%   The calculation of the impulse response from data is based a 'long'
%   FIR model, computed with suitably prewhitened input signals. The order
%   of the prewhitening filter (default 10) can be set to NA by the 
%   property/value pair  IMPULSE( ....,'PW',NA,... ) appearing anywhere
%   in the input argument list.
%
%   NOTE: IDMODEL/IMPULSE and IDDATA/IMPULSE are adjusted to the use with
%   identification tasks. If you have the CONTROL SYSTEMS TOOLBOX and want
%   to access the LTI/IMPULSE, use VIEW(MOD1,...,'impulse').

%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/10 23:16:50 $

if nargin<1
   disp('Usage: IMPULSE(Data/Model)')
   disp('       [Y,T,YSD,YMOD] = IMPULSE(Data/Model,T).')  
   return
end

for k=1:length(varargin)
    if isa(varargin{k},'idfrd')
        varargin{k} = iddata(varargin{k});
    end
end
if nargout
    ymod = impulse(varargin{:});
else
    impulse(varargin{:});
end
 