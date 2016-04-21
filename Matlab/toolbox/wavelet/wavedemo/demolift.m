function varargout = demolift(varargin)
%DEMOLIFT Demonstrates Lifting functions in the Wavelet Toolbox.  
%
% This is a slideshow file for use with wshowdrv.m
% To see it run, type 'wshowdrv demolift', 

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 10-Dec-2002.
%   Last Revision: 04-Sep-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:39:08 $

% Initialization and Local functions if necessary.
if nargin>0
	action = varargin{1};
    switch action
        case 'addHelp'
            % Add Help Item.
            %---------------
            hdlFig = varargin{2};
            wfighelp('addHelpItem',hdlFig,'Wavelet Decomposition','DW1D_DECOMPOS');
            
        case 'auto'    , wshowdrv('#autoMode',mfilename,'close');
        case 'gr_auto' , wshowdrv('#gr_autoMode',mfilename,'close');
        case 'getFigParam'
            figName  = 'Lifting';
            showType = 'mix10';
            varargout = {figName,showType};
            
        case 'initShowViewer'
            figHandle = varargin{2};
            slideData = get(figHandle,'Userdata');
            autoHndl = slideData.autoHndl;
            propAuto = get(autoHndl,{'Units','Position','BackGroundColor'});
            txtBkColor = get(slideData.slitxtHndl,'BackGroundColor');
            pos  = propAuto{2};
            hBtn = pos(4);
            pos(2) = pos(2)-2*hBtn;
            popstr = strvcat('db1','db2');
            txtstr = 'Wavelet';
            propUIC = {'Units',propAuto{1},'Position',pos,'BackGroundColor',txtBkColor};
            slideData.txtLocHandle = uicontrol('Parent',figHandle,...
                'style','text','String',txtstr,propUIC{:});
            pos(2) = pos(2)-hBtn+hBtn/2;
            propUIC = {'Units',propAuto{1},'Position',pos,'BackGroundColor',propAuto{3}};
            propAuto{2} = pos;
            propUIC{4}  = propAuto{2};		
            slideData.popLocHandle = uicontrol('Parent',figHandle,...
                'style','popupmenu','String',popstr,propUIC{:}, ...
                'Tag','popWAV','Enable','Off');

            pos(2) = pos(2)-hBtn;
            popstr = strvcat('blocks','bumps','heavy sine','doppler','quadchirp','mishmash');
            txtstr = 'Signal';
            propUIC = {'Units',propAuto{1},'Position',pos,'BackGroundColor',txtBkColor};
            slideData.txtLocHandle(2) = uicontrol('Parent',figHandle,...
                'style','text','String',txtstr,propUIC{:});
            pos(2) = pos(2)-hBtn+hBtn/2;
            propUIC = {'Units',propAuto{1},'Position',pos,'BackGroundColor',propAuto{3}};
            propAuto{2} = pos;
            propUIC{4}  = propAuto{2};		
            slideData.popLocHandle(2) = uicontrol('Parent',figHandle,...
                'style','popupmenu','String',popstr,propUIC{:}, ...
                'Tag','popSIG','Enable','Off');
 
            pos(2) = pos(2)-hBtn;
            editstr = '';
            txtstr = 'Nb. Kept Cfs.';
            propUIC = {'Units',propAuto{1},'Position',pos,'BackGroundColor',txtBkColor};
            slideData.txtLocHandle(3) = uicontrol('Parent',figHandle,...
                'style','text','String',txtstr,propUIC{:});
            pos(2) = pos(2)-hBtn+hBtn/2;
            propUIC = {'Units',propAuto{1},'Position',pos,'BackGroundColor',propAuto{3}};
            pos(4) = pos(4)/2;
            pos(2) = pos(2)+hBtn/2;
            propUIC{4}  = pos;
            edit_CB = ['demolift(''Local_FUN'',''edit_CB'');'];
            slideData.editLocHandle = uicontrol('Parent',figHandle,...
                'style','edit','String',editstr,propUIC{:},...
                'Tag','ediCFS','Enable','Off','Callback',edit_CB);
            
            set(figHandle,'Userdata',slideData);
 
        case 'Local_FUN'
            funNAME = varargin{2};
            nbOUT = nargout;
            varargout = cell(1,nbOUT);
            switch nbOUT
                case 0 , feval(funNAME,varargin{3:end});
                case 1 , varargout{1} = feval(funNAME,varargin{3:end});
                case 2 , [varargout{1},varargout{2}] = feval(funNAME,varargin{3:end});    
        end
	end
	return
end

if nargout<1,
  wshowdrv(mfilename)
