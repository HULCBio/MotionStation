function varargout = dcmdcomp(varargin)
%DCMDCOMP Demonstrates compression tools in the Wavelet Toolbox.
%
% This is a slideshow file for use with wshowdrv.m
% To see it run, type 'wshowdrv dcmdcomp',
%
% See also WAVEDEC2, WCODEMAT, WDENCMP.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 01-Jun-2001.
%   Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.14 $

% Initialization and Local functions if necessary.
if nargin>0
	action = varargin{1};
	switch action
      case 'addHelp'
		% Add Help Item.
		%---------------
        hdlFig = varargin{2};
		wfighelp('addHelpItem',hdlFig,'Compression Procedure','COMP_PROCEDURE');
        
	  case 'auto'    , wshowdrv('#autoMode',mfilename,'close');
	  case 'gr_auto' , wshowdrv('#gr_autoMode',mfilename,'close');

	  case 'getFigParam'
		figName  = 'Compression 1-D';
		showType = 'mix9';
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
	  ' compression tools in the Wavelet Toolbox.',
	  '',
	  ' This demo uses Wavelet Toolbox functions.',
	  ''};

  %========== Slide 2 ==========
  idx = idx+1;
  slide(idx).code = {
	  'load leleccum; indx = 2600:3100;', 
	  'x = leleccum(indx);',
	  
	  'ax = findall(figHandle,''type'',''axes''); delete(ax); drawnow; h = [];',
	  'h(1) = subplot(2,1,1);',
	  'plot(indx,x,''r''), title(''Original signal'');',
	  '' };

  slide(idx).text = {
	  ' % Load electrical signal and select a part.',
	  ' ',
	  '        load leleccum; indx = 2600:3100;',
	  '        x = leleccum(indx);',
	  ''};

  %========== Slide 3 ==========
  idx = idx+1;
  slide(idx).code = {
	  'thr = 35;',
	  '[xd,cxd,lxd,perf0,perfl2] = wdencmp(''gbl'',x,''db3'',3,thr,''h'',1);',
	  
	  'set(figHandle,''Name'',''Compression 1-D'');',	
	  'ax = findall(figHandle,''type'',''axes''); delete(ax); drawnow; h = [];',
	  'h(1) = subplot(2,1,1);',
	  'plot(indx,x,''r''), title(''Original signal'');',
	  
	  'set(h(1),''Xtick'',[],''XtickLabel'',[]);',
	  'h(2) = subplot(2,1,2);',
	  'plot(indx,xd), title(''Compressed signal'')',
	  'N2Str = [''2-norm rec.: '',num2str(perfl2,''%5.2f''),'' %''];',
	  'N0Str = [''nul cfs: '',num2str(perf0,''%5.2f''),'' %''];',
	  'xlabel([N2Str,'' - '',N0Str])',
	  ''};

  slide(idx).text = {
	  ' % Use wdencmp for signal compression.', 
	  ' ', 
	  '        % compress using a fixed threshold',
	  '        % and compute 2-norm recovery.', 
	  '        thr = 35;',
	  '        [xd,cxd,lxd,perf0,perfl2] = wdencmp(''gbl'',x,''db3'',3,thr,''h'',1);',
	  ''};

  slide(idx).info = 'wdencmp';

  %========== Slide 4 ==========
  idx = idx+1;
  slide(idx).code = {
	  'subr = 1; subc = 2;',
	  ['idxPREV = wshowdrv(''#get_idxSlide'',figHandle); idxSlide = ' int2str(idx) ';'],
	  'if idxPREV<idxSlide',
	  '   set(figHandle,''Name'',''Compression 2-D'');',
	  '   ax = findall(figHandle,''type'',''axes''); delete(ax); drawnow; h = [];',
	  '   load woman; x = X(100:200,100:200);',
	  '   nbc = size(map,1);',	
	  '   h(1) = subplot(subr,subc,1);',
	  '   colormap(pink(nbc));',
	  '   image(wcodemat(x,nbc)); title(''Original image'');',
	  '   axis(''square'');',
	  '   set(h(1),''Xtick'',[],''Ytick'',[]);',
	  'else',
	  '   delete(subplot(subr,subc,2));',
	  'end',
	  '' };

  slide(idx).text = {
	  ' % load original image.', 
	  ' ', 
	  '        load woman; x = X(100:200,100:200);',
	  ''};

  %========== Slide 5 ==========
  idx = idx+1;
  slide(idx).code = {
	  'n = 5; w = ''sym2'';', 
	  '[c,l] = wavedec2(x,n,w);',
	  'thr = 20;',
	  '[xd,cxd,lxd,perf0,perfl2] = wdencmp(''gbl'',c,l,w,n,thr,''h'',1);',
	  
	  'h(2) = subplot(subr,subc,2);',
	  'image(wcodemat(xd,nbc));',
	  'title([''Compressed Image. Threshold = '',num2str(thr)])',
	  'N2Str = [''2-norm rec.: '',num2str(perfl2,''%5.2f''),'' %''];',
	  'N0Str = [''nul cfs: '',num2str(perf0,''%5.2f''),'' %''];',
	  'strxlab = strvcat(N2Str,N0Str);',
	  'xlabel(strxlab);',
	  'axis(''square'');',
	  'set(h(2),''Xtick'',[],''Ytick'',[]);',	
	  '' };

  slide(idx).text = {
	  ' % Use wdencmp for image compression.',
	  '     % wavelet decomposition of x.',
	  '         n = 5; w = ''sym2'';',
	  '         [c,l] = wavedec2(x,n,w);',
	  '     % wavelet coefficients thresholding',
	  '     % and computation of  2-norm recovery.',
	  '         thr = 20;',
	  '         [xd,cxd,lxd,perf0,perfl2] = wdencmp(''gbl'',c,l,w,n,thr,''h'',1);',
	  ''};

  slide(idx).info = 'wdencmp';

  %========== Slide 5 ==========
  idx = idx+1;
  slide(idx).code = {
	  'thr_h = [17 18];',        % horizontal thresholds.
	  'thr_d = [19 20];',        % diagonal thresholds.
	  'thr_v = [21 22];',        % vertical thresholds.
	  'thr = [thr_h ; thr_d ; thr_v];',        
	  '[xd,cxd,lxd,perf0,perfl2] = wdencmp(''lvd'',x,''sym8'',2,thr,''h'');',

	  'h(2) = subplot(subr,subc,2);',
	  'image(wcodemat(xd,nbc));',
	  'title([''Comp. Ima. Thr = [17 18;19 20;21 22]''])',
	  'N2Str = [''2-norm rec.: '',num2str(perfl2,''%5.2f''),'' %''];',
	  'N0Str = [''nul cfs: '',num2str(perf0,''%5.2f''),'' %''];',
	  'strxlab = strvcat(N2Str,N0Str);',
	  'xlabel(strxlab);',
	  'axis(''square'');',
	  'set(h(2),''Xtick'',[],''Ytick'',[]);',	
	  '' };

  slide(idx).text = {
	  ' % In addition the first option allows level and orientation',
	  ' % dependent thresholds. In this case the approximation is kept.',
	  ' % The level dependent thresholds in the three orientations', 
	  ' % horizontal, diagonal and vertical are as follow.',
	  '         thr_h = [17 18];        % horizontal thresholds.', 
	  '         thr_d = [19 20];        % diagonal thresholds.',
	  '         thr_v = [21 22];        % vertical thresholds.',
	  '         thr = [thr_h ; thr_d ; thr_v]', 
	  '         [xd,cxd,lxd,perf0,perfl2] = wdencmp(''lvd'',x,''sym8'',2,thr,''h'');',
	  ''};
 
  slide(idx).info = 'wdencmp';

  varargout{1} = slide;
end
