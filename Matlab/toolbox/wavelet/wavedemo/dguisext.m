function varargout = dguisext(varargin)
%DGUISEXT Demonstrates Signal extension GUI tools in the Wavelet Toolbox.
%
% This is a slideshow file for use with wshowdrv.m
% To see it run, type 'wshowdrv dguisext', 

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 03-Jul-99.
%   Last Revision: 03-Feb-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $  $Date: 2004/03/15 22:37:14 $

% Initialization and Local functions if necessary.
if nargin>0
	action = varargin{1};
	switch action
	  case 'auto'    , wshowdrv('#autoMode',mfilename,'close');
	  case 'gr_auto' , wshowdrv('#gr_autoMode',mfilename,'close');

	  case 'getFigParam'
		  figName  = 'Wavelet GUI Demo: Signal Extension';
		  showType = 'command';
		  varargout = {figName,showType};

	  case 'slidePROC_Init'
		  figHandle = varargin{2};
		  localPARAM = wtbxappdata('get',figHandle,'localPARAM');
		  if ~isempty(localPARAM)
			  active_fig = localPARAM{1};
			  delete(active_fig);
			  wtbxappdata('del',figHandle,'localPARAM');
		  end

	  case 'slidePROC'
		  [figHandle,idxSlide]  = deal(varargin{2:end});
		  localPARAM = wtbxappdata('get',figHandle,'localPARAM');
		  if isempty(localPARAM)
			  active_fig = sigxtool;
			  wenamngr('Inactive',active_fig);
			  localPARAM = {active_fig};
			  wtbxappdata('set',figHandle,'localPARAM',localPARAM);
			  wshowdrv('#modify_cbClose',figHandle,active_fig,'sigxtool');
		  else
			  active_fig = deal(localPARAM{:});
		  end
		  numDEM = idxSlide-1;
		  demoSET = {...
				  'noisbloc' , 'ext'   , {'zpd' , 1236 , 'both'}  ; ...
				  'noisbloc' , 'trunc' , {'nul' ,  865 , 'both'}  ; ...
				  'cuspamax' , 'ext'   , {'spd' , 1400 , 'right'} ; ...
				  'cuspamax' , 'ext'   , {'spd' , 1400 , 'left'}  ; ...
				  'cuspamax' , 'ext'   , {'spd' , 1400 , 'both'}  ; ...
				  'noisbump' , 'ext'   , {'sym' , 1600 , 'both'}  ; ...
				  'freqbrk'  , 'trunc' , {'nul' ,  666 , 'left'}  ; ...
				  'freqbrk'  , 'ext'   , {'swt' ,   10 , 'right'}   ...
			  };
		  nbDEM = size(demoSET,1);
		  if ismember(numDEM,[1:nbDEM])
			  paramDEM = demoSET(numDEM,:);
			  sigxtool('demo',active_fig,paramDEM{:});
			  wfigmngr('storeValue',active_fig,'File_Save_Flag',1);
			  wenamngr('Inactive',active_fig);
		  end
	end
	return
end

if nargout<1,
  wshowdrv(mfilename)
else
  idx = 0;	slide(1).code = {}; slide(1).text = {};
  
  %========== Slide 1 ==========
  idx = idx+1;
  slide(idx).code = {
	  'figHandle = gcf;',
	  [mfilename ,'(''slidePROC_Init'',figHandle);'],
	  '' };
  
  %========== Slide 2 to 9 ==========
  for idx = 2:9
	  slide(idx).code = {
		  [mfilename ,'(''slidePROC'',figHandle,', int2str(idx), ');']
	  };
  end
  
  varargout{1} = slide;
  
end

