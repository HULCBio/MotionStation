function varargout = cbcolmap(option,fig,varargin);
%CBCOLMAP Callbacks for colormap utilities.
%   NBC = CBCOLMAP(OPTION,FIG,VARARGIN)
%   option :
%       'pal' : change the colormap.
%       'bri' : change the brightness.
%       'nbc' : change the number of colors.
%       'set' : sets colormap.
%   FIG = handle of the figure.
%   HDL = handle(s) of used button(s). (IN3 or IN4)
%   NBC = number of colors. (IN4 or IN5)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-98.
%   Last Revision: 05-Feb-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2004/03/15 22:39:44 $

if isempty(find(wfindobj('figure')==fig)) , return; end

% Default Values.
%----------------
maxmax_nbcolors = 448;
min_nbcolors = 2;
def_nbcolors = 128;
min_bright   = -2;
max_bright   = 2;
def_bright   = 0;

% Find Handles.
%--------------
[Pop_PAL,Sli_NBC,Edi_NBC,Pus_BRI_M,Pus_BRI_P] = utcolmap('handles',fig,'cell');

switch option
    case 'nbc'
        e_or_s = varargin{1};
        if ~ishandle(e_or_s)
            if nargin==4
                NBC = cbcolmap('pal',fig,varargin{2});
            else
                NBC = cbcolmap('pal',fig);
            end
            varargout{1} =  NBC;
            return; 
        end
        max_sli = get(Sli_NBC,'Max');
        st = get(e_or_s,'style');
        if strcmp(st,'edit')
            nbcol = wstr2num(get(e_or_s,'String'));
            continu = 1;
            if isempty(nbcol)
                continu = 0;
            elseif (nbcol<min_nbcolors)
                continu = 0 ;
            elseif nbcol>max_sli
                nbcol = max_sli;
                set(e_or_s,'String',sprintf('%.0f',nbcol));
            end
            if ~continu
                map = get(fig,'Colormap');
                nbcol = size(map,1);
                set(e_or_s,'String',sprintf('%.0f',nbcol));
                varargout{1} = nbcol;
                return;
            end
            if ~isempty(Sli_NBC) , set(Sli_NBC,'Value',nbcol); end
        elseif strcmp(st,'slider')
            nbcol = round(get(e_or_s,'Value'));
            if ~isempty(Edi_NBC)
                set(Edi_NBC,'String',sprintf('%.0f',nbcol));
            end
        end
        varargout{1} = cbcolmap('pal',fig,nbcol);

    case 'pal'
        map = get(fig,'Colormap');
        if length(varargin)<1 , NBC = size(map,1); else NBC = varargin{1}; end
        val  = get(Pop_PAL,'Value');
        name = get(Pop_PAL,'String');
        name = deblankl(name(val,:));   
        if strcmp(name,'self')
            map = get(Pop_PAL,'Userdata');
            nbcol = size(map,1);
            if ~isempty(Sli_NBC) , set(Sli_NBC,'Value',nbcol); end
            if ~isempty(Edi_NBC)
                set(Edi_NBC,'String',sprintf('%.0f',nbcol));
            end
        elseif name(1:2)=='1-'
            name = name(3:end);
            map  = 1-feval(name,NBC);
        else
            map = feval(name,NBC);
        end
        set(fig,'Colormap',map);
        varargout{1} = NBC;

    case 'bri'
        val = 0.5*varargin{1};
        old_Vis = get(fig,'HandleVisibility');
        set(fig,'HandleVisibility','on')
        if ~isequal(get(0,'CurrentFigure'),fig) , figure(fig); end
        brighten(val);
        set(fig,'HandleVisibility',old_Vis)

    case 'set'
        nbarg = length(varargin);
        if nbarg<1 , return; end
        for k = 1:2:nbarg
           argType = varargin{k};
           argVal  = varargin{k+1};
           switch argType
             case 'pal'
                 names = get(Pop_PAL,'String');
                 NBC   = [];
                 if iscell(argVal)
                     namepal = argVal{1};
                     if length(argVal)>1
                         NBC = argVal{2};
                         if length(argVal)==4
                             % Adding the "self" colormap.
                             %----------------------------
                             % addNam = argVal{3}; For next versions.
                             addNam = 'self'; 
                             udMap  = argVal{4};                             
                             if ~isempty(udMap)
                                 ind = strmatch(addNam,names);
                                 if isempty(ind)
                                     names = strvcat(names,addNam);
                                 end
                             else
                                 names = mextglob('get','Lst_ColorMap');
                             end
                             set(Pop_PAL,'String',names,'Userdata',udMap);
                         end
                     end
                 else
                     namepal = argVal;
                 end

                 % Setting the number of colors.
                 %------------------------------
                 max_sli = get(Sli_NBC,'Max');
                 map     = get(fig,'Colormap');
                 nb_col  = size(map,1);
                 if isempty(NBC) | ~isnumeric(NBC)
                     NBC = nb_col;
                 elseif (NBC<min_nbcolors)
                     NBC = nb_col;
                 end
                 if NBC>max_sli , NBC = max_sli; end

                 % Setting the name of colormap.
                 %------------------------------
                 namepal = deblankl(namepal);
                 if ~(isempty(namepal) | isequal(namepal,'same'))
                     ind = 0;
                     for k = 1:size(names,1)
                         if strcmp(namepal,deblankl(names(k,:)))
                             ind = k; break;
                         end
                     end
                 else
                     ind = get(Pop_PAL,'Value');
                 end
                 if ind
                     set(Pop_PAL,'Value',ind);
                     if ~isempty(Edi_NBC)
                         set(Edi_NBC,'String',sprintf('%.0f',NBC));
                     end
                     if ~isempty(Sli_NBC) , set(Sli_NBC,'Value',NBC); end
                     % NBC = cbcolmap('nbc',fig,Edi_NBC,NBC);
                     cbcolmap('pal',fig,NBC);
                 end
                 if nargout>0 , varargout{1} = NBC; end
           end
        end

    case 'get'
        nbarg = length(varargin);
        if nbarg<1 , return; end
        varargout = {};
        for k = 1:nbarg
           outType = lower(varargin{k});
           switch outType
             case 'self_pal' , varargout{k} = get(Pop_PAL,'Userdata');
             case 'pop_pal'  , varargout{k} = Pop_PAL;
             case 'sli_nbc'  , varargout{k} = Sli_NBC;
             case 'edi_nbc'  , varargout{k} = Edi_NBC;
             case 'btn_bri'  , varargout{k} = [Pus_BRI_M,Pus_BRI_P];
             case 'mapname'  , prop =  get(Pop_PAL,{'String','Value'});
                               varargout{k} = prop{1}(prop{2},:);
             case 'nbcolors' , varargout{k} = round(get(Sli_NBC,'Value'));
           end
        end

    case 'enable'
        set([Pop_PAL,Sli_NBC,Edi_NBC,Pus_BRI_M,Pus_BRI_P],'Enable',varargin{1});

    case 'visible'
        handles = utcolmap('handles',fig,'all');
        handles = handles(ishandle(handles));
        set(handles,'Visible',varargin{1});

    otherwise
        errargt(mfilename,'Unknown Option','msg');
        error('*');
end
