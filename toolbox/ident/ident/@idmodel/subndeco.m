function [yind,uind,returnflag,flagmea,flagall,flagnoise,flagboth] = ...
   subndeco(idm,index,lam)
% SUBNDECO Decodes the calls for subsref

%   $Revision: 1.8.4.1 $  $Date: 2004/04/10 23:17:46 $
%   Copyright 1986-2002 The MathWorks, Inc.


yind =[];
uind =[];
flagall = 0;
flagmea = 0;
flagnoise = 0;
flagboth = 0;
returnflag = 0;
ny = length(idm.OutputName);
nu = length(idm.InputName);
if length(index)==1 % then make a nice interpretation
   if ischar(index{1})&isempty(strmatch(index{1},idm.OutputName,'exact')) ...
         &any(strcmp(lower(index{1}(1)),{'n','m','a','b'}))
      index{2}=index{1};
      index{1}=':';
      
   elseif ny ==1 & nu >0
      index{2} = index{1};
      index{1}=':';
   elseif nu==1
      index{2}=':';
   elseif nu==0
      index{2} = [];
   else
      error('For a multi-input-multi-output system both indices S(ny,nu) must be given.')
   end
end

if length(index)>2&strcmp(index{3},'s')
   silent = 1;
else 
   silent = 0;
end

if (strcmp(index(1),':')&strcmp(index{2},':'))
    returnflag = 1;
    return
end
try
    if (strcmp(index(1),':')&strcmp(lower(index{2}(1)),'m')&norm(lam)==0)
        returnflag = 1;
        return
    end
end

[yind,errflagy] = indmatch(index{1},idm.OutputName,ny,'Output');
flagnoise = 0;
if ~silent
   error(errflagy)
else
   if ~isempty(errflagy)
      returnflag = 3;
      return
   end
end
if nu == 0
    
    if length(index{2})>0
        ind = index{2};
        if ischar(ind)
            tm = idchnona(ind);
            if strcmp(tm,'measured')
                flagmea = 1;
                returnflag = 3;
                return
                
            elseif strcmp(ind,'allx9')|strcmp(ind,'all')%'all' temp allowed for compatibility
                flagall = 1;
                return
            elseif strcmp(ind,'bothx9')
                flagboth = 1;
                return
            elseif ~strcmp(tm,'noise')&~strcmp(ind,':')
                error('Unknown input channel name')
            end
        end
        %       if strcmp(lower(index{2}(1)),'a')
        %          flagall = 1;
        %          return
        %       end
        %       if strcmp(lower(index{2}(1)),'b')  %% both
        %          flagboth = 1;
        %          return
        %       end
        %       if strcmp(lower(index{2}(1)),'m')
        %          flagmea = 1;
        %          returnflag = 3;
        %          return
        %       end
        if isa(index{2},'double')& index{2}>0
            error('Input index exceeds number of inputs (0).')
        end
    end
    index{2}=[];
    try
        if all(yind==[1:ny])&~flagall
            returnflag = 1;
            
        end
    catch
    end
    return
end

[uind,errflagu,flagmea,flagall,flagnoise,flagboth] = indmatch(index{2},idm.InputName,...
    nu,'Input',lam);
if ~silent
    error(errflagu)
else
    if ~isempty(errflagu)
        returnflag = 3;
        return
    end
end

try
    if ~flagall&~flagmea
        if (isempty(uind))
            if all(yind ==[1:ny])&nu==0
                returnflag = 1;
            end
        elseif all(uind==[1:nu])
            if all(yind ==[1:ny])
                returnflag = 1;
            end
            
        end
    end
catch
end

if (flagnoise&(norm(lam)==0|isempty(lam)))|(flagmea&nu==0)
    returnflag = 2;
    return
end

