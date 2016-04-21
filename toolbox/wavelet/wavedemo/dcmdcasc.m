function varargout = dcmdcasc(varargin)
%DCMDCASC Demonstrates cascade algorithm in the Wavelet Toolbox.
%
% This is a slideshow file for use with wshowdrv.m
% To see it run, type 'wshowdrv dcmdcasc', 
%   
%   See also WAVEFUN.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 13-Feb-2002.
%   Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.14 $

% Initialization and Local functions if necessary.
if nargin>0
	action = varargin{1};
	switch action
	  case 'auto'    , wshowdrv('#autoMode',mfilename,'close');
	  case 'gr_auto' , wshowdrv('#gr_autoMode',mfilename,'close');

	  case 'getFigParam'
		figName  = 'Cascade algorithm';
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
			'sym4','sym8','db3','db5',...
			'db8','coif1','coif5');
		txtstr = 'Wavelet';
		propUIC = {'Units',propAuto{1},'Position',pos,'BackGroundColor',txtBkColor};
		slideData.txtLocHandle = uicontrol('Parent',figHandle,...
			'style','text','String',txtstr,propUIC{:});
		pos(2) = pos(2)-hBtn+hBtn/3;
		propUIC = {'Units',propAuto{1},'Position',pos,'BackGroundColor',propAuto{3}};
		propAuto{2} = pos;
		propUIC{4} = propAuto{2};		
		slideData.popLocHandle = uicontrol('Parent',figHandle,...
			'style','popupmenu','String',popstr,propUIC{:},'Tag','popWave');
		set(figHandle,'Userdata',slideData);
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
	'figHandle = gcf;' 
	'ax  = findall(figHandle,''type'',''axes''); delete(ax); drawnow; h = [];',
	'popTMP = findobj(figHandle,''style'',''popupmenu'');',
	'set(popTMP,''enable'',''on'');',
	'' };

  slide(idx).text = {
	'',
	sprintf(' Press the "Start" button to see a demonstration of'),
	sprintf(' the cascade algorithm in the Wavelet Toolbox.'),
	'',
	sprintf(' This demo uses Wavelet Toolbox functions.'),
	''};

  %========== Slide 2 ==========
  idx = idx+1;
  slide(idx).code = {
	'pop = findobj(figHandle,''style'',''popupmenu'');',
	'lstWAV = get(pop,''String''); idxWAV = get(pop,''Value'');',
	'set(pop,''enable'',''off'');',
	'wname = deblankl(lstWAV(idxWAV,:));',
	'comma = char(39);',
	'newTXT = [''        wname = '',comma,wname,comma,'';''];';
	'wshowdrv(''#modify_Comment'',figHandle,3,newTXT);',
	'ax = findall(figHandle,''type'',''axes''); delete(ax); h = [];',		  	
	'strINIT = [''Approximation of the wavelet '' wname];';
	'beg_title = [strINIT ''. Iteration : ''];',
	'iter = 10;',
	'for i = 1:iter',
	'    [phi,psi,xval] = wavefun(wname,i);',
	'    plot(xval,psi);',
	'    hold on',
	'	 title([beg_title int2str(i)]);',
	'    if      i==1 ,           pause(2)',
	'    elseif  (1<i) & (i<=4) , pause(1)',
	'    else ,                   pause(0.5)',
	'    end',
	'    drawnow',
	'end',

	'title([strINIT,'' for 1 to '', int2str(iter),'' iterations'']);',
	'linw = 2;',
	'h = plot(xval,psi,''r'',''linewidth'',linw);',
	'drawnow',
	'hold off',

	'' };

  slide(idx).text = {
	' % Compute approximations of the wavelet function', 
	' % using the cascade algorithm.',
	'        wname = ''sym4'';',
	'        iter = 10;',
	'        for i = 1:iter',
	'            [phi,psi,xval] = wavefun(wname,i);',
	'            plot(xval,psi);',
	'            hold on',
	'            drawnow',
	'        end',
	''};

  slide(idx).info = 'wavefun';

  %========== Slide 3 ==========
  idx = idx+1;
  slide(idx).code = {
	'ax = findall(figHandle,''type'',''axes''); delete(ax); h = [];',
	'wshowdrv(''#modify_Comment'',figHandle,3,newTXT);',
	'strINIT = [''Approximation of the wavelet '' wname];';
	'[phi,psi,xval] = wavefun(wname,iter);',
	'h = plot(xval,psi,''r'',''linewidth'',linw);',
	'title([strINIT,'' after '',int2str(iter),'' iterations.'']);',
	'drawnow',
	'' };

  slide(idx).text = {
	' % Compute approximations of the wavelet function', 
	' % using the cascade algorithm.',
	'        wname = ''sym4'';',
	'        iter = 10;',
	'        [phi,psi,xval] = wavefun(wname,iter);',
	'        plot(xval,psi,''r'');',
	''};

  slide(idx).info = 'wavefun';

  varargout{1} = slide;
end


