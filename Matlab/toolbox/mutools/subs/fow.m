% function weight = fow(dcval,bw,ginf)
%
%  Creates a stable, 1st order system, WEIGHT,
%  with the following properties:
%
%	          WEIGHT(0) = dcval
%	        WEIGHT(inf) = ginf
%	|WEIGHT(j*abs(bw))| = 1
%
%  It is necessary that either
%
%	 |dcval| < 1 < |ginf|
%  or
%	 |dcval| > 1 > |ginf|

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function weight = fow(dcval,bw,ginf)

 if nargin ~= 3
   disp('usage: weight = fow(dcval,bw,ginf)');
   return
 end

 poleloc = abs(bw)*sqrt((ginf*ginf-1)/(1-dcval*dcval));
 weight = nd2sys([ginf poleloc*dcval],[1 poleloc]);