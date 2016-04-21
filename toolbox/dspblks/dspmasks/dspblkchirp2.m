function varargout = dspblkchirp2(action,varargin)
% DSPBLKCHIRP2 Signal Processing Blockset CHIRP block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.8.4.2 $ $Date: 2004/04/12 23:06:07 $

blk = gcbh;

switch action,
case 'icon'
	t = [0:0.1:1.5*pi];
	y = (sin(t.*t)+1)/2*0.7;
	t = t / max(t);
   
    % Determine string on icon:
    txt = get_param(blk,'sweep');
    switch txt
    case {'Quadratic'}
        txt=txt(1:4); 
    case {'Linear', 'Logarithmic'}
        txt=txt(1:3); 
    case {'Swept cosine'}
        txt=txt(1:5); 
    end
    
   varargout = {t,y,txt};
   
case 'param'
   sweep = varargin{1};
   f0    = varargin{2};
   f1    = varargin{3};
   t1    = varargin{4};
   Tsweep= varargin{5};
   
   % Provide safe parameter handling for model update
   % [f0,f1,t1,Tsweep]=CheckParameter(f0,f1,t1,Tsweep);
   
   % Error checking:
	if (sweep == 3) & (f0 > f1),
   	error('F1>F0 is required for a log-sweep.');
	end
      
    fd = abs(f1-f0);
        
    switch sweep
    case 1
        % Swept cosine
        beta = fd/t1;
		if (f1 > f0) 
			fmin=f0;			
		else 
			fmin=f0-beta*Tsweep; 
		end;	
    case 2
        % Linear
        beta = fd/t1;
		if (f1 > f0) 
			fmin=f0;			
		else 
			fmin=f0-beta*Tsweep; 
		end;
    case 3
        % Logarithmic
        beta = log10(fd)./t1;
		fmin = f0;	
    otherwise
        % Quadratic
        if (f1 > f0)
            beta = fd./(t1.^2);
			fmin = f0;
        else
            beta = fd./(2.*Tsweep-t1)./t1;
			fmin = f0-beta*Tsweep^2;
		end
    end
    
   varargout = {beta, fmin};   
end

