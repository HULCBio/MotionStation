function varargout = dguicf1d(varargin)
%DGUICF1D Demonstrates 1-D wavelet coefficients selection GUI tools in the Wavelet Toolbox.
%
% This is a slideshow file for use with wshowdrv.m
% To see it run, type 'wshowdrv dguicf1d', 

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 03-Jul-99.
%   Last Revision: 03-Feb-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $  $Date: 2004/03/15 22:37:04 $

% Initialization and Local functions if necessary.
if nargin>0
	action = varargin{1};
	switch action
	  case 'auto'    , wshowdrv('#autoMode',mfilename,'close');
	  case 'gr_auto' , wshowdrv('#gr_autoMode',mfilename,'close');
		
	  case 'getFigParam'
		figName  = 'Wavelet GUI Demo: Coefficients 1-D selection';
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
			  active_fig = cf1dtool;
			  wenamngr('Inactive',active_fig);
			  toolATTR = wfigmngr('getValue',active_fig,'ToolATTR');
			  hdl_UIC  = toolATTR.hdl_UIC;
			  chk_sho  = hdl_UIC.chk_sho;
			  cba_chk  = get(chk_sho,'Callback');
			  localPARAM = {active_fig,chk_sho,cba_chk};
			  wtbxappdata('set',figHandle,'localPARAM',localPARAM);
			  wshowdrv('#modify_cbClose',figHandle,active_fig,'cf1dtool');
		  else
			  [active_fig,chk_sho,cba_chk] = deal(localPARAM{:});
		  end
		  numDEM = idxSlide-1;
		  switch numDEM
		  case 1 , paramDEM = {'freqbrk','db5',5,{'Global'}};
		  case 2 , paramDEM = {'noisbloc','sym4',5,{'Global'}};
		  case 3 , paramDEM = {'noisbloc','sym4',5,{'Stepwise'}};
		  case 4 , paramDEM = {'noisbump','sym4',5,{'Stepwise'}};
		  case 5 , paramDEM = {'nelec','db3',5,{'Global'}};
		  end
		  cf1dtool('demo',active_fig,paramDEM{:});
		  wenamngr('Inactive',active_fig);
		  if ismember(numDEM,[1,2,5])
			  set(chk_sho,'value',1);
			  eval(cba_chk);
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
  
  %========== Slide 2 to 6 ==========
  for idx = 2:6
	  slide(idx).code = {
		  [mfilename ,'(''slidePROC'',figHandle,', int2str(idx), ');']
	  };
  end
  
  varargout{1} = slide;
  
end

