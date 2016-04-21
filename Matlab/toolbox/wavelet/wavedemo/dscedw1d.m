function varargout = dscedw1d(varargin)
%DSCEDW1D Demonstrates typical wavelet 1-D scenarios in the Wavelet Toolbox (Auto play). 
%
% This is a slideshow file for use with wshowdrv.m
% To see it run, type 'wshowdrv dscedw1d', 

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
		figName  = 'Short Scenario DW1D';
		showType = 'command';
		varargout = {figName,showType};
		
	  case 'slidePROC'
		  wait_mode = 0;
		  [figHandle,idxSlide]  = deal(varargin{2:end});
		  idxPREV = wshowdrv('#get_idxSlide',figHandle);
		  localPARAM = wtbxappdata('get',figHandle,'localPARAM');
		  switch idxSlide
		  	case 1
				if ~isempty(localPARAM)
					win_dw1d = localPARAM{1};
					delete(win_dw1d);
					dmsgfun('close');
					wtbxappdata('del',figHandle,'localPARAM');
				end
				% wshowdrv('#bloc_BackBtn',figHandle);
				return

			case 2
				if ~isempty(localPARAM)
					win_dw1d = localPARAM{1};
					delete(win_dw1d);
				end
				%-------------------------------------------
				% Display main window (demo initialization).
				%-------------------------------------------
				win_dw1d = dw1dtool;
				%----------------------------------------------
				% Main window parameters.
				%----------------------------------------------
				tag_pop_viewm  = 'View_Mode';
				tag_valapp_scr = 'ValApp_Scr';
				pop_handles    = findobj(win_dw1d,'style','popupmenu');
				pop_viewm      = findobj(pop_handles,'tag',tag_pop_viewm);
				pop_app_scr    = findobj(pop_handles,'tag',tag_valapp_scr);
				%------------------------------------------------
				localPARAM = {win_dw1d,pop_viewm,pop_app_scr};
				wtbxappdata('set',figHandle,'localPARAM',localPARAM);
				wshowdrv('#modify_cbClose',figHandle,win_dw1d,'dw1dtool');
				msg = get_Message(idxSlide);
				wshowdrv('#disp_msg',figHandle,msg,'step',localPARAM{1});
				if idxPREV<idxSlide
					figMSG = dmsgfun('handle');
					wshowdrv('#modify_cbClose',figHandle,figMSG,'dmsgfun');
				end
				return
			  
		    otherwise
				[win_dw1d,pop_viewm,pop_app_scr] = deal(localPARAM{:});
		  end

		  switch idxSlide
		    case 3
				if idxPREV<idxSlide
					%--------------------------
					% Full decomposition mode.
					%--------------------------
					sig_nam = 'noisdopp'; wav_nam = 'sym4';	lev_dec = 5;
					dw1dmngr('demo',win_dw1d,sig_nam,wav_nam,lev_dec);
					wenamngr('Inactive',win_dw1d);
				else
					set(pop_viewm,'value',2);
					eval(get(pop_viewm,'Callback'));
				end

		    case 4
				if idxPREV<idxSlide
					%----------------
					% Separate mode.
					%----------------
					set(pop_viewm,'value',3);
					eval(get(pop_viewm,'Callback'));
				else
					win_mopt_Params = wtbxappdata('get',figHandle,'win_mopt_Params');
					[win_mopt,chk_det_on,chk_cfs_on,pop_ccfs] = deal(win_mopt_Params{:});
					figure(win_mopt);
					set(chk_det_on,'Value',1);
					pause(0.5);
					dw1ddisp('apply',win_dw1d,win_mopt);
					set(pop_app_scr,'Value',1);
					eval(get(pop_app_scr,'Callback'));
					delete(win_mopt)
					wtbxappdata('del',figHandle,'win_mopt_Params');
				end

		    case 5
				if idxPREV<idxSlide
					%--------------------------------------
					% Show and Scroll mode (app5+sig+cfs).
					%--------------------------------------
					set(pop_viewm,'value',1);
					eval(get(pop_viewm,'Callback'));
					pause(2);
					%----------------------------------------
					% More Display Option window parameters.
					%----------------------------------------
					win_mopt_Params = makeWinOpt(figHandle,win_dw1d);
					[win_mopt,chk_det_on,chk_cfs_on,pop_ccfs] = deal(win_mopt_Params{:});
					%------------------------------------------------
					pause(1);
					set(chk_det_on,'Value',0);
					pause(1);
					dw1ddisp('apply',win_dw1d,win_mopt);
					set(pop_app_scr,'Value',5);
					eval(get(pop_app_scr,'Callback'));
				else
					win_mopt_Params = wtbxappdata('get',figHandle,'win_mopt_Params');
					[win_mopt,chk_det_on,chk_cfs_on,pop_ccfs] = deal(win_mopt_Params{:});
					figure(win_mopt);
					pause(1)
					set(pop_ccfs,'Value',1);
					pause(1)
					dw1ddisp('apply',win_dw1d,win_mopt);
				end

		    case 6
				%--------------------------------------------
				% Show and Scroll mode (app5+sig+cfs ).
				%     coloration : init + all levels + abs
				%--------------------------------------------
				if idxPREV>idxSlide
					makeWinOpt(figHandle,win_dw1d);
					return;
				end
				win_mopt_Params = wtbxappdata('get',figHandle,'win_mopt_Params');
				[win_mopt,chk_det_on,chk_cfs_on,pop_ccfs] = deal(win_mopt_Params{:});
				figure(win_mopt);
				pause(1)
				set(pop_ccfs,'Value',3);
				pause(1)
				dw1ddisp('apply',win_dw1d,win_mopt);

		    case 7
				%-----------------------------------
				% Close More Display Option window.
				% And message for Histograms.
				%-----------------------------------
				if idxPREV<idxSlide
					win_mopt_Params = wtbxappdata('get',figHandle,'win_mopt_Params');
					win_mopt = win_mopt_Params{1};
					dw1ddisp('close',win_dw1d,win_mopt);
					wtbxappdata('del',figHandle,'win_mopt_Params');
					wenamngr('Inactive',win_dw1d);
				else
					win_hist_Params = wtbxappdata('get',figHandle,'win_hist_Params');
					win_hist = win_hist_Params{1};
					dw1dhist('close',win_hist);
					delete(win_hist)
					wtbxappdata('del',figHandle,'win_hist_Params');
				end

			case 8
				%--------------------------------------------------
				% Histograms window - all the detail coefficients.
				% And first message for De-noising.
				%--------------------------------------------------
				win_hist      = dw1dmngr('hist',win_dw1d);
				wenamngr('Inactive',win_hist);
				tag_det_sig   = 'Det_sig';
				tag_det_all   = 'Det_All';
				tag_sel_cfs   = 'Sel_Cfs';
				tag_show_hist = 'Show_Hist';
				uic_win_hist  = findobj(win_hist,'Type','uicontrol');
				chk_win_hist  = findobj(uic_win_hist,'Style','checkbox');
				pus_win_hist  = findobj(uic_win_hist,'Style','pushbutton');
				chk_det_sig   = findobj(chk_win_hist,'tag',tag_det_sig);
				pus_det_all   = findobj(pus_win_hist,'tag',tag_det_all);
				rad_sel_cfs   = findobj(uic_win_hist,'Style','radiobutton','tag',tag_sel_cfs);
				pus_show_hist = findobj(pus_win_hist,'tag',tag_show_hist);
				win_hist_Params = {win_hist,chk_det_sig,pus_det_all,rad_sel_cfs,pus_show_hist};
				wtbxappdata('set',figHandle,'win_hist_Params',win_hist_Params);
				%--------------------------------------------------
				set(chk_det_sig,'value',1)      
				eval(get(chk_det_sig,'Callback')); pause(1)
				eval(get(pus_det_all,'Callback')); pause(1)
				eval(get(rad_sel_cfs,'Callback')); pause(1)
				eval(get(pus_show_hist,'Callback'));
				wenamngr('Inactive',win_hist);
				
		    case 9
				if idxPREV<idxSlide
					%------------------------------------
					% Close Histograms window.
					% And first message for Compression.
					%------------------------------------
					deleteSubFig(figHandle,'win_hist_Params');
					wenamngr('Inactive',win_dw1d);
				else
					deleteSubFig(figHandle,'win_comp_Params');
				end

		    case 10
				if idxPREV>idxSlide
					deleteSubFig(figHandle,'win_comp_Params');
					deleteSubFig(figHandle,'win_deno_Params');
				end

				%----------------------------------------
				% Compression: Initialization of  window.
				%----------------------------------------
				win_comp = dw1dmngr('comp',win_dw1d);
				wenamngr('Inactive',win_comp);
				% UTTHRGBL handlesUIC (Compression).
				%---------------------------------------
				% ud.handlesUIC = ...
				%   [fra_utl;txt_top;pop_met;...
				%    txt_sel;sli_sel;edi_sel; ...
				%    txt_nor;edi_nor;txt_npc;...
				%    txt_zer;edi_zer;txt_zpc;...
				%    tog_res;pus_est];
				%---------------------------------------
				% Memory of stored values (Compression).
				%---------------------------------------
				n_misc_comp = ['MB1_dw1dcomp'];
				ind_status  = 2;
				ind_pop_mod = 8;
				pop_mod    = wmemtool('rmb',win_comp,n_misc_comp,ind_pop_mod);
				handlesUIC = utthrgbl('handlesUIC',win_comp);
				edi_zer    = handlesUIC(11);
				win_comp_Params = {win_comp,pop_mod,edi_zer,n_misc_comp,ind_status};
				wtbxappdata('set',figHandle,'win_comp_Params',win_comp_Params);
				%--------------------------------------------------
				
			case 11
				%----------------------------------------------------
				% Compression: Global mode.
				% After compression with the default threshold value.
				%----------------------------------------------------
				win_comp_Params = wtbxappdata('get',figHandle,'win_comp_Params');
				win_comp = win_comp_Params{1};
				dw1dcomp('compress',win_comp,win_dw1d);
				wenamngr('Inactive',win_comp);
				
			case 12
				%--------------------------------------
				% Compression: change the zeros value.
				%--------------------------------------
				win_comp_Params = wtbxappdata('get',figHandle,'win_comp_Params');
				[win_comp,pop_mod,edi_zer,n_misc_comp,ind_status] = deal(win_comp_Params{:});
				set(edi_zer,'String',num2str(96.4));
				eval(get(edi_zer,'Callback'));
				dw1dcomp('compress',win_comp,win_dw1d);
				wenamngr('Inactive',win_comp);
				
			case 13
				%----------------------------------------------------
				% Compression: By Level mode.
				%----------------------------------------------------
				win_comp_Params = wtbxappdata('get',figHandle,'win_comp_Params');
				[win_comp,pop_mod,edi_zer,n_misc_comp,ind_status] = deal(win_comp_Params{:});
				set(pop_mod,'Value',2)
				eval(get(pop_mod,'Callback'))
				wenamngr('Inactive',win_comp);
				
			case 14
				%-----------------------------------------------------
				% Compression: By Level mode.
				% After compression with the default threshold values.
				%-----------------------------------------------------
				win_comp_Params = wtbxappdata('get',figHandle,'win_comp_Params');
				win_comp = win_comp_Params{1};
				dw1dcomp('compress',win_comp,win_dw1d);
				wenamngr('Inactive',win_comp);
				
		    case 15
				%----------------------------
				% Close Compression window.
				% And message for De-noising.
				%----------------------------
				deleteSubFig(figHandle,'win_comp_Params');
				wenamngr('Inactive',win_dw1d);
			  
		    case 16
				if idxPREV>idxSlide
					deleteSubFig(figHandle,'win_deno_Params');
					lin_handles = findobj(win_dw1d,'type','line');
					try
						lin(1) = findobj(lin_handles,'tag','SSig_in_App');
						lin(2) = findobj(lin_handles,'tag','SSig_in_Det');
						delete(lin);
					end
				end
				
				%--------------------------------------------------
				% De-noising: 
				%   - Initialization of  window.
				%   - De-noising with the default threshold values,
				%     with Fixed form soft thresholding method.
				%--------------------------------------------------
				win_deno = dw1dmngr('deno',win_dw1d);
				wenamngr('Inactive',win_deno);
				% UTTHRW1D handlesUIC (De-noising).
				%-------------------------------------
				% ud.handlesUIC = ...
				%   [fra_utl;txt_top;pop_met; ...
				%    rad_sof;rad_har;txt_noi;pop_noi; ...
				%    txt_BMS;sli_BMS;txt_tit(1:4),...
				%    txt_nor;edi_nor;txt_npc; ...
				%    txt_zer;edi_zer;txt_zpc; ...
				%    tog_thr;tog_res;pus_est];
				%--------------------------------------------------
				handlesUIC = utthrw1d('handlesUIC',win_deno);
				pop_met    = handlesUIC(3);
				rad_har    = handlesUIC(5);
				win_deno_Params = {win_deno,pop_met,rad_har};
				wtbxappdata('set',figHandle,'win_deno_Params',win_deno_Params);
				%--------------------------------------------------
				pause(1)
				dw1ddeno('denoise',win_deno,win_dw1d);
				wenamngr('Inactive',win_deno);				
				
			case 17
				%--------------------------------------------------
				% De-noising: 
				%   - De-noising with the default threshold values.
				%     with Fixed form hard thresholding.
				%--------------------------------------------------
				win_deno_Params = wtbxappdata('get',figHandle,'win_deno_Params');
				[win_deno,pop_met,rad_har] = deal(win_deno_Params{:});
				if idxPREV>idxSlide
					set(pop_met,'Value',1)
					eval(get(pop_met,'Callback'))
				end
				set(rad_har,'Value',1)
				eval(get(rad_har,'Callback'))
				dw1ddeno('denoise',win_deno,win_dw1d);
				wenamngr('Inactive',win_deno);

			case 18
				% De-noising: 
				%   - Change the method of thresholding to:
				%     the Penalize medium thresholding method.
				%--------------------------------------------------
				win_deno_Params = wtbxappdata('get',figHandle,'win_deno_Params');
				[win_deno,pop_met,rad_har] = deal(win_deno_Params{:});
				set(pop_met,'Value',6)
				eval(get(pop_met,'Callback'))
				
			case 19
				if idxPREV<idxSlide
					% De-noising: 
					%   - De-noising with the default threshold values,
					%     with Penalize medium thresholding method.
					%--------------------------------------------------
					win_deno_Params = wtbxappdata('get',figHandle,'win_deno_Params');
					win_deno = win_deno_Params{1};
					dw1ddeno('denoise',win_deno,win_dw1d);
					wenamngr('Inactive',win_deno);
				else
					dmsgfun('close');
				end

			case 20 
				if idxPREV>idxSlide
					deleteSubFig(figHandle,'win_deno_Params');
					win_deno = dw1dmngr('deno',win_dw1d);
					wenamngr('Inactive',win_deno);
					handlesUIC = utthrw1d('handlesUIC',win_deno);
					pop_met    = handlesUIC(3);
					rad_har    = handlesUIC(5);
					win_deno_Params = {win_deno,pop_met,rad_har};
					wtbxappdata('set',figHandle,'win_deno_Params',win_deno_Params);
					set(pop_met,'Value',6)
					eval(get(pop_met,'Callback'))
					dw1ddeno('denoise',win_deno,win_dw1d);
					wenamngr('Inactive',win_deno);
				else
					% DISPLAY MESSAGE ONLY!
				end

			case 21
				%-------------------------------
				% Close De-noising window
				% and update synthesized signal.
				%-------------------------------
				win_deno_Params = wtbxappdata('get',figHandle,'win_deno_Params');
				win_deno = win_deno_Params{1};
				% MemBloc1 of stored values.
				%---------------------------
				n_param_anal  = 'DWAn1d_Par_Anal';
				ind_ssig_type = 7;
				wwaiting('msg',win_deno,'Wait ... computing');
				lin_den = utthrw1d('get',win_deno,'handleTHR');
				wmemtool('wmb',win_dw1d,n_param_anal,ind_ssig_type,'ds');
				dw1dmngr('return_deno',win_dw1d,1,lin_den);
				wenamngr('Inactive',win_dw1d);
				wwaiting('off',win_deno);
				delete(win_deno)
				dmsgfun('close');
				
			case 22
				if idxPREV<idxSlide
					%----------------------------------------
					% More Display Option window parameters.
					%----------------------------------------
					win_mopt_Params = makeWinOpt(figHandle,win_dw1d);
					win_mopt = win_mopt_Params{1};
					wenamngr('Inactive',win_mopt);
					%-----------------------------------------
				else
					win_mopt_Params = wtbxappdata('get',figHandle,'win_mopt_Params');
					[win_mopt,chk_det_on,chk_cfs_on,pop_ccfs] = deal(win_mopt_Params{:});
					set(chk_cfs_on,'Value',1);
					dw1ddisp('apply',win_dw1d,win_mopt);
				end

		    case 23
				if idxPREV<idxSlide
					win_mopt_Params = wtbxappdata('get',figHandle,'win_mopt_Params');
				else
					win_mopt_Params = makeWinOpt(figHandle,win_dw1d);
				end
				[win_mopt,chk_det_on,chk_cfs_on,pop_ccfs] = deal(win_mopt_Params{:});
				set(chk_cfs_on,'Value',0);
				pause(1)
				dw1ddisp('apply',win_dw1d,win_mopt);

			case 24
				%-----------------------------------
				% Close More Display Option window.
				%-----------------------------------
				deleteSubFig(figHandle,'win_mopt_Params');
		  end
		  [msg,ok] = get_Message(idxSlide);
		  if ok , wshowdrv('#disp_msg',figHandle,msg,'step',win_dw1d); end
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
	  [mfilename ,'(''slidePROC'',figHandle,',int2str(idx),');']};

  %========== Slide 2 to Slide 24 ==========
  for idx = 2:24
    slide(idx).code = {[mfilename ,'(''slidePROC'',figHandle,',int2str(idx),');']};
  end

  %========== Set "previous" slide indices ==========
  
  % Compression slides.
  %--------------------
  slide(12).idxPrev = 10;
  slide(13).idxPrev = 10;
  slide(14).idxPrev = 10;
  slide(15).idxPrev = 10;
  
  % De-noising slides.
  %-------------------
  slide(16).idxPrev = 10;
  slide(21).idxPrev = 20;
  slide(22).idxPrev = 20;
  %===================================================

  varargout{1} = slide;
  
