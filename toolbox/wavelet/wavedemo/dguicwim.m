function varargout = dguicwim(varargin)
%DGUICWIM Demonstrates complex continuous 1-D wavelet GUI tools in the Wavelet Toolbox. 
%
% This is a slideshow file for use with wshowdrv.m
% To see it run, type 'wshowdrv dguicwim', 
%   
%   See also CWT.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Jun-99.
%   Last Revision: 03-Feb-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $  $Date: 2004/03/15 22:37:07 $

% Initialization and Local functions if necessary.
if nargin>0
	action = varargin{1};
	switch action
	  case 'auto'    , wshowdrv('#autoMode',mfilename,'close');
	  case 'gr_auto' , wshowdrv('#gr_autoMode',mfilename,'close');

	  case 'getFigParam'
		figName  = 'Wavelet GUI Demo: Complex Continuous Wavelet Analysis';
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
			active_fig = cwimtool;
			cw1dmngr('demo',active_fig,'cuspamax','cgau2',1,1,32,1);
			wenamngr('Inactive',active_fig);
			handles = wfigmngr('getValue',active_fig,['CW1D_handles']);
			UIC = handles.hdl_UIC;
			pop_ccm = UIC.pop_ccm;
			pop_pal = cbcolmap('get',active_fig,'pop_pal');
			cba_ccm = get(pop_ccm,'Callback');
			cba_pal = get(pop_pal,'Callback');
			localPARAM = {active_fig,pop_ccm,pop_pal,cba_ccm,cba_pal};
			wtbxappdata('set',figHandle,'localPARAM',localPARAM);
			wshowdrv('#modify_cbClose',figHandle,active_fig,'cwimtool');
			return
	    end

		[active_fig,pop_ccm,pop_pal,cba_ccm,cba_pal] = deal(localPARAM{:});
		idxPREV = wshowdrv('#get_idxSlide',figHandle);
		switch idxSlide
		  case 3
			  if idxPREV<idxSlide
				  wenamngr('Inactive',active_fig);
				  map_val = get(pop_pal,'Value');
				  if map_val~=1 , map_val = 1; else , map_val = 2; end
				  str_col = get(pop_pal,'String');
				  str_col = deblank(str_col(map_val,:));
				  msg = strvcat(...
					  ['To change the Colormap use the popupmenu at the ' ...
						  'bottom right of the window.'], ...
					  [sprintf('We select the %s colormap', str_col)]...
					  );
				  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
				  set(pop_pal,'value',map_val);
				  eval(cba_pal);
			  end
			  
		  case 4
			  ccm_old = get(pop_ccm,'Value');
			  if ccm_old~=1 , ccm_new = 1; else , ccm_new = 2; end
			  str_ccm = get(pop_ccm,'String');
			  str_ccm_old = deblank(str_ccm(ccm_old,:));
			  str_ccm_new = deblank(str_ccm(ccm_new,:));
			  msg = strvcat(...
				  ['To change the Coloration Mode use the popupmenu in the ' ...
					  'middle of the window.'], ...
				  [sprintf('The present mode is the (%s) mode. ',str_ccm_old)], ...
				  [sprintf('We select the (%s) mode.', str_ccm_new)] ...
				  );
			  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
			  set(pop_ccm,'value',ccm_new);
			  eval(cba_ccm);

		  case 5
			  if idxPREV<idxSlide
				  cw1dmngr('demo',active_fig,'brkintri','cmor1-0.1',1,1,64,1);
				  wenamngr('Inactive',active_fig);
				  map_val = get(pop_pal,'value');
				  wtbxappdata('set',figHandle,'map_val',map_val);
			  else
				  set([pop_ccm;pop_pal],'Enable','Off');
				  map_val = wtbxappdata('get',figHandle,'map_val');
				  set(pop_pal,'value',map_val);
				  eval(cba_pal);
			  end

		  case 6
			  msg = 'We select the hot colormap';
			  wshowdrv('#gui_wait',figHandle,active_fig,msg); 
			  set(pop_pal,'value',4);
			  eval(cba_pal);
			  set([pop_ccm;pop_pal],'Enable','On');

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
  
  %========== Slide 2 to Slide 6 ==========
  for idx = 2:6
    slide(idx).code = {[mfilename ,'(''slidePROC'',figHandle,',int2str(idx),');']};
  end
  
  varargout{1} = slide;
  
end
