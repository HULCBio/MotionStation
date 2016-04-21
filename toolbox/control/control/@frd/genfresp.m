function [mag,ph,w,FocusInfo] = genfresp(sys,Grade,fspec,varargin)
%GENFRESP   Generates frequency grid and response data for MIMO model.
%
%  [MAG,PHASE,W,FOCUSINFO] = GENFRESP(SYS,GRADE,FGRIDSPEC) computes the 
%  frequency response magnitude MAG and phase PH (in radians) of a single 
%  MIMO model SYS on some auto-generated frequency grid W.  
%
%  GRADE and FGRIDSPEC control the grid density and span as follows:
%    GRADE               ignored for FRD models
%    FGRIDSPEC     [] :  auto-ranging
%            'decade' :  auto-ranging + grid includes 10^k points 
%         {fmin,fmax} :  user-defined range (grid spans this range)
%
%  The structure FOCUSINFO contains the preferred frequency ranges for 
%  displaying each grade of response (FOCUSINFO.Range(k,:) is the preferred
%  range for the k-th grade).
%
%  [MAG,PHASE,W,FOCUSINFO] = GENFRESP(SYS,GRADE,FGRIDSPEC,Z,P,K) also supplies 
%  the zeros, poles, and gains for each I/O pair of SYS.
%
%  See also FREQRESP, BODE, NYQUIST, NICHOLS.

%  Author(s): P. Gahinet
%  Copyright 1986-2002 The MathWorks, Inc.
%  $Revision: 1.7 $ $Date: 2002/04/10 06:18:50 $

w = unitconv(sys.Frequency,sys.Units,'rad/sec');
h = permute(sys.ResponseData,[3 1 2]);

if length(w)<2
   focus = [];
elseif isempty(fspec) | ischar(fspec)
   focus = [w(1+(w(1)==0)),w(end)];
else
   focus = [max(w(1),fspec{1}),min(w(end),fspec{2})];
   % Clip to specified range if any
   idx = find(w>=focus(1) & w<=focus(2));
   w = w(idx,:);
   h = h(idx,:,:);
end
FocusInfo = struct('Range',focus(ones(4,1),:),'Soft',false);

% Mag and phase
mag = abs(h);
ph = angle(h);
if Grade<4
   % Unwrapping
   ph = unwrap(ph,[],1);
end

% Add delays
Ts = abs(getst(sys.lti));
Td = totaldelay(sys);
D = reshape((Ts + (~Ts)) * Td,[1 prod(size(Td))]);
ph = ph - reshape(w * D,size(ph));