end


%------------------------------------------------------------------------------------------%
function deleteSubFig(figHandle,win_Params_Name)

win_Params = wtbxappdata('get',figHandle,win_Params_Name);
if ~isempty(win_Params)
	win = win_Params{1};
	if ishandle(win) , delete(win); end
	wtbxappdata('del',figHandle,win_Params_Name);
end
%------------------------------------------------------------------------------------------%
function win_mopt_Params = makeWinOpt(figHandle,win_dw1d)

win_mopt = dw1ddisp('create',win_dw1d);
wenamngr('Inactive',win_mopt);
tag_cfs_on   = 'Chk_Cfs';
tag_det_on   = 'Chk_Det';
tag_pop_ccfs = 'Pop_CCfs';
uic_win_mopt = findobj(win_mopt,'Type','uicontrol');
chk_det_on   = findobj(uic_win_mopt,'Tag',tag_det_on);
chk_cfs_on   = findobj(uic_win_mopt,'Tag',tag_cfs_on);
pop_ccfs     = findobj(uic_win_mopt,'Tag',tag_pop_ccfs);
win_mopt_Params = {win_mopt,chk_det_on,chk_cfs_on,pop_ccfs};
wtbxappdata('set',figHandle,'win_mopt_Params',win_mopt_Params);
%------------------------------------------------------------------------------------------%
function [msg,ok_msg] = get_Message(idxSlide)

