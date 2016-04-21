function tex2 = display(m,conf1,ku,nuend,bf,df)
%DISPLAY   Pretty-print for IDPROC models.
%
%   DISPLAY(SYS) is invoked by typing SYS followed
%   by a carriage return.   .
%

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.12.4.1 $ $Date: 2004/04/10 23:17:05 $

if nargin <2
    conf1 = 0;
end
if nargin<3
    ku=0;
end
if nargin<4
    nuend=0;
end
if nargin<5
    bf = 1;
end
if nargin<6
    df = 1;
end
covm = pvget(m,'CovarianceMatrix');
conf = conf1;
if ischar(covm)|isempty(covm)
    conf = 0;
end
type = i2type(m);%m.Type;
div = repmat('-',1,100);
bl = repmat(' ',1,100);
%df = 1;%1.8; %factor for dividing line;
%bf =1;%1.5; %factor for blank
nu = length(type);
if nu>1
    if nu>2
        extra = [' + ...+ '];
    else
        extra = [' + '];
    end
    texnu = sprintf(['Process model with %d inputs: y = G_1(s)u_1',...
            extra,'G_%d(s)u_%d'],nu,nu,nu);
    
    for ku = 1:nu
        lsub.type='()';
        lsub.subs = {[1],ku};
        mku= subsref(m,lsub);
        if ku==nu,nuend = 0;else nuend = 1;end
        texku = display(mku,conf,ku,nuend,bf,df);
        texnu = char({texnu;texku});
    end
    if nargout
        tex2 = texnu;
    else
        disp(texnu);
    end
    return
end
if iscell(type)
    type = type{1};
end 
if ku==0
    tex1 = 'Process model with transfer function';
elseif ku==1
    tex1 = 'where';
else
    tex1 ='';
end
% if nargout == 0
%     disp(tex1)
% end
%disp('G(s) = K(1+T1*s)/s(1+T2*s)')
par = pvget(m,'ParameterVector');
if conf
dpar = sqrt(diag(pvget(m,'CovarianceMatrix')));
end
sep = '-';
bl = ' ';
if ku==0
    gg = 'G';
    ebla = 0;
else
    gg = ['G_',int2str(ku)];
    ebla = 2;
end
if any(type=='Z')
    start = ceil((11+ebla)*bf); %Number of chars in middle line
else
    start = ceil((7+ebla)*bf);
end

blstart = bl(ones(1,start));
if any(type=='D') 
    del = ' * exp(-Td*s)';
else
    del = '';
end

