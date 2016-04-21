function varargout = dguiwp1d(varargin)
%DGUIWP1D Demonstrates 1-D wavelet packet GUI tools in the Wavelet Toolbox.
%
% This is a slideshow file for use with wshowdrv.m
% To see it run, type 'wshowdrv dguiwp1d', 
%   
%   See also WPDEC, WPREC.

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
		figName  = 'Wavelet GUI Demo: Wavelet Packet 1-D';
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
			active_fig = wp1dtool;
			tag_sli_size = 'Sli_Size';
			tag_sli_pos  = 'Sli_Pos';
			sli_handles  = findobj(active_fig,'style','slider');
			sli_size     = findobj(sli_handles,'Tag',tag_sli_size);
			sli_pos      = findobj(sli_handles,'Tag',tag_sli_pos);
			set([sli_size;sli_pos],'visible','off');
			wp1dmngr('demo',active_fig,'noischir','db3',4,'threshold',0.2);
			wenamngr('Inactive',active_fig);
			tag_pus_btree   = 'Pus_Btree';
			tag_inittree    = 'Pus_InitTree';
			tag_wavtree     = 'Pus_WavTree';
			tag_nodlab      = 'Pop_NodLab';
			tag_nodact      = 'Pop_NodAct';
			tag_pus_full    = strvcat(...
				'Pus_Full.1','Pus_Full.2',...
				'Pus_Full.3','Pus_Full.4'...
				);
			tag_pop_colm    = 'Txt_PopM';
			tag_axe_t_lin   = 'Axe_TreeLines';
			tag_txt_in_t    = 'Txt_In_tree';
			pop_handles     = findobj(active_fig,'style','popupmenu');
			pus_handles     = findobj(active_fig,'style','pushbutton');
			pus_inittree    = findobj(pus_handles,'Tag',tag_inittree);
			pus_wavtree     = findobj(pus_handles,'Tag',tag_wavtree);
			pus_btree       = findobj(pus_handles,'Tag',tag_pus_btree);
			pus_full        = findobj(pus_handles,'tag',tag_pus_full(4,:));
			pop_nodlab      = findobj(pop_handles,'Tag',tag_nodlab);
			pop_nodact      = findobj(pop_handles,'Tag',tag_nodact);
			pop_colm        = findobj(pop_handles,'Tag',tag_pop_colm);
			cba_inittree    = get(pus_inittree,'Callback');
			cba_wavtree     = get(pus_wavtree,'Callback');
			cba_btree       = get(pus_btree,'Callback');
			cba_full        = get(pus_full,'Callback');
			cba_colm        = get(pop_colm,'Callback');
			cba_nodlab      = get(pop_nodlab,'Callback');
			cba_nodact      = get(pop_nodact,'Callback');
			axe_handles     = findobj(active_fig,'type','axes');
			WP_Axe_Tree	= findobj(axe_handles,'flat','Tag',tag_axe_t_lin);
			figTMP        = [];
			localPARAM = {active_fig,pop_nodlab,cba_nodlab,cba_wavtree,...
					      cba_inittree,cba_btree,cba_full,...
						  pop_nodact,cba_nodact,WP_Axe_Tree,tag_txt_in_t,...
						  pop_colm,cba_colm,figTMP};
			wtbxappdata('set',figHandle,'localPARAM',localPARAM);
			wshowdrv('#modify_cbClose',figHandle,active_fig,'wp1dtool');
		else
			[active_fig,pop_nodlab,cba_nodlab,cba_wavtree,...
			 cba_inittree,cba_btree,cba_full,...
			 pop_nodact,cba_nodact,WP_Axe_Tree,tag_txt_in_t,...
			 pop_colm,cba_colm,figTMP] = deal(localPARAM{:});
		end
		idxPREV = wshowdrv('#get_idxSlide',figHandle);

		switch idxSlide
		  case 2
			  if idxPREV>idxSlide
				  set(pop_nodlab,'value',1);
				  eval(cba_nodlab);
			  end
			
		  case 3
			  msg = strvcat(...
				  ['To change the Node Label use the corresponding popupmenu ' ...
					  'in the middle of the window.'], ...
				  'The default labelling is the depth-position labelling', ...
				  'We select the indices labelling.'  ...
				  );
			  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
			  set(pop_nodlab,'value',2);
			  eval(cba_nodlab);

		  case 4
			  msg = strvcat('We select the entropy labelling which gives the entropy of each packet');
			  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
			  set(pop_nodlab,'value',3);
			  eval(cba_nodlab);

		  case 5
			  msg = strvcat('We select the length labelling which gives the length of each packet');
			  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
			  set(pop_nodlab,'value',5);
			  eval(cba_nodlab);
			  
		  case 6
			  if idxPREV<idxSlide
				  msg = strvcat('We go back to the depth-position labelling.');
				  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
				  set(pop_nodlab,'value',1);
				  eval(cba_nodlab);
			  else
				  eval(cba_inittree);
			  end

		  case 7
			  msg = ['We extract the Wavelet tree using the corresponding pushbutton ' ...
					  'in the middle of the window.'];
			  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
			  eval(cba_wavtree);

		  case 8
			  msg = ['We restore the Initial tree using the corresponding pushbutton ' ...
					  'in the middle of the window.'];
			  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
			  eval(cba_inittree);

		  case 9
			  msg = ['We Compute the Best tree using the corresponding pushbutton ' ...
					  'in the middle of the window.'];
			  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
			  eval(cba_btree);

		  case 10
			  if idxPREV<idxSlide
				  eval(cba_inittree);
			  else
				  eval(cba_full);
			  end
			  
		  case 11
			  msg = strvcat(...
				  'The four pushbuttons labelled [1 2 3 4] in the middle of the window', ...
				  'allow to see Full Size for one of the four axes.', ...
				  'Let''s display the coefficients (button 4) Full Size.' ...
				  );
			  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
			  eval(cba_full);

		  case 12
			  if idxPREV<idxSlide
				  msg = 'We restore the previous display.';
				  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
				  eval(cba_full);
			  else
				  set(pop_colm,'value',1);
				  eval(cba_colm);
			  end

		  case 13
			  msg = strvcat(...
				  ['To change the Coloration Mode use the popupmenu at the bottom ' ...
					  'of the window.'], ...
				  'Eight coloration modes are available.', ...
				  'Four are based on the frequency order of the packets,', ...
				  'The other four are based on the natural order of the packets.', ...
				  'We select the natural order : by level and with abs. value of coefficients.' ...
				  );
			  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
			  set(pop_colm,'value',5);
			  eval(cba_colm);

		  case 14
			  if idxPREV<idxSlide
				  msg = 'We restore the frequency order : global with abs. value of coefficients.';
				  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
				  set(pop_colm,'value',1);
				  eval(cba_colm);
			  else
				  eval(cba_inittree);
			  end

		  case 15
			  msg = 'We change Node Action to Split-Merge and we merge the node (1,1) or 2.';
			  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
			  set(pop_nodact,'value',2);
			  eval(cba_nodact);
			  Tree_txt = findobj(WP_Axe_Tree,'type','text','tag',tag_txt_in_t);
			  hdl_node = findobj(Tree_txt,'userdata',2);
			  cba_node = get(hdl_node,'ButtonDownFcn');
			  set(active_fig,'CurrentObject',hdl_node);
			  eval(cba_node);

		  case 16
			  if idxPREV<idxSlide
				  msg = ['We restore the Initial tree using the corresponding pushbutton ' ...
						 'in the middle of the window.'];
				  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
				  eval(cba_inittree);
			  else
				  delete(figTMP); modify_localPARAM(figHandle,localPARAM,[]);
			  end
			  
		  case 17
			  if idxPREV<idxSlide
				  msg = 'The Compress pushbutton is used to call the compression tool.';
				  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
				  figTMP = wp1dmngr('comp',active_fig);
				  modify_localPARAM(figHandle,localPARAM,figTMP);
				  wenamngr('Inactive',figTMP);
				  msg = 'We compress the signal with the default options.';
				  wshowdrv('#gui_wait',figHandle,figTMP,msg); 
				  wp1dcomp('compress',figTMP,active_fig);
			  else
				  delete(figTMP); modify_localPARAM(figHandle,localPARAM,[]);
			  end
			  
			  
		  case 18
			  delete(figTMP); modify_localPARAM(figHandle,localPARAM,[]);
			  wp1dmngr('return_comp',active_fig,0);
			  wenamngr('Inactive',active_fig);
			  msg = 'The De-noise pushbutton is used to call the de-noising tool.';
			  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
			  figTMP = wp1dmngr('deno',active_fig);
			  modify_localPARAM(figHandle,localPARAM,figTMP);
			  wenamngr('Inactive',figTMP);
			  msg = 'We de-noise the signal with the default options.';
			  wshowdrv('#gui_wait',figHandle,figTMP,msg); 
			  wp1ddeno('denoise',figTMP,active_fig);
			  
		  case 19
			  delete(figTMP); modify_localPARAM(figHandle,localPARAM,[]);
			  wp1dmngr('return_deno',active_fig,0);
			  wenamngr('Inactive',active_fig);
			  msg = 'The Statistics information for the node 1 are displayed clicking on the node.';
			  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
			  set(pop_nodlab,'value',2);
			  eval(cba_nodlab);
			  set(pop_nodact,'value',6);
			  eval(cba_nodact);
			  figTMP = wp1dstat('create',active_fig,1);
			  modify_localPARAM(figHandle,localPARAM,figTMP);
			  wp1dstat('demo',figTMP);
			  wenamngr('Inactive',figTMP);

		  case 20
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
  
  %========== Slide 2 to Slide 20 ==========
  for idx = 2:20
    slide(idx).code = {[mfilename ,'(''slidePROC'',figHandle,',int2str(idx),');']};
  end
  
  varargout{1} = slide;
  
end


%------------------------------------------------------------------------------------------%
function modify_localPARAM(figHandle,localPARAM,figTMP)

localPARAM{end} = figTMP;
wtbxappdata('set',figHandle,'localPARAM',localPARAM);	   
%------------------------------------------------------------------------------------------%