ok_msg = 1;
switch idxSlide
case 2
	str1 = 'This demo shows the 1-D wavelet capabilities of the ';
	str2 = 'Wavelet GUI tools. The scenario supposes that we want to';
	str3 = 'de-noise or compress a 1-D signal. In this example, we ';
	str4 = 'decompose a simple synthetic noisy Doppler signal using ';
	str5 = 'the Symlet 4 wavelet (sym4) into five levels.';
	msg  = strvcat(str1,str2,str3,str4,str5);
	
case 3
	str1 = 'The full decomposition appears, with the signal denoted s at the top.';
	str2 = 'This signal is equal to the sum of the coarsest approximation (a5)';
	str3 = 'and the details at levels 1 to 5 (d1 ... d5).';
	str4 = 'i.e.,  s = a5 + d5 + d4 + d3 + d2 + d1';
	str5 = 'Since sym4 is an orthogonal wavelet, the decomposition is orthogonal.';
	msg  = strvcat(str1,str2,str3,str4,str5,'$');
	
	str1 = 'How do we select the wavelet and decomposition level?';
	msg  = strvcat(msg,str1,'$');
	
	str1 = 'For de-noising or compression, both the decomposition level and ';
	str2 = 'wavelet are useful tuning parameters.';
	str3 = 'Recall that the de-noised or compressed signal is equal to';
	str4 = 'the coarsest approximation + some signal reconstructed using the ';
	str5 = 'thresholded detail coefficients.';
	msg  = strvcat(msg,str1,str2,str3,str4,str5,'$');
	
	str1 = 'Often the wavelet choice is not crucial, and any "short" wavelet';
	str2 = 'except Haar is a good starting point.';
	msg  = strvcat(msg,str1,str2,'$');
	
	str1 = 'Having selected a wavelet, the decomposition level needs to be selected.';
	str2 = 'To study this, let us change to the Separate display mode.';
	msg  = strvcat(msg,str1,str2);
	
