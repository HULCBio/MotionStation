function ymod = step(varargin)
%STEP  Step response of IDMODELs and direct estimation from IDDATA or IDFRD sets.
%
%   STEP(MOD) plots the step response of the IDMODEL model MOD (either 
%   IDPOLY, IDARX, IDSS or IDGREY).  
%
%   STEP(DAT) estimates and plots the step response from the data set 
%   DAT given as an IDDATA or IDFRD object. This does not apply to time series data.
%
%   For multi-input models, independent step commands are applied to each 
%   input channel.  
%
%   STEP(MOD,'sd',K) also plots the confidence regions corresponding to
%   K standard deviations.
%
%   The time span of the plot is determined by the argument T: STEP(MOD,T).
%   If T is a scalar, the time from -T/4 to T is covered. For a
%   step response estimated directly from data, this will also show feedback
%   effects in the data (response prior to t=0). 
%   If T is a 2-vector, [T1 T2], the time span from T1 to T2 is covered.
%   For a continuous time model, T can be any vector with equidistant values:
%   T = [T1:ts:T2] thus defining the sampling interval. For discrete time models
%   only max(T) and min(T) determine the time span. The time interval is modified to
%   contain the time t=0, where the input step occurs. The initial state vector
%   is taken as zero, even when specified to something else in MOD.

%
%   STEP(MOD1,MOD2,..,DAT1,..,T) plots the step responses of multiple
%   IDMODEL models and IDDATA sets MOD1,MOD2,...,DAT1,... on a single plot. 
%   The time vector T is optional.  You can also specify a color, line style,
%   and markers for each system, as in  
%      STEP(MOD1,'r',MOD2,'y--',MOD3,'gx').
%
%   When invoked with left-hand arguments and a model input argument
%      [Y,T,YSD] = STEP(MOD) 
%   returns the output response Y and the time vector T used for 
%   simulation.  No plot is drawn on the screen.  If MOD has NY
%   outputs and NU inputs, and LT=length(T), Y is an array of size
%   [LT NY NU] where Y(:,:,j) gives the step response of the 
%   j-th input channel. YSD contains the standard deviations of Y.
%   
%   For a DATA input MOD = STEP(DAT),  returns the model of the 
%   step response, as an IDARX object. This can of course be plotted
%   using STEP(MOD).
%
%   The calculation of the step response from data is based a 'long'
%   FIR model, computed with suitably prewhitened input signals. The order
%   of the prewhitening filter (default 10) can be set to NA by the 
%   property/value pair  STEP( ....,'PW',NA,... ) appearing anywhere
%   in the input argument list.
%
%   NOTE: IDMODEL/STEP and IDDATA/STEP are adjusted to the use with
%   identification tasks. If you have the CONTROL SYSTEMS TOOLBOX and want
%   to access the LTI/STEP, use PLOT(MOD1,....,'step'). 

%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/12/02 16:43:40 $

if nargin<1
   disp('Usage: STEP(Data/Model)')
   disp('       [Y,T,YSD,YMOD] = STEP(Data/Model,T).')  
   return
end
for k=1:length(varargin)
    if isa(varargin{k},'idfrd')
        varargin{k} = iddata(varargin{k});
    end
end
if nargout
    ymod = step(varargin{:});
else
    step(varargin{:});
end
 
