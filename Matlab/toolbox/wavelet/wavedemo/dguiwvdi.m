function varargout = dguiwvdi(varargin)
%DGUIWVDI Demonstrates wavelet display GUI tools in the Wavelet Toolbox. 
%
% This is a slideshow file for use with wshowdrv.m
% To see it run, type 'wshowdrv dguiwvdi', 

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 03-Feb-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.12.4.2 $

% Initialization and Local functions if necessary.
if nargin>0
	action = varargin{1};
	switch action
	  case 'auto'    , wshowdrv('#autoMode',mfilename,'close');
	  case 'gr_auto' , wshowdrv('#gr_autoMode',mfilename,'close');

	  case 'getFigParam'
		  figName  = 'Wavelet GUI Demo: Wavelet Display';
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
			  active_fig = wvdtool;
			  wenamngr('Inactive',active_fig);
			  localPARAM = {active_fig};
			  wtbxappdata('set',figHandle,'localPARAM',localPARAM);
			  wshowdrv('#modify_cbClose',figHandle,active_fig,'wvdtool');
		  else
			  active_fig = deal(localPARAM{:});
		  end
		  numDEM = idxSlide-1;
		  active_fig = deal(localPARAM{:});
		  switch numDEM
		  case 1 , paramDEM = 'db4';
		  case 2 , paramDEM = 'bior4.4';
		  case 3 , paramDEM = 'meyr';
		  case 4 , paramDEM = 'mexh';
		  case 5 , paramDEM = 'cmor1-1';
		  end
		  wvdtool('demo',active_fig,paramDEM);
		  wenamngr('Inactive',active_fig);
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
  
  %========== Slide 2:6 ==========
  for idx = 2:6
	  slide(idx).code = {
		  [mfilename ,'(''slidePROC'',figHandle,', int2str(idx), ');']
	  };
  end
  
  varargout{1} = slide;
  
end