case 4
	str1 = 'As a rule of thumb, we can select the decomposition level in such';
	str2 = 'a way that the corresponding approximation is noise free. In this';
	str3 = 'example 4 or 5 are good candidates, since the approximations at levels';
	str4 = '1 to 3 are clearly noisy. In addition, the detail d5 contains';
	str5 = 'significant noise as it can be seen inspecting the second half of the';
	str6 = 'detail, so 5 should be a good value for the decomposition level.';
	msg  = strvcat(str1,str2,str3,str4,str5,str6,'$');
	
	str1 = 'The Wavelet GUI provides a flexible and configurable interface.';
	msg  = strvcat(msg,str1,'$');
	
	str1 = 'In the current view, one can see the wavelet coefficients, cfs. We';
	str2 = 'focus on the coefficients, selecting Show and Scroll display mode,';
	str3 = 'selecting the approximation at level 5 and using the More Display';
	str4 = 'Options and removing the Detail Axes.';
	msg  = strvcat(msg,str1,str2,str3,str4);
	
case 6
	str1 = 'The time-scale pattern shows that the';
	str2 = 'deterministic part of the signal is concentrated in a few big coefficients,';
	str3 = 'and noise corrupts all the time-scale representation.';
	str4 = 'To reinforce this, use the coloration  mode init + all levels + abs';
	str5 = 'in order to rescale globally the absolute coefficients.';
	msg  = strvcat(str1,str2,str3,str4,str5);
	
