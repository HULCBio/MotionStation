function varargout = utguidiv(option,varargin)
%UTGUIDIV Utilities for testing inputs for different "TOOLS" files.
%   VARARGOUT = UTGUIDIV(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-May-98.
%   Last Revision: 21-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $  $Date: 2004/03/15 22:42:06 $

switch option
    case 'ini'
        winAttrb = [];
        optval   = varargin{1};
        switch nargin
            case 2
                if ~ischar(optval)
                    winAttrb = optval; optval = 'create';
                end
            otherwise
                if isequal(optval,'create') ,  winAttrb = varargin{2}; end
            end
            varargout = {optval,winAttrb};
        
    case 'WTB_DemoPath'
        testfile = varargin{1};
        dum = which('dguicf1d.m','-all');
        pathname = fileparts(dum{1});
        pathname = which([pathname filesep testfile]);
        if ~isempty(pathname)
            ind = findstr(pathname,testfile);
            pathname = pathname(1:ind-1);
        end
        varargout{1} = pathname;       
        
    case {'test_load','test_save'}
        fig  = varargin{1};
        mask = varargin{2};
        txt  = varargin{3};
        [xpos,ypos] = wfigutil('left_up',fig,10,30);
        verMAT = version; 
        verMAT = str2double(verMAT(1:3));
        switch option
            case 'test_load',
                if verMAT<7
                    [filename,pathname] = uigetfile(mask,txt,xpos,ypos);
                else
                    [filename,pathname] = uigetfile(mask,txt,'location',[xpos,ypos]);
                end
            case 'test_save'
                if verMAT<7
                    [filename,pathname] = uiputfile(mask,txt,xpos,ypos);
                else
                    [filename,pathname] = uiputfile(mask,txt,'location',[xpos,ypos]);
                end
                try
                    [name,ext] = strtok(filename,'.');
                    eval([name ' = 0;'])
                catch
                    filename = 0;
                end
        end
        if isempty(filename) | filename==0 , ok = 0;
        else , ok = 1;
        end
        varargout = {filename,pathname,ok};
        
    case {'load_sig','load_dem1D'}
        fig  = varargin{1};
        switch option
            case 'load_sig'       
                mask = varargin{2};
                if isequal(mask,'Signal_Mask')
                    mask = {...
                       '*.mat;*.wav;*.au','Signal ( *.mat , *.wav , *.au)';
                       '*.*','All Files (*.*)'};
                end
                txt  = varargin{3};
                [filename,pathname,ok] = utguidiv('test_load',fig,mask,txt);
                
            case 'load_dem1D'
                pathname = varargin{2};
                filename = varargin{3};
                ok = 1;
        end
        
        % default.
        %---------
        sigInfos = struct(...
            'pathname',pathname, ...
            'filename',filename, ...
            'name','',     ...
            'size',0       ...
            );
        sig_Anal = [];
        
        if ok
            wwaiting('msg',fig,'Wait ... loading');
            [sigInfos.name,ext,fullName,fileStruct,err] = ...
                getFileINFO(pathname,filename);
            if ~err
                err = 1;
                for k = 1:length(fileStruct)
                    if isequal(fileStruct(k).class,'double')
                        siz = fileStruct(k).size;
                        if min(siz)==1 & max(siz)>1
                            err = 0;
                            sigInfos.name = fileStruct(k).name;
                            break
                        end
                    end
                end
                if ~err
                    try
                        load(fullName,'-mat');
                        sig_Anal = eval(sigInfos.name);
                    catch
                        err = 1; numMSG = 1;
                    end
                else
                    numMSG = 2;
                end
            else
                numMSG = 1;
                [sig_Anal,err,msg] = load_1D_NotMAT(pathname,filename);
                if ~isempty(msg) , numMSG = msg; end
            end
            if ~err
                err = ~isreal(sig_Anal);
                if err , numMSG = 4; end
            end        
            if err ,  dispERROR_1D(fig,sigInfos.filename,numMSG); end
            ok = ~err;
        end
        if ok
            if size(sig_Anal,1)>1 , sig_Anal = sig_Anal'; end
            sigInfos.size = length(sig_Anal);        
        end
        varargout = {sigInfos,sig_Anal,ok};
        
    case {'direct_load_sig'}
        pathname = varargin{2};
        filename = varargin{3};
        [sig_Anal,err] = load_1D_NotMAT(pathname,filename);
        ok = ~err;
        varargout = {sig_Anal,ok};
        
    case {'load_img','load_dem2D'}
        fig  = varargin{1}; 
        switch option
            case 'load_img'       
                mask = varargin{2};
                txt  = varargin{3};
                [filename,pathname,ok] = utguidiv('test_load',fig,mask,txt);
                
            case 'load_dem2D'
                pathname = varargin{2};
                filename = varargin{3};
                ok = 1;
        end
        default_nbcolors = varargin{4};
        
        % default.
        %---------
        imgInfos = struct(...
            'pathname',pathname,  ...    
            'filename',filename,  ...
            'name','',      ...
            'true_name','', ...
            'type','mat',   ...
            'self_map',0,   ...
            'size',[0 0]    ...
            );
        X = []; map = [];
        
        if ok
            wwaiting('msg',fig,'Wait ... loading');
            [imgInfos.name,ext,fullName,fileStruct,err] = ...
                getFileINFO(pathname,filename);
            if ~err
                err = 1;
                for k = 1:length(fileStruct)
                    mm = min(fileStruct(k).size);
                    if mm>3
                        err = 0;
                        imgInfos.true_name = fileStruct(k).name;
                        break
                    end
                end
                if ~err
                    try
                        load(fullName,'-mat');
                        imgInfos.type = 'mat';
                        X = eval(imgInfos.true_name);
                        X = double(X);
                    catch
                        err = 1; numMSG = 1;
                    end
                else
                    numMSG = 2;
                end
            else
                numMSG = 1;
                try
                    [X,map,imgFormat,colorType,err] = ...
                        load_2D_NotMAT(pathname,filename);
                    if ~err
                        mi = min(min(X));
                        if mi<1 , X = X-mi+1; end
                        if isempty(map)
                            ma  = max(max(X));
                            map = pink(ma);
                            X   = wcodemat(X,ma);
                        end
                        [dummy,name,ext,dummy] = fileparts(filename);
                        imgInfos.type = imgFormat;
                        imgInfos.name = [name,ext];
                        imgInfos.true_name = 'X';
                        err = 0;
                    else
                        numMSG = 3;
                    end
                catch
                    numMSG = lasterr;
                end
            end
            if ~err
                err = ~isreal(X);
                if err , numMSG = 4; end
            end
            ok = ~err;
            if ~err
                imgInfos.self_map = ~isempty(map);
                if ~imgInfos.self_map
                    mi = round(min(min(X)));
                    ma = round(max(max(X)));
                    if mi<=0 , ma = ma-mi+1; end
                    ma  = min([default_nbcolors,max([2,ma])]);
                    map = pink(ma);
                end
                imgInfos.size = fliplr(size(X));
            else
                dispERROR_2D(fig,imgInfos.filename,numMSG);
            end
        end
        varargout = {imgInfos,X,map,ok};

    case {'direct_load_img'}
        pathname = varargin{2};
        filename = varargin{3};
        [X,map,imgFormat,colorType,err] = load_2D_NotMAT(pathname,filename);
        varargout = {X,map,imgFormat,colorType,err};
        
    case 'load_var'
        fig  = varargin{1};
        mask = varargin{2};
        txt  = varargin{3};
        vars = varargin{4};
        [filename,pathname,ok] = utguidiv('test_load',fig,mask,txt);
        if ok
            wwaiting('msg',fig,'Wait ... loading');
            try
                err = 0;
                load([pathname filename],'-mat');
                for k = 1:length(vars)
                    var = vars{k};
                    if ~exist(vars{k},'var') , err = 1; break; end
                end
                if err , msg = sprintf('variable : %s not found !', var); end
            catch
                err = 1;
                msg = sprintf('File %s is not a valid file.', filename);
            end
            if err
                wwaiting('off',fig);
                errordlg(msg,'Load ERROR','modal');
                ok = 0;
            end
        end
        varargout = {filename,pathname,ok};
        
    case 'load_wpdec'
        fig  = varargin{1};
        mask = varargin{2};
        txt  = varargin{3};
        ord  = varargin{4};
        [filename,pathname,ok] = utguidiv('test_load',fig,mask,txt);
        if ok
            wwaiting('msg',fig,'Wait ... loading');
            fullName = fullfile(pathname,filename);
            try
                err = 0;
                load(fullName,'-mat');
                if ~exist('tree_struct','var')
                    err = 1; var = 'tree_struct';
                elseif ~exist('data_struct','var')
                    if ~isa(tree_struct,'wptree')
                        err = 1; var = 'data_struct';
                    end
                end
                if ~err
                    order = treeord(tree_struct);
                    err = ~isequal(ord,order);
                    if err
                        msg = strvcat(sprintf('The decomposition is not a %s dimensional analysis',...
                            int2str(ord)),' ');
                    end
                else
                    msg = sprintf('variable : %s not found !', var);
                end
            catch
                err = 1;
                msg = sprintf('File %s is not a valid file.', filename);
            end
            if err
                wwaiting('off',fig);
                errordlg(msg,'Load ERROR','modal');
                ok = 0;
            end
        end
        varargout = {filename,pathname,ok};
end


%------------------------------------------------------------------------------
function [name,ext,fullName,fileStruct,err] = getFileINFO(pathname,filename)

fullName = fullfile(pathname,filename);
[name,ext] = strtok(filename,'.');
if ~isempty(ext) , ext = ext(2:end); end
try
    [fileStruct,err] = wfileinf(fullName);
    err = 0;
catch
    err = 1; fileStruct = [];
end
%------------------------------------------------------------------------------
function dispERROR_1D(fig,fileName,numMSG)

if isnumeric(numMSG)
    switch numMSG
    case 1 ,
        msg = sprintf('File %s is not a valid file.',fileName);
        
    case 2 ,
        msg = strvcat(...
		      sprintf('File %s doesn''t contain one dimensional Signal.', fileName),' ');
    case 3 ,
        msg = strvcat(...
		      sprintf('File %s is not a valid file or is empty.',fileName),' ');
    case 4 ,
        msg = strvcat(...
		      sprintf('File %s doesn''t contain a real Signal.',fileName),' ');    
    end
else
    msg = numMSG;
end
wwaiting('off',fig);
errordlg(msg,'Load Signal ERROR','modal');
%------------------------------------------------------------------------------
function dispERROR_2D(fig,fileName,numMSG)

if isnumeric(numMSG)
    switch numMSG
    case 1
        msg = strvcat(...
            sprintf('File %s is not a valid file or is empty.', fileName),' ');
    case 2
        msg = strvcat(...
            sprintf('File %s doesn''t contain an Image.', fileName),' ');
    case 3
        msg = strvcat(...
            sprintf('File %s doesn''t contain  an indexed Image.', fileName),' ');
        
    case 4
        msg = strvcat(...
		    sprintf('File %s doesn''t contain real data.', fileName),' ');
    end
else
    msg = numMSG;
end
wwaiting('off',fig);
errordlg(msg,'Load Image ERROR','modal');
%------------------------------------------------------------------------------
function [sig,err,msg] = load_1D_NotMAT(pathname,filename)

fullName = fullfile(pathname,filename);
[name,ext] = strtok(filename,'.');
if ~isempty(ext) , ext = ext(2:end); end
sig = []; err = 1; msg = '';
switch lower(ext)
case 'wav' , try , sig = wavread(fullName); err = 0; catch , msg = lasterr; end
case 'au'  , try , sig = auread(fullName);  err = 0; catch , msg = lasterr; end                
end
if ~err & size(sig,1)>1 , sig = sig'; end          
%------------------------------------------------------------------------------
function [X,map,imgFormat,colorType,err] = load_2D_NotMAT(pathname,filename)

[name,ext,fullName,fileStruct,err] = getFileINFO(pathname,filename);
switch ext
    case {'bmp','hdf','jpg','jpeg','pcx','tif','tiff','gif'}
        [info,msginfo] = imfinfo(fullName,ext);
    otherwise
        [info,msginfo] = imfinfo(fullName);
end
imgFormat = info.Format;
colorType = info.ColorType;
err = 0;
[X,map] = imread(fullName,ext);
X = double(X);
switch lower(colorType)
    case {'rgb','truecolor'}
        try
            Xrgb = 0.2990*X(:,:,1) + 0.5870*X(:,:,2) + 0.1140*X(:,:,3);
            X = round(Xrgb);
        catch
            err = 1;
        end
    case {'indexed','grayscale'}
end
%------------------------------------------------------------------------------
