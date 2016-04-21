function varargout = dguiwfus(varargin)
%DGUIWFUS Demonstrates Image Fusion tool in the Wavelet Toolbox.
%
% This is a slideshow file for use with wshowdrv.m
% To see it run, type 'wshowdrv dguiwfus', 

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 04-Sep-2003.
%   Last Revision: 11-Sep-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/03/15 22:37:18 $

% Initialization and Local functions if necessary.
if nargin>0
	action = varargin{1};
	switch action
	  case 'auto'    , wshowdrv('#autoMode',mfilename,'close');
	  case 'gr_auto' , wshowdrv('#gr_autoMode',mfilename,'close');

	  case 'getFigParam'
		  figName  = 'Wavelet GUI Demo: Image Fusion';
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
			  active_fig = wfustool;
			  wenamngr('Inactive',active_fig);
			  localPARAM = {active_fig};
			  wtbxappdata('set',figHandle,'localPARAM',localPARAM);
			  wshowdrv('#modify_cbClose_NEW',figHandle,active_fig,'wfustool');
		  else
			  active_fig = deal(localPARAM{:});
		  end
		  numDEM = idxSlide-1;
          nbDEM = 17;
		  if ismember(numDEM,[1:nbDEM])
              wfustool('demoPROC',active_fig,[],[],numDEM);
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
  
  %========== Slide 2 to 18 ==========
  for idx = 2:18
	  slide(idx).code = {
		  [mfilename ,'(''slidePROC'',figHandle,', int2str(idx), ');']
	  };
  end
  
  varargout{1} = slide;
  
end

