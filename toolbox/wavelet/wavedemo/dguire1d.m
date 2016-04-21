function varargout = dguire1d(varargin)
%DGUIRE1D Demonstrates 1-D Regression estimation GUI tools in the Wavelet Toolbox.
%
% This is a slideshow file for use with wshowdrv.m
% To see it run, type 'wshowdrv dguire1d', 

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 03-Jul-99.
%   Last Revision: 03-Feb-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $  $Date: 2004/03/15 22:37:13 $

% Initialization and Local functions if necessary.
if nargin>0
	action = varargin{1};
	switch action
	  case 'auto'    , wshowdrv('#autoMode',mfilename,'close');
	  case 'gr_auto' , wshowdrv('#gr_autoMode',mfilename,'close');

	  case 'getFigParam'
		  figName  = 'Wavelet GUI Demo: Regression Estimation';
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
			  wshowdrv('#modify_cbClose',figHandle,active_fig,'re1dtool');
		  end
		  active_fig = deal(localPARAM{:});
		  numDEM = idxSlide-1;
		  demoSET = {...
				  'fixreg' , 'ex1nfix'  , 'db2'  , 5 , {}  ; ...
				  'fixreg' , 'noisdopp' , 'db5'  , 5 , {}  ; ...
				  'fixreg' , 'nbumpr3'  , 'sym4' , 5 , {4} ; ...
				  'fixreg' , 'nelec'    , 'sym4' , 5 , {3} ; ...
				  'storeg' , 'ex1nsto'  , 'sym4' , 5 ,{}   ; ...
				  'storeg' , 'noisdopp' , 'db5'  , 5 ,{}   ; ...
				  'storeg' , 'noisbump' , 'db5'  , 5 ,{}   ; ...
				  'storeg' , 'snblocr1' , 'sym4' , 5 ,{3}  ; ...
				  'storeg' , 'snbumpr1' , 'sym4' , 5 ,{3}  ; ...
				  'storeg' , 'snelec'   , 'sym4' , 5 ,{3}    ...
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
  
  %========== Slide 2 to 11 ==========
  for idx = 2:11
	  slide(idx).code = {
		  [mfilename ,'(''slidePROC'',figHandle,', int2str(idx), ');']
	  };
  end
  
  varargout{1} = slide;

end

