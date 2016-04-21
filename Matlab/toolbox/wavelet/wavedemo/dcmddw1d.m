function varargout = dcmddw1d(varargin)
%DCMDDW1D Demonstrates discrete 1-D wavelet tools in the Wavelet Toolbox.
%
% This is a slideshow file for use with wshowdrv.m
% To see it run, type 'wshowdrv dcmddw1d', 
%
% See also APPCOEF, DETCOEF, DWT, IDWT, UPCOEF,
%          WAVEDEC, WAVEREC, WRCOEF. 

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 01-Jun-2001.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.14 $

% Initialization and Local functions if necessary.
if nargin>0
	action = varargin{1};
	switch action
      case 'addHelp'
		% Add Help Item.
		%---------------
        hdlFig = varargin{2};
		wfighelp('addHelpItem',hdlFig,'Wavelet Decomposition','DW1D_DECOMPOS');
          
	  case 'auto'    , wshowdrv('#autoMode',mfilename,'close');
	  case 'gr_auto' , wshowdrv('#gr_autoMode',mfilename,'close');
	  case 'getFigParam'
		figName  = 'Orthogonal Wavelets 1-D';
		showType = 'mix6';
		varargout = {figName,showType};
	end
	return
end

if nargout<1,
  wshowdrv(mfilename)
