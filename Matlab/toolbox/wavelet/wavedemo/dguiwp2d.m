function varargout = dguiwp2d(varargin)
%DGUIWP2D Demonstrates 2-D wavelet packet GUI tools in the Wavelet Toolbox.
%
% This is a slideshow file for use with wshowdrv.m
% To see it run, type 'wshowdrv dguiwp2d', 
%   
%   See also WPDEC2, WPREC2.

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
		figName  = 'Wavelet GUI Demo: Wavelet Packet 2-D';
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
			  active_fig = wp2dtool;
			  tag_sli_size = 'Sli_Size';
			  tag_sli_pos  = 'Sli_Pos';
			  sli_handles  = findobj(active_fig,'style','slider');
			  sli_size     = findobj(sli_handles,'Tag',tag_sli_size);
			  sli_pos      = findobj(sli_handles,'Tag',tag_sli_pos);
			  set([sli_size;sli_pos],'visible','off');
			  wp2dmngr('demo',active_fig,'noiswom','sym4',2,'shannon');
			  wenamngr('Inactive',active_fig);
			  tag_nodlab   = 'Pop_NodLab';
			  tag_nodact   = 'Pop_NodAct';
			  tag_nodsel   = 'Pus_NodSel';
			  tag_pus_full = strvcat(...
				  'Pus_Full.1','Pus_Full.2',...
				  'Pus_Full.3','Pus_Full.4'...
				  );
			  tag_axe_t_lin = 'Axe_TreeLines';
			  tag_txt_in_t  = 'Txt_In_tree';
			  tag_axe_pack = 'Axe_Pack';
			  pop_handles  = findobj(active_fig,'style','popupmenu');
			  pus_handles  = findobj(active_fig,'style','pushbutton');
			  pop_nodlab   = findobj(pop_handles,'Tag',tag_nodlab);
			  pop_nodact   = findobj(pop_handles,'Tag',tag_nodact);
			  pus_full     = findobj(pus_handles,'tag',tag_pus_full(2,:));
			  pus_nodsel   = findobj(pus_handles,'Tag',tag_nodsel);
			  cba_nodlab   = get(pop_nodlab,'Callback');
			  cba_nodact   = get(pop_nodact,'Callback');
			  cba_nodsel   = get(pus_nodsel,'Callback');
			  cba_full     = get(pus_full,'Callback');
			  axe_handles  = findobj(active_fig,'type','axes');
			  WP_Axe_Tree  = findobj(axe_handles,'flat','Tag',tag_axe_t_lin);
			  WP_Axe_Pack  = findobj(axe_handles,'flat','Tag',tag_axe_pack);
			  figTMP        = [];
			  localPARAM = {active_fig,pop_nodlab,cba_nodlab,cba_full,...
					  pop_nodact,cba_nodact,cba_nodsel,WP_Axe_Tree,WP_Axe_Pack,tag_txt_in_t,...
					  figTMP};
			  wtbxappdata('set',figHandle,'localPARAM',localPARAM);
			  wshowdrv('#modify_cbClose',figHandle,active_fig,'wp1dtool');
		  else
			  [active_fig,pop_nodlab,cba_nodlab,cba_full,pop_nodact,cba_nodact,...
					  cba_nodsel,WP_Axe_Tree,WP_Axe_Pack,tag_txt_in_t,figTMP] = deal(localPARAM{:});
		  end
		  idxPREV = wshowdrv('#get_idxSlide',figHandle);
		  switch idxSlide
		  case 2
			  if idxPREV>idxSlide
				  set(pop_nodlab,'value',1);
				  eval(cba_nodlab);
			  end

		  case 3
			  if idxPREV<idxSlide
				  msg = strvcat(...
					  ['To change the Node Label use the corresponding popupmenu ' ...
						  'in the middle of the window.'], ...
					  'The default labelling is the depth-position labelling', ...
					  'We select the indices labelling.'  ...
					  );
				  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
				  set(pop_nodlab,'value',2);
				  eval(cba_nodlab);
			  else
				  set(pop_nodact,'value',5);
				  eval(cba_nodact);
				  delete(allchild(WP_Axe_Pack));
				  axes(WP_Axe_Pack);
				  title('Node Action Result');
			  end

		  case 4
			  if idxPREV<idxSlide
				  msg = strvcat(...
					  ['To change the Node Action use the corresponding popupmenu ' ...
						  'in the middle of the window.'], ...
					  'The default Node Action is Visualize.', ...
					  'We select the Select On node action.'  ...
					  );
				  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
				  set(pop_nodact,'value',4);
				  msg = 'Now we select the nodes [2 3 5].';
				  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
				  eval(cba_nodact);
				  Tree_txt = findobj(WP_Axe_Tree,'type','text','tag',tag_txt_in_t);
				  for num = [5 2 3]
					  hdl_node = findobj(Tree_txt,'userdata',num);
					  cba_node = get(hdl_node,'ButtonDownFcn');
					  set(active_fig,'CurrentObject',hdl_node);
					  eval(cba_node);
				  end
				  msg = 'We use the "Reconstruct" pushbutton.';
				  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
				  eval(cba_nodsel)
			  else
				  eval(cba_full);
			  end
			  
		  case 5
			  msg = strvcat(...
				  'The four pushbuttons labelled [1 2 3 4] in the middle of the window', ...
				  'allow to see Full Size for one of the four axes.', ...
				  'Let''s display the reconstructed packets (button 2) Full Size.' ...
				  );
			  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
			  eval(cba_full);
			  
		  case 6
			  if idxPREV<idxSlide
				  eval(cba_full);
			  else
				  set(pop_nodact,'value',4);
				  eval(cba_nodact);
				  Tree_txt = findobj(WP_Axe_Tree,'type','text','tag',tag_txt_in_t);
				  for num = [5 2 3]
					  hdl_node = findobj(Tree_txt,'userdata',num);
					  cba_node = get(hdl_node,'ButtonDownFcn');
					  set(active_fig,'CurrentObject',hdl_node);
					  eval(cba_node);
				  end
			  end
			  
		  case 7
			  if idxPREV<idxSlide
				  msg = 'We change the node action and unselect the nodes [2 3 5].';
				  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
				  set(pop_nodact,'value',5);
				  eval(cba_nodact);
			  else
				  delete(figTMP); modify_localPARAM(figHandle,localPARAM,[]);
			  end

		  case 8
			  if idxPREV<idxSlide
				  msg = 'The Compress pushbutton is used to call the compression tool.';
				  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
				  figTMP = wp2dmngr('comp',active_fig);
				  modify_localPARAM(figHandle,localPARAM,figTMP);
				  wenamngr('Inactive',figTMP);
				  msg = 'We compress the image with the default options.';
				  wshowdrv('#gui_wait',figHandle,figTMP,msg); 
				  wp2dcomp('compress',figTMP,active_fig);
			  else
				  delete(figTMP); modify_localPARAM(figHandle,localPARAM,[]);
			  end

		  case 9
			  delete(figTMP); modify_localPARAM(figHandle,localPARAM,[]);
			  wp2dmngr('return_comp',active_fig,0);
			  wenamngr('Inactive',active_fig);
			  msg = 'The De-noise pushbutton is used to call the de-noising tool.';
			  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
			  figTMP = wp2dmngr('deno',active_fig);
			  modify_localPARAM(figHandle,localPARAM,figTMP);
			  wenamngr('Inactive',figTMP);
			  msg = 'We de-noise the image with the default options.';
			  wshowdrv('#gui_wait',figHandle,figTMP,msg); 
			  wp2ddeno('denoise',figTMP,active_fig);
			  
		  case 10
			  delete(figTMP); modify_localPARAM(figHandle,localPARAM,[]);
			  wp2dmngr('return_deno',active_fig,0);
			  wenamngr('Inactive',active_fig);
			  msg = 'The Statistics information for the node 0 are displayed clicking on the node.';
			  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
			  set(pop_nodact,'value',6);
			  eval(cba_nodact);
			  figTMP = wp2dstat('create',active_fig,1);
			  modify_localPARAM(figHandle,localPARAM,figTMP);
			  wp2dstat('demo',figTMP);
			  wenamngr('Inactive',figTMP);
			  
		  case 11
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

  %========== Slide 2 to Slide 11 ==========
  for idx = 2:11
    slide(idx).code = {[mfilename ,'(''slidePROC'',figHandle,',int2str(idx),');']};
  end
  
  varargout{1} = slide;
  
end


%------------------------------------------------------------------------------------------%
function modify_localPARAM(figHandle,localPARAM,figTMP)

localPARAM{end} = figTMP;
wtbxappdata('set',figHandle,'localPARAM',localPARAM);	   
%------------------------------------------------------------------------------------------%
