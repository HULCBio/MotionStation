function varargout = wavemngr(option,varargin)
%WAVEMNGR Wavelet manager.
%   WAVEMNGR is a wavelet manager used to add, delete, restore
%   or read wavelets.
%
%   WAVEMNGR('add',FN,FSN,WT,NUMS,FILE) or
%   WAVEMNGR('add',FN,FSN,WT,NUMS,FILE,B) or 
%   WAVEMNGR('add',FN,FSN,WT,{NUMS,TYPNUMS},FILE) or
%   WAVEMNGR('add',FN,FSN,WT,{NUMS,TYPNUMS},FILE,B)
%   adds a new wavelet family.
%     FN  = family name (string).
%     FSN = family short name (string).
%
%     WT defines the wavelet type: 
%     WT = 1 for orthogonal wavelets.
%     WT = 2 for biorthogonal wavelets.
%     WT = 3 for wavelet with scale function.
%     WT = 4 for wavelet without scale function.
%     WT = 5 for complex wavelet without scale function.
%
%     If the wavelet is a single one, NUMS = ''.
%       examples: mexh, morl.
%     If the wavelet is part of a finite family of wavelets, NUMS
%       is a string containing a blank separated list of items
%       representing wavelet parameters.
%       example: bior, NUMS = '1.1 1.3 ... 4.4 5.5 6.8'.
%     If the wavelet is part of an infinite family of wavelets, 
%       NUMS is a string containing a blank separated list of 
%       items representing wavelet parameters, terminated by the 
%       special sequence **.
%       examples: 
%         db,    NUMS = '1 2 3 4 5 6 7 8 9 10 **'.
%         shan,  NUMS = '1-1.5 1-1 1-0.5 1-0.1 2-3 **'
%     In these last two cases, TYPNUMS specifies the wavelet parameter 
%       input format: 'integer' or 'real' or 'string'; the default 
%       value is 'integer'.
%       examples: db,   TYPNUMS = 'integer'
%                 bior, TYPNUMS = 'real'
%                 shan, TYPNUMS = 'string'
%
%     FILE  = MAT-file or M-file name (string).
%
%     B = [lb ub] specifies lower and upper bounds of
%     effective support for wavelets of type = 3, 4 or 5.
%
%   WAVEMNGR('del',N), deletes a wavelet or a wavelet family where
%     N is the wavelet name or the family short name.
%
%   WAVEMNGR('restore') restores the previous 
%     wavelets.asc ASCII-file.
%   WAVEMNGR('restore',IN2) restores the initial 
%     wavelets.asc ASCII-file.
%
%   OUT1 = WAVEMNGR('read') returns all wavelets family names.
% 
%   OUT1 = WAVEMNGR('read',IN2) returns all wavelet names.
%
%   OUT1 = WAVEMNGR('read_asc') returns all wavelets information
%   retrieved from wavelets.asc ASCII-file.

%----------------------
%   INTERNAL OPTIONS.
%----------------------
%   WAVEMNGR('create')
%   creates wavelets.inf MAT-file using wavelets.asc ASCII-file.
%
%   OUT1 = WAVEMNGR('load') or WAVEMNGR('load')
%   loads Wavelets_Info from wavelets.inf matfile,
%   and puts it in the global variable: Wavelets_Info.
%
%   WAVEMNGR('clear') clear the global Wavelets_Info.
%
%   [OUT1,OUT2,OUT3,OUT4,OUT5,OUT6] = WAVEMNGR('indw',W)
%   returns:
%   family indice, number indice,
%   family, number for the wavelet W.
%   OUT5 is the family table of number.
%   OUT6 is a flag for GUI.
%
%   OUT1 = WAVEMNGR('indf',F) returns indice
%   for wavelet family F (short name).
%
%   varargout = wavemngr('fields',varargin) see below.
%
%   OUT1 = WAVEMNGR('read_struct')
%   OUT1 gives all wavelets structures.
% 
%   OUT1 = WAVEMNGR('read_struct',NUMS)
%   OUT1 gives the wavelets structures.
%   specified by NUMS.
%
%   OUT1 = WAVEMNGR('tfsn') or WAVEMNGR('tfsn',T)
%   returns shortname-table (of type = T : 'dwt' or 'cwt' or 'owt' or 'ccwt').
%
%   OUT1 = WAVEMNGR('tfn') or out1 = WAVEMNGR('tfn',T)
%   returns name-table (of type = T : 'dwt' or 'cwt' or 'owt' or 'ccwt').
%
%   OUT1 = WAVEMNGR('isbior',W)
%   returns 1 for biorthogonal wavelets.
%
%   [FAM,NUM] = WAVEMNGR('fam_num',W) returns
%   family and number for the wavelet W.
%
%   LEN = WAVEMNGR('length',W) returns the
%   length of the support of the wavelet W.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 26-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.17.4.2 $

