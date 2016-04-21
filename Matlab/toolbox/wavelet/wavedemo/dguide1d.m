function varargout = dguide1d(varargin)
%DGUIDE1D Demonstrates 1-D density estimation GUI tools in the Wavelet Toolbox.
%
% This is a slideshow file for use with wshowdrv.m
% To see it run, type 'wshowdrv dguide1d', 

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 03-Jul-99.
%   Last Revision: 03-Feb-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $  $Date: 2004/03/15 22:37:08 $

% Initialization and Local functions if necessary.
if nargin>0
	action = varargin{1};
	switch action
	  case 'auto'    , wshowdrv('#autoMode',mfilename,'close');
	  case 'gr_auto' , wshowdrv('#gr_autoMode',mfilename,'close');

	  case 'getFigParam'
		  figName  = 'Wavelet GUI Demo: Density Estimation';
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
		  [figHandle,idxSlide] = deal(varargin{2:end});
		  localPARAM = wtbxappdata('get',figHandle,'localPARAM');
		  if isempty(localPARAM)
			  active_fig = de1dtool;
			  wenamngr('Inactive',active_fig);
			  localPARAM = {active_fig};
			  wtbxappdata('set',figHandle,'localPARAM',localPARAM);
			  wshowdrv('#modify_cbClose',figHandle,active_fig,'de1dtool');
		  end
		  active_fig = deal(localPARAM{:});
		  numDEM = idxSlide-1;
		  demoSET = {...
				  'denest' , 'ex1cusp1' , 'sym4'  , 5 ; ...
				  'denest' , 'ex2cusp1' , 'sym6'  , 5 ; ...
				  'denest' , 'ex1cusp2' , 'sym4'  , 5 ; ...
				  'denest' , 'ex2cusp2' , 'coif1' , 5 ; ...
				  'denest' , 'ex1gauss' , 'sym3'  , 5 ; ...
				  'denest' , 'ex2gauss' , 'sym4'  , 5   ...
			  };
		  nbDEM = size(demoSET,1);
		  if ismember(numDEM,[1:nbDEM])
			  paramDEM = demoSET(numDEM,:);
			  wdretool('demo',active_fig,paramDEM{:});
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
  
  %========== Slide 2 to 7 ==========
  for idx = 2:7
	  slide(idx).code = {
		  [mfilename ,'(''slidePROC'',figHandle,', int2str(idx), ');']
	  };
  end
  
  varargout{1} = slide;
  
end

