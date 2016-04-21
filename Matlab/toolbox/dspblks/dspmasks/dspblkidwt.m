function varargout = dspblkidwt(action,varargin)
%DSPBLKWAVREC Signal Processing Blockset Wavelet Synthesis block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.3.4.2 $  $Date: 2004/04/12 23:06:39 $

if nargin==0, action = 'dynamic'; end

% Cache the block handle once
blk = gcbh;
wavname = get_param(blk,'Wname');

switch action 
case 'dynamic',
    % Execute dynamic dialogs      
    mask_enables = get_param(blk,'maskenables');
    mask_visibilities = get_param(blk,'maskvisibilities');
   
    % Dynamic dialog callback:
    if strcmp(wavname,'User-defined'),
        %user defined LPF and HPF 
        mask_enables{2} = 'off';
        mask_enables{3} = 'off';
        mask_enables{4} = 'on';
        mask_enables{5} = 'on';
        %mask_enables{7} = 'on';
        mask_visibilities{2} = 'off';
        mask_visibilities{3} = 'off';
        mask_visibilities{4} = 'on';
        mask_visibilities{5} = 'on';
    else 
        %wavelet families
        mask_enables{4} = 'off';
        mask_enables{5} = 'off';
        %mask_enables{7} = 'off';
        mask_visibilities{4} = 'off';
        mask_visibilities{5} = 'off';
        %mask_visibilities{7} = 'off';
        if strcmp(wavname,'Haar'),
            mask_enables{2} = 'off';
            mask_enables{3} = 'off';
            mask_visibilities{2} = 'off';
            mask_visibilities{3} = 'off';
        elseif strcmp(wavname,'Daubechies'),
            mask_enables{2} = 'off';
            mask_enables{3} = 'on';
            mask_visibilities{2} = 'off';
            mask_visibilities{3} = 'on';      
        elseif strcmp(wavname,'Symlets'),
            mask_enables{2} = 'off';
            mask_enables{3} = 'on';
            mask_visibilities{2} = 'off';
            mask_visibilities{3} = 'on';            
        elseif strcmp(wavname,'Coiflets'),
            mask_enables{2} = 'off';
            mask_enables{3} = 'on';
            mask_visibilities{2} = 'off';
            mask_visibilities{3} = 'on';      
        elseif strcmp(wavname,'Biorthogonal'),
            mask_enables{2} = 'on';
            mask_enables{3} = 'off';
            mask_visibilities{2} = 'on';
            mask_visibilities{3} = 'off';            
        elseif strcmp(wavname,'Reverse Biorthogonal'),
            mask_enables{2} = 'on';
            mask_enables{3} = 'off';
            mask_visibilities{2} = 'on';
            mask_visibilities{3} = 'off';            
        elseif strcmp(wavname,'Discrete Meyer'),
            mask_enables{2} = 'off';
            mask_enables{3} = 'off';
            mask_visibilities{2} = 'off';
            mask_visibilities{3} = 'off';
        end
    end
      
set_param(blk,'maskenables',mask_enables);
set_param(blk,'maskvisibilities',mask_visibilities);

case 'init'
    if strcmp(wavname,'User-defined')
        hl = varargin{1};
        hh = varargin{2};
    else
        %Wavelet families
        order = get_param(blk, 'Order');
        %Biorthogonal and Reverse Biorthogonal cases:
        nrec_ndec = get_param(blk,'OrdRec_ordDec');
        nrec_ndec = [nrec_ndec(2) '.' nrec_ndec(end-1)]; 
        %Build wavelet name
        switch wavname,
        case 'Haar',
            Wname = 'haar';
        case 'Daubechies',
            Wname = ['db', order];
        case 'Symlets',
            Wname = ['sym', order];
        case 'Coiflets',
            Wname = ['coif', order];
        case 'Biorthogonal',
            Wname = ['bior', nrec_ndec];
        case 'Reverse Biorthogonal',
            Wname = ['rbio', nrec_ndec];
        case 'Discrete Meyer',
            Wname = 'dmey';
        end
        if (exist('wfilters.m','file') == 2),
   	        try
	            % Calculate Wavelet filter coefficients (Wavelet Toolbox)
		        [hl, hh] = wfilters(Wname,'r'); 
	        catch	
   		        error(lasterr); % Error on invalid wavelet case
   	        end		
 	    else
		    error('The Wavelet Toolbox is not installed.');      
        end	
        
    end
    
    orig_hl = hl;
    orig_hh = hh;