global Wavelets_Info

%----------------------%
% Wavelets Structures. %
%--------------------------------------------------------%
% Wavelets_Info is a  structure array with size [nb_fam 1]
%
% Wavelet_Struct =
%   struct(...
%     'index'           integer
%     'familyName'      string
%     'familyShortName' string
%     'type'            integer
%     'tabNums'         matrix of string
%     'typNums'         string
%     'file'            string
%     'bounds'          string
%     );
%---------------------------------------------------------%

% Files Names.
%--------------
bin_ini_file = 'wavelets.bin';
asc_ini_file = 'wavelets.ini';
bin_file = 'wavelets.inf';
asc_file = 'wavelets.asc';
sav_file = 'wavelets.prv';

if nargin==0 , option = 'create' ; end

% Miscellaneous Values.
%----------------------
nb_InfoByWave =  7;
NB_FamInWTB   = 11;
WaveTypePOS   = [1:5];

switch option
    case 'load'
      if isempty(Wavelets_Info)
          try
              load(bin_file,'-mat')
          catch
              try
                  load(bin_ini_file,'-mat')
              catch
                  clc
                  disp(' ');
                  disp('---------------------------------------------');
                  sprintf('*** File : %s not found ! ***', bin_ini_file);
                  disp(['***     Using rescue resource ... !     ***']);
                  disp('---------------------------------------------');
                  disp(' ');
                  Wavelets_Info  = wavemngr('rescue');
              end
          end
      end
      if nargout>0 , varargout{1} = Wavelets_Info; end

    case 'clear' , clear global Wavelets_Info 

    case 'indw'
      % in2 : wavelet name
      %-------------------
      % out1 = i_fam
      % out2 = i_num
      % out3 = fam
      % out4 = num_str
      % out5 = tabNums
      % out6 = flag '**' (for GUI)
      %---------------------------
      if isempty(Wavelets_Info) , wavemngr('load'); end
      nb_fam = size(Wavelets_Info,1);
      wname  = deblankl(varargin{1});
      lwna   = length(wname);
      for i_fam=1:nb_fam
          fam = Wavelets_Info(i_fam).familyShortName;
          len = length(fam);
          ok_wave = 0;
          if lwna>=len
              if fam==wname(1:len)
                  tabNums = Wavelets_Info(i_fam).tabNums;
                  for i_num = 1:size(tabNums,1)
                      num_str = noblank(tabNums(i_num,:));
                      if strcmp(num_str,'no') , num_str = '' ; end
                      if strcmp([fam num_str],wname)
                          ok_wave = 1; add_num = 0; break;
                      end
                  end

                  % test for ** number
                  %------------------
                  if ok_wave==0 && strcmp(num_str,'**') && (lwna>len)
                      typNums = Wavelets_Info(i_fam).typNums;
                      num_str = wname(len+1:lwna);
                      switch typNums
                        case 'integer'
                          num = wstr2num(num_str);
                          if ~isempty(num) && (num==fix(num)) && (0<num)
                              ok_wave = 1; add_num = 1;
                          end

                        case 'real'
                          num = wstr2num(num_str);
                          if ~isempty(num)
                              ok_wave = 1; add_num = 1;
                          end

                        case 'string'
                          ok_wave = 1; add_num = 1;
                      end                        
                  end
 
              end
          end
          if ok_wave , break; end
      end
      if ok_wave
          varargout = {i_fam,i_num};
          if nargout<3 , return; end
          varargout = {varargout{:},fam,num_str,tabNums,add_num};
      else
          msg = sprintf('Invalid wavelet name : %s', wname);
          errargt('Wavelet test',msg,'msg');
          error(['***  ' msg '  ***']);
      end

    case 'indf'
      if isempty(Wavelets_Info) , wavemngr('load'); end
      fsnCell  = {Wavelets_Info(:).familyShortName}';
      fsnInput = deblankl(varargin{1});
      varargout{1} = find(strcmp(fsnInput,fsnCell)==1);

    case 'tfsn'
      if isempty(Wavelets_Info) , wavemngr('load'); end
      fsnCell = {Wavelets_Info(:).familyShortName}';
      varargout{1} = strvcat(fsnCell{:});
      if nargin==2
          wtype = lower(varargin{1});
          if isequal(wtype,'all') , return; end
          tab_type = {Wavelets_Info(:).type}';
          tab_type = cat(1,tab_type{:});
          switch wtype
            case {'dwt'}  , ind = find(tab_type==1 | tab_type==2);
            case {'cwt'}  , ind = find(tab_type>0 & tab_type<5);
            case {'owt'}  , ind = find(tab_type==1);
            case {'ccwt'} , ind = find(tab_type==5);
            case {'666'}
               ind = [find(tab_type==5) ; find(tab_type>0 & tab_type<5)];
          end
          varargout{1} = varargout{1}(ind,:);
       end

    case 'tfn'
      if isempty(Wavelets_Info) , wavemngr('load'); end
      fnCell = {Wavelets_Info(:).familyName}';
      varargout{1} = strvcat(fnCell{:});
      if nargin==2
          wtype = lower(varargin{1});
          if isequal(wtype,'all') , return; end
          tab_type = {Wavelets_Info(:).type}';
          tab_type = cat(1,tab_type{:});
          switch wtype
            case {'dwt'}  , ind = find(tab_type==1 | tab_type==2);
            case {'cwt'}  , ind = find(tab_type>0 & tab_type<5);
            case {'owt'}  , ind = find(tab_type==1);
            case {'ccwt'} , ind = find(tab_type==5);
          end
          varargout{1} = varargout{1}(ind,:);
       end

    case 'fields'
      % in2 = {'ind', wavelet index} or
      % in2 = {'fsn', family shortname} or
      % in2 = {'wn' , wavelet name}
      % or
      % in2 = wavelet name
      %----------------------------
      % in3  ... = field(s) name(s)
      %----------------------------
      % out1 ... = field(s) value(s)
      %-----------------------------
      if iscell(varargin{1})
          in_type = varargin{1}{1};
          arg = varargin{1}{2};
      else
          in_type = 'wn';
          arg = varargin{1};
      end
      switch in_type
          case 'ind'
              if isempty(Wavelets_Info) , wavemngr('load'); end
              i_fam = arg;
 
          case 'fsn' , i_fam = wavemngr('indf',arg);
          case 'wn'  , i_fam = wavemngr('indw',arg);
      end
      nb = nargin-2;
      if nb==0
          varargout{1} = Wavelets_Info(i_fam);
          return;
      end
      for k=1:nb
          switch varargin{k+1}
              case 'ind'     , field = 'index';
              case 'fn'      , field = 'familyName';
              case 'fsn'     , field = 'familyShortName';
              case 'type'    , field = 'type';
              case 'tabNums' , field = 'tabNums';
              case 'typNums' , field = 'typNums';
              case 'file'    , field = 'file';
              case 'bounds'  , field = 'bounds';
              otherwise      , field = '';
          end
          if ~isempty(field)
              varargout{k} = Wavelets_Info(i_fam).(field);
          else
              varargout{k} = Wavelets_Info(i_fam);
          end
      end

    case 'type'
        i_fam = wavemngr('indw',varargin{1});
        varargout{1} = Wavelets_Info(i_fam).('type');

    case 'file'
        i_fam = wavemngr('indw',varargin{1});
        varargout{1} = Wavelets_Info(i_fam).('file');

    case 'fn'
        i_fam = wavemngr('indw',varargin{1});
        varargout{1} = Wavelets_Info(i_fam).('familyName');

    case 'fsn'
        i_fam = wavemngr('indw',varargin{1});
        varargout{1} = Wavelets_Info(i_fam).('familyShortName');

    case {'tabnums','tabNums'}
        i_fam = wavemngr('indf',varargin{1});
        varargout{1} = Wavelets_Info(i_fam).('tabNums');

    case {'typNums'}
        i_fam = wavemngr('indf',varargin{1});
        varargout{1} = Wavelets_Info(i_fam).('typNums');

    case 'bounds'
        i_fam = wavemngr('indw',varargin{1});
        varargout{1} = Wavelets_Info(i_fam).('bounds');

    case 'isbior'
        wname = varargin{1};
        if length(wname)>3,
            wname = wname(1:4);
            varargout{1} = isequal(wname,'bior') | isequal(wname,'rbio');
        else
            varargout{1} = 0;
        end

    case 'fam_num'
        [nul,nul,varargout{1},varargout{2}] = wavemngr('indw',varargin{1});

    case 'length'
        wname = varargin{1};
        [wtype,bounds] = wavemngr('fields',{'wn',wname},'type','bounds');
        switch wtype
            case {1,2}
                Lo_D = wfilters(wname);
                varargout{1} = length(Lo_D);
            case {3,4}
                varargout{1} = bounds(2)-bounds(1)+1;
            otherwise
                errargt(mfilename,'invalid argument','msg'); error('*');
        end
                                       
    case 'create'
        wavemngr('clear')
        beg_fam = 'Family Name : ';
        fid = fopen(asc_file);
        if fid==-1
            fid   = fopen(asc_ini_file); 
            winfo = fread(fid);
            fclose(fid);
            fid   = fopen(asc_file,'w');
            fwrite(fid,winfo); 
            fclose(fid);
        else
            winfo = fread(fid);
            fclose(fid);
        end
        winfo   = setstr(winfo');
        str_NL  = findNL('string',winfo);
        lennewl = length(str_NL);
        ind_NL  = findstr(str_NL,winfo);
        first   = findstr(beg_fam,winfo)+length(beg_fam);
        nb_fam  = length(first);

        %------------------------------%
        % Building Wavelets Structure. %
        %------------------------------%
        nul = cell(nb_fam,1);
        Wavelets_Info = struct(...
                    'index',nul,           ...
                    'familyName',nul,      ...
                    'familyShortName',nul, ...
                    'type',nul,            ...
                    'tabNums',nul,         ...
                    'typNums',nul,         ...
                    'file',nul,            ...
                    'bounds',nul           ...
                    );

        for j = 1:nb_fam
            i_fam   = first(j);
            indexs  = find(ind_NL>i_fam);
            indexs  = ind_NL(indexs(1:nb_InfoByWave));
            fam     = winfo(i_fam:indexs(1)-1);
            sname   = winfo(indexs(1)+lennewl:indexs(2)-1);
            wtype   = winfo(indexs(2)+lennewl:indexs(3)-1);
            nums    = winfo(indexs(3)+lennewl:indexs(4)-1);
            typNums = winfo(indexs(4)+lennewl:indexs(5)-1);                  
            fname   = winfo(indexs(5)+lennewl:indexs(6)-1);
            bounds  = winfo(indexs(6)+lennewl:indexs(7)-1);

            notspace = ~isspace(nums);
            lnot     = length(notspace);
            index1   = find(notspace==1);
            k0       = index1(1);
            k1       = index1(length(index1));
            indnum   = diff(notspace);
            fnum     = find(indnum==1)+1;
            lnum     = find(indnum==-1);
            if k0==1    , fnum = [1 fnum];  end
            if k1==lnot , lnum = [lnum k1]; end
            nb_num   = length(fnum);
            tabNums  = '';
            for p = 1:nb_num
                tabNums = strvcat(tabNums,nums(fnum(p):lnum(p)));
            end

            Wavelets_Info(j).index = j;
            Wavelets_Info(j).familyName = fam;
            Wavelets_Info(j).familyShortName = sname;
            Wavelets_Info(j).type = wstr2num(wtype);
            Wavelets_Info(j).tabNums = tabNums;
            Wavelets_Info(j).typNums = typNums;
            Wavelets_Info(j).file = fname;
            Wavelets_Info(j).bounds = wstr2num(bounds);
        end
        try
            save(bin_file,'Wavelets_Info')
        catch
            errargt(mfilename,'Changing Wavelets : Save FAILED !','msg');
        end

    case 'read'
        if isempty(Wavelets_Info) , wavemngr('load'); end
        nb_fam  = size(Wavelets_Info,1);
        sep_fam = '=';
        sep_fam = sep_fam(:,ones(1,35));
        sep_num = '-';
        sep_num = sep_num(:,ones(1,30));
        varargout{1} = sep_fam; 
        tab     = setstr(9);

        families = strvcat(Wavelets_Info(:).familyName);
        tabtab   = tab(ones(1,nb_fam),ones(1,2));

        if  nargin==1
            famSName    = strvcat(Wavelets_Info(:).familyShortName);
            famTAB      = [families tabtab famSName];
            varargout{1}= strvcat(varargout{1},famTAB,sep_fam);
        else
            famTAB = [families tabtab];
            for k =1:nb_fam
                 sfname = Wavelets_Info(k).familyShortName;
                 varargout{1} = strvcat(varargout{1},[famTAB(k,:) sfname]);
                 nb     = 0;
                 wnames = [];
                 tabNums = Wavelets_Info(k).tabNums;
                 if size(tabNums,1)>1
                     varargout{1} = strvcat(varargout{1},sep_num);
                 end
                 for j = 1:size(tabNums,1)
                     num_str = noblank(tabNums(j,:));
                     if ~strcmp(num_str,'no')
                         wnames = [wnames sfname noblank(tabNums(j,:)) tab];
                     end
                     if nb<3
                         nb = nb+1;
                     else
                         if ~isempty(wnames)
                             varargout{1} = strvcat(varargout{1},wnames);
                         end
                         nb  = 0;
                         wnames = [];
                     end
                 end
                 if nb>0 && ~isempty(wnames)
                     varargout{1} = strvcat(varargout{1},wnames);
                 end
                 varargout{1} = strvcat(varargout{1},sep_fam);
            end
        end

    case 'read_asc'
        fid = fopen(asc_file);
        if fid==-1 , fid = fopen(asc_ini_file); end
        winfo = fread(fid);
        fclose(fid);
        varargout{1} = setstr(winfo');

    case 'read_struct'
        if isempty(Wavelets_Info) , wavemngr('load'); end
        if nargin==2
            indfam = varargin{1};
        else
            nb_fam = size(Wavelets_Info,1);
            indfam = [1:nb_fam];
        end
        if nargout==0
            sep_fam = '*';
            sep_fam = sep_fam(:,ones(1,35));
            disp(' '); disp(' '); disp(' ');
            disp(sep_fam);
        end
        for k =1:length(indfam)
            tmp{k} = Wavelets_Info(indfam(k));
            if nargout==0
                disp(tmp{k}); disp(sep_fam);
            end
        end
        if nargout>0 , varargout = tmp; end

    case 'add'
        wavemngr('clear')
        Wavelets_Info = wavemngr('load');
        nb_fam = size(Wavelets_Info,1);
        err = 0;
        family_Name = varargin{1};        
        if isempty(family_Name)
            err = 1; 
            msg = 'Wavelet Family Name is empty !';
        else
            fnIn  = noblank(family_Name);
            tmpCell = {Wavelets_Info(:).familyName}';
            ind   = find(strcmp(fnIn,tmpCell)==1);
            err   = ~isempty(ind);
            if err , msg = 'The Wavelet Family Name is already used !'; end
        end

        if err==0
            family_Short_Name = varargin{2};
            if isempty(family_Short_Name)
                err = 1; 
                msg = 'Wavelet Family Short Name is empty !';
            else
                fsnIn   = deblankl(family_Short_Name);
                tmpCell = {Wavelets_Info(:).familyShortName}';
                ind     = find(strcmp(fsnIn,tmpCell)==1);
                err     = ~isempty(ind);
                if err
                    msg = 'The Wavelet Family Short Name is already used !';
                end
            end
        end

        if err==0
            wavelet_Type = varargin{3};
            if isempty(find(wavelet_Type==WaveTypePOS))
                err = 1;
                msg = 'Invalid Wavelet Type !';
            end
        end

        if err==0            
            if isempty(varargin{4})
                wavelet_tabNums = 'no';
                wavelet_typNums = 'no';
            elseif ischar(varargin{4})
                wavelet_tabNums = deblank(varargin{4});
                wavelet_typNums = 'integer';
            elseif iscell(varargin{4})
                wavelet_tabNums = deblank(varargin{4}{1});
                wavelet_typNums = deblank(varargin{4}{2});
                if ischar(wavelet_typNums)
                   switch wavelet_typNums
                     case {'integer','real','string'}
                     otherwise
                       err = 1;
                       msg = 'Invalid Wavelet type of numbers !';
                   end                 
                else
                    err = 1;
                    msg = 'Invalid Wavelet type of numbers !';
                end
                
            else
                err = 1;
                msg = 'Invalid Wavelet numbers !';
            end
        end

        if err==0
            wavelet_File = varargin{5};
            if isempty(wavelet_File)
                err = 1;
            elseif findstr('.mat',wavelet_File)

            else 
                wavelet_File = deblankl(wavelet_File);
                ind = findstr('.m',wavelet_File);
                if ind>0 , wavelet_File = wavelet_File(1:ind-1); end
                if isempty(wavelet_File) , err = 1; end
            end
            if err==1
                msg = 'Invalid Wavelet File Name !';
            end
        end
        if err==0
            nbArgIN = length(varargin);
            switch wavelet_Type
              case {1,2}
                if nbArgIN<6 , wavelet_Bounds = ''; end
                
              otherwise  
                if nbArgIN<6
                    err = 1;
                    msg = 'Invalid number of arguments !';
                else
                    wavelet_Bounds = varargin{6};
                    if length(wavelet_Bounds)~=2,               err = 1;
                    elseif wavelet_Bounds(1)>wavelet_Bounds(2), err = 1;
                    end
                    if err==1
                        msg = 'Invalid value for wavelet bounds !';
                    end
                end
            end
        end
        if err
            msg = strvcat('Add New Wavelet FAILED !!',msg);
            errargt(mfilename,msg,'msg');
            return
        end

        fid = fopen(asc_file);
        if fid==-1 , fid = fopen(asc_ini_file); end
        winfo = fread(fid);
        fclose(fid);
        fid = fopen(sav_file,'w');
        fwrite(fid,winfo);
        fclose(fid);

        Chrline = findNL('char',winfo);
        beg_fam = 'Family Name : ';
        sep_fam = '------------------------';

        wavelet_Type = sprintf('%.0f',wavelet_Type);
        if ~isempty(wavelet_Bounds)
            wavelet_Bounds = [num2str(wavelet_Bounds(1)) ' ' ...
                              num2str(wavelet_Bounds(2))];
        end

        winfo = [winfo(1:end-1);           Chrline;  ...
                abs(beg_fam'); ...
                abs(family_Name(:));       Chrline;  ...
                abs(family_Short_Name(:)); Chrline;  ...
                abs(wavelet_Type(:));      Chrline;  ...
                abs(wavelet_tabNums(:));   Chrline;  ...
                abs(wavelet_typNums(:));   Chrline;  ...
                abs(wavelet_File(:));      Chrline;  ...
                abs(wavelet_Bounds(:));    Chrline;  ...
                abs(sep_fam');             Chrline   ...
                ];

        fid = fopen(asc_file,'w');
        fwrite(fid,winfo);
        fclose(fid);
        wavemngr('create');

    case 'del'
        wavemngr('clear')
        Wavelets_Info = wavemngr('load');
        err   = 0;
        i_fam = [];
        if isempty(varargin{1})
            err = 1; 
            msg = 'Wavelet Family (Short) Name is empty !';       
        else
            name = noblank(varargin{1});
            tmpCell = {Wavelets_Info(:).familyName}';
            i_fam = find(strcmp(name,tmpCell)==1);
            if isempty(i_fam)
                tmpCell = {Wavelets_Info(:).familyShortName}';
                i_fam = find(strcmp(name,tmpCell)==1);
            end
        end

        if err==0
            if isempty(i_fam)
                err = 1;
                msg = 'Invalid Wavelet Family (Short) Name !';
            elseif i_fam<=NB_FamInWTB
                err = 1;
                fn  = Wavelets_Info(i_fam).familyName;
                msg = sprintf('You can''t delete %s Wavelet Family !',fn);
            end
        end
        if err
            errargt(mfilename,msg,'msg');
            return 
        end

        fid = fopen(asc_file);
        if fid==-1 , fid = fopen(asc_ini_file); end
        winfo = fread(fid);
        fclose(fid);
        fid = fopen(sav_file,'w');
        fwrite(fid,winfo);
        fclose(fid);

        str_winfo = setstr(winfo');
        str_NL    = findNL('string',winfo);
        beg_fam   = 'Family Name : ';
        first     = findstr(beg_fam,str_winfo);
        first     = first(i_fam);
        ind_NL    = findstr(str_NL',str_winfo);
        indexs    = find(ind_NL>first);
        indexs    = ind_NL(indexs(1:nb_InfoByWave+1));
        last      = indexs(nb_InfoByWave+1)+length(str_NL)-1;

        winfo(first:last) = [];
        fid = fopen(asc_file,'w');
        fwrite(fid,winfo);
        fclose(fid);
        wavemngr('create');

    case 'restore'
        wavemngr('clear')
        if nargin==1
            fid = fopen(sav_file);
            if fid==-1 , fid = fopen(asc_ini_file); end
        else
            fid = fopen(asc_ini_file);
        end
        winfo = fread(fid);
        fclose(fid);
        fid = fopen(asc_file,'w');
        fwrite(fid,winfo);
        fclose(fid);
        wavemngr('create');

    case 'rescue'
        famtype = ...
           {...
            1, 'Haar',         'haar',  1;
            2, 'Daubechies',   'db',    1;
            3, 'Symlets',      'sym',   1;
            4, 'Coiflets',     'coif',  1;
            5, 'BiorSplines',  'bior',  2;
            6, 'ReverseBior',  'rbio',  2;
            7, 'Meyer',        'meyr',  3;
            8, 'DMeyer',       'dmey',  1;
            9, 'Gaussian',     'gaus',  4;
           10, 'Mexican_hat',  'mexh',  4;
           11, 'Morlet',       'morl',  4;
           10, 'Complex Gaussian',   'cgau',  5;
           11, 'Shannon',            'shan',  5;
           10, 'Frequency B-Spline', 'fbsp',  5;
           11, 'Complex Morlet',     'cmor',  5

            };

        nums = ...
           {...
            '';
            '1 2 3 4 5 6 7 8 9 10 **';
            '2 3 4 5 6 7 8 **';
            '1 2 3 4 5';
            '1.1 1.3 1.5 2.2 2.4 2.6 2.8 3.1 3.3 3.5 3.7 3.9 4.4 5.5 6.8';
            '1.1 1.3 1.5 2.2 2.4 2.6 2.8 3.1 3.3 3.5 3.7 3.9 4.4 5.5 6.8';
            '';
            '';
            '1 2 3 4 5 6 7 8 **';
            '';
            '';
            '1 2 3 4 5 **';
            '1-1.5 1-1 1-0.5 1-0.1 2-3 **';
            '1-1-1.5 1-1-1 1-1-0.5 2-1-1 2-1-0.5 2-1-0.1 **';
            '1-1.5 1-1 1-0.5 1-1 1-0.5 1-0.1 **'
            };

        typNums = ...
           {...
            'no';
            'integer';
            'integer';
            'integer';
            'real';
            'real';
            'no';
            'no';
            'integer';
            'no';
            'no';
            'integer';
            'string';
            'string';
            'string'
            };

        files = ...
           {...
            'dbwavf';
            'dbwavf';
            'symwavf';
            'coifwavf';
            'biorwavf';
            'rbiowavf';
            'meyer';
            'dmey.mat';
            'gauswavf';
            'mexihat';
            'morlet'
            'cgauwavf';
            'shanwavf';
            'fbspwavf';
            'cmorwavf'
            };

        bounds = ...
           {...
            [];
            [];
            [];
            [];
            [];
            [];
            [-8 8];
            [];
            [-5 5];
            [-8 8];
            [-8 8];
            [-5 5];
            [-20 20];
            [-20 20];
            [-8 8]
            };

        nbfam   = size(famtype,1); 
        tabNums = cell(nbfam,1);
        for k = 1:nbfam
            tabNums{k} = '';
            s = deblank(nums{k});
            if ~isempty(s)
                I = find(isspace(s));
                i_beg = 1;
                for j = 1:length(I)
                    i_end = I(j)-1;
                    ss = deblank(s(i_beg:i_end));
                    if ~isempty(ss)
                        tabNums{k} = strvcat(tabNums{k},ss);
                    end
                    i_beg = i_end+2;
                end
                ss = deblank(s(i_beg:end));
                tabNums{k} = strvcat(tabNums{k},ss);
            end
            if isempty(tabNums{k}) , tabNums{k} = 'no'; end
        end

        varargout{1} = ...
           struct(...
                  'index',           famtype(:,1), ...
                  'familyName',      famtype(:,2), ...
                  'familyShortName', famtype(:,3), ...
                  'type',            famtype(:,4), ...
                  'tabNums',         tabNums,      ...
                  'typNums',         typNums,      ...
                  'file',            files,        ...
                  'bounds',          bounds        ...
                  );

    otherwise
        errargt(mfilename,'Unknown Option','msg');
        error('*');
end

%----------------------------------%
% Internal Function(s)             %
%----------------------------------%
function nl = findNL(opt,txt)
%FINDNL Find New Line char or string.

ind10 = find(txt==10);
ind13 = find(txt==13);
if isempty(ind13) ,
    nl = 10;
elseif isempty(ind10)
    nl = 13;
else
    nl = [13;10];
end
if isequal(opt,'string')
    nl = setstr(nl);
end
if size(txt,2)>1 , nl = nl'; end
%----------------------------------%
function s = noblank(x)
%NOBLANK Removes blanks in a string.

if ~isempty(x)
    s = x(find(x~=' ' & x~=0));
else
    s = '';
end
%----------------------------------%