else
  idx = 0;	
  
  %========== Slide 1 ==========
  idx = idx+1;
  slide(idx).code = {
	'figHandle = gcf;',
    'set(figHandle,''Position'',[240 100 752 612]);'
    'demolift(''Local_FUN'',''set_UI_Graphics'',-1); ',
	'' };

  slide(idx).text = {
	'',
	' Press the "Start" button to see a demonstration of Lifting tools.',
	'',
	'',
	' This demo uses Wavelet Toolbox functions.',
	''};

  %========== Slide 2 ==========
  idx = idx+1;
  slide(idx).code = {
	'popWAV = findall(figHandle,''style'',''popupmenu'',''tag'',''popWAV'');',
    'popSIG = findobj(figHandle,''style'',''popupmenu'',''Tag'',''popSIG'');',
	'ediCFS = findobj(figHandle,''style'',''edit'',''Tag'',''ediCFS''); drawnow',
	'set([popWAV,popSIG,ediCFS],''enable'',''Off''); ',
	'set(popWAV,''Value'',1, ''String'',strvcat(''db1'',''db2'')); ',
	'set(ediCFS,''String'',''''); ',
    
    'blanc = '' '';';  
    'S1  = ''LIFTING (1)'';',
    'S2  = ''-----------'';',
    'S3  = blanc;',
    'S4  = '' In the Wavelet Toolbox, the lifting functions are'';',
    'S5  = '' designed to implement the discrete wavelet transform'';',
    'S6  = '' and the inverse discrete wavelet transform using the'';',
    'S7  = '' "LIFTING SCHEME" tool (See W. SWELDENS).'';',
    'S8  = blanc;',
    'S9  = '' The main feature of the Lifting Scheme Tool is that all'';',
    'S10 = '' constructions are derived in the spatial domain. Staying in '';',
    'S11 = '' spatial domain leads to two major advantages:'';',
    'S12 = blanc;',    
    'S13 = ''     1) the machinery of Fourier analysis is not required'';',
    'S14 = ''     2) lifting leads to algorithms that can easily be  '';',
    'S15 = ''        generalized to more complex geometric situations.'';',
    'Infostr = strvcat(S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,S11,S12,S13,S14,S15);',

    'demolift(''Local_FUN'',''set_UI_Graphics'',0);',
    'hdl_UI_Graphics = wtbxappdata(''get'',figHandle,''hdl_UI_Graphics'');',
    'ax = hdl_UI_Graphics.ax ; t = hdl_UI_Graphics.t;',
    'set(t(1),''String'',Infostr,''FontName'',''Courier New'',''FontSize'',10);',
	'' };

  slide(idx).text = {
    ' ',    
    '   type: doc lifting',
    ' ',    
    '   or click on the "Info" button ',
    ' ',
    '   to see more information about lifting functions',
  ''};

  slide(idx).info = 'lifting';
  
  %========== Slide 3 ==========
  idx = idx+1;
  slide(idx).code = {
    'S1  = ''LIFTING (2)'';',
    'S2  = ''-----------'';',
    'S3  = blanc;',
    'S4  = '' To implement the discrete wavelet transform, the POLYPHASE'';',
    'S5  = '' technique is used. So the Lifting Wavelet Transform (LWT) may be'';',
    'S6  = '' expressed with ELEMENTARY LIFTING STEPS.'';',
    'S7  = blanc;',
    'S8  = '' There are two types of elementary lifting steps:'';',
    'S9  = ''     "primal" lifting and "dual" lifting'';',
    'S10 = blanc;',
    'S11 = '' This implementation leads to three major advantages: '';',
    'S12 = blanc;',
    'S13 = ''     1) the traditional "well known" wavelets used in the DWT '';',
    'S14 = ''        transform may have one or more "lifted" decompositions'';'
    'S15 = ''     2) the inverse discrete wavelet transform is very easily'';',
    'S16 = ''        computed'';',    
    'S17 = ''     3) "generalized" wavelets can be easily constructed.'';',
    
    'Infostr = strvcat(S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,S11,S12,S13,S14,S15,S16,S17);',
    'set(t(1),''String'',Infostr,''FontName'',''Courier New'',''FontSize'',10);',
	'' };

  slide(idx).text = {
    ' ',    
    '   type: doc lifting',
    ' ',    
    '   or click on the "Info" button ',
    ' ',
    '   to see more information about lifting functions',
  ''};

  slide(idx).info = 'lifting';
  
  %========== Slide 4 ==========
  idx = idx+1;
  slide(idx).code = {
    'S1  = ''LIFTING (3)'';',
    'S2  = ''-----------'';',
    'S3  = blanc;',
    'S4  = '' Each elementary lifting step is defined by:'';',
    'S5  = ''     - a TYPE : "primal" (p) or "dual" (d)'';',
    'S6  = ''     - a LAURENT POLYNOMIAL P(z) which defines the coefficients'';',
    'S7  = ''       of the filter associated to the lifting step'';',
    'S8  = blanc;',
    'S9  = '' A LIFTING SCHEME (LS) is a set of elementary lifting steps'';',
    'S10 = '' completed by an information about normalization coefficients.'';',
    'S11 = '' (see W. SWELDENS papers for more information about theory)'';',
    'S12  = blanc;',
    'S13 = '' Example 1: lifting decomposition of DWT for the db1 wavelet '';',
    'bcar = '' '';',
    'LS = liftwave(''db1'');',
    'TMP = displs(LS,''%8.4f''); nbROW = size(TMP,1);',
    'S14 = [bcar(ones(nbROW,12)),TMP];',
    'S15  = blanc;',
    'S16 = '' See next slide for comments ...'';',    
    'Infostr = strvcat(S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,S11,S12,S13,blanc,S14,S15,S16);',
    
    'set(t(1),''String'',Infostr,''FontName'',''Courier New'',''FontSize'',10);',
	'' };

  slide(idx).text = {
    ' ',    
    '   type: doc lifting',
    ' ',    
    '   or click on the "Info" button ',
    ' ',
    '   to see more information about lifting functions',
  ''};

  slide(idx).info = 'lifting';
 
  %========== Slide 5 ==========
  idx = idx+1;
  slide(idx).code = {
    'S1  = ''LIFTING (3) - continu '';',
    'S2  = ''----------------------'';',
    'S3  = blanc;',
    'S4  = '' Example 2: lifting decomposition of DWT for the wavelet db2'';',
    'bcar = '' '';',
    'LSdb2 = liftwave(''db2'');',
    'PStr = disp(lp(LSdb2{2,2},LSdb2{2,3}));',
    'PStr = demolift(''Local_FUN'',''wlift_str_util'',''replace'',PStr);',
    'TMP = displs(LSdb2,''%8.4f''); nbROW = size(TMP,1);',
    'S5  = [bcar(ones(nbROW,12)),TMP];',
    'S6  = '' The last line contains the normalization coefficients.'';', 
    'S7  = '' In the other lines:'';',
    'S8  = ''    - The third column contains the Laurent Polynomial'';', 
    'S9  = ''      maximal degree.'';', 
    'S10 = ''    - The second column contains the Laurent Polynomial'';',
    'S11 = ''      coefficients. For example in the second line: '';',
    'S12 = [''         P'', PStr ''  ''];',
    'Infostr = strvcat(S1,S2,S3,S4,blanc,S5,S6,S7,blanc,S8,S9,blanc,S10,S11,S12);',
    
    'set(t(1),''String'',Infostr,''FontName'',''Courier New'',''FontSize'',10);',
	'' };

  slide(idx).text = {
    ' ',    
    '   type: doc lifting',
    ' ',    
    '   or click on the "Info" button ',
    ' ',
    '   to see more information about lifting functions',
  ''};

  slide(idx).info = 'lifting';
 
  %========== Slide 6 ==========
  idx = idx+1;
  slide(idx).code = {
    'S1  = ''LIFTING (4)'';',
    'S2  = ''------------'';',
    'S4  = '' To implement LIFTING SCHEMES and POLYPHASE techniques'';',
    'S5  = '' the Wavelet Toobox needs two types of object:'';',
    'S7  = ''    - LP Object to manage Laurent Polynomials.'';',
    'S8  = ''    - LM Object to manage Laurent Matrices.'';',
    'S10 = '' The last one is used in particular for the Factorization'';',
    'S11 = '' Algorithm of "usual" wavelets.'';',
    'Infostr = strvcat(S1,S2,blanc,S4,S5,blanc,S7,blanc,S8,blanc,S10,S11);',
    
    'set(t(1),''String'',Infostr,''FontName'',''Courier New'',''FontSize'',10);',
	'' };

  slide(idx).text = {
    ' ',    
    '   type: doc lifting',
    ' ',    
    '   or click on the "Info" button ',
    ' ',
    '   to see more information about lifting functions',
  ''};

  slide(idx).info = 'lifting';
  
  %========== Slide 7 ==========
  idx = idx+1;
  slide(idx).code = {
    'S1  = ''LIFTING (5): lp OBJECT'';',
    'S2  = ''-------------------------'';',
    'HelpSTR = help(''lp'');',
    'HelpSTR = demolift(''Local_FUN'',''wlift_str_util'',''replacePOW'',HelpSTR);',
    'Infostr = strvcat(S1,S2,HelpSTR);',
    'set(t(1),''String'',Infostr,''FontName'',''Courier New'',''FontSize'',9);',
	'' };

  slide(idx).text = {
    ' ',    
    '   type: doc lp',
    ' ',    
    '   or click on the "Info" button ',
    ' ',
    '   to see more information about lp OBJECT',
  ''};

  slide(idx).info = 'lp'; 
  
  %========== Slide 8 ==========
  idx = idx+1;
  slide(idx).code = {
    'S1  = ''LIFTING (6): lm OBJECT'';',
    'S2  = ''-------------------------'';',
    'HelpSTR = help(''lm'');',
    'HelpSTR = demolift(''Local_FUN'',''wlift_str_util'',''replacePOW'',HelpSTR);',
    'Infostr = strvcat(S1,S2,HelpSTR);',
    'set(t(1),''String'',Infostr,''FontName'',''Courier New'',''FontSize'',10);',
	'' };

  slide(idx).text = {
    ' ',    
    '   type: doc lm',
    '   ',    
    '   or click on the "Info" button ',
    '   ',
    '   to see more information about lm OBJECT',
  ''};

  slide(idx).info = 'lm';
  
  %========== Slide 9 ==========
  idx = idx+1;
  slide(idx).code = {
 	'set(popWAV,''enable'',''off'');',
      
    'S1  = ''LIFTING (7): MAIN LIFTING FUNCTIONS'';',
    'S2  = ''-----------------------------------'';',
    'S3  = blanc;',
    
    'S4  = ''addlift   - Adding lifting and dual-lifting steps.'';', 
    'S5  = ''bswfun    - Biorthogonal scaling and wavelet functions.'';', 
    'S6  = ''displs    - Display lifting scheme.'';',
    'S7  = ''filt2ls   - Filters to lifting scheme.'';',
    'S8  = ''ilwt      - Wavelet reconstruction 1-D using lifting.'';',
    'S9  = ''ilwt2     - Wavelet reconstruction 2-D using lifting.'';',
    'S10 = ''liftfilt  - Apply elementary lifting steps on filters.'';', 
    'S11 = ''liftwave  - Lifting structure for wavelets.'';',
    'S12 = ''lsinfo    - Information about lifting schemes.'';',
    'S13 = ''lwt       - Wavelet decomposition 1-D using lifting.'';',
    'S14 = ''lwt2      - Wavelet decomposition 2-D using lifting.'';',
    'S15 = ''lwtcoef   - Extract or reconstruct 1-D wavelet coefficients.'';',
    'S16 = ''lwtcoef2  - Extract or reconstruct 2-D wavelet coefficients.'';',
    'S17 = ''wave2lp   - Laurent polynomial associated to a wavelet.'';',
    'S18 = ''wavenames - Wavelet names information.'';',
    'Infostr = strvcat(S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,S11,S12,S13,S14,S15,S16,S17,S18);',
    
    'set(t(1),''String'',Infostr,''FontName'',''Courier New'',''FontSize'',10);',
	'' };
    
  slide(idx).text = {
    ' ',    
    '   type: doc lifting',
    ' ',    
    '   or click on the "Info" button ',
    ' ',
    '   to see more information about lifting functions',
  ''};

  slide(idx).info = 'lifting';
  
  %========== Slide 10 ==========
  idx = idx+1;
  slide(idx).code = {
	'set(popWAV,''enable'',''On'');',
    
    'S1  = ''LIFTING (8): FILTERS and POLYNOMIALS ...'';',
    'S2  = ''----------------------------------------'';',
    'S3  = blanc;',
    'S4  = '' Choose the Wavelet (db1 or db2) with the popupMenu'';',
    'S5  = '' on the right part of the window.'';',
    
    'Infostr = strvcat(S1,S2,S3,S4,S5);',
    'set(t(1),''String'',Infostr);',
    'demolift(''Local_FUN'',''set_UI_Graphics'',0);', 
	'' };

  slide(idx).text = {
    ' ',    
    '   type: doc lifting',
    ' ',    
    '   or click on the "Info" button ',
    ' ',
    '   to see more information about lifting functions',
  ''};

  slide(idx).info = 'lifting';

  %========== Slide 11 ==========
  idx = idx+1;
  slide(idx).code = {
 	'set(popWAV,''enable'',''off'');',
	'lstWAV = get(popWAV,''String''); idxWAV = get(popWAV,''Value'');',
	'wname = deblankl(lstWAV(idxWAV,:));',
	'comma = char(39);',
	'newTXT = [''        wname = '',comma,wname,comma,'';''];';
	'wshowdrv(''#modify_Comment'',figHandle,3,newTXT);',
    'W = load(wname);',
    'F = sqrt(2)*W.(wname);',
    'FStr =  [ ''F = ['' num2str(F,4) '']'' ];',
    
    'S1  = ''LIFTING (9): FILTERS and POLYNOMIALS ...'';',
    'S2  = ''----------------------------------------'';',
    'S3  = blanc;',
    'S4  = FStr;',
    'Infostr = strvcat(S1,S2,S3,S4);', 
    
    'set(t(1),''String'',Infostr);',
    'demolift(''Local_FUN'',''set_UI_Graphics'',0);', 
	'' };

  slide(idx).text = {
	' % Load wavelet filter.',
	'',
	'        wname = ''db1'';',
	'        load(wname);',
	'',
	' % Compute the associated normalized filter F.',
    '',
    '        F = sqrt(2)*wname;',
	''};

  slide(idx).info = 'lifting';

  %========== Slide 12 ==========
  idx = idx+1;
  slide(idx).code = {
    'H = lp(F);',
    'HStr = disp(H);',
    'HStr = demolift(''Local_FUN'',''wlift_str_util'',''replace'',HStr);',

    'S1  = ''LIFTING (10): FILTERS and POLYNOMIALS ...'';',
    'S2  = ''-----------------------------------------'';',    
    'S3  = blanc;',
    'S4  = FStr;',
    'S5  = blanc;',
    'S6  = HStr;',
    'Infostr = strvcat(S1,S2,S3,S4,S5,S6);', 
    
	'set(t(1),''String'',Infostr);',
	'' };

  slide(idx).text = {
	' % Compute the associated reconstruction low-pass',
    ' % Laurent polynomial H.',
	'',
 	'        H = lp(F);',
	''};

  slide(idx).info = 'lp';
  
%   %========== Slide 13 ==========
  idx = idx+1;
  slide(idx).code = {
    'G = lp(1,-1)*modulate(reflect(H));',
    'GStr = disp(G);',
    'GStr = demolift(''Local_FUN'',''wlift_str_util'',''replace'',GStr);',
    
    'S1  = ''LIFTING (11): FILTERS and POLYNOMIALS ...'';',
    'S2  = ''-----------------------------------------'';',
    'S3  = blanc;',
    'S4  = FStr;',
    'S5  = HStr;',
    'S6  = blanc;',
    'S7  = GStr;',
    'Infostr = strvcat(S1,S2,S3,S4,S5,S6,S7);', 
    
	'set(t(1),''String'',Infostr);',
	'' };

  slide(idx).text = {
	' % Compute the associated reconstruction high-pass',
    ' % Laurent polynomial G.',
	'',
 	'        G = lp(1,-1)*modulate(reflect(H));',
	''};

  slide(idx).info = 'lp/modulate';
  
  %========== Slide 14 ==========
  idx = idx+1;
  slide(idx).code = {
    'E_H = even(H); H_EvenPart = disp(E_H);',
    'O_H = odd(H);  H_OddPart  = disp(O_H);',
    'H_EvenPart = demolift(''Local_FUN'',''wlift_str_util'',''replace'',H_EvenPart);',
    'H_OddPart  = demolift(''Local_FUN'',''wlift_str_util'',''replace'',H_OddPart);',
  
    'S1  = ''LIFTING (12): FILTERS and POLYNOMIALS ...'';',
    'S2  = ''-----------------------------------------'';',
    'S3  = blanc;',
    'S4  = FStr;',
    'S5  = HStr;',
    'S6  = GStr;',
    'S7  = blanc;',
    'S8  = H_EvenPart;',
    'S9  = H_OddPart;',
    'Infostr = strvcat(S1,S2,S3,S4,S5,S6,S7,S8,S9);', 
    
	'set(t(1),''String'',Infostr);',
	'' };

  slide(idx).text = {
	' % Compute the even and odd parts of H ...',
	'',
 	'        E_H = even(H);',
    '        O_H = odd(H); ',
	''};

  slide(idx).info = 'lp/even';

  %========== Slide 15 ==========
  idx = idx+1;
  slide(idx).code = {
    'E_G = even(G); G_EvenPart = disp(E_G);',
    'O_G = odd(G);  G_OddPart  = disp(O_G);',
    'G_EvenPart = demolift(''Local_FUN'',''wlift_str_util'',''replace'',G_EvenPart);',
    'G_OddPart  = demolift(''Local_FUN'',''wlift_str_util'',''replace'',G_OddPart);',
    
    'S1  = ''LIFTING (13): FILTERS and POLYNOMIALS ...'';',
    'S2  = ''-----------------------------------------'';',
    'S3  = blanc;',
    'S4  = FStr;',
    'S5  = HStr;',
    'S6  = GStr;',
    'S7  = blanc;',
    'tmpSTR_E = strvcat(H_EvenPart,G_EvenPart);',
    'tmpSTR_O = strvcat(H_OddPart,G_OddPart);',
    'tmpSTR_EO = [tmpSTR_E , bcar(ones(2,8)) , tmpSTR_O];';
    'Infostr = strvcat(S1,S2,S3,S4,S5,S6,S7,tmpSTR_EO);', 
    
	'set(t(1),''String'',Infostr);',
	'' };

  slide(idx).text = {
	' % Compute the even and odd parts of G ...',
	'',
 	'        E_G = even(G);',
    '        O_G = odd(G); ',
	''};

  slide(idx).info = 'lp/odd';

  %========== Slide 16 ==========
  idx = idx+1;
  slide(idx).code = {
    'S1  = ''LIFTING (14): FILTERS and POLYNOMIALS ...'';',
    'S2  = ''-----------------------------------------'';',
    'S3  = blanc;',
    'S4  = FStr;',
    'S5  = HStr;',
    'S6  = GStr;',
    'S7  = blanc;',
    'Infostr = strvcat(S1,S2,S3,S4,S5,S6,S7,tmpSTR_EO);', 
    
	'set(t(1),''String'',Infostr);',
	'' };

  slide(idx).text = {
	' % Now we have the even and odd parts of H and G.',
	' % So we can built the Polyphase Matrix.',
 	'',
 	'        |  E_H    E_G  | ',
    '        |  O_H    O_G  | ',
	''};

  slide(idx).info = 'lp/ppm';

  %========== Slide 17 ==========
  idx = idx+1;
  slide(idx).code = {
    'PolyMAT = ppm(H,G);',
    'M_dispSTR = disp(PolyMAT);',
    
    'S1  = ''LIFTING (15): POLYPHASE MATRIX ...'';',
    'S2  = ''----------------------------------'';',
    'S3  = blanc;',
    'S4  = M_dispSTR;',
    'if isequal(wname,''db2''),',
    '   S4  = demolift(''Local_FUN'',''wlift_str_util'',''replaceMAT'',S4);',
    'end',
    
    'Infostr = strvcat(S1,S2,S3,S4);', 
    
	'set(t(1),''String'',Infostr);',
	'' };

  slide(idx).text = {
	' % Compute the associated polyphase matrix: PolyMAT',
	'',
 	'        PolyMAT = ppm(H,G);',
	''};

  slide(idx).info = 'lp/ppm';

  %========== Slide 18 ==========
  idx = idx+1;
  slide(idx).code = {
    'MatFACT = ppmfact(H,G);',
    'DEC = MatFACT{1}; tmpSTR = [];',
    'for j = 1:length(DEC), ',
    '    tmp{j} = disp(DEC{j},''M''); tmp{j}(:,[1:4]) = '' '';',
    '    if isequal(wname,''db2'')',
    '        tmp{j}(2:3,:) = [];',
    '        tmp{j} = demolift(''Local_FUN'',''wlift_str_util'',''replaceMAT_2'',tmp{j});',    
    '    end',
    'end',
    'if isequal(wname,''db2'')',
    '   tmpSTR = strvcat([tmp{1},tmp{2}],'' '','' '',[tmp{3},tmp{4}]);',
    '   interSTR = ''none'';',    
    'else',
    '   for j = 1:length(DEC), tmpSTR = [tmpSTR , tmp{j}]; end',
    '   interSTR = ''tex'';',
    'end',
    
    'S1  = ''LIFTING (16): POLYPHASE MATRIX DECOMPOSITION'';',
    'S2  = ''--------------------------------------------'';',
    'S3  = blanc;',
    'S4  = '' The polyphase matrix may be decomposed in '';',
    'S5  = '' elementary lifting steps matrices:'';',
    'S6  = blanc;',
    'S7  = tmpSTR;',
    'S8  = blanc;',
    'S9  = '' The last matrix is devoted to a normalization operation.'';',
    
    'Infostr = strvcat(S1,S2,S3,S4,S5,S6,S7,S8,S9);', 
    
	'set(t(1),''Interpreter'',interSTR,''String'',Infostr);',
	'' };

  slide(idx).text = {
	' % Compute Matrix decomposition(s) ...',
	'',
 	'        MatFACT = ppmfact(H,G);',
	''};

  slide(idx).info = 'lp/ppmfact';

  %========== Slide 19 ==========
  idx = idx+1;
  slide(idx).code = {
    '[LS_d,LS_p] = pmf2ls(MatFACT,''t''); LSd = LS_d{1}; LSp = LS_p{1};',
    'LS_d_STR  = displs(LSd,''%8.4f'');',
    'bcar = '' '';',
    'nbROW = size(LS_d_STR,1);',
    'LS_d_STR = [bcar(ones(nbROW,4)),LS_d_STR];',
    'LS_p_STR  = displs(LSp,''%8.4f''); ',
    'bcar = '' '';',
    'nbROW = size(LS_p_STR,1);',
    'LS_p_STR = [bcar(ones(nbROW,4)),LS_p_STR];',
    
    'S1  = ''LIFTING (17): POLYPHASE MATRIX DECOMPOSITION'';',
    'S2  = ''--------------------------------------------'';',
    'S3  = blanc;',
    'S4  = ''Now we can build the Lifting Scheme(s) associated'';',
    'S5  = ''with the previous decomposition:'';',
    'S6  = blanc;',
    'S7  = LS_d_STR;',
    'S8  = ''  or '';',
    'S9  = blanc;',
    'S10  = LS_p_STR;',
    'Infostr = strvcat(S1,S2,S3,S4,S5,S6,S7,S8,S9,S10);', 
    
	'set(t(1),''Interpreter'',''tex'',''FontSize'',10,''String'',Infostr);',
	'' };

  slide(idx).text = {
	' % Computing and Viewing lifting schemes table ...',
	'',
 	'        [LS_d,LS_p] = pmf2ls(MatFACT,''t'');',
	''};

  slide(idx).info = 'pmf2ls';

  %========== Slide 20 ==========

  idx = idx+1;
  slide(idx).code = {
    'LS = liftwave(wname);',
    'LS_STR  = displs(LS,''%8.4f'');',
    'bcar = '' '';',
    'nbROW = size(LS_STR,1);',
    'LS_STR = [bcar(ones(nbROW,4)),LS_STR];',

    'S1  = ''LIFTING (18): LIFTING SCHEME'';',
    'S2  = ''----------------------------'';',
    'S3  = blanc;',
    'S4  = ''For "classical" wavelets we can obtain directly '';',
    'S5  = ''the associated Lifting Scheme using the LIFTWAVE function:'';',
    'S6  = blanc;',
    'S7  = ''   LS = liftwave(wname);'';',
    'S8  = blanc;',    
    'S9  = ''So we get:'';',
    'S10  = blanc;',
    'S11 = LS_STR;',
    
    'Infostr = strvcat(S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,S11);',
    
	'set(t(1),''FontSize'',10,''String'',Infostr);',
    'demolift(''Local_FUN'',''set_UI_Graphics'',0);',
    
	'' };

  slide(idx).text = {
	' % Compute the lifting scheme  ...',
	'',
 	'        ',
	''};

  slide(idx).info = 'liftwave';

  %========== Slide 21 ==========
  idx = idx+1;
  slide(idx).code = {
    'popstr = strvcat(''db1'',''db2'');',
    'set(popWAV,''String'',popstr,''Value'',idxWAV)',      
    'LS = liftwave(wname);',
    
    'demolift(''Local_FUN'',''set_UI_Graphics'',1);',
    'demolift(''Local_FUN'',''plot_phi_psi'',LS,ax);', 
	'' };

  slide(idx).text = {
	' % Viewing Scaling function and Wavelet ... ',
	'',
 	'        ',
	''};

  slide(idx).info = 'liftwave';
  
  %========== Slide 22 ==========
  idx = idx+1;
  slide(idx).code = {
    'liftSTEP = {''p'' , [-1 2 -1]/4 , [1] };',
    'LSnew_1 = addlift(LS,liftSTEP);',
    'LS_STR = displs(LSnew_1,''%8.4f'');',
    'bcar = '' '';',
    'nbROW = size(LS_STR,1);',
    'LS_STR = [bcar(ones(nbROW,4)),LS_STR];',
    
    'newWAV = [wname ''_LS1''];',
    'popstr = strvcat(''db1'',''db2'',newWAV);',
    'set(popWAV,''String'',popstr,''Value'',3)',
    
    'S1  = ''LIFTING (19): LIFTING SCHEME'';',
    'S2  = ''----------------------------'';',
    'S3  = blanc;',
    'S4  = ''Compute a new Lifting Scheme adding a new '';',
    'S5  = ''elementary lifting step:'';',
    'S6  = blanc;',
    'S7  = LS_STR(end-2,:);',
    'S8  = blanc;',    
    'S9  = ''So we get:'';',
    'S10 = blanc;',
    'S11 = LS_STR;',
    'S12 = blanc;',
    'S13 = ''Plot the new "Scaling function" and "Wavelet".'';', 
    'Infostr = strvcat(S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,S11,S12,S13);',
    
	'set(t(1),''FontSize'',10,''String'',Infostr);',
    'demolift(''Local_FUN'',''set_UI_Graphics'',0);', 
	'' };

  slide(idx).text = {
	' % Viewing a new Lifting Scheme ... ',
 	' ',
	' '};

  slide(idx).info = 'addlift';
  
  %========== Slide 23 ==========
  idx = idx+1;
  slide(idx).code = {
    'demolift(''Local_FUN'',''set_UI_Graphics'',1);', 
    'demolift(''Local_FUN'',''plot_phi_psi'',LSnew_1,ax);', 
	'' };

  slide(idx).text = {
	' % Viewing new Scaling function and new Wavelet ... ',
 	' ',
	' '};

  slide(idx).info = 'addlift';

  %========== Slide 24 ==========
  idx = idx+1;
  slide(idx).code = {
    'liftSTEP = { ''p'' , [3 2 1 7 -1 2 -1]/4  ,  [1] };',   
    'LSnew_2 = addlift(LS,liftSTEP);',
    'LS_STR = displs(LSnew_2,''%6.2f'');',
    'bcar = '' '';',
    'nbROW = size(LS_STR,1);',
    'LS_STR = [bcar(ones(nbROW,4)),LS_STR];',
    
    'Lift_1 = [wname ''_LS1'']; Lift_2 = [wname ''_LS2''];',
    'popstr = strvcat(''db1'',''db2'',Lift_1,Lift_2);',
    'set(popWAV,''String'',popstr,''Value'',4)',    
    
    'S1  = ''LIFTING (20): LIFTING SCHEME'';',
    'S2  = ''----------------------------'';',
    'S3  = blanc;',
    'S4  = ''Compute a new Lifting Scheme adding a new '';',
    'S5  = ''elementary lifting step:'';',
    'S6  = blanc;',
    'S7  = LS_STR(end-2,:);',
    'S8  = blanc;',    
    'S9  = ''So we get:'';',
    'S10 = blanc;',
    'S11 = LS_STR;',
    'S12 = blanc;',
    'S13 = ''Plot the new "Scaling function" and "Wavelet".'';', 
    'Infostr = strvcat(S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,S11,S12,S13);',
    
	'set(t(1),''FontSize'',10,''String'',Infostr);',
    'demolift(''Local_FUN'',''set_UI_Graphics'',0);', 
	'' };

  slide(idx).text = {
	' % Viewing a new Lifting Scheme ... ',
 	' ',
	' '};

  slide(idx).info = 'addlift';
  
  %========== Slide 25 ==========
  idx = idx+1;
  slide(idx).code = {
    'set([popWAV,popSIG],''Enable'',''Off'')',  
    
    'demolift(''Local_FUN'',''set_UI_Graphics'',1);', 
    'demolift(''Local_FUN'',''plot_phi_psi'',LSnew_2,ax);', 
	'' };

  slide(idx).text = {
	' % Viewing new "Scaling function" and new "Wavelet" ... ',
    ' ',    
 	'   This is not a wavelet in the usal sense since:'
    ' ',    
    '       mean(PSI) is not zero ! ',
    ' ',
	' '};

  slide(idx).info = 'addlift';
    
  %========== Slide 26 ==========
  idx = idx+1;
  slide(idx).code = {
    'set([popWAV,popSIG],''Enable'',''On'')',
    
    'S1  = ''LIFTING (21): ANALYSIS'';',
    'S2  = ''----------------------'';',
    'S3  = blanc;',
    'S4  = ''Choose the SIGNAL to analyze and the WAVELET using '';',
    'S5  = ''the popupmenus in the right part of the window.'';',
    'S6  = blanc;',
    'S7  = ''The LEVEL of decomposition is 5.'';',    
    'S8  = blanc;',
    'S9  = ''Then Press the "Next" button to perform the analysis.'';',
    'Infostr = strvcat(S1,S2,S3,S4,S5,S6,S7,S8,S9);',
    
	'set(t(1),''FontSize'',10,''String'',Infostr);',
    'demolift(''Local_FUN'',''set_UI_Graphics'',0);', 
	'' };

  slide(idx).text = {
	' % Analysis with a Lifting Scheme ... ',
 	' ',
	' '};

  slide(idx).info = 'addlift';
  
  %========== Slide 27 ==========
  idx = idx+1;
  slide(idx).code = {
    'set([popWAV,popSIG],''Enable'',''Off'')',
	'lstSIG = get(popSIG,''String''); idxSIG = get(popSIG,''Value'');',
	'sigNAM = deblankl(lstSIG(idxSIG,:));',
	'idxWAV = get(popWAV,''Value'');',
    'switch idxWAV ',
    '    case {1,2} , LSnew = LS;',
    '    case 3     , LSnew = LSnew_1;',
    '    case 4     , LSnew = LSnew_2;',
    'end', 
    'x  = wnoise(sigNAM,10); level = 5;',
	'lx = length(x);',
	'xDEC = lwt(x,LSnew,level);',
	'a = zeros(level,lx);',
	'd = zeros(level,lx);',
    'for k = 1:level',
       'a(k,:) = lwtcoef(''a'',xDEC,LSnew,level,k);',
       'd(k,:) = lwtcoef(''d'',xDEC,LSnew,level,k);' ,
    'end',
    'demolift(''Local_FUN'',''set_UI_Graphics'',2);',
    'demolift(''Local_FUN'',''plot_ANALYSIS'',x,a,d,1,ax(4:6));',
    'demolift(''Local_FUN'',''store_ANALYSIS'',x,xDEC,LSnew,level,ax(4:7),lx,''1D'');',
    
	'' };

  slide(idx).text = {
	' % Compute the decomposition at level 5.',
 	' ',
	'       xDEC = lwt(x,LSnew,level);',
	'       a = zeros(level,lx);',
	'       d = zeros(level,lx);',
    '       for k = 1:level',
    '           a(k,:) = lwtcoef(''a'',xDEC,LSnew,level,k);',
    '           d(k,:) = lwtcoef(''d'',xDEC,LSnew,level,k);' ,
    '       end',
  	' ',   
	' % And view the decomposition at level 1.',
 	' ',
	' '};

  slide(idx).info = 'lwtcoef';
  
  %========== Slide 28 ==========
  idx = idx+1;
  slide(idx).code = {
    'errorSTR = [];',
    'for k = 1:level,',
      'er = x-a(k,:);',
      'for j=1:k , er = er-d(j,:); end',
      'err(k) = max(abs(er));',
      'errLEV = [''    level:'' int2str(k) '' - error = '' num2str(err(k))];',
      'errorSTR = strvcat(errorSTR,errLEV);',
    'end',
    
	'wshowdrv(''#modify_Comment'',figHandle,9,errorSTR);',
	'set(popSIG,''enable'',''off'');',      
    'demolift(''Local_FUN'',''set_UI_Graphics'',3);',
    'demolift(''Local_FUN'',''plot_ANALYSIS'',x,a,d,2,ax(4:7));', 
	'' };

  slide(idx).text = {
	' % View the decomposition at level 2.',
 	' ',
 	' % S = A1 + D1 = A2 + D2 + D1 = A3 + D3 + D2 + D1 ...',
 	' ',
 	' % err_Level_1 = max( | S - A1 - D1 | )',
 	' % err_Level_2 = max( | S - A1 - D1 - D2 | )',
 	' % ...',
 	' ',
 	' ',    
	' '};

  slide(idx).info = 'lwtcoef';
  
  %========== Slide 29 ==========
  idx = idx+1;
  slide(idx).code = {
    'set(ediCFS,''String'','' '',''Enable'',''Off'');',      
	'wshowdrv(''#modify_Comment'',figHandle,3,errorSTR);',      
    'demolift(''Local_FUN'',''set_UI_Graphics'',4);', 
    'demolift(''Local_FUN'',''plot_ANALYSIS'',x,a,d,3,ax(4:8));',        
	'' };

  slide(idx).text = {
	' % View the decomposition at level 3.',
 	' ',
 	' ',    
	' '};

  slide(idx).info = 'addlift';
  
  %========== Slide 30 ==========
  idx = idx+1;
  slide(idx).code = {
	'keptCFSMAX = length(x);',
	'set(ediCFS,''String'',int2str(keptCFSMAX),''Enable'',''On'');',
    'demolift(''Local_FUN'',''set_UI_Graphics'',5);', 
    'demolift(''Local_FUN'',''plot_DECOMP'',x,xDEC,LSnew,level,ax(4:7),keptCFSMAX,''1D'');',
	'' };

  slide(idx).text = {
 	' ',      
	'   Choose the number of kept coefficients in the edit.',
    ' ',
 	'   Then:' , 
 	'              Press the "Enter" key to execute the edit button callback.' , 
 	'   Or:',    
 	'              Press the "Next" button.',
	' '};

  slide(idx).info = 'addlift';
  
  %========== Slide 31 ==========
  idx = idx+1;
  slide(idx).code = {
    'img = findall(ax(4:7),''type'',''image''); delete(img);',
    'keptDEF = 10;',
    'keptCFS = str2num(get(ediCFS,''String''));',
    ['if isempty(keptCFS) | keptCFS<0 | keptCFSMAX<keptCFS | keptCFS~=fix(keptCFS)' ...
           ' , keptCFS = keptDEF; end'],
	'set(ediCFS,''String'',int2str(keptCFS));',      
    'demolift(''Local_FUN'',''set_UI_Graphics'',5);', 
    'demolift(''Local_FUN'',''plot_DECOMP'',x,xDEC,LSnew,level,ax(4:7),keptCFS,''1D'');',
	'' };

  slide(idx).text = {
 	' ',
	'   Choose the number of kept coefficients in the edit then ',
 	'   Press the "Enter" key to execute the edit button callback.' , 
 	' ',    
 	'   Or',
 	' ',    
 	'   Press the "Prev" button.',
	'   Choose the number of kept coefficients in the edit.',
 	'   Then press the "Next" button.',
	' '};

  slide(idx).info = 'addlift';
  
  %========== Slide 32 ==========
  idx = idx+1;
  slide(idx).code = {
    'S1  = ''LIFTING (22): 2D ANALYSIS'';',
    'S2  = ''-------------------------'';',
    'S3  = blanc;',
    'S4  = ''  Like for one dimensional signal, you can perform '';',
    'S5  = ''  2D analysis using Lifting Tools.'';',
    'S6  = ''  Look at LWT2, ILWT2, LWTCOEF2 functions to get more information.'';',
    'S7  = blanc;',
    'S8  = ''  As an example:'';',  
    'S9  = ''      Load an image (woman)'';', 
    'S10 = ''      And perform a 2D wavelet analysis at level 8'';',  
    'S11 = ''      using the Haar wavelet.'';',  
    'S12 = blanc;',
    'S13 = '' '';',
    'Infostr = strvcat(S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,S11,S12,S13);',
    
	'set(t(1),''FontSize'',10,''String'',Infostr);',
    'demolift(''Local_FUN'',''set_UI_Graphics'',0);', 
	'' };

  slide(idx).text = {
	' % Compute the decomposition at level 8.',
 	' ',
    '       LSdb1 = liftwave(''db1''); level2D = 8;',
    '       St = load(''woman.mat'');',
	'       xDEC = lwt2(St.X,LSdb1,level2D);',
 	' ',    
	' % And then view the decomposition.',
 	' ',
	'      Choose the number of kept coefficients in the edit then ',
 	'      Press the "Enter" key to execute the edit button callback.' , 
 	' ',    
 	' ',
	' '};

  slide(idx).info = 'lwt2';

  %========== Slide 32 ==========
  idx = idx+1;
  slide(idx).code = {
    'lin = findall(ax(4:7),''type'',''line''); delete(lin);',
    'LSdb1 = liftwave(''db1''); level2D = 8;',
    'St = load(''woman.mat'');',
	'xDEC = lwt2(St.X,LS,level2D);',
	'keptCFSMAX = prod(size(St.X));',
	'set(ediCFS,''String'',int2str(keptCFSMAX),''Enable'',''On'');',
    'demolift(''Local_FUN'',''set_UI_Graphics'',6);', 
    'demolift(''Local_FUN'',''plot_DECOMP'',St.X,xDEC,LS,level2D,ax(4:7),keptCFSMAX,''2D'');',
	'' };

  slide(idx).text = {
 	' ',
	'      Choose the number of kept coefficients in the edit then ',
 	'      Press the "Enter" key to execute the edit button callback.' , 
 	' ',    
 	' ',
	' '};

  slide(idx).info = 'lwt2';
  
  %==============================

  
  varargout{1} = slide;
  
end

%--------------------------------------------------------------
function set_UI_Graphics(axMode)

hdl_UI_Graphics = wtbxappdata('get',gcf,'hdl_UI_Graphics');
if isempty(hdl_UI_Graphics)
    pos = [0.0200  0.3700  0.7700  0.6000 ;  ...
           0.0750  0.4327  0.2848  0.4973 ;  ...
           0.4652  0.4327  0.2848  0.4973 ;  ...
           0.1300  0.4527  0.7750  0.1297 ;  ...
           0.1300  0.2813  0.7750  0.1297 ;  ...
           0.1300  0.1100  0.7750  0.1297 ;  ...
           0.1300  0.6240  0.7750  0.1297 ;  ...
           0.1300  0.7953  0.7750  0.1297    ...
           ];
    ax(1) = axes('Position',pos(1,:), ...
        'Xtick',[],'Ytick',[],'Color',[1 1 1],'Box','On');
    rectangle('LineWidth',10,'EdgeColor',[1 0.75 0.75]);
    t(1) = text(0.04,0.95,' ', ...
        'Interpreter','tex','VerticalAlignment','top',...
        'Color',[0 0 0],'tag','LiftDEMO');
    for k = 2:size(pos,1)
        ax(k) = axes('Position',pos(k,:),'Visible','Off');
    end
    %-------------------------------------------------------
    hdl_UI_Graphics.mode = axMode; 
    hdl_UI_Graphics.ax = ax; 
    hdl_UI_Graphics.t  = t;
    wtbxappdata('set',gcf,'hdl_UI_Graphics',hdl_UI_Graphics);
else
    axModeOLD = hdl_UI_Graphics.mode;
    hdl_UI_Graphics.mode = axMode; 
    ax = hdl_UI_Graphics.ax;
    t  = hdl_UI_Graphics.t;
    pos = get(ax,'Position'); pos = cat(1,pos{:});
end

switch axMode
    case -1
        setPOS = [];
        vis ={'Off','Off','Off','Off','Off','Off','Off','Off'};
        
    case 0
        setPOS = [];
        vis ={'On','Off','Off','Off','Off','Off','Off','Off'};
        
    case 1
        setPOS = [];
        vis ={'Off','On','On','Off','Off','Off','Off','Off'};
        
    case 2
        setPOS = [4:6]; 
        pos(setPOS,:) = [...
                0.07  0.80  0.70  0.15
                0.07  0.60  0.70  0.15
                0.07  0.40  0.70  0.15
                ];
        vis ={'Off','Off','Off','On','On','On','Off','Off'}; 
        
    case 3
        setPOS = [4:7];         
        pos(setPOS,:) = [  ...
                0.07  0.85  0.70  0.11
                0.07  0.70  0.70  0.11
                0.07  0.55  0.70  0.11
                0.07  0.40  0.70  0.11
                ];
        vis ={'Off','Off','Off','On','On','On','On','Off'}; 
        
    case 4
        setPOS = [4:8];         
        pos(setPOS,:) = [  ...
                0.07  0.88  0.70  0.09
                0.07  0.76  0.70  0.09
                0.07  0.64  0.70  0.09
                0.07  0.52  0.70  0.09
                0.07  0.40  0.70  0.09
                ];
        vis ={'Off','Off','Off','On','On','On','On','On'}; 
        
    case {5,6}
        setPOS = [4:7];                 
        pos(setPOS,:) = [  ...
                0.06  0.72  0.30  0.23                 
                0.45  0.72  0.30  0.23
                0.06  0.41  0.30  0.23
                0.45  0.41  0.30  0.23
                ];
        vis ={'Off','Off','Off','On','On','On','On','Off'}; 
end

switch axMode
    case {2,3,4}
        hdl_DEN = findobj(ax(4),'type','line','Tag','denoSIG');
        if ~isempty(hdl_DEN), delete(hdl_DEN); end
    case 5 , set(ax(4),'Ydir','Normal');
    case 6 , set(ax(4),'Ydir','Reverse');
end

for j=1:length(setPOS)
    k = setPOS(j);
    set(ax(k),'Position',pos(k,:));
end
for k = 1:size(pos,1)
    set(findall(ax(k)),'Visible',vis{k});
end
%--------------------------------------------------------------
function plot_phi_psi(LS,ax)

N = 10;
phi = zeros(1,16); phi(9) = 1;
for k = 1:N , phi = dyadup(phi,0); phi = ilwt(phi,LS,1); end;
phi = (sqrt(2)^N)*phi;

psi = zeros(1,16); psi(8) = 1;
psi = ilwt(psi,LS,1);
for k = 1:N, psi = dyadup(psi,0); psi = ilwt(psi,LS,1); end;
psi = -(sqrt(2)^(N+1))*psi;

yLimPHI = [min(phi) max(phi)];
yLimPSI = [min(psi) max(psi)];

set(findall(ax),'Visible','Off')
set(ax(2:3),'Visible','On')
axes(ax(2)); plot(phi,'r','LineWidth',2); grid
set(ax(2),'Ylim',yLimPHI);
xlabel('Scaling Function');
axes(ax(3)); plot(psi,'g','LineWidth',2); grid
set(ax(3),'Ylim',yLimPSI);

xlabel('Wavelet');
set(ax(2:3),'Xlim',[1 length(psi)],'XtickLabel','')
%--------------------------------------------------------------
function plot_ANALYSIS(x,a,d,level,ax)

lx = length(x);
for k = 1:level
   axes(ax(1)) ; plot(x,'r') ; 
   title(''); yl = ylabel('S');
   p  = get(yl,'Position'); p(1) = -55;
   set(yl,'Rotation',0,'Position',p)
   set(ax(1),'Ylim',[min(x) max(x)]);

   axes(ax(2)) ; plot(a(k,:),'b') ; 
   yl = ylabel(['A' int2str(k)]);
   p  = get(yl,'Position'); p(1) = -55;
   set(yl,'Rotation',0,'Position',p)
   
   set(ax(2),'Ylim',[min(a(k,:)) max(a(k,:))]);
   for j =1:k
       idxAX = 3+k-j;
       axes(ax(idxAX)) ; plot(d(j,:),'g') ; 
       yl = ylabel(['D' int2str(j)]);
       p  = get(yl,'Position'); p(1) = -55;
       set(yl,'Rotation',0,'Position',p)
       set(ax(idxAX),'Ylim',[min(d(j,:)) max(d(j,:))]);
   end
   set(ax,'Xlim',[1 lx])

end
%--------------------------------------------------------------
function plot_DECOMP(x,xDEC,LS,level,ax,keptCFS,DIM)

switch DIM
    case '1D'
        NbMaxCFS = length(x);
        idxMIN = NbMaxCFS-keptCFS;
        T = sort(abs(xDEC(:)));
        
        xDEC_Thr = xDEC;
        if idxMIN>0 , thr = T(idxMIN); else , thr = 0; end 
        xDEC_Thr(abs(xDEC_Thr)<=thr) = 0;
        xREC = ilwt(xDEC_Thr,LS,level);
        
        yLX    = [min(x) max(x)];
        yLXREC = [min(xREC) max(xREC)];
        yLX_XREC = [min([yLX(1),yLXREC(1)]) , max([yLX(2),yLXREC(2)])];
        
        axes(ax(1)) ; plot(x,'r') ; title('Signal')
        hdl_DEN = findobj(ax(1),'type','line','Tag','denoSIG');
        if (idxMIN>0)
            if isempty(hdl_DEN)
                axes(ax(1)) ; hold on; hdl_DEN = plot(xREC,'y','Tag','denoSIG');
            else
                set(hdl_DEN,'Ydata',xREC);
            end
            set(ax(1),'Ylim',yLX_XREC);
        else
            delete(hdl_DEN)
            set(ax(1),'Ylim',yLX);
        end
        
        axes(ax(3)) ; plot(xDEC,'b')
        xlabel('Original Lifted Decomposition (in place)','Color','k')
        
        axes(ax(4)) ; plot(xDEC_Thr,'b')
        xlabel('Modified Lifted Decomposition (in place)','Color','k')
        
        axes(ax(2)) ;  plot(xREC,'y') ; set(ax(2),'Ylim',yLXREC);
        strTITLE = ['Nb. Cfs ==> total: ' int2str(NbMaxCFS) ...
                ' - kept: ' int2str(NbMaxCFS-idxMIN)];
        title(strTITLE,'Color','c');
        xlabel(['Threshold = ' , num2str(thr)],'Color','c')
        
        set(ax,'Xlim',[1,NbMaxCFS]);
        wtbxappdata('set',gcf,'analysis_PARAM_1D',{x,xDEC,LS,level,ax,keptCFS,DIM});        
        
    case '2D'
		LSType  = [];
		NBC = min(max(max(x)),256);
		NbMaxCFS = prod(size(x));
		idxMIN = NbMaxCFS-keptCFS;
		T = sort(abs(xDEC(:)));
		xDEC_Thr = xDEC;
		if idxMIN>0 , thr = T(idxMIN); else , thr = 0; end 
		xDEC_Thr(abs(xDEC_Thr)<=thr) = 0;
		xREC = ilwt2(xDEC_Thr,LS,level);
		
		set(gcf,'Colormap',pink(NBC));
		axes(ax(1)) ; image(x); title('Original Image')
        set(ax(1),'Xlim',[1,size(x,2)],'Ylim',[1,size(x,1)])
		axes(ax(3)); 
		if isempty(LSType) , image(abs(xDEC)); else , imagesc(abs(xDEC)); end
		xlabel('Original Lifted Decomposition (in place)','Color','k')
		axes(ax(4));
		if isempty(LSType) , image(abs(xDEC_Thr)); else , imagesc(abs(xDEC_Thr)); end
		xlabel('Modified Lifted Decomposition (in place)','Color','k')
		
		axes(ax(2)); image(xREC);
		strTITLE = ['Nb. Cfs ==> total: ' int2str(NbMaxCFS) ...
                    ' - kept: ' int2str(NbMaxCFS-idxMIN)];
		title(strTITLE,'Color','c');
		xlabel(['Threshold = ' , num2str(thr)],'Color','c')
        wtbxappdata('set',gcf,'analysis_PARAM_2D',{x,xDEC,LS,level,ax,keptCFS,DIM});        
end
wtbxappdata('set',gcf,'analysis_DIM',DIM);
%--------------------------------------------------------------
function store_ANALYSIS(x,xDEC,LSnew,level,ax,keptCFS,DIM)

switch DIM
    case '1D' , wtbxappdata('set',gcf,'analysis_PARAM_1D',{x,xDEC,LSnew,level,ax,keptCFS,DIM});
    case '2D' , wtbxappdata('set',gcf,'analysis_PARAM_1D',{x,xDEC,LSnew,level,ax,keptCFS,DIM});
end
wtbxappdata('set',gcf,'analysis_DIM',DIM);
%--------------------------------------------------------------
function edit_CB

DIM = wtbxappdata('get',gcf,'analysis_DIM');
switch DIM
    case '1D' , analysis_PARAM = wtbxappdata('get',gcf,'analysis_PARAM_1D');
    case '2D' , analysis_PARAM = wtbxappdata('get',gcf,'analysis_PARAM_2D');
end
keptCFS = str2num(get(gcbo,'String'));
if isempty(keptCFS)
    keptCFS = analysis_PARAM{end-1};
    set(gcbo,'String',int2str(keptCFS));
end
analysis_PARAM{end-1} = keptCFS;
demolift('Local_FUN','plot_DECOMP',analysis_PARAM{:});  
%--------------------------------------------------------------
function S = wlift_str_util(option,S)
%WLIFT_STR_UTIL String utilities for lifting demos. 
switch option
    case 'replace'
        idx = find(S=='('); S(idx(2:end)) = '{'; 
        idx = find(S==')'); S(idx(2:end)) = '}';
        idx = find(S=='*'); S(idx) = ' ';
    case 'replaceMAT'
        idx = find(S=='('); S(idx) = '{';
        idx = find(S==')'); S(idx) = '}';
        idx = find(S=='*'); S(idx) = ' ';
        idx = find(S=='|'); S(idx) = ' ';
    case 'replaceMAT_1'
        idx = find(S=='('); S(idx) = '{';
        idx = find(S==')'); S(idx) = '}';
        idx = find(S=='*'); S(idx) = ' ';
    case 'replaceMAT_2'
        idx = find(S=='('); S(idx) = '{';
        idx = find(S==')'); S(idx) = '}';
    case 'replacePOW'
        idx_1 = find(S=='^'); 
        idx_2 = find(S=='('); idx_3 = find(S==')'); 
        for k = 1:length(idx_1)
            j = idx_1(k);
            if isequal(S(j+1),'(')
                S(j+1) = '{';
                tmp = find(idx_3>j);
                jj = idx_3(tmp(1));
                S(jj) = '}';
            end
        end
        idx = find(S=='*'); S(idx) = ' ';
end
%--------------------------------------------------------------