case 7
	str1 = 'Clicking on the Histograms button and selecting all the detail coefficients,';
	str2 = 'we can see that the detail coefficients are approximately Gaussian N(0,1)';
	str3 = 'except for extreme values outside the interval [-4 4] which are';
	str4 = 'linked to the decomposition of the deterministic part of the signal.';
	msg  = strvcat(str1,str2,str3,str4);
	
case 8
	str1 = 'The de-noising or compression procedure acts on these coefficients killing';
	str2 = 'the lowest coefficients in absolute value terms and keeping large values.';
	msg  = strvcat(str1,str2);
	
case 9
	str1 = 'Compression.';
	str2 = '------------';
	str3 = 'We press the Compress button, and the compression window appears.';
	str4 = 'This allows the user to select the threshold value with respect to';
	str5 = 'two design parameters:';
	msg  = strvcat(str1,str2,str3,str4,str5);
	
case 10
	str1 = '- the retained energy in percent which is equal to 100 times';
	str2 = 'the square norm of the compressed signal over the square norm of the';
	str3 = 'original signal (magenta line on the left);';
	msg  = strvcat(str1,str2,str3,'$');
	str4 = '- the number of zeros in percent which is equal to the percentage of zeros of';
	str5 = 'the wavelet representation of the compressed signal (blue line on the left).';
	str6 = 'The threshold default value given by the toolbox in the 1-D case is the one';
	str7 = 'for which the two previously defined design parameters are approximately the';
	str8 = 'same.';
	msg  = strvcat(msg,str4,str5,str6,str7,str8,'$');
	str1 = 'Then compression using the threshold default value leads a smoothed signal,';
	str2 = 'and the explanation of how the compression works is clear from the';
	str3 = 'comparison of original and thresholded coefficients in the time-scale';
	str4 = 'representations.';
	msg  = strvcat(msg,str1,str2,str3,str4);
	
