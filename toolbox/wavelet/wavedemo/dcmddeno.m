function varargout = dcmddeno(varargin)
%DCMDDENO Demonstrates de-noising tools in the Wavelet Toolbox. 
%
% This is a slideshow file for use with wshowdrv.m
% To see it run, type 'wshowdrv dcmddeno', 
%
% See also DDENCMP, WAVEDEC, WCODEMAT, WDEN, WDENCMP, WNOISE.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 01-Jun-2001.
%   Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.16 $

% Initialization and Local functions if necessary.
if nargin>0
	action = varargin{1};
	switch action
      case 'addHelp'
		% Add Help Item.
		%---------------
        hdlFig = varargin{2};
		wfighelp('addHelpItem',hdlFig,'De-noising Procedure','DENO_PROCEDURE');
        
      case 'auto'    , wshowdrv('#autoMode',mfilename,'close');
	  case 'gr_auto' , wshowdrv('#gr_autoMode',mfilename,'close');

	  case 'getFigParam'
		figName  = '1-D De-noising using wavelet';
		showType = 'mix8';
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
	  ' denoising tools in the Wavelet Toolbox.',
	  '',
	  ' This demo uses Wavelet Toolbox functions.',
	  ''};

  %========== Slide 2 ==========
  idx = idx+1;
  slide(idx).code = {
	  'sigCOL = ''r''; sigCOL_2 = ''m''; noiCOL = ''g''; denCOL = ''y'';',
	  'sqrt_snr = 3; init = 2055615866;',
	  '[xref,x] = wnoise(3,11,sqrt_snr,init);',
	  'snr = sqrt_snr^2;',
	  
	  'ax = findall(figHandle,''type'',''axes''); delete(ax); drawnow; h = [];',
	  'h(1) = subplot(3,1,1);',
	  'plot(xref,sigCOL), axis([1 2048 -10 10]);',
	  'title(''Original signal'');',
	  'h(2) = subplot(3,1,2);',
	  'plot(x,noiCOL), axis([1 2048 -10 10]);',
	  'title([''Noisy signal - Signal to noise ratio = '',num2str(fix(snr))]);',
	  'set(h(1),''Xtick'',[],''Xticklabel'',[]);',	
	  '' };

  slide(idx).text = {
	  ' % Set signal to noise ratio and set rand seed.',
	  '        sqrt_snr = 3; init = 2055615866;',
	  ' % Generate original signal and a noisy version adding',
	  ' % a standard Gaussian white noise.',
	  '        [xref,x] = wnoise(3,11,sqrt_snr,init);',
	  ''};

  slide(idx).info = 'wnoise';

  %========== Slide 3 ==========
  idx = idx+1;
  slide(idx).code = {
	  'lev = 5;',
	  'xd  = wden(x,''heursure'',''s'',''one'',lev,''sym8'');',

	  'h(2) = subplot(3,1,2);',
	  'set(h(2),''Xtick'',[],''Xticklabel'',[]);',	
	  'h(3) = subplot(3,1,3); plot(xd); axis([1 2048 -10 10]);',
	  'title(''Denoised signal - heuristic SURE'');',	
	  '' };

  slide(idx).text = {
	  ' % Denoise noisy signal using soft heuristic SURE thresholding',
	  ' % and scaled noise option, on detail coefficients obtained',
	  ' % from the decomposition of x, at level 5 by sym8 wavelet.',
	  ' % Generate original signal and a noisy version adding',
	  ' % a standard Gaussian white noise.',
	  '         lev = 5;',
	  '         xd  = wden(x,''heursure'',''s'',''one'',lev,''sym8'');'
	  ''};

  slide(idx).info = 'wden';

  %========== Slide 4 ==========
  idx = idx+1;
  slide(idx).code = {
	  'xd  = wden(x,''rigrsure'',''s'',''one'',lev,''sym8'');',

	  'h(3) = subplot(3,1,3); plot(xd,denCOL); axis([1 2048 -10 10]);',
	  'title(''Denoised signal - SURE'');',	
	  '' };

  slide(idx).text = {
	  ' % Denoise noisy signal using soft SURE thresholding.',
	  ' ',
	  '         xd  = wden(x,''rigrsure'',''s'',''one'',lev,''sym8'');'
	  ''};

  slide(idx).info = 'wden';

  %========== Slide 5 ==========
  idx = idx+1;
  slide(idx).code = {
	  'xd  = wden(x,''sqtwolog'',''s'',''sln'',lev,''sym8'');',

	  'h(3) = subplot(3,1,3); plot(xd,denCOL); axis([1 2048 -10 10]);',
	  'title(''Denoised signal - Fixed form threshold'');',	
	  '' };

  slide(idx).text = {
	  ' % Denoise noisy signal using fixed form threshold with',
	  ' % a single level estimation of noise standard deviation.',
	  ' ',
	  '         xd  = wden(x,''sqtwolog'',''s'',''sln'',lev,''sym8'');'
	  ''};

  slide(idx).info = 'wden';

  %========== Slide 6 ==========
  idx = idx+1;
  slide(idx).code = {
	  'xd  = wden(x,''minimaxi'',''s'',''sln'',lev,''sym8'');',

	  'h(3) = subplot(3,1,3); plot(xd,denCOL); axis([1 2048 -10 10]);',
	  'title(''Denoised signal - Minimax'');',	
	  '' };

  slide(idx).text = {
	  ' % Denoise noisy signal using fixed minimax threshold with',
	  ' % a multiple level estimation of noise standard deviation.',
	  ' ',
	  '         xd  = wden(x,''minimaxi'',''s'',''sln'',lev,''sym8'');'
	  ''};

  slide(idx).info = 'wden';

  %========== Slide 7 ==========
  idx = idx+1;
  slide(idx).code = {
	  '[c,l] = wavedec(x,lev,''sym8'');',
	  'xd  = wden(x,''minimaxi'',''s'',''sln'',lev,''sym8'');',	

	  ['idxPREV = wshowdrv(''#get_idxSlide'',figHandle); idxSlide = ' int2str(idx) ';'],
	  'if idxPREV>idxSlide',
	  '   ax = findall(figHandle,''type'',''axes''); delete(ax); drawnow; h = [];',
	  '   h(1) = subplot(3,1,1);',
	  '   plot(xref,sigCOL), axis([1 2048 -10 10]);',
	  '   title(''Original signal'');',
	  '   h(2) = subplot(3,1,2);',
	  '   plot(x,noiCOL), axis([1 2048 -10 10]);',
	  '   snr = sqrt_snr^2;',
	  '   title([''Noisy signal - Signal to noise ratio = '',num2str(fix(snr))]);',
	  '   set(h(1:2),''Xtick'',[],''Xticklabel'',[]);',
	  'end'

	  'h(3) = subplot(3,1,3); plot(xd,denCOL); axis([1 2048 -10 10]);',
	  'title(''Denoised signal - Minimax'');',	
	  '' };

  slide(idx).text = {
	  ' % If many trials are necessary, it is better to perform',
	  ' % decomposition one time and threshold it many times :',
	  ' ',
	  '         % decomposition.',
	  '         [c,l] = wavedec(x,lev,''sym8'');',
	  ' ',
	  '         % threshold the decomposition structure [c,l].',
	  '         xd = wden(c,l,''minimaxi'',''s'',''sln'',lev,''sym8'');'
	  ''};

  slide(idx).info = 'wden';

  %========== Slide 8 ==========
  idx = idx+1;
  slide(idx).code = {
	  'load leleccum; indx = 2600:3100;',
	  'x = leleccum(indx);',	
	  
	  'ax = findall(figHandle,''type'',''axes''); delete(ax); drawnow; h = [];',
	  'h(1) = subplot(2,1,1);',
	  'plot(indx,x,sigCOL), title(''Original signal'');',
	  'title(''Original signal'');',
	  '' };

  slide(idx).text = {
	  ' % Load electrical signal and select a part.',
	  ' ',
	  '         load leleccum; indx = 2600:3100;',
	  '         x = leleccum(indx);',
	  ''};

  %========== Slide 9 ==========
  idx = idx+1;
  slide(idx).code = {
	  '[thr,sorh,keepapp] = ddencmp(''den'',''wv'',x);',
	  'xd = wdencmp(''gbl'',x,''db3'',2,thr,sorh,keepapp);',	
	  
	  'ax = findall(figHandle,''type'',''axes''); delete(ax); drawnow; h = [];',
	  'h(1) = subplot(2,1,1);',
	  'plot(indx,x,sigCOL), title(''Original signal'');',
	  'title(''Original signal'');',
	  'h(2) = subplot(2,1,2);',
	  'plot(indx,xd,denCOL); title(''Denoised signal'')',
	  '' };

  slide(idx).text = {
	  ' % Use wdencmp for signal de-noising.',
	  ' ',
	  '       % find default values (see ddencmp).',
	  '        [thr,sorh,keepapp] = ddencmp(''den'',''wv'',x);',
	  ' ',
	  '       % denoise signal using global thresholding option.',
	  '       xd = wdencmp(''gbl'',x,''db3'',2,thr,sorh,keepapp);',	
	  ''};

  slide(idx).info = 'wdencmp';

  %========== Slide 10 ==========
  idx = idx+1;
  slide(idx).code = {
	  'ax = findall(figHandle,''type'',''axes''); delete(ax); drawnow; h = [];',
	  'init = 2055615866;',
	  'sqrt_snr = 5;',      % square root of signal to noise ratio.
	  'snr = sqrt_snr^2;',  % signal to noise ratio.
	  '[xref,x] = wnoise(1,11,sqrt_snr,init);',
	  'indx = linspace(0,1,length(x));',
	  'h(1) = subplot(2,1,1);',
	  'plot(indx,x,denCOL,indx,xref,sigCOL_2)',
	  'title(''Noisy and Original signals'');',
	  'xlabel([''Signal to noise ratio = '',num2str(fix(snr))])',
	  'xd = wden(x,''heursure'',''s'',''one'',5,''sym8'');',
	  'h(2) = subplot(2,1,2);'
	  'plot(indx,xd,denCOL,indx,xref,sigCOL_2); xlabel(''Denoised and Original signals'');'
	  '' };

  slide(idx).text = {
	  ' % Some trial examples without commands counterpart.',
	  ' ',
	  ' % Rand initialization: init = 2055615866;',
	  ' % Square root of signal to noise ratio: sqrt_snr = 5;',
	  ' % [xref,x] = wnoise(1,11,sqrt_snr,init);',
	  ''};

  slide(idx).info = 'wden';

  %========== Slide 11 ==========
  idx = idx+1;
  slide(idx).code = {
	  'ax = findall(figHandle,''type'',''axes''); delete(ax); drawnow; h = [];',
	  'sqrt_snr = 4;',      % square root of signal to noise ratio.
	  'snr = sqrt_snr^2;',  % signal to noise ratio.
	  '[xref,x] = wnoise(2,11,sqrt_snr,init);',
	  'indx = linspace(0,1,length(x));',
	  'h(1) = subplot(2,1,1);',
	  'plot(indx,x,denCOL,indx,xref,sigCOL_2)',
	  'title(''Noisy and Original signals'');',
	  'xlabel([''Signal to noise ratio = '',num2str(fix(snr))])',
	  'xd = wden(x,''rigrsure'',''s'',''one'',5,''sym4'');',
	  'h(2) = subplot(2,1,2);'
	  'plot(indx,xd,denCOL,indx,xref,sigCOL_2); xlabel(''Denoised and Original signals'');'
	  '' };

  slide(idx).text = {
	  ' % Some trial examples without commands counterpart (more).',
	  ' ',
	  ' % Rand initialization: init = 2055615866;',
	  ' % Square root of signal to noise ratio: sqrt_snr = 4;',
	  ' % [xref,x] = wnoise(2,11,sqrt_snr,init);',
	  ''};

  slide(idx).info = 'wden';

  %========== Slide 12 ==========
  idx = idx+1;
  slide(idx).code = {
	  'ax = findall(figHandle,''type'',''axes''); delete(ax); drawnow; h = [];',
	  'sqrt_snr = 3;',      % square root of signal to noise ratio.
	  'snr = sqrt_snr^2;',  % signal to noise ratio.
	  '[xref,x] = wnoise(3,11,sqrt_snr,init);',
	  'indx = linspace(0,1,length(x));',
	  'h(1) = subplot(2,1,1);',
	  'plot(indx,x,denCOL,indx,xref,sigCOL_2)',
	  'title(''Noisy and Original signals'');',
	  'xlabel([''Signal to noise ratio = '',num2str(fix(snr))])',
	  'xd = wden(x,''sqtwolog'',''s'',''one'',5,''sym8'');',
	  'h(2) = subplot(2,1,2);'
	  'plot(indx,xd,denCOL,indx,xref,sigCOL_2); xlabel(''Denoised and Original signals'');'
	  '' };

  slide(idx).text = {
	  ' % Some trial examples without commands counterpart (more).',
	  ' ',
	  ' % Rand initialization: init = 2055615866;',
	  ' % Square root of signal to noise ratio: sqrt_snr = 3;',
	  ' % [xref,x] = wnoise(3,11,sqrt_snr,init);',
	  ''};

  slide(idx).info = 'wden';

  %========== Slide 13 ==========
  idx = idx+1;
  slide(idx).code = {
	  'set(figHandle,''Name'',''1-D De-noising using wavelet'');',
	  'ax = findall(figHandle,''type'',''axes''); delete(ax); drawnow; h = [];',
	  'sqrt_snr = 2;',      % square root of signal to noise ratio.
	  'snr = sqrt_snr^2;',  % signal to noise ratio.
	  '[xref,x] = wnoise(3,11,sqrt_snr,init);',
	  'indx = linspace(0,1,length(x));',
	  'h(1) = subplot(2,1,1);',
	  'plot(indx,x,denCOL,indx,xref,sigCOL_2)',
	  'title(''Noisy and Original signals'');',
	  'xlabel([''Signal to noise ratio = '',num2str(fix(snr))])',
	  'xd = wden(x,''sqtwolog'',''s'',''one'',5,''sym8'');',
	  'h(2) = subplot(2,1,2);'
	  'plot(indx,xd,denCOL,indx,xref,sigCOL_2); xlabel(''Denoised and Original signals'');'
	  '' };

  slide(idx).text = {
	  ' % Some trial examples without commands counterpart (more).',
	  ' ',
	  ' % Rand initialization: init = 2055615866;',
	  ' % Square root of signal to noise ratio: sqrt_snr = 2;',
	  ' % [xref,x] = wnoise(3,11,sqrt_snr,init);',
	  ''};

  slide(idx).info = 'wden';

  %========== Slide 14 ==========
  idx = idx+1;
  slide(idx).code = {
	  'ax = findall(figHandle,''type'',''axes''); delete(ax); drawnow; h = [];',
	  'sqrt_snr = 4;',      % square root of signal to noise ratio.
	  'snr = sqrt_snr^2;',  % signal to noise ratio.
	  '[xref,x] = wnoise(4,11,sqrt_snr,init);',
	  'indx = linspace(0,1,length(x));',
	  'h(1) = subplot(2,1,1);',
	  'plot(indx,x,denCOL,indx,xref,sigCOL_2)',
	  'title(''Noisy and Original signals'');',
	  'xlabel([''Signal to noise ratio = '',num2str(fix(snr))])',
	  'xd = wden(x,''minimaxi'',''s'',''one'',5,''sym4'');',
	  'h(2) = subplot(2,1,2);'
	  'plot(indx,xd,denCOL,indx,xref,sigCOL_2); xlabel(''Denoised and Original signals'');'
	  '' };

  slide(idx).text = {
	  ' % Some trial examples without commands counterpart (more).',
	  ' ',
	  ' % Rand initialization: init = 2055615866;',
	  ' % Square root of signal to noise ratio: sqrt_snr = 4;',
	  ' % [xref,x] = wnoise(4,11,sqrt_snr,init);',
	  ''};
  
  slide(idx).info = 'wden';

  %========== Slide 15 ==========
  idx = idx+1;
  slide(idx).code = {
	  'row = 2; col = 2;',
	  'load  sinsin',
	  'sm = size(map,1);',
	  
	 ['idxPREV = wshowdrv(''#get_idxSlide'',figHandle); idxSlide = ' int2str(idx) ';'],
	  'if idxPREV>idxSlide',
	  '   delete(subplot(row,col,2));',
	  'else',
	  '   set(figHandle,''Name'',''2-D De-noising using wavelet'');',
	  '   ax = findall(figHandle,''type'',''axes''); delete(ax); drawnow; h = [];',
	  '   colormap(pink)',
	  '   h(1) = subplot(row,col,1);';
	  '   image(wcodemat(X,sm)), title(''Original Image'');',
	  '   axis(''square'')';
	  '   set(h(1),''Xtick'',[],''Xticklabel'',[],''Ytick'',[],''Yticklabel'',[]);',
	  'end',
	  '' };

  slide(idx).text = {
	  ' % Load original image.',
	  '         load sinsin',	
	  '         % X contains the original image.',	
	  ''};
  
  %========== Slide 16 ==========
  idx = idx+1;
  slide(idx).code = {
	  'init = 2055615866; randn(''seed'',init);', 
	  'x = X + 18*randn(size(X));',

	  ['idxPREV = wshowdrv(''#get_idxSlide'',figHandle); idxSlide = ' int2str(idx) ';'],
	  'if idxPREV>idxSlide',
	  '   delete(subplot(row,col,3));',
	  'else',
	  '   h(2) = subplot(row,col,2);',
	  '   image(wcodemat(x,sm)), title(''Noisy Image'');',
	  '   axis(''square'')',
	  '   set(h(2),''Xtick'',[],''Xticklabel'',[],''Ytick'',[],''Yticklabel'',[]);',
	  'end',
	  '' };

  slide(idx).text = {
	  ' % Generate noisy image.',
	  ' ',
	  '         init = 2055615866; randn(''seed'',init);',	
	  '         x = X + 18*randn(size(X));',	
	  ''};

  %========== Slide 17 ==========
  idx = idx+1;
  slide(idx).code = {
	  '[thr,sorh,keepapp] = ddencmp(''den'',''wv'',x);',
	  'xd = wdencmp(''gbl'',x,''sym4'',2,thr,sorh,keepapp);',
	  'h(3) = subplot(row,col,3);',
	  'image(wcodemat(xd,sm)), title(''De-noised Image'');',
	  'axis(''square'')',
	  'set(h(3),''Xtick'',[],''Xticklabel'',[],''Ytick'',[],''Yticklabel'',[]);',	
	  '' };

  slide(idx).text = {
	  ' % Use wdencmp for image de-noising.',
	  ' ',
	  '         % find default values (see ddencmp).',	
	  '         [thr,sorh,keepapp] = ddencmp(''den'',''wv'',x);',	
	  ' ',
	  '         % denoise image using global thresholding option.',	
	  '         xd = wdencmp(''gbl'',x,''sym4'',2,thr,sorh,keepapp);',	
	  ''};

  slide(idx).info = 'wdencmp';

  varargout{1} = slide;
end
