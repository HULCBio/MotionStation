function varargout = dcmdextm(varargin)
%DCMDEXTM Demonstrates border distortions tools in the Wavelet Toolbox. 
%
% This is a slideshow file for use with wshowdrv.m
% To see it run, type 'wshowdrv dcmdextm', 
%
% See also DWTMODE, WAVEDEC, WAVEDEC2, WRCOEF2. 

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 07-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.14.4.2 $  $Date: 2004/03/15 22:36:59 $

% Initialization and Local functions if necessary.
if nargin>0
	action = varargin{1};
	switch action
      case 'addHelp'
		% Add Help Item.
		%---------------
        hdlFig = varargin{2};
		wfighelp('addHelpItem',hdlFig,'Border distortion','BORDER_DIST');
        
	  case 'auto'    , wshowdrv('#autoMode',mfilename,'close');
	  case 'gr_auto' , wshowdrv('#gr_autoMode',mfilename,'close');

	  case 'getFigParam'
		figName  = 'Border distortion';
		showType = 'mix6';
		varargout = {figName,showType};
		
	  case 'localPROC_1'
		[figHandle,modeDWT,axeHDL,strTIT] = deal(varargin{2:end});
		dataSTRUCT = wtbxappdata('get',figHandle,'dataSTRUCT');
		[x,lev,wname,nbcol] = deal(dataSTRUCT{:});
		dwtmode(modeDWT,'silent');
		[c,l] = wavedec(x,lev,wname);
		len = length(x);
		cfd = zeros(lev,len);
		for k = 1:lev
			d = detcoef(c,l,k);
			d = d(:)';
			d = d(ones(1,2^k),:);
			cfd(k,:) = wkeep1(d(:)',len);
		end
		cfd =  cfd(:);
		I = find(abs(cfd)<sqrt(eps));
		cfd(I) = zeros(size(I));
		cfd    = reshape(cfd,lev,len);
		imgCFS = wcodemat(cfd,nbcol);
		tics = 1:lev; labs = int2str([1:lev]');
		axes(axeHDL); image(imgCFS);
		set(axeHDL,'YTicklabelMode','manual','YTick',tics, ...
			'YTicklabel',labs,'YDir','normal','Box','On');
		ylabel('level');
		title(strTIT);
		colormap(pink(nbcol));
		
	  case 'localPROC_2'
		[figHandle,modeDWT,axeHDL,strTIT] = deal(varargin{2:end});
		dataSTRUCT = wtbxappdata('get',figHandle,'dataSTRUCT');
		[X,lev,wname,nbcol] = deal(dataSTRUCT{:});
		dwtmode(modeDWT,'silent');
		[c,s] = wavedec2(X,lev,wname);
	    a = wrcoef2('a',c,s,wname,lev);
		imgCFS = wcodemat(a,nbcol);
		axes(axeHDL); image(imgCFS);
		set(axeHDL,'XTick',[],'YTick',[]);
		title(strTIT);

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
	  'try',
	  '   wtbxappdata(''del'',figHandle,''local_AXES'');',
	  '   wtbxappdata(''del'',figHandle,''dataSTRUCT'');',
	  'end',
	  'ax = findall(figHandle,''type'',''axes''); delete(ax); drawnow; ',		  	
	  '' };

  slide(idx).text = {
	  '',
	  ' Press the "Start" button to see a demonstration on',
	  ' border distortions for Discrete Wavelet Transform (DWT).',
	  '',
	  ' This demo uses Wavelet Toolbox functions.',
	  ''};
  
  %========== Slide 2 ==========
  idx = idx+1;
  slide(idx).code = {
	  ['idxPREV = wshowdrv(''#get_idxSlide'',figHandle); idxSlide = ' int2str(idx) ';'],
	  'if idxPREV<idxSlide',
	  '   wshowdrv(''#set_axes'',figHandle,[4,1]);'
	  '   h = wshowdrv(''#get_axes'',figHandle);',
	  '   load nearbrk; signal = nearbrk; clear nearbrk',
	  '   lev = 5; wname = ''db2''; nbcol = 128;',
	  '   dataSTRUCT = {signal,lev,wname,nbcol};',
	  '   colormap(pink(nbcol));',
	  '   axes(h(1)); plot(signal,''r'');',
	  '   title(''Original Signal : two near first derivative discontinuities'');',
	  '   wtbxappdata(''set'',figHandle,''local_AXES'',h);'
	  '   wtbxappdata(''set'',figHandle,''dataSTRUCT'',dataSTRUCT);'
	  'else ',
	  '   h = wtbxappdata(''get'',figHandle,''local_AXES'');'
	  'end',
	  'set(findobj(h(2:4)),''Visible'',''Off'');',
	  'set(findobj(h(1)),''Visible'',''On'');',
	  '' };

  slide(idx).text = {
	' % Load signal.',
	'        load nearbrk;',
	'        x = nearbrk;',
	''};

  %========== Slide 3 ==========
  idx = idx+1;
  slide(idx).code = {
	['idxPREV = wshowdrv(''#get_idxSlide'',figHandle); idxSlide = ' int2str(idx) ';'],
	'if idxPREV>idxSlide',
	'   set(findobj(h(2:4)),''Visible'',''Off'');',
	'   set(findobj(h(1)),''Visible'',''On'');',
	'end',
	'' };

  slide(idx).text = {
	' % Set DWT signal extension mode to zero padding.',
	' ',
	'        dwtmode(''zpd'')',
	''};

  slide(idx).info = 'dwtmode';

  %========== Slide 4 ==========
  idx = idx+1;
  slide(idx).code = {
	['idxPREV = wshowdrv(''#get_idxSlide'',figHandle); idxSlide = ' int2str(idx) ';'],
	'if idxPREV<idxSlide',
	'   modeDWT = ''zpd'';',
	'   strTIT = ''Coefficients using zero padding'';',
	[   mfilename ,'(''localPROC_1'',figHandle,modeDWT,h(2),strTIT);'],
	'end',
	'set(findobj(h(3:4)),''Visible'',''Off'');',
	'set(findobj(h(1:2)),''Visible'',''On'');',	
	'' };

  slide(idx).text = {
	' % Perform decomposition at level 5',
	' % for the signal using db2 and',
	' % expand discrete wavelet coefficients for plot.',
	'        lev = 5;',
	'        [c,l] = wavedec(x,lev,''db2'');',
	''};
 
  slide(idx).info = 'wavedec';

  %========== Slide 5 ==========
  idx = idx+1;
  slide(idx).code = {
	['idxPREV = wshowdrv(''#get_idxSlide'',figHandle); idxSlide = ' int2str(idx) ';'],
	'if idxPREV<idxSlide',
	'   modeDWT = ''sym'';',
	'   strTIT = ''Coefficients using symmetrization padding'';',
	[   mfilename ,'(''localPROC_1'',figHandle,modeDWT,h(3),strTIT);'],
	'end',
	'set(findobj(h(4)),''Visible'',''Off'');',
	'set(findobj(h(1:3)),''Visible'',''On'');',	
	'' };

  slide(idx).text = {
	' % Set DWT signal extension mode to symmetrization.',
	'        dwtmode(''sym'')',
	' % Perform the same two previous steps.',
	'        [c,l] = wavedec(x,lev,''db2'');',
	''};
 
  slide(idx).info = 'wavedec';

  %========== Slide 6 ==========
  idx = idx+1;
  slide(idx).code = {
	['idxPREV = wshowdrv(''#get_idxSlide'',figHandle); idxSlide = ' int2str(idx) ';'],
	'if idxPREV<idxSlide',
	'   modeDWT = ''spd'';',
	'   strTIT = ''Coefficients using smooth padding'';',
	[   mfilename ,'(''localPROC_1'',figHandle,modeDWT,h(4),strTIT);'],
	'else'
	'	dataSTRUCT = wtbxappdata(''get'',figHandle,''dataSTRUCT'');',
	'   nbcol = dataSTRUCT{4};',
	'   colormap(pink(nbcol));'
	'end',
	'set(findobj(h(1:4)),''Visible'',''On'');',	
	'' };

  slide(idx).text = {
	' % Set DWT signal extension mode to smooth padding.',
	'        dwtmode(''spd'')',
	' % Perform the same two previous steps.',
	'        [c,l] = wavedec(x,lev,''db2'');',
	''};
 
  slide(idx).info = 'wavedec';

  %========== Slide 7 ==========
  idx = idx+1;
  slide(idx).code = {
	['idxPREV = wshowdrv(''#get_idxSlide'',figHandle); idxSlide = ' int2str(idx) ';'],
	'colormap(cool(2))',	  
	'' };

  slide(idx).text = {
	' % Change colormap.',
	' ',
	'        [colormap(cool(2))',
	''};
 
  slide(idx).info = 'dwtmode';

  %========== Slide 8 ==========
  idx = idx+1;
  slide(idx).code = {
	  ['idxPREV = wshowdrv(''#get_idxSlide'',figHandle); idxSlide = ' int2str(idx) ';'],
	  'if idxPREV<idxSlide',
	  '   wshowdrv(''#set_axes'',figHandle,[2,2]);',
	  '   h = wshowdrv(''#get_axes'',figHandle);',
	  '   load geometry; [row,col] = size(X);',
	  '   lev = 3; wname = ''sym4''; nbcol = size(map,1);',
	  '   dataSTRUCT = {X,lev,wname,nbcol};',
	  '   colormap(pink(nbcol));',
	  '   axes(h(1)); image(wcodemat(X,nbcol));',
	  '   title(''Original image'');',
	  '   wtbxappdata(''set'',figHandle,''local_AXES'',h);'
	  '   wtbxappdata(''set'',figHandle,''dataSTRUCT'',dataSTRUCT);'
	  'else',
	  '   h = wtbxappdata(''get'',figHandle,''local_AXES'');'
	  'end',
	  'set(findobj(h(2:4)),''Visible'',''Off'');',
	  'set(findobj(h(1)),''Visible'',''On'');',	
	'' };

  slide(idx).text = {
	' % Load artificial image.',
	'        load geometry;' ,
	' % Set DWT signal extension mode to zero padding.',
	'        dwtmode(''zpd'')', 
	''};
 
  slide(idx).info = 'dwtmode';

  slide(idx).idxPrev = 1; 

  %========== Slide 9 ==========
  idx = idx+1;
  slide(idx).code = {
	['idxPREV = wshowdrv(''#get_idxSlide'',figHandle); idxSlide = ' int2str(idx) ';'],
	'if idxPREV<idxSlide',
	'   modeDWT = ''zpd'';',
	'   strTIT = ''app. 3 using zero padding'';',
	[   mfilename ,'(''localPROC_2'',figHandle,modeDWT,h(2),strTIT);'],
	'end',
	'set(findobj(h(3:4)),''Visible'',''Off'');',
	'set(findobj(h(1:2)),''Visible'',''On'');',
	'' };

  slide(idx).text = {
	' % Perform decomposition at level 3',
	' % of X using sym4, and reconstruct',
	' % approximation of level 3.',
	'        lev = 3; [c,s] = wavedec2(X,lev,''sym4'');',
	'        a = wrcoef2(''a'',c,s,''sym4'',lev);',
	''};
 
  slide(idx).info = 'wavedec2';

  %========== Slide 10 ==========
  idx = idx+1;
  slide(idx).code = {
	['idxPREV = wshowdrv(''#get_idxSlide'',figHandle); idxSlide = ' int2str(idx) ';'],
	'if idxPREV<idxSlide',
	'   modeDWT = ''sym'';',
	'   strTIT = ''app. 3 using symmetrization padding'';',
	[   mfilename ,'(''localPROC_2'',figHandle,modeDWT,h(3),strTIT);'],
	'end',
	'set(findobj(h(4)),''Visible'',''Off'');',
	'set(findobj(h(1:3)),''Visible'',''On'');',
	'' };

  slide(idx).text = {
	' % Set DWT signal extension mode to symmetrization.',
	'        dwtmode(''sym'')',
	' % Perform the same two previous steps.',
	'        [c,s] = wavedec2(X,lev,''sym4'');',
	'        a = wrcoef2(''a'',c,s,''sym4'',lev);',
	''};
 
  slide(idx).info = 'wrcoef2';

  %========== Slide 11 ==========
  idx = idx+1;
  slide(idx).code = {
	['idxPREV = wshowdrv(''#get_idxSlide'',figHandle); idxSlide = ' int2str(idx) ';'],
	'if idxPREV<idxSlide',
	'   modeDWT = ''spd'';',
	'   strTIT = ''app. 3 using smooth padding'';',
	[   mfilename ,'(''localPROC_2'',figHandle,modeDWT,h(4),strTIT);'],
	'end',
	'set(findobj(h(1:4)),''Visible'',''On'');',
	'' };

  slide(idx).text = {
	' % Set DWT signal extension mode to smooth.',
	'        dwtmode(''spd'')',
	' % Perform the same two previous steps.',
	'        [c,s] = wavedec2(X,lev,''sym4'');',
	'        a = wrcoef2(''a'',c,s,''sym4'',lev);',
	''};
 
  slide(idx).info = 'wrcoef2';

  varargout{1} = slide;
end