% Need to reshuffle the coefficients into phase order 
[M,N] = size(hl);
if (M == 1 | N == 1)
 % Need to reshuffle the coefficients into phase order
 len = length(hl);
  L = 2;
 if (rem(len, L) ~= 0)
  nzeros = L - rem(len, L);
  hl = [(hl(:)); zeros(nzeros,1)];
  end
  len = length(hl);
  nrows = len / L;
  % Re-arrange the coefficient and gain-scale
  hl = reshape(hl, L, nrows).'; 
  end
    
   [M,N] = size(hh);
   if (M == 1 | N == 1)  
  	% Need to reshuffle the coefficients into phase order
  	len = length(hh);
    L = 2;
  	if (rem(len, L) ~= 0)
  		nzeros = L - rem(len, L);
  		hh = [(hh(:)); zeros(nzeros,1)];
  	end
  	len = length(hh);
  	nrows = len / L;
  	% Re-arrange the coefficient and gain-scale
  	hh = reshape(hh, L, nrows).';
  end

varargout = {hl, hh, orig_hl, orig_hh};

case 'icon'
   % Icon drawing
   levelStr = get_param(blk,'NumLevels');
   numLevels = str2num(levelStr);
   if (isempty(numLevels) | ~isfinite(numLevels) | ~isnumeric(numLevels) | numLevels < 1)
   	numLevels = 2;
   end		
   
   tree = get_param(blk,'tree');
   
   numLevels = 2;   %We decide to draw only generic 2-level icon for all numLevels
   if strcmp(tree,'Symmetric')
       %Draw Symmetric Tree
         dx = -(1.0 - 0.1) / (numLevels+1);
         [x1,y1] = recursive_icon(1, numLevels, 0.95+dx, 0.5);
         % Draw the arrowhead
         x0 = 0.95;
         x(1) = x0;            y(1) = 0.5;
         x(2) = x0 + 0.2*dx;   y(2) = 0.5;
         x(3) = x0 + 0.8*dx;   y(3) = 0.4;
         x(4) = x0 + 0.8*dx;   y(4) = 0.6;
         x(5) = x0 + 0.2*dx;   y(5) = 0.5;
         x0 = x0 + dx;
         x(6) = x0;            y(6) = 0.5;
         x = [x x1];
         y = [y y1];
         
   else
        %Draw Asymmetric Tree
          dx = -(1.0 - 0.1) / (numLevels+1);
         dy = (1.0) / (numLevels+1);
         x0 = 0.95;
         y0 = 1 - dy*0.5;
         % Draw the arrowhead
         x(1) = x0;            y(1) = y0;
         x(2) = 0.05;          y(2) = y0;
         x(3) = x0 + 0.2*dx;   y(3) = y0;
         x(4) = x0 + 0.8*dx;   y(4) = y0 + 0.3*dy;
         x(5) = x0 + 0.8*dx;   y(5) = y0 - 0.3*dy;
         x(6) = x0 + 0.2*dx;   y(6) = y0;
         x0 = x0 + dx;
         x(7) = x0;            y(7) = y0;
         y0 = y0 - dy;
         
         for k=0:numLevels-1
            m = 3*k+8;
            x(m) = x0;      y(m) = y0;
            x(m+1) = 0.05;  y(m+1) = y0; 
            x0 = x0 + dx;
            x(m+2) = x0;    y(m+2) = y0;
            y0 = y0 - dy;
         end
   
    end
   
    if strcmp(tree,'Asymmetric')
        treeStr = ': Asym';
    else
        treeStr = ': Sym';
    end
	disp_str = [levelStr treeStr];
   varargout = {x, y, disp_str};
   
otherwise,
   error('Unknown action specified');
end

%-------------------------------------------------
function [x, y] = recursive_icon(level, numLevels, x0, y0)
dx = -(1.0 - 0.1) / (numLevels+1);
dy = 0.5 / (round(2^level));
x1(1) = x0;			y1(1) = y0 + dy;
x1(2) = x0 + dx;	y1(2) = y0 + dy;
if (level < numLevels)
   [x2, y2] = recursive_icon(level+1, numLevels, x0+dx, y0+dy);
else
   x2 = [];  y2=[];
end
x3(1) = x0;			y3(1) = y0 + dy;
x3(2) = x0;			y3(2) = y0 - dy;
x3(3) = x0+dx;		y3(3) = y0 - dy;
if (level < numLevels)
   [x4, y4] = recursive_icon(level+1, numLevels, x0+dx, y0-dy);
else
   x4 = [];  y4= [];
end
x5(1) = x0;			y5(1) = y0 - dy;
x5(2) = x0;			y5(2) = y0;
x = [x1 x2 x3 x4 x5];
y = [y1 y2 y3 y4 y5];

%-------------------------------------------------
% [EOF] dspblkwaverec.m 