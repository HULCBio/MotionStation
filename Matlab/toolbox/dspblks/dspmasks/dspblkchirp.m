function varargout = dspblkchirp(action,varargin)
% DSPBLKCHIRP Signal Processing Blockset CHIRP block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.5.4.2 $ $Date: 2004/04/12 23:06:06 $

blk = gcbh;

switch action,
case 'icon'
	t = [0:0.1:1.5*pi];
	y = (sin(t.*t)+1)/2*0.7;
	t = t / max(t);
   
   % Determine string on icon:
	txt = get_param(blk,'method');
	if strcmp(txt,'Quadratic'),
	   txt=txt(1:4); 
	else 
	   txt=txt(1:3); 
	end
     
   varargout = {t,y,txt};
   
case 'param'
   p = varargin{1};
   f0 = varargin{2};
   f1 = varargin{3};
   t1 = varargin{4};
      
   % Error checking:
	if (p == 3) & (f0 > f1),
   	error('F1>F0 is required for a log-sweep.');
	end
      
   if p==3,
		beta = log10(f1-f0)./t1;
	else
		beta = (f1-f0).*(t1.^(-p));
	end
      
   varargout = {beta,p};   
end


