function varargout = dguidw1d(varargin)
%DGUIDW1D Demonstrates discrete 1-D wavelet GUI tools in the Wavelet Toolbox. 
%
% This is a slideshow file for use with wshowdrv.m
% To see it run, type 'wshowdrv dguidw1d', 
%   
%   See also DWT, IDWT, WAVEDEC, WAVEREC.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 03-Feb-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.14.4.2 $

% Initialization and Local functions if necessary.
if nargin>0
	action = varargin{1};
	switch action
	  case 'auto'    , wshowdrv('#autoMode',mfilename,'close');
	  case 'gr_auto' , wshowdrv('#gr_autoMode',mfilename,'close');

	  case 'getFigParam'
		figName  = 'Wavelet GUI Demo: Wavelet 1-D';
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
		idxPREV = wshowdrv('#get_idxSlide',figHandle);
		if isempty(localPARAM)
			active_fig = dw1dtool;
			dw1dmngr('demo',active_fig,'noisdopp','db2',6);
			wenamngr('Inactive',active_fig);
			tag_pop_viewm = 'View_Mode';
			tag_declev    = 'Pop_DecLev';
			pop_handles   = findobj(active_fig,'style','popupmenu');
			pop_viewm     = findobj(pop_handles,'tag',tag_pop_viewm);
			pop_decm      = findobj(pop_handles,'tag',tag_declev);
			cba_viewm     = get(pop_viewm,'Callback');
			cba_decm      = get(pop_decm,'Callback');
			figTMP        = [];
			localPARAM = {active_fig,pop_viewm,cba_viewm,pop_decm,cba_decm,figTMP};
			wtbxappdata('set',figHandle,'localPARAM',localPARAM);
			wshowdrv('#modify_cbClose',figHandle,active_fig,'dw1dtool');
		else
			[active_fig,pop_viewm,cba_viewm,pop_decm,cba_decm,figTMP] = deal(localPARAM{:});
		end
		switch idxSlide
		  case 3
			  if idxPREV<idxSlide
				  msg = strvcat(...
					  'The present Display mode is Full Decomposition mode.', ...
					  ['To change the Display mode use the corresponding popupmenu ' ...
						  'in the middle of the window.'],...
					  'Six display modes are available.'...
					  );
				  wshowdrv('#gui_wait',figHandle,active_fig,msg);
			  else
				  msg = ['We select the Full Decomposition mode.'];
				  wshowdrv('#gui_wait',figHandle,active_fig,msg);
				  set(pop_viewm,'value',2);
				  eval(cba_viewm);
			  end
			  
		  case 4
			  msg = ['We select the Superimpose Mode.'];
			  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
			  set(pop_viewm,'value',4);
			  eval(cba_viewm);
			  
		  case 5
			  msg = ['We select the Show and Scroll Mode.'];
			  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
			  set(pop_viewm,'value',1);
			  eval(cba_viewm);

		  case 6
			  msg = ['We select the Separate Mode.'];
			  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
			  set(pop_viewm,'value',3);
			  eval(cba_viewm);

		  case 7
			  msg = ['We select the Tree Mode.'];
			  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
			  set(pop_viewm,'value',5);
			  eval(cba_viewm);

		  case 8
			  msg = ['We select the Show and Scroll (Stem Cfs) Mode.'];
			  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
			  set(pop_viewm,'value',6);
			  eval(cba_viewm);

		  case 9
			  if idxPREV<idxSlide
				  msg = ['We go back to the Full Decomposition mode.'];
				  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
				  set(pop_viewm,'value',2);
				  eval(cba_viewm);
			  else
				  msg = ['We restore the Full Decomposition at level 6.'];
				  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
				  set(pop_decm,'value',6);
				  eval(cba_decm);
			  end

		  case 10
			  msg = ['We select the Full Decomposition at level 2.'];
			  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
			  set(pop_decm,'value',2);
			  eval(cba_decm);

		  case 11
			  if idxPREV<idxSlide
				  msg = ['We restore the Full Decomposition at level 6.'];
				  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
				  set(pop_decm,'value',6);
				  eval(cba_decm);
			  else
				  delete(figTMP); modify_localPARAM(figHandle,localPARAM,[]);
			  end

		  case 12
			  if idxPREV>idxSlide
				  delete(figTMP); modify_localPARAM(figHandle,localPARAM,[]);
			  end
			  msg = 'The Compress pushbutton is used to call the compression tool.';
			  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
			  figTMP = dw1dmngr('comp',active_fig);
			  modify_localPARAM(figHandle,localPARAM,figTMP);
			  wenamngr('Inactive',figTMP);
			  msg = 'We compress the signal with the default options.';
			  wshowdrv('#gui_wait',figHandle,figTMP,msg); 
			  dw1dcomp('compress',figTMP,active_fig);

		  case 13
			  delete(figTMP); modify_localPARAM(figHandle,localPARAM,[]);
			  pause(2)
			  dw1dmngr('return_comp',active_fig,0);
			  wenamngr('Inactive',active_fig);
			  msg = 'The De-noise pushbutton is used to call the de-noising tool.';
			  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
			  figTMP = dw1dmngr('deno',active_fig);
			  modify_localPARAM(figHandle,localPARAM,figTMP)
			  wenamngr('Inactive',figTMP);
			  msg = 'We de-noise the signal with the default options.';
			  wshowdrv('#gui_wait',figHandle,figTMP,msg); 
			  dw1ddeno('denoise',figTMP,active_fig);

		  case 14
			  delete(figTMP); modify_localPARAM(figHandle,localPARAM,[]);
			  pause(2)
			  dw1dmngr('return_deno',active_fig,0);
			  wenamngr('Inactive',active_fig);
			  msg = 'The Statistics pushbutton is used to call the statistics tool.';
			  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
			  figTMP = dw1dmngr('stat',active_fig);
			  modify_localPARAM(figHandle,localPARAM,figTMP);
			  dw1dstat('demo',figTMP);
			  wenamngr('Inactive',figTMP);

		  case 15
			  delete(figTMP); modify_localPARAM(figHandle,localPARAM,[]);
			  pause(2)
			  msg = 'The Histograms pushbutton is used to call the histograms tool.';
			  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
			  figTMP = dw1dmngr('hist',active_fig);
			  modify_localPARAM(figHandle,localPARAM,figTMP)
			  dw1dhist('demo',figTMP);
			  wenamngr('Inactive',figTMP);

		  case 16
			  delete(figTMP); modify_localPARAM(figHandle,localPARAM,[]);
			  pause(2)
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
  
  %========== Slide 2 to Slide 16 ==========
  for idx = 2:16
    slide(idx).code = {[mfilename ,'(''slidePROC'',figHandle,',int2str(idx),');']};
  end
  
  varargout{1} = slide;
  
end


%------------------------------------------------------------------------------------------%
function modify_localPARAM(figHandle,localPARAM,figTMP)

localPARAM{end} = figTMP;
wtbxappdata('set',figHandle,'localPARAM',localPARAM);	   
%------------------------------------------------------------------------------------------%
