function varargout = dcmddw2d(varargin)
%DCMDDW2D Demonstrates discrete 2-D wavelet tools in the Wavelet Toolbox. 
%
% This is a slideshow file for use with wshowdrv.m
% To see it run, type 'wshowdrv dcmddw2d', 
%
% See also APPCOEF2, DETCOEF2, DWT2, IDWT2, UPCOEF2, 
%          WAVEDEC2, WAVEREC2, WRCOEF2, WCODEMAT.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 18-Apr-2001.
%   Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.15 $

% Initialization and Local functions if necessary.
if nargin>0
	action = varargin{1};
	switch action
	  case 'auto'    , wshowdrv('#autoMode',mfilename,'close');
	  case 'gr_auto' , wshowdrv('#gr_autoMode',mfilename,'close');

	  case 'getFigParam'
		figName  = 'Orthogonal Wavelets 2-D';
		showType = 'mix9';
		varargout = {figName,showType};
		
	  case 'initShowViewer'
		figHandle = varargin{2};
		slideData = get(figHandle,'Userdata');
		autoHndl = slideData.autoHndl;
		propAuto = get(autoHndl,{'Units','Position','BackGroundColor'});
		txtBkColor = get(slideData.slitxtHndl,'BackGroundColor');
		pos  = propAuto{2};
		hBtn = pos(4);
		pos(2) = pos(2)-2*hBtn;
        popstr = strvcat(...
                        'woman2','sinsin','detfingr', ...
                        'wbarb','detail','geometry', ...
                        'tire','mandrill','woman',...
                        'wifs','facets','tartan');
        txtstr = 'Image';
		propUIC = {'Units',propAuto{1},'Position',pos,'BackGroundColor',txtBkColor};
		slideData.txtLocHandle = uicontrol('Parent',figHandle,...
			'style','text','String',txtstr,propUIC{:});
		pos(2) = pos(2)-hBtn+hBtn/3;
		propUIC = {'Units',propAuto{1},'Position',pos,'BackGroundColor',propAuto{3}};
		propAuto{2} = pos;
		propUIC{4} = propAuto{2};		
		slideData.popLocHandle = uicontrol('Parent',figHandle,...
			'style','popupmenu','String',popstr,propUIC{:});
		set(figHandle,'Userdata',slideData);
		set(figHandle,'DefaultAxesXtick',[],'DefaultAxesYtick',[]);
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
	'ax  = findall(figHandle,''type'',''axes''); delete(ax); drawnow;  h = [];',
	'popTMP = findobj(figHandle,''style'',''popupmenu'');',
	'set(popTMP,''enable'',''on'');',
	'' };

  slide(idx).text = {
	'',
	' Press the "Start" button to see a demonstration of',
	' 2-D wavelet tools in the Wavelet Toolbox.',
	'',
	' This demo uses Wavelet Toolbox functions.',
	''};

  %========== Slide 2 ==========
  idx = idx+1;
  slide(idx).code = {
	'pop = findobj(figHandle,''style'',''popupmenu'');',
	'lstIMG = get(pop,''String''); idxIMG = get(pop,''Value'');',
	'set(pop,''enable'',''off'');',
	'imgName = deblankl(lstIMG(idxIMG,:));',
	'feval(''load'',imgName)',
	'newTXT = [''         load '',imgName];';
	'wshowdrv(''#modify_Comment'',figHandle,2,newTXT);',
	'[r,c] = size(X);'
	'ax = findall(figHandle,''type'',''axes''); delete(ax); drawnow;  h = [];',
	
	'if strcmp(imgName,''detail'')',
	'	c = r; X = X(1:2:r,1:2:c);',
	'elseif strcmp(imgName,''mandrill'')',
	'	X = X(1:4:r,1:5:c);',
	'elseif strcmp(imgName,''tire'')',
	'	X = X(1:204,:);',
	'elseif strcmp(imgName,''detfingr'')',
	'	r = 296; c = 296; X = X(1:2:r,1:2:c);',
	'elseif strcmp(imgName,''durer'')',
	'	r = 640; X = X(1:4:r,1:4:c);',
	'elseif strcmp(imgName,''wifs'')',
	' ',
	'end',
	'[r,c] = size(X);',
	'if rem(r,4)>0 | rem(c,4)>0',
	'	X = X(1:r-rem(r,4),1:c-rem(c,4));',
	'end',
	'sX = size(X);',
	'row = sX(1); col = sX(2);',
	'nbcol = size(map,1);',
	'cod_X = wcodemat(X,nbcol);',     
	'row_1 = 1; col_1 = 2;',
	'colormap(pink(nbcol));',
	'h(1) = subplot(row_1,col_1,1);',
	'image(cod_X); axis(''square'');',
	'title(''Original image X.'');',
	'' };

  slide(idx).text = {
	' % Load original image.',
	'         load  imgName',
	'         % X is the loaded image.',
	'         % and map the loaded colormap.',
	' ',
	' % Image coding.',
	'         nbcol = size(map,1);',
	'         cod_X = wcodemat(X,nbcol);',
	''};

  slide(idx).info = 'wcodemat';

  %========== Slide 3 ==========
  idx = idx+1;
  slide(idx).code = {
	  '[ca1,ch1,cv1,cd1] = dwt2(X,''db1'');',
	  'cod_ca1 = wcodemat(ca1,nbcol);',
	  'cod_ch1 = wcodemat(ch1,nbcol);',
	  'cod_cv1 = wcodemat(cv1,nbcol);',
	  'cod_cd1 = wcodemat(cd1,nbcol);',
	  'ax = subplot(row_1,col_1,2);',
	  'lineCOL = ''r'';',
	  'image([cod_ca1,cod_ch1;cod_cv1,cod_cd1]); axis(''square'');',
	  'line(''Xdata'',[1 col],''Ydata'',[row/2 row/2],''Color'',lineCOL);',
	  'line(''Xdata'',[col/2 col/2],''Ydata'',[1 row],''Color'',lineCOL);',
	  'title(''Decomposition at level 1'');',
	  '' };

  slide(idx).text = {
	  ' % Perform one step decomposition.',
	  '        [ca1,ch1,cv1,cd1] = dwt2(X,''db1'');',
	  ' '
	  ' % Image coding.'
	  '        cod_ca1 = wcodemat(ca1,nbcol);',
	  '        cod_ch1 = wcodemat(ch1,nbcol);',
	  '        cod_cv1 = wcodemat(cv1,nbcol);',
	  '        cod_cd1 = wcodemat(cd1,nbcol);',
	  '        image([cod_ca1,cod_ch1;cod_cv1,cod_cd1]);',
	  ''};

  slide(idx).info = 'dwt2';

  %========== Slide 4 ==========
  idx = idx+1;
  slide(idx).code = {
	  'nul = zeros(size(cod_ca1));',
	  'subplot(row_1,col_1,2);',
	  'image([cod_ca1,nul;nul,nul]); axis(''square'');',
	  'line(''Xdata'',[1 col],''Ydata'',[row/2 row/2],''Color'',lineCOL);',
	  'line(''Xdata'',[col/2 col/2],''Ydata'',[1 row],''Color'',lineCOL);',
	  'title(''Coef. of Approximation at level 1'');',
	  ''};

  slide(idx).text = slide(idx-1).text;

  slide(idx).info = 'dwt2';

  %========== Slide 5 ==========
  idx = idx+1;
  slide(idx).code = {
	  'subplot(row_1,col_1,2);',
	  'image([nul,cod_ch1;nul,nul]); axis(''square'');',
	  'line(''Xdata'',[1 col],''Ydata'',[row/2 row/2],''Color'',lineCOL);',
	  'line(''Xdata'',[col/2 col/2],''Ydata'',[1 row],''Color'',lineCOL);',
	  'title(''Coef. of Horizontal Detail at level 1'');',
	  '' };

  slide(idx).text = slide(idx-1).text;

  slide(idx).info = 'dwt2';

  %========== Slide 6 ==========
  idx = idx+1;
  slide(idx).code = {
	  'subplot(row_1,col_1,2);',
	  'image([nul,nul;cod_cv1,nul]); axis(''square'');',
	  'line(''Xdata'',[1 col],''Ydata'',[row/2 row/2],''Color'',lineCOL);',
	  'line(''Xdata'',[col/2 col/2],''Ydata'',[1 row],''Color'',lineCOL);',
	  'title(''Coef. of Vertical Detail at level 1'');',
	  '' };

  slide(idx).text = slide(idx-1).text;

  %========== Slide 7 ==========
  idx = idx+1;
  slide(idx).code = {
	  'subplot(row_1,col_1,2);',
	  'image([nul,nul;nul,cod_cd1]); axis(''square'');',
	  'line(''Xdata'',[1 col],''Ydata'',[row/2 row/2],''Color'',lineCOL);',
	  'line(''Xdata'',[col/2 col/2],''Ydata'',[1 row],''Color'',lineCOL);',
	  'title(''Coef. of Diagonal Detail at level 1'');',
	  '' };

  slide(idx).text = slide(idx-1).text;

  slide(idx).info = 'dwt2';

  %========== Slide 8 ==========
  idx = idx+1;
  slide(idx).code = {
	  'subplot(row_1,col_1,2);',
	  'image([cod_ca1,cod_ch1;cod_cv1,cod_cd1]);axis(''square'');',
	  'line(''Xdata'',[1 col],''Ydata'',[row/2 row/2],''Color'',lineCOL);',
	  'line(''Xdata'',[col/2 col/2],''Ydata'',[1 row],''Color'',lineCOL);',
	  'title(''Decomposition at level 1'');',
	  'clear nul',
	  '' };

  slide(idx).text = slide(idx-1).text;

  slide(idx).info = 'dwt2';

  %========== Slide 9 ==========
  idx = idx+1;
  slide(idx).code = {
	 ['idxPREV = wshowdrv(''#get_idxSlide'',figHandle); idxSlide = ' int2str(idx) ';'],
	  'if idxPREV>idxSlide',
	  '   subplot(row_1,col_1,1);',
	  '   image(cod_X); axis(''square'');',
	  '   title(''Original image X.'');',
	  'end',
	  '[ca2,ch2,cv2,cd2] = dwt2(ca1,''db1'');',
	  'cod_ca2 = wcodemat(ca2,nbcol);        clear ca2',
	  'cod_ch2 = wcodemat(ch2,nbcol);        clear ch2',
	  'cod_cv2 = wcodemat(cv2,nbcol);        clear cv2',
	  'cod_cd2 = wcodemat(cd2,nbcol);        clear cd2',
	  'cod_ca1 = [cod_ca2,cod_ch2;cod_cv2,cod_cd2];',
	  'clear cod_ca2 cod_ch2 cod_cv2 cod_cd2',
	  'subplot(row_1,col_1,2)',
	  'image([cod_ca1,cod_ch1;cod_cv1,cod_cd1]); axis(''square'');',
	  'line(''Xdata'',[1 col/2],''Ydata'',[row/4 row/4],''Color'',lineCOL);',
	  'line(''Xdata'',[col/4 col/4],''Ydata'',[1 row/2],''Color'',lineCOL);',
	  'line(''Xdata'',[1 col],''Ydata'',[row/2 row/2],''Color'',lineCOL);',
	  'line(''Xdata'',[col/2 col/2],''Ydata'',[1 row],''Color'',lineCOL);',
	  'title(''Decomposition at level 2'');',
	  '' };

  slide(idx).text = {
	  ' % Perform second step decomposition :'
	  ' % decompose approx. cfs of level 1.'
	  '        [ca2,ch2,cv2,cd2] = dwt2(ca1,''db1'');'
	  ' ' 
	  ' % Code ca2, ch2,cv2 and cd2.'
	  '        cod_ca2 = wcodemat(ca2,nbcol);'
	  '        cod_ch2 = wcodemat(ch2,nbcol);'
	  '        cod_cv2 = wcodemat(cv2,nbcol);'
	  '        cod_cd2 = wcodemat(cd2,nbcol);',
	  '' };

  slide(idx).info = 'dwt2';

  %========== Slide 10 ==========
  idx = idx+1;
  slide(idx).code = {
	  'ax = findall(figHandle,''type'',''axes''); delete(ax); drawnow;  h = [];',	  
	  'image([cod_ca1,cod_ch1;cod_cv1,cod_cd1]); axis(''square'');',
	  'line(''Xdata'',[1 col/2],''Ydata'',[row/4 row/4],''Color'',lineCOL);',
	  'line(''Xdata'',[col/4 col/4],''Ydata'',[1 row/2],''Color'',lineCOL);',
	  'line(''Xdata'',[1 col],''Ydata'',[row/2 row/2],''Color'',lineCOL);',
	  'line(''Xdata'',[col/2 col/2],''Ydata'',[1 row],''Color'',lineCOL);',
	  'title(''Decomposition at level 2'');',
	  '' };

  slide(idx).text = {
	  ' % Zoom the decomposition at level 2.', 
	  '' };

  slide(idx).info = 'dwt2';

  %========== Slide 11 ==========
  idx = idx+1;
  slide(idx).code = {
	  'ax = findall(figHandle,''type'',''axes''); delete(ax); drawnow;  h = [];',	  
	  'row_2 = 1; col_2 = 3;',
	  'h(1) = subplot(row_2,col_2,1); image(cod_X);',
	  'axis(''square'');',
	  'title(''Original image X.'');',
	  'drawnow;',
	  'cod_ca1  = wcodemat(ca1,nbcol);',
	  'h(3) = subplot(row_2,col_2,3);',
	  'image([cod_ca1,cod_ch1;cod_cv1,cod_cd1]);',
	  'axis(''square'');',
	  'clear cod_ca1 cod_ch1 cod_cv1 cod_cd1',
	  'line(''Xdata'',[1 col],''Ydata'',[row/2 row/2],''Color'',lineCOL);',
	  'line(''Xdata'',[col/2 col/2],''Ydata'',[1 row],''Color'',lineCOL);',
	  'title(''Decomp. at level 1'');',
	  'a0 = idwt2(ca1,ch1,cv1,cd1,''db1'',sX);',
	  'h(2) = subplot(row_2,col_2,2); image(wcodemat(a0,nbcol));',
	  'axis(''square'');',
	  'title(''Recons. image : a0.'');',
	  '' };

  slide(idx).text = {
	  ' % Invert directly decomposition of X' ,
	  ' % using coefficients at level 1.', 
	  ' ',
	  '         a0 = idwt2(ca1,ch1,cv1,cd1,''db1'',size(X));', 
	  ' ',
	  '' };

  slide(idx).info = 'idwt2';

  %========== Slide 12 ==========
  idx = idx+1;
  slide(idx).code = {
	  'ax = findall(figHandle,''type'',''axes''); delete(ax); drawnow;  h = []; drawnow;',
	  'h(1) = subplot(row_2,col_2,1); image(cod_X);',
	  'axis(''square'');',
	  'title(''Original image X.'');',
	  '[c,s] = wavedec2(X,2,''db1'');',	  
	  '' };

  slide(idx).text = {
	  ' % Perform decomposition at level 2',
	  ' % of X using db1.',
	  ' ',
	  '         [c,s] = wavedec2(X,2,''db1'');',
	  '' };

  slide(idx).info = 'wavedec2';

  %========== Slide 13 ==========
  idx = idx+1;
  slide(idx).code = {
	 ['idxPREV = wshowdrv(''#get_idxSlide'',figHandle); idxSlide = ' int2str(idx) ';'],
	  'if idxPREV>idxSlide',
	  '   delete(subplot(row_2,col_2,3));',
	  'end',
	  'ca2 = appcoef2(c,s,''db1'',2);',
	  'ch2 = detcoef2(''h'',c,s,2);',
	  'cv2 = detcoef2(''v'',c,s,2);',
	  'cd2 = detcoef2(''d'',c,s,2);',
	  'cod_ca2 = wcodemat(ca2,nbcol); clear ca2',
	  'cod_ch2 = wcodemat(ch2,nbcol); clear ch2',
	  'cod_cv2 = wcodemat(cv2,nbcol); clear cv2',
	  'cod_cd2 = wcodemat(cd2,nbcol); clear cd2',
	  'cod_ca1 = [cod_ca2,cod_ch2;cod_cv2,cod_cd2];',
	  'clear cod_ca2 cod_ch2 cod_cv2 cod_cd2',
	  'nul = zeros(size(cod_ca1));',
	  'h(2) = subplot(row_2,col_2,2); image([cod_ca1,nul;nul,nul]);',
	  'axis(''square'');',
	  'clear nul',
	  'line(''Xdata'',[1 col/2],''Ydata'',[row/4 row/4],''Color'',lineCOL);',
	  'line(''Xdata'',[col/4 col/4],''Ydata'',[1 row/2],''Color'',lineCOL);',
	  'line(''Xdata'',[1 col],''Ydata'',[row/2 row/2],''Color'',lineCOL);',
	  'line(''Xdata'',[col/2 col/2],''Ydata'',[1 row],''Color'',lineCOL);',
	  'title(''Coef. at level 2.'');',
	  '' };

  slide(idx).text = {
	  ' % Extract coefficients at level 2 from',
	  ' % the wavelet decomposition structure [c,s].',
	  ' ',
	  '         ca2 = appcoef2(c,s,''db1'',2);',
	  '         ch2 = detcoef2(''h'',c,s,2);',
	  '         cv2 = detcoef2(''v'',c,s,2);',
	  '         cd2 = detcoef2(''d'',c,s,2);',
	  '' };

  slide(idx).info = 'appcoef2';

  %========== Slide 14 ==========
  idx = idx+1;
  slide(idx).code = {
	 ['idxPREV = wshowdrv(''#get_idxSlide'',figHandle); idxSlide = ' int2str(idx) ';'],
	  'if idxPREV>idxSlide',
	  '   subplot(row_2,col_2,1);',
	  '   image(cod_X); axis(''square'');',
	  '   title(''Original image X.'');',
	  'end',
	  'ca1 = appcoef2(c,s,''db1'',1);',
	  'ch1 = detcoef2(''h'',c,s,1);',
	  'cv1 = detcoef2(''v'',c,s,1);',
	  'cd1 = detcoef2(''d'',c,s,1);',
	  'cod_ca1 = wcodemat(ca1,nbcol);       clear ca1',
	  'cod_ch1 = wcodemat(ch1,nbcol);       clear ch1',
	  'cod_cv1 = wcodemat(cv1,nbcol);       clear cv1',
	  'cod_cd1 = wcodemat(cd1,nbcol);       clear cd1',
	  'h(3) = subplot(row_2,col_2,3); image([cod_ca1,cod_ch1;cod_cv1,cod_cd1]);',
	  'axis(''square'');',
	  'clear cod_ca1 cod_ch1 cod_cv1 cod_cd1',
	  'line(''Xdata'',[1 col],''Ydata'',[row/2 row/2],''Color'',lineCOL);',
	  'line(''Xdata'',[col/2 col/2],''Ydata'',[1 row],''Color'',lineCOL);',
	  'title(''Coef. at level 1.'');',
	  '' };

  slide(idx).text = {
	  ' % Extract coefficients at level 1,',
	  ' % from wavelet decomposition structure [c,s].',
	  ' '
	  '        ca1 = appcoef2(c,s,''db1'',1);',
	  '        ch1 = detcoef2(''h'',c,s,1);',
	  '        cv1 = detcoef2(''v'',c,s,1);',
	  '        cd1 = detcoef2(''d'',c,s,1);',
	  '' };

  slide(idx).info = 'detcoef2';

  %========== Slide 15 ==========
  idx = idx+1;
  slide(idx).code = {
	  'ax = findall(figHandle,''type'',''axes''); delete(ax); drawnow;  h = [];',
	  'row_3 = 3; col_3 = 4;';
	  'ax = subplot(row_3,col_3,1); image(cod_X); axis(''square'');',
	  'title(''X'');',
	  '' };

  slide(idx).text = {
	  ' % Plot the original image.',
	  '' };

  slide(idx).info = 'detcoef2';

  slide(idx).idxPrev = 12;

  %========== Slide 16 ==========
  idx = idx+1;
  slide(idx).code = {
	 ['idxPREV = wshowdrv(''#get_idxSlide'',figHandle); idxSlide = ' int2str(idx) ';'],
	  'if idxPREV>idxSlide',
	  '   for j = 1:3 , tmp(j) = subplot(row_3,col_3,j+9); end;',
	  '   delete(tmp); clear tmp',
	  'end',
	  'a2 = wrcoef2(''a'',c,s,''db1'',2);',
	  'ax = subplot(row_3,col_3,9); image(wcodemat(a2,nbcol)); axis(''square'');',
	  'title(''a2'')',
	  'clear a2',
	  '' };

  slide(idx).text = {
	  ' % Reconstruct approximation at level 2 from',
	  ' % the wavelet decomposition structure [c,s].',
	  ' ',
	  '        a2 = wrcoef2(''a'',c,s,''db1'',2);',
	  '' };

  slide(idx).info = 'wrcoef2';

  %========== Slide 17 ==========
  idx = idx+1;
  slide(idx).code = {
	 ['idxPREV = wshowdrv(''#get_idxSlide'',figHandle); idxSlide = ' int2str(idx) ';'],
	  'if idxPREV<idxSlide',
	  '    h2 = wrcoef2(''h'',c,s,''db1'',2);',
	  '    v2 = wrcoef2(''v'',c,s,''db1'',2);',
	  '    d2 = wrcoef2(''d'',c,s,''db1'',2);',
	  '    ax = subplot(row_3,col_3,10); image(wcodemat(h2,nbcol)); axis(''square'');',
	  '    title(''h2'');',
	  '    clear h2',
	  '    ax = subplot(row_3,col_3,11); image(wcodemat(v2,nbcol)); axis(''square'');',
	  '    title(''v2'');',
	  '    clear v2',
	  '    ax = subplot(row_3,col_3,12); image(wcodemat(d2,nbcol)); axis(''square'');',
	  '    title(''d2'');',
	  '    clear d2',
	  'end',
	  '' };

  slide(idx).text = {
	  ' % Reconstruct detail at level 2 from',
	  ' % the wavelet decomposition structure [c,s].',
	  '         h2 = wrcoef2(''h'',c,s,''db1'',2);',
	  '         v2 = wrcoef2(''v'',c,s,''db1'',2);',
	  '         d2 = wrcoef2(''d'',c,s,''db1'',2);',
	  '' };

  slide(idx).info = 'wrcoef2';

  %========== Slide 18 ==========
  idx = idx+1;
  slide(idx).code = {
	  'sc = size(c);',
	  'val_s = s;',
	  '[c,s] = upwlev2(c,s,''db1'');',
	  'sc = size(c);',
	  'val_s = s;',
	  '' };

  slide(idx).text = {
	  ' % One step reconstruction of wavelet',
	  ' % decomposition structure [c,s].',
	  '        [c,s] = upwlev2(c,s,''db1'');',
	  '' };

  slide(idx).info = 'upwlev2';

  %========== Slide 19 ==========
  idx = idx+1;
  slide(idx).code = {
	 ['idxPREV = wshowdrv(''#get_idxSlide'',figHandle); idxSlide = ' int2str(idx) ';'],
	  'if idxPREV>idxSlide',
	  '   for j = 1:4 , tmp(j) = subplot(row_3,col_3,j+4); end; ',
	  '   delete(tmp); clear tmp',
	  'end',	  
	  '' };

  slide(idx).text = {
	  ' % Reconstruct approximation and details',
	  ' % at level 1, from coefficients.',
	  ' %'
	  ' % step 1 : extract coefficients',
	  ' % decomposition structure [c,s].',
	  ' %',
	  ' % step 2 : reconstruct.',
	  '' };

  slide(idx).info = '';

  %========== Slide 20 ==========
  idx = idx+1;
  slide(idx).code = {
	 ['idxPREV = wshowdrv(''#get_idxSlide'',figHandle); idxSlide = ' int2str(idx) ';'],
	  'if idxPREV>idxSlide',
	  '   delete(subplot(row_3,col_3,3));',
	  'else',
	  '   siz = s(size(s,1),:);',
	  '   ca1 = appcoef2(c,s,''db1'',1);',
	  '   a1  = upcoef2(''a'',ca1,''db1'',1,siz);',
	  '   clear ca1',
	  '   ch1 = detcoef2(''h'',c,s,1);',
	  '   hd1 = upcoef2(''h'',ch1,''db1'',1,siz);',
	  '   clear ch1',
	  '   cv1 = detcoef2(''v'',c,s,1);',
	  '   vd1 = upcoef2(''v'',cv1,''db1'',1,siz);',
	  '   clear cv1',
	  '   cd1 = detcoef2(''d'',c,s,1);',
	  '   dd1 = upcoef2(''d'',cd1,''db1'',1,siz);',
	  '   clear cd1',
	  '   ax = subplot(row_3,col_3,5); image(wcodemat(a1,nbcol)); axis(''square'');',
	  '   title(''a1'');',
	  '   clear a1',
	  '   ax = subplot(row_3,col_3,6); image(wcodemat(hd1,nbcol)); axis(''square'');',
	  '   title(''h1'');',
	  '   clear hd1',
	  '   ax = subplot(row_3,col_3,7); image(wcodemat(vd1,nbcol)); axis(''square'');',
	  '   title(''v1'');',
	  '   clear vd1',
	  '   ax = subplot(row_3,col_3,8); image(wcodemat(dd1,nbcol)); axis(''square'');',
	  '   title(''d1'');',
	  '   clear dd1',
	  'end'
	  '' };

  slide(idx).text = {
	  '    siz = s(size(s,1),:);',
	  '    ca1 = appcoef2(c,s,''db1'',1);',
	  '    ch1 = detcoef2(''h'',c,s,1);',
	  '    cv1 = detcoef2(''v'',c,s,1);',
	  '    cd1 = detcoef2(''d'',c,s,1);',
	  '    a1  = upcoef2(''a'',ca1,''db1'',1,siz);',
	  '    hd1 = upcoef2(''h'',ch1,''db1'',1,siz);',
	  '    vd1 = upcoef2(''v'',cv1,''db1'',1,siz);',
	  '    dd1 = upcoef2(''d'',cd1,''db1'',1,siz);',
	  '' };

  slide(idx).info = 'upcoef2';

  %========== Slide 21 ==========
  idx = idx+1;
  slide(idx).code = {
	  'a0 = waverec2(c,s,''db1'');',
	  'subplot(row_3,col_3,3); image(wcodemat(a0,nbcol)); axis(''square'');',
	  'title(''Reconstructed image a0.'');',
	  '' };

  slide(idx).text = {
	  ' % Reconstruct X from the wavelet',
	  ' % decomposition structure [c,s].',
	  ' ',
	  '         a0 = waverec2(c,s,''db1'');',
	  '' };

  slide(idx).info = 'waverec2';

  varargout{1} = slide;
end