case 12
	str1 = 'You can then iterate choosing the threshold value or the retained energy';
	str2 = 'or the number of zeros. A modification of each of the three parameters';
	str3 = 'automatically updates the other two.';
	msg  = strvcat(str1,str2,str3);
	
case 13
	str1 = 'To learn more about the compression procedure we select';
	str2 = 'the By-Level thresholding mode.';
	str3 = 'The detail coefficients are thresholded according to the thresholds represented';
	str4 = 'by the yellow lines on the left. With respect to the previous mode, this one';
	str5 = 'allows level-dependent threshold values leading to additional flexibility.';
	str6 = 'The resulting compressed signal can be found in the following figure.';
	msg  = strvcat(str1,str2,str3,str4,str5,str6);
	
case 15
	str1 = 'De-noising.';
	str2 = '-----------';
	str3 = 'The design objective is to recover the signal or to remove noise,';
	str4 = 'without reference to an original interesting signal which is supposed to be';
	str5 = 'unknown. It is assumed that additive noise corrupts the signal to be';
	str6 = 'recovered, and is supposed to be stationary (at least at each scale).';
	msg  = strvcat(str1,str2,str3,str4,str5,str6,'$');
	
	str1 = 'The main ideas for de-noising and for compression are the same. The differences';
	str2 = 'are located at two points:';
	str3 = '- soft thresholding (shrinkage) is often used instead of the more crude';
	str4 = 'hard thresholding.';
	str5 = '- the noise structure (scaled or unscaled white noise, coloured noise) is of';
	str6 = 'interest.';
	msg  = strvcat(msg,str1,str2,str3,str4,str5,str6,'$');
	
	str1 = 'The GUI tools for de-noising are similar to the Compression tools. ';
	str2 = ' ';
	str3 = 'When you push on De-noise, the de-noising window appears,';
	str4 = 'we apply the default selection.';
	msg  = strvcat(msg,str1,str2,str3,str4);

case 16
	str1 = 'As can be seen, the procedure keeps roughly the highest coefficients.';
	str2 = 'Then using the same default, we can show the differences between';
	str3 = 'soft and hard thresholding.';
	msg  = strvcat(str1,str2,str3);
	ok_msg = 1;

case 177
	str1 = ' ';
	str2 = ' ';
	msg  = strvcat(str1,str2);

case 20
	str1 = 'Now we close the de-noising window, update the de-noised signal and compare';
	str2 = 'the two signals in full size.';
	msg  = strvcat(str1,str2);

otherwise
	msg = '';
	ok_msg = 0;
end
%------------------------------------------------------------------------------------------%
