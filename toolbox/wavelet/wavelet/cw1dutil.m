function varargout = cw1dutil(option,fig,varargin)
%CW1DUTIL Continuous wavelet 1-D utilities.
%   VARARGOUT = CW1DUTIL(OPTION,FIG,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 01-Jun-1999.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.13 $

switch option
    case 'plotSignal'
      axe = varargin{1};
      sig = varargin{2};
      hdlAXES = varargin{3};
      %-----------------------
      color = wtbutils('colors','cw1d','sig');
      vis   = get(axe,'Visible');
      xValMin = 1;
      xValMax = length(sig);
      ymin = min(sig)-eps;
      ymax = max(sig)+eps;
      plot(sig,'Color',color,'Parent',axe);
      set(axe,'Xlim',[xValMin xValMax],'Ylim',[ymin ymax],...
              'XGrid','Off','YGrid','Off');
      strTitle = sprintf('Analyzed Signal  (length = %s)', int2str(xValMax));
      wtitle(strTitle,'Parent',axe,'Visible',vis);
      set(axe,'Visible',vis);        
      set(hdlAXES,'Xlim',[xValMin xValMax]);

    case 'plotCfsLine'
      axe   = varargin{1};
      coefs = varargin{2};
      strTitle = varargin{3};
      %--------------------
      color = wtbutils('colors','cw1d','lin');
      xlim  = get(axe,'xlim');
      vis   = get(axe,'Visible');
      plot(coefs,'Color',color,'Parent',axe,'Visible',vis);     
      wtitle(strTitle,'Parent',axe,'Visible',vis);
      set(axe,'Visible',vis,'Xlim',xlim,'Box','On');

    case 'plotChainLine'
      axe      = varargin{1};
      scales   = varargin{2};
      coefs    = varargin{3};
      strTitle = varargin{4};
      %----------------------- 
      fig = get(axe,'Parent');
      vis = get(axe,'Visible');
      [iRow,iCol] = find(coefs);
      if ~isempty(iRow)
          [nbRow,nbCol] = size(coefs);
          markersize = 2;
          marker     = 'o';
          linestyle  = 'none';
          color      = wtbutils('colors','cw1d','spy');
          x = [1:nbCol];
          xlim  = get(axe,'xlim');
          ylim = [min(scales) max(scales)]+sqrt(eps)*[-1 1];
          varargout{1} = ...
            plot(x(iCol),scales(iRow), ...
               'Visible',vis, ...
               'marker',marker, ...
               'markersize',markersize, ...
               'MarkerEdgeColor',color, ...
               'MarkerFaceColor',color, ...
               'linestyle',linestyle,   ...
               'color',color, ...
               'parent',axe   ...
               ); 
          step  = ceil(nbRow/20);
          ytics = scales(1:step:nbRow);
          ylabs = num2str(ytics(:));
          set(axe,...
              'Visible',vis, ...
              'xlim',xlim,'ylim',ylim,...
              'Box','On',...
              'ydir','normal','grid','none',...
              'YTick',ytics,'YTicklabel',ylabs,...
              'clipping','on'...
              );
      end
      wtitle(strTitle,'Parent',axe,'Visible',vis);

    case 'computeChainLine'
      scales = varargin{1};
      coefs  = varargin{2};
      indBeg = varargin{3};
      %--------------------
      [tmp,I1] = sort(scales);
      [tmp,I2] = sort(I1);
      coefs = coefs(I2,:);
      coefs = localmax(coefs,indBeg);
      varargout{1} = coefs(I1,:);
      varargout{2} = ['Local Maxima Lines'];

    case 'cfsLineTitle'
      toolATTR = wfigmngr('getValue',fig,'ToolSettings');
      toolMode = toolATTR.Mod;
      scale    = toolATTR.Sca;
      freq     = toolATTR.Frq;
      scaStr   = num2str(scale);
      frqStr   = sprintf('%7.3f',freq);
      realStr  = 'Ca,b';
      absStr   = 'Modulus (Ca,b)';
      argStr   = 'Angle (Ca,b)';
      tmpStr   = '   ';
      switch toolMode
        case {'real','abs','arg'}
          scaStr = ['for scale a = ' scaStr];
          frqStr = ['  (frequency = ' frqStr ')'];
          begStr = ['Coefficients Line - '];          
          endStr = [tmpStr,scaStr,frqStr];
          switch toolMode
           case 'real' , varargout{1} = [begStr,realStr,endStr];
           case {'abs','arg'}
             varargout{1} = ...
               strvcat([begStr,absStr,endStr],[begStr,argStr,endStr]);
          end
        case {'all'} 
          scaStr = ['for a = ' scaStr];
          frqStr = [' (frq = '  frqStr ')'];
          endStr = [tmpStr,scaStr frqStr];
          varargout{1} = strvcat([absStr,endStr],[argStr,endStr]);
       end        

    case 'cfsColorTitle'
      toolMode = varargin{1};
      pop_ccm  = varargin{2};
      %----------------------
      strPopCM = get(pop_ccm,'String');
      strPopCM = strPopCM(get(pop_ccm,'value'),:);
      realStr  = '';
      absStr   = 'Modulus of ';
      argStr   = 'Angle of ';
      midStr   = ['Ca,b Coefficients'];
      endStr   = ['  - Coloration mode : ' strPopCM];
      switch toolMode
        case 'real'
          varargout{1} = [realStr,midStr,endStr];
        case {'abs','arg'}
          varargout{1} = strvcat([absStr,midStr,endStr],[argStr,midStr,endStr]);
        case 'all' 
          varargout{1} = strvcat([absStr,midStr],[argStr,midStr]);
       end        

   case 'initPosAxes'
      toolMode = varargin{1};
      pos_Gra_Rem = varargin{2};
      %-------------------------------
      bdx = 0.045; bdy = 0.05; ecy = 0.06;
      h_col = 0.015;
      x_axe = pos_Gra_Rem(1)+bdx;
      w_axe = (pos_Gra_Rem(3)-2*bdx);
      w_col = pos_Gra_Rem(3)/3;
      x_col = pos_Gra_Rem(1)+w_col;
      h_rem = pos_Gra_Rem(4)-2*bdy;
      pos_axes = zeros(8,4,5);
      pos_axes(:,1,[1:4]) = x_axe;
      pos_axes(:,3,[1:4]) = w_axe;
      dummy = [x_col , 0 , w_col , h_col];
      pos_axes(:,:,5) = dummy(ones(1,8),:);
      pos_axes = permute(pos_axes,[3 2 1]);
 
      % Proportion.
      %-------------
      NB_Config = 8;
      prop = zeros(NB_Config,4);
      prop = [...
        2 4 2 4 ;
        1 3 1 0 ;
        1 3 0 3 ;
        1 0 1 3 ;
        1 3 0 0 ;
        1 0 1 0 ;
        1 0 0 3 ;
        1 0 0 0 ;
        ];
      dummy = sum(prop,2);
      for k = 1:NB_Config , prop(k,:) = (12*prop(k,:))/dummy(k); end
      vis = (prop>0);
      for k = 1:NB_Config
        visFlg = vis(k,[1 2 3 4 2]);
        DY     = ecy*visFlg.*[1 1 1.125 1 0.250];
        h_ele = (h_rem-h_col*visFlg(5)-sum(DY(2:5)))/12;
        h_axe = max(prop(k,:)*h_ele,1.E-6);

        y_axe = pos_Gra_Rem(2)+pos_Gra_Rem(4)-bdy-h_axe(1);
        pos_axes(1,:,k) = [x_axe y_axe w_axe h_axe(1)];
        y_axe = pos_axes(1,2,k)-DY(2)-h_axe(2);
        pos_axes(2,:,k) = [x_axe y_axe w_axe h_axe(2)];
        y_col = pos_axes(2,2,k)-DY(5)-h_col*visFlg(5);
        pos_axes(5,:,k) = [x_col , y_col , w_col , h_col];
        y_axe = pos_axes(5,2,k)-DY(3)-h_axe(3);
        pos_axes(3,:,k) = [x_axe y_axe w_axe h_axe(3)];
        y_axe = pos_axes(3,2,k)-DY(4)-h_axe(4);
        pos_axes(4,:,k) = [x_axe y_axe w_axe h_axe(4)];
      end
      %-----------------------------------------------------------
      num = 1;
      toolATTR = struct( ...
          'Pos',pos_axes,'Vis',vis,'Num',num,'Mod',toolMode,...
          'Sca',[],'Frq',[]);
      wfigmngr('storeValue',fig,'ToolSettings',toolATTR);
      hdl_Re_AXES = zeros(5,1);
      for k = 1:5
          hdl_Re_AXES(k) = axes(...
              'Parent',fig,              ...
              'Units','normalized',      ...
              'Position',pos_axes(k,:,num),...
              'Visible','off',           ...
              'XTicklabelMode','manual', ...
              'YTicklabelMode','manual', ...
              'XTickLabel',[],           ...
              'YTickLabel',[],           ...
              'XTick',[],'YTick',[],     ...
              'Box','On'                 ...
              );
      end
      if ~isequal(toolMode,'real')
          hdl_Im_AXES = copyobj(hdl_Re_AXES,fig);
          varargout = {hdl_Re_AXES,hdl_Im_AXES};
      else
          varargout = {hdl_Re_AXES};        
      end

    otherwise
      errargt(mfilename,'Unknown Option','msg');
      error('*');
end