switch eval(type(2))
    case 0
        if any(type=='I')
            num = [bl(ones(1,ceil(11*bf))),'s'];
            sh='';
        end
        if conf
            txt = sprintf('with   K = %0.5g+-%0.5g',par(1),dpar(1));
        else
            txt = char({'',sprintf('with   K = %0.5g',par(1))});
        end
        
        if any(type=='D')
            if conf
                txt=char({txt,sprintf('      Td = %0.5g+-%0.5g',par(2),dpar(1))});
            else
                txt=char({txt,sprintf('      Td = %0.5g',par(2))});
            end
            
        end
        if ~any(type=='I')
            mod = sprintf([gg,'(s) = K',del]);
            % disp(sprintf(['\n',gg,'(s) = K',del]))
        else
            mod = char({[bl(ones(1,ceil(8*bf))),'K'],[gg,'(s) = ',div(1:ceil(3*df)),del],'        s'});
            %disp('         K')
            %disp(['G(s) =  ---',del])
            %disp(['         s'])
        end
    case 1
        if conf
            txt = sprintf('\nwith   K = %0.5g+-%0.5g\n     Tp1 = %0.5g+-%0.5g',par(1),dpar(1),par(2),dpar(2));
        else
            txt = char({'',sprintf('with   K = %0.5g',par(1)),sprintf('     Tp1 = %0.5g',par(2))});
        end
        
        if any(type=='I')
            if any(type=='Z')
            blden = bl(ones(1,ceil(8*bf)));
        else
                        blden = bl(ones(1,ceil(8*bf)));
                    end
            num = [blden,'s(1+Tp1*s)'];%was ceil(8*bf)
            sh = ' ';
        else
            if any(type=='Z')
                blden = bl(ones(1,start-1));
            else
                blden = bl(ones(1,start+1));
            end
            num =[blden,'1+Tp1*s'];
            sh ='';
        end
        
        if any(type=='D')
            if conf
                txt=[txt,sprintf('\n      Td = %0.5g+-%0.5g',par(3),dpar(3))];
            else
                txt=char({txt,sprintf('      Td = %0.5g',par(3))});
            end
            
            if any(type=='Z')
                if conf
                    txt=[txt,sprintf('\n      Tz = %0.5g+-%0.5g',par(4),dpar(4))];
                else
                    txt=char({txt,sprintf('      Tz = %0.5g',par(4))});
                end
                
            end
        elseif any(type=='Z')
            if conf
                txt=[txt,sprintf('\n      Tz = %0.5g+-%0.5g',par(3),dpar(3))];
            else
                txt=char({txt,sprintf('      Tz = %0.5g',par(3))});
            end
        end
        
        
        
        if any(type=='Z')
           streck = div(1:ceil(10*df));
             mod = char({[bl(ones(1,start+1)),'1+Tz*s'],...
                     [gg,'(s) = K * ',streck,del],...
                    [bl(ones(1,ceil(2*bf))),num]});
        else
                            numbl =bl(ones(1,ceil(11*bf)));
              if any(type=='I')
                streck = div(1:ceil(12*df));
            else
                                streck = div(1:ceil(10*df));
                            end
            mod = char({[sh,numbl,'K'],...
                    [gg,'(s) = ',streck,del],num});
            
        end
        
    case 2
        if ~any(type=='U')
            part1 = ' Tp1';
            part2 = ' Tp2';
        else
            part1 = '  Tw';
            part2 = 'Zeta';
        end
        if conf
            txt = sprintf(['\nwith    K = %0.5g+-%0.5g\n     ',part1,' = %0.5g+-%0.5g'],par(1),dpar(1),par(2),dpar(2));
            txt = [txt,sprintf(['\n     ',part2,' = %0.5g+-%0.5g'],par(3),dpar(3))];
        else
            txt = char({'',sprintf(['with    K = %0.5g'],par(1)),...
                    sprintf(['     ',part1,' = %0.5g'],par(2))});
            txt = char({' ',txt,sprintf(['     ',part2,' = %0.5g'],par(3))});
        end
        if any(type=='D')
            if conf
                txt=[txt,sprintf('\n       Td = %0.5g+-%0.5g',par(4),dpar(4))];
            else
                txt=char({txt,sprintf('       Td = %0.5g',par(4))});
            end
            if any(type=='Z')
                if conf
                    txt=[txt,sprintf('\n       Tz = %0.5g+-%0.5g',par(5),dpar(5))];
                else
                    txt=char({txt,sprintf('       Tz = %0.5g',par(5))});
                end
            end
        elseif any(type=='Z')
            if conf
                txt=[txt,sprintf('\n       Tz = %0.5g+-%0.5g',par(4),dpar(4))];
            else
                txt=char({txt,sprintf('       Tz = %0.5g',par(4))});
            end
        end
        
        if any(type=='I')
            if any(type=='U')
                num = [blstart,'s(1+2*Zeta*Tw*s+(Tw*s)^2)'];
            else
                num = [blstart,'s(1+Tp1*s)(1+Tp2*s)'];
            end
            sh = ' ';
        else
            if any(type=='U')
                num =[blstart,'1+2*Zeta*Tw*s+(Tw*s)^2'];
            else
                num =[blstart,'(1+Tp1*s)(1+Tp2*s)'];
            end
            sh ='';
        end
        
        if any(type=='Z')
            mid = fix((length(num)/bf-start)/2) + start -4;
           % mod = sprintf([bl(ones(1,mid)),'1+Tz*s',...
            %        '\n',gg,'(s) = K * ',sep(ones(1,length(num)-start)),del,'\n',num]);
             mod = char({[bl(ones(1,ceil(mid*bf))),'1+Tz*s'],...
                    [gg,'(s) = K * ',sep(ones(1,ceil((length(num)-start)*df))),del],[num]});
            % mod = sprintf(['                  1+Tz*s\n',gg,'(s) = K * -------------------',del,'\n   ',num]);
            
        else
            mid = fix((length(num)/bf-start)/2) + start -2;
            mod = sprintf([bl(ones(1,ceil(mid*bf))),'K',...
                    '\n',gg,'(s) = ',sep(ones(1,ceil((length(num)-start)*df))),del,'\n',num]);
              mod = char({[bl(ones(1,ceil(mid*bf))),'K'],...
                    [gg,'(s) = ',sep(ones(1,ceil((length(num)-start)*df))),del],num});
            %mod = sprintf([sh,'                K\n',gg,'(s) =  -------------------',del,'\n',num]);
            
        end
    case 3
        if ~any(type=='U')
            part1 = ' Tp1';
            part2 = ' Tp2';
        else
            part1 = '  Tw';
            part2 = 'Zeta';
        end
        if conf
            txt = sprintf(['\nwith    K = %0.5g+-%0.5g\n     ',part1,' = %0.5g+-%0.5g'],par(1),dpar(1),par(2),dpar(2));
            txt = [txt,sprintf(['\n     ',part2,' = %0.5g+-%0.5g\n      Tp3 = %0.5g+-%0.5g'],...
                    par(3),dpar(3),par(4),dpar(4))];
        else
            txt = char({'',sprintf(['with    K = %0.5g'],par(1)),...
                        sprintf(['     ',part1,' = %0.5g'],par(2))});
            txt = char({txt,sprintf(['     ',part2,' = %0.5g'],par(3))...
                    sprintf(['      Tp3 = %0.5g'],par(4))});
        end
        if any(type=='D')
            if conf
                txt=[txt,sprintf('\n       Td = %0.5g+-%0.5g',par(5),dpar(5))];
            else
                txt=char({txt,sprintf('       Td = %0.5g',par(5))});
            end
            if any(type=='Z')
                if conf
                    txt=[txt,sprintf('\n       Tz = %0.5g+-%0.5g',par(6),dpar(6))];
                else
                    txt=char({txt,sprintf('       Tz = %0.5g',par(6))});
                end
            end
        elseif any(type=='Z')
            if conf
                txt=[txt,sprintf('\n       Tz = %0.5g+-%0.5g',par(5),dpar(5))];
            else
                txt=char({txt,sprintf('       Tz = %0.5g',par(5))});
            end
        end
        
        if any(type=='I')
            if any(type=='U')
                num = [blstart,'s(1+2*Zeta*Tw*s+(Tw*s)^2)(1+Tp3*s)'];
            else
                num = [blstart,'s(1+Tp1*s)(1+Tp2*s)(1+Tp3*s)'];
            end
            sh = ' ';
        else
            if any(type=='U')
                num =[blstart,'(1+2*Zeta*Tw*s+(Tw*s)^2)(1*Tp3*s)'];
            else
                num =[blstart,'(1+Tp1*s)(1+Tp2*s)(1+Tp3*s)'];
            end
            sh ='';
        end
        
        if any(type=='Z')
            mid = fix((length(num)/bf-start)/2) + start -4;
            mod = char({[bl(ones(1,ceil(mid*bf))),'1+Tz*s'],...
                    [gg,'(s) = K * ',sep(ones(1,ceil((length(num)-start)*df))),del],num});
            
        else
            mid = fix((length(num)/bf-start)/2) + start-2;
            mod = char({[sh,bl(ones(1,ceil(mid*bf))),'K'],[gg,'(s) = ',...
                    sep(ones(1,ceil((length(num)-start)*df))),del],num});
            
        end
        