else
  idx = 0;	
  %========== Slide 1 ==========
  idx = idx+1;
  slide(idx).code = {
	'figHandle = gcf;',
	'ax = findall(figHandle,''type'',''axes''); delete(ax); drawnow; h = [];',		  	
	'' };

  slide(idx).text = {
	'',
	' Press the "Start" button to see a demonstration of',
	' 1-D wavelet tools.',
	'',
	' This demo uses Wavelet Toolbox functions.',
	''};
	
  %========== Slide 2 ==========
  idx = idx+1;
  slide(idx).code = {
	'ax = findall(figHandle,''type'',''axes''); delete(ax); drawnow;  h = [];',		  	
	'load leleccum; s = leleccum(1:3920);',
	'ls = length(s);',
	'clear leleccum',
	'h(1) = subplot(2,1,1); plot(1:ls,s,''r'')',
	'title(''Original signal s.'');',
	'set(h(1),''Xlim'',[1,ls]);',
	'' };

  slide(idx).text = {
	' % Load original 1D signal.',
	'',
	'        load leleccum; s = leleccum(1:3920);',
	'        ls = length(s);',
	''};

  %========== Slide 3 ==========
  idx = idx+1;
  slide(idx).code = {
	'[ca1,cd1] = dwt(s,''db1'');',

	'ax = findall(figHandle,''type'',''axes''); delete(ax); drawnow; h = [];',		  	
	'h(1) = subplot(2,1,1); plot(1:ls,s,''r'')',
	'title(''Original signal s.'');',
	'set(h(1),''Xlim'',[1,ls]);',

	'h(3) = subplot(2,2,3); plot(1:length(ca1),ca1);',
	'title(''Approx. coef. : ca1'');',
	'set(h(3),''Xlim'',[1,length(ca1)]);',  
	'h(4) = subplot(2,2,4); plot(1:length(cd1),cd1);',
	'title(''Detail coef. : cd1'');',
	'set(h(4),''Xlim'',[1,length(cd1)]);',   
	'' };

  slide(idx).text = {
	' % Perform one step decomposition of s using db1.',
	'',
 	'        [ca1,cd1] = dwt(s,''db1'');',
	''};

  slide(idx).info = 'dwt';

  %========== Slide 4 ==========
  idx = idx+1;
  slide(idx).code = {
	'a1 = upcoef(''a'',ca1,''db1'',1,ls);',
    'd1 = upcoef(''d'',cd1,''db1'',1,ls);',

	'ax = findall(figHandle,''type'',''axes''); delete(ax); drawnow;  h = [];',		  	
	'h(1) = subplot(3,1,1); plot(1:ls,s,''r'');',
	'title(''Original signal s.'');',
	'h(2) = subplot(3,1,2); plot(1:ls,a1);',
	'title(''Approximation : a1.'');',
	'h(3) = subplot(3,1,3); plot(1:ls,d1);',
	'title(''Detail : d1.'');',
	'set(h(1:2),''Xtick'',[],''Xticklabel'',[]);', 
	'set(h,''Xlim'',[1,ls]);', 	
	''};

  slide(idx).text = {
	' % Perform one step reconstruction of  ca1 and cd1.',
	'',
	'        a1 = upcoef(''a'',ca1,''db1'',1,ls);',
	'        d1 = upcoef(''d'',cd1,''db1'',1,ls);',
	''};

  slide(idx).info = 'upcoef';

  %========== Slide 5 ==========
  idx = idx+1;
  slide(idx).code = {
	'ax = findall(figHandle,''type'',''axes''); delete(ax); drawnow;  h = [];',		  	
	'h(1) = subplot(3,1,1); plot(1:ls,s,''r'');',
	'title(''Original signal s.'');',
	'h(2) = subplot(3,1,2); plot(1:ls,a1+d1);',
	'title(''Approximation + detail : a1  + d1.'');',
	'set(h(1),''Xtick'',[],''Xticklabel'',[]);',
	'set(h,''Xlim'',[1,ls]);', 		
	''};

  slide(idx).text = {
	' % Now plot a1 + d1.',
	''};

  slide(idx).info = 'upcoef';

  %========== Slide 6 ==========
  idx = idx+1;
  slide(idx).code = {
	'a0 = idwt(ca1,cd1,''db1'',ls);',
	  
	'ax = findall(figHandle,''type'',''axes''); delete(ax); drawnow;  h = [];',		  	
	'h(1) = subplot(3,1,1); plot(1:ls,s,''r'');',
	'title(''Original signal s.'');',
	'h(2) = subplot(3,1,2); plot(1:ls,a1+d1);',
	'title(''Approximation + detail : a1  + d1.'');',
	'set(h(1:2),''Xtick'',[],''Xticklabel'',[]);',
	  
	'h(3) = subplot(3,1,3); plot(1:ls,a0);',
	'title(''Reconstructed signal : a0.'');',
	'set(h,''Xlim'',[1,ls]);', 			
	''};

  slide(idx).text = {
	' % Invert directly decomposition of s using coefficients.',
	'',
	'        a0 = idwt(ca1,cd1,''db1'',ls);',
	''};

  slide(idx).info = 'idwt';

  %========== Slide 7 ==========
  idx = idx+1;
  slide(idx).code = {
	'ax = findall(figHandle,''type'',''axes''); delete(ax); drawnow;  h = [];',		  	
	'[c,l] = wavedec(s,3,''db1'');',
	'h(1) = subplot(5,1,1); plot(1:ls,s,''r'');',
	'title(''Original signal s.'');',
	'set(h,''Xlim'',[1,ls]);', 				
	''};

  slide(idx).text = {
	' % Perform decomposition at level 3 of s using db1.',
	'',
	'        [c,l] = wavedec(s,3,''db1'');',
	''};

  slide(idx).info = 'wavedec';

  %========== Slide 8 ==========
  idx = idx+1;
  slide(idx).code = {
	'ca3 = appcoef(c,l,''db1'',3);',		  	  

	'ax = findall(figHandle,''type'',''axes''); delete(ax); drawnow;  h = [];',		  	
	'h(1) = subplot(5,1,1); plot(1:ls,s,''r'');',
	'set(h(1),''Xtick'',[],''Xticklabel'',[],''Xlim'',[1,ls]);', 	
	'h(2) = subplot(5,8,9); plot(1:length(ca3),ca3);',
	'subplot(5,1,1); title(''Original signal s and ca3.'')',
	''};

  slide(idx).text = {
	' % Extract approximation coefficients at level 3,',
	' % from wavelet decomposition structure [c,l].',
	'',
	'        ca3 = appcoef(c,l,''db1'',3);',
	''};

  slide(idx).info = 'appcoef';

  %========== Slide 9 ==========
  idx = idx+1;
  slide(idx).code = {
	'cd3 = detcoef(c,l,3);',
	'cd2 = detcoef(c,l,2);',		  	  
	'cd1 = detcoef(c,l,1);',

	'ax = findall(figHandle,''type'',''axes''); delete(ax); drawnow;  h = [];',		  	
	'h(1) = subplot(5,1,1); plot(1:ls,s,''r'');',
	'set(h(1),''Xtick'',[],''Xticklabel'',[],''Xlim'',[1,ls]);', 	
	'h(2) = subplot(5,8,9); plot(1:length(ca3),ca3);',

	'subplot(5,1,1); title(''Original signal s , ca3 and cd3.'')',
	'set(h(2),''Xtick'',[],''Xticklabel'',[]);', 	
	'h(3) = subplot(5,8,17); plot(1:length(cd3),cd3);',
	'pause(1)',
	'subplot(5,1,1); title(''Original signal s , ca3, cd3 and cd2.'')',
	'set(h(3),''Xtick'',[],''Xticklabel'',[]);', 	
	'h(4) = subplot(5,4,13); plot(1:length(cd2),cd2);',
	'pause(1)',
	'subplot(5,1,1); title(''Original signal s , ca3, cd3, cd2 and cd1.'')',	
	'set(h(4),''Xtick'',[],''Xticklabel'',[]);', 	
	'h(5) = subplot(5,2,9); plot(1:length(cd1),cd1);',		
	''};

  slide(idx).text = {
	' % Extract detail coefficients at levels 1, 2 and 3,',
	' % from wavelet decomposition structure [c,l].',
	'',
	'        cd3 = detcoef(c,l,3);',
	'        cd2 = detcoef(c,l,2);',
	'        cd1 = detcoef(c,l,1);',
	''};

  slide(idx).info = 'detcoef';

  %========== Slide 10 ==========
  idx = idx+1;
  slide(idx).code = {
	'a3 = wrcoef(''a'',c,l,''db1'',3);',

	'ax = findall(figHandle,''type'',''axes''); delete(ax); drawnow;  h = [];',		  	
	'h(1) = subplot(5,1,1); plot(s,''r'');',
	'title(''Original signal s and approximation of level 3.'');',
	'h(2) = subplot(5,1,2); plot(1:ls,a3);',
	'set(h(1),''Xtick'',[],''Xticklabel'',[]);',
	'set(h,''Xlim'',[1,ls]);',		
	''};

  slide(idx).text = {
	' % Reconstruct approximation at level 3,',
 	' % from wavelet decomposition structure [c,l].',
	'',
	'        a3 = wrcoef(''a'',c,l,''db1'',3);',
	''};

  slide(idx).info = 'wrcoef';

  %========== Slide 11 ==========
  idx = idx+1;
  slide(idx).code = {
	'd3 = wrcoef(''d'',c,l,''db1'',3);',
	'd2 = wrcoef(''d'',c,l,''db1'',2);',
	'd1 = wrcoef(''d'',c,l,''db1'',1);',
	
	'ax = findall(figHandle,''type'',''axes''); delete(ax); drawnow;  h = [];',		  	
	'h(1) = subplot(5,1,1); plot(s,''r'');',
	'title(''Original signal s and a3 d3 d2 d1.'');',	
	'h(2) = subplot(5,1,2); plot(1:ls,a3);',
	
	'h(3) = subplot(5,1,3); plot(1:ls,d3);',
	'h(4) = subplot(5,1,4); plot(1:ls,d2);',
	'h(5) = subplot(5,1,5); plot(1:ls,d1);',
	'set(h(1:4),''Xtick'',[],''Xticklabel'',[]);',
	'set(h,''Xlim'',[1,ls]);',	
	''};

  slide(idx).text = {
	' % Reconstruct detail coefficients at levels 1,2 and 3,',
	' % from the wavelet decomposition structure [c,l].',
	'',
	'        d3 = wrcoef(''d'',c,l,''db1'',3);',
	'        d2 = wrcoef(''d'',c,l,''db1'',2);',
	'        d1 = wrcoef(''d'',c,l,''db1'',1);',  
	''};

  slide(idx).info = 'wrcoef';

  %========== Slide 12 ==========
  idx = idx+1;
  slide(idx).code = {
	'a0 = waverec(c,l,''db1'');',

	'ax = findall(figHandle,''type'',''axes''); delete(ax); drawnow;  h = [];',		  	
	'h(1) = subplot(2,1,1); plot(s,''r'');',
	'title(''Original signal s .'');',	
	'h(2) = subplot(2,1,2); plot(1:ls,a0);',
	'title(''Reconstructed signal a0.'');',
	'set(h,''Xlim'',[1,ls]);',		
	''};

  slide(idx).text = {
	' % Reconstruct s from the wavelet decomposition structure [c,l].',
	'',
	'        a0 = waverec(c,l,''db1'');',
	''};

  slide(idx).info = 'waverec';

  varargout{1} = slide;
end
