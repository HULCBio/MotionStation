%function vzoom('axis')
%
%   VZOOM freezes axis by clicking on 2 points in the plot.
%   STR is a string variable:
%	'ss'  standard plot  (default)
%	'll'  log-log
%	'ls'  semilogx
%	'sl'  semilogy
%
%   Also, STR can be any allowable input to VPLOT, except 'bode'.
%     Example:
%              tf = frsp(nd2sys([ 1 .1],[.1 1]),logspace(-2,2,100));
%	       vplot('nic',tf); vzoom('nic'); vplot('nic',tf);axis;
%
%   See Also: GINPUT and VPLOT.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function vzoom(str)

 if nargin == 0
	disp('usage: vzoom(''axis'')');
	return;
 end

if strcmp(str,'ss')|strcmp(str,'iv,d')|strcmp(str,'iv,m')|strcmp(str,'iv,p')...
		|strcmp(str,'ri')|strcmp(str,'nyq')|strcmp(str,'nic')
	[x,y]=ginput(2);
	axis([min(x) max(x) min(y) max(y)]);
elseif strcmp(str,'ll')|strcmp(str,'liv,lm')
	[x,y]=ginput(2);
	axis(log10([min(x) max(x) min(y) max(y)]));
elseif strcmp(str,'ls')|strcmp(str,'liv,d')|strcmp(str,'liv,m')|...
		strcmp(str,'liv,p')
	[x,y]=ginput(2);
	axis([log10([min(x) max(x)]) min(y) max(y)]);
elseif strcmp(str,'sl')|strcmp(str,'iv,lm')
	[x,y]=ginput(2);
	axis([min(x) max(x) log10([min(y) max(y)]) ]);
elseif strcmp(str,'bode')
	disp('This function not defined for bode plots');
else
	disp(['This function not defined for: ' str]);
end %if


%
%