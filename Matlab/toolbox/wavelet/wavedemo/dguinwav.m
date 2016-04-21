function varargout = dguinwav(varargin)
%DGUINWAV Demonstrates New wavelet for ... tool in the Wavelet Toolbox.
%
% This is a slideshow file for use with wshowdrv.m
% To see it run, type 'wshowdrv dguinwav', 

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 04-Sep-2003.
%   Last Revision: 12-Sep-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/03/15 22:37:12 $

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
			  active_fig = nwavtool;
			  wenamngr('Inactive',active_fig);
			  localPARAM = {active_fig};
			  wtbxappdata('set',figHandle,'localPARAM',localPARAM);
			  wshowdrv('#modify_cbClose_NEW',figHandle,active_fig,'nwavtool');
		  else
			  active_fig = deal(localPARAM{:});
		  end
          numDEM = idxSlide-1;
          tabNumExample = [ ...
              1 1 1 1 2 2 3 4 5 6 7 7 8 8 9 10 11 11 12 12 13 14 14 15 16 17 18 19 19
              ];
          nbDEM  = length(tabNumExample);
          if ~ismember(numDEM,[1:nbDEM]) , return; end
          numExample = tabNumExample(numDEM);
          switch numDEM
              case 1 , paramDEM = {'run'       , 1  , ''};
              case 2 , paramDEM = {'compare'   , 1 ,  ''};
              case 3 , paramDEM = {'compare_2' , 1 , 'db2'};
              case 4 , paramDEM = {'compare_2' , 1 , 'sym4'};
              case 5 , paramDEM = {'run'       , 2 , ''};
              case 6 , paramDEM = {'compare'   , 2 , ''};
              otherwise
                  paramDEM = {'run' , numExample ,''};
                  numPrev = tabNumExample(numDEM-1);
                  if numPrev==numExample
                      paramDEM{1} = 'compare';
                  end
          end
          nwavtool('demoPROC',active_fig,[],[],paramDEM);
          wfigmngr('storeValue',active_fig,'File_Save_Flag',1);
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
  
  %========== Slide 2 to ... ==========
  tabNumExample = [ ...
      1 1 1 1 2 2 3 4 5 6 7 7 8 8 9 10 11 11 12 12 13 14 14 15 16 17 18 19 19
      ];
  idxMAX = length(tabNumExample);
  for idx = 2:idxMAX+1
	  slide(idx).code = {
		  [mfilename ,'(''slidePROC'',figHandle,', int2str(idx), ');']
	  };
  end
  slide(5).idxPrev = 3;
  
  varargout{1} = slide;
  
end