end
tex1 = char({tex1,mod,txt});%str2mat(tex1,mod,txt);
% if nargout == 0
%     disp(txt)
% else
%     tex = str2mat(tex1,txt);
% end
if ~nuend
    dist = pvget(m,'DisturbanceModel');
    
    if iscell(dist)&~strcmp(dist{1},'None')
        [a,b,c,d,f,da,db,dc] = polydata(dist{2});
        noi = char({' ',['An additive ARMA disturbance model has been estimated:'],...
                ['    y = G u + (C/D)e'],['with']});
        dch = 's'; nchar = 60;
        if nargin==1
            dc =[];da=[];
        end
        str1=sformat(['C(',dch,') = ',...
                poly2str(c,dch,dc)],'+-',nchar);
        str2=sformat(['D(',dch,') = ',...
                poly2str(a,dch,da)],'+-',nchar);
        noi = char({noi,str1,str2,' '});
    else
        noi = [];
    end
    estim = pvget(m,'EstimationInfo');
    switch lower(estim.Status(1:3))
        case {'est','mod'}
            DN = estim.DataName;
            if ~isempty(DN)
                str = char({sprintf('Estimated using %s from data set %s',...
                        estim.Method,DN),sprintf('Loss function %g and FPE %g',...
                    estim.LossFcn, estim.FPE)});
            else
                str = char({sprintf('Estimated using %s',estim.Method),...
                        sprintf('Loss function %g and FPE %g',...
                    estim.LossFcn, estim.FPE)});
            end
            % case 'mod'
            %str = sprintf('Originally estimated using %s (later modified).',...
             %   estim.Method);
        case 'not'
            str = sprintf('This model was not estimated from data.');
        case 'tra'
            str = sprintf('Model translated from the old Theta-format.');
        otherwise
            str = [];
    end
    txt = str;
    
    if conf1
        txt=str2mat(txt,timestamp(m));
    end
    txt = str2mat(txt,' ');
    tex1 = str2mat(tex1,noi,txt);
end %if nuend
if ~nargout
    disp(tex1)
else
    tex2 = str2mat([],tex1);
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

