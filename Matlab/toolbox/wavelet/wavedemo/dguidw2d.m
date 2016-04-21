function varargout = dguidw2d(varargin)
%DGUIDW2D Demonstrates discrete 2-D wavelet GUI tools in the Wavelet Toolbox.
%
% This is a slideshow file for use with wshowdrv.m
% To see it run, type 'wshowdrv dguidw2d', 
%   
%   See also DWT2, IDWT2, WAVEDEC2, WAVEREC2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 03-Feb-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.13.4.2 $

% Initialization and Local functions if necessary.
if nargin>0
	action = varargin{1};
	switch action
	  case 'auto'    , wshowdrv('#autoMode',mfilename,'close');
	  case 'gr_auto' , wshowdrv('#gr_autoMode',mfilename,'close');

	  case 'getFigParam'
		figName  = 'Wavelet GUI Demo: Wavelet 2-D';
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
		idxPREV = wshowdrv('#get_idxSlide',figHandle);
	    localPARAM = wtbxappdata('get',figHandle,'localPARAM');
		if idxSlide==2
			if isempty(localPARAM)
				active_fig = dw2dtool;
				dw2dmngr('demo',active_fig,'woman2','sym4',2);
				wenamngr('Inactive',active_fig);
				tag_pop_declev  = 'Pop_DecLev';
				tag_pop_viewm   = 'Pop_ViewM';
				tag_pus_full    = strvcat(...
					'Pus_Full.1','Pus_Full.2',...
					'Pus_Full.3','Pus_Full.4'...
					);
				pop_handles     = findobj(active_fig,'style','popupmenu');
				pus_handles     = findobj(active_fig,'style','pushbutton');
				pop_viewm       = findobj(pop_handles,'tag',tag_pop_viewm);
				pop_decm        = findobj(pop_handles,'tag',tag_pop_declev);
				pus_full        = findobj(pus_handles,'tag',tag_pus_full(4,:));
				cba_viewm       = get(pop_viewm,'Callback');
				cba_decm        = get(pop_decm,'Callback');
				cba_full        = get(pus_full,'Callback');
				figTMP          = [];
				localPARAM = {active_fig,pop_viewm,cba_viewm,pop_decm,cba_decm,cba_full,figTMP};
				wtbxappdata('set',figHandle,'localPARAM',localPARAM);
				wshowdrv('#modify_cbClose',figHandle,active_fig,'dw2dtool');
			else
				[active_fig,pop_viewm,cba_viewm,pop_decm,cba_decm,cba_full,figTMP] = deal(localPARAM{:});
				set(pop_viewm,'value',1);
				eval(cba_viewm);
			end
			return
		end
			
		[active_fig,pop_viewm,cba_viewm,pop_decm,cba_decm,cba_full,figTMP] = deal(localPARAM{:});
		switch idxSlide
		  case 3
			  msg = strvcat(...
				  'The present View mode is Square mode.', ...
				  ['To change the Display mode use the corresponding popupmenu ' ...
					  'in the middle of the window.'],...
				  'Two view modes are available.'...
				  );
			  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
			  msg = ['We select the Tree Mode.'];
			  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
			  set(pop_viewm,'value',2);
			  eval(cba_viewm);

		  case 4
			  if idxPREV<idxSlide
				  msg = ['We go back to the Square mode.'];
				  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
				  set(pop_viewm,'value',1);
				  eval(cba_viewm);
			  else
				  eval(cba_full);
			  end

		  case 5
			  if idxPREV<idxSlide
				  msg = strvcat(...
					  'The four pushbuttons labelled [1 2 3 4] in the middle of the window', ...
					  'allow to see Full Size for one of the four axes.', ...
					  'Let''s display the decomposition (button 4) Full Size.' ...
					  );
				  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
				  eval(cba_full);
			  else
				  set(pop_decm,'value',2);
				  eval(cba_decm);
			  end
			  
		  case 6
			  if idxPREV<idxSlide
				  msg = ['We select the decomposition at level 1.'];
				  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
				  set(pop_decm,'value',1);
				  eval(cba_decm);
			  else
				  eval(cba_full);
			  end
			  
		  case 7
			  if idxPREV<idxSlide
				  msg = ['We go back to the Square mode.'];
				  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
				  eval(cba_full);
			  else
				  set(pop_decm,'value',1);
				  eval(cba_decm);
			  end
			  
		  case 8
			  if idxPREV<idxSlide
				  msg = ['We restore the decomposition at level 2.'];
				  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
				  set(pop_decm,'value',2);
				  eval(cba_decm);
			  else
				  delete(figTMP);  modify_localPARAM(figHandle,localPARAM,[]);
			  end

		  case 9
			  if idxPREV<idxSlide
				  msg = 'The Compress pushbutton is used to call the compression tool.';
				  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
				  figTMP = dw2dmngr('comp',active_fig);
				  modify_localPARAM(figHandle,localPARAM,figTMP);
				  wenamngr('Inactive',figTMP);
				  msg = 'We compress the image with the default options.';
				  wshowdrv('#gui_wait',figHandle,figTMP,msg); 
				  dw2dcomp('compress',figTMP,active_fig);
			  else
				  delete(figTMP);  modify_localPARAM(figHandle,localPARAM,[]);
			  end
			  
		  case 10
			  delete(figTMP);  modify_localPARAM(figHandle,localPARAM,[]);
			  pause(2)
			  dw2dmngr('return_comp',active_fig,0);
			  wenamngr('Inactive',active_fig);
			  msg = 'The De-noise pushbutton is used to call the de-noising tool.';
			  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
			  figTMP = dw2dmngr('deno',active_fig);
			  modify_localPARAM(figHandle,localPARAM,figTMP);
			  wenamngr('Inactive',figTMP);
			  msg = 'We de-noise the image with the default options.';
			  wshowdrv('#gui_wait',figHandle,figTMP,msg); 
			  dw2ddeno('denoise',figTMP,active_fig);

		  case 11
			  delete(figTMP);  modify_localPARAM(figHandle,localPARAM,[]);
			  pause(2)
			  dw2dmngr('return_deno',active_fig,0);
			  wenamngr('Inactive',active_fig);
			  msg = 'The Statistics pushbutton is used to call the statistics tool.';
			  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
			  figTMP = dw2dmngr('stat',active_fig);
			  modify_localPARAM(figHandle,localPARAM,figTMP);
			  dw2dstat('demo',figTMP);
			  wenamngr('Inactive',figTMP);

		  case 12
			  delete(figTMP);  modify_localPARAM(figHandle,localPARAM,[]);
			  msg = 'The Histograms pushbutton is used to call the histograms tool.';
			  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
			  figTMP = dw2dmngr('hist',active_fig);
			  modify_localPARAM(figHandle,localPARAM,figTMP);
			  dw2dhist('demo',figTMP);
			  wenamngr('Inactive',figTMP);

		  case 13
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

  %========== Slide 2 to Slide 13 ==========
  for idx = 2:13
    slide(idx).code = {[mfilename ,'(''slidePROC'',figHandle,',int2str(idx),');']};
  end
  
  varargout{1} = slide;
  
end

%------------------------------------------------------------------------------------------%
function modify_localPARAM(figHandle,localPARAM,figTMP)

localPARAM{end} = figTMP;
wtbxappdata('set',figHandle,'localPARAM',localPARAM);	   
%------------------------------------------------------------------------------------------%
