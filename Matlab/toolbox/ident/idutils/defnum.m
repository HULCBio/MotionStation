function str = defnum(nos,sym,nu)
% DEFNUM  Sets Default channel names
%
%   STRING = DEFNUM(OLDSTRING,SYMBOL,NUMBER)
%
%   Example: OLDSTRING = {'Hello';'Hi';'Good_Morning'}
%            DEFNUM(OLDSTRING,'me',5) gives 
%            STRING = {'Hello';'Hi';'Good_Morning';'me4';'me5'}
%
%            DEFNUM(OLDSTRING,'me',2) gives
%            STRING = {'Hello';'Hi'}

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $ $Date: 2004/04/10 23:18:22 $

str=nos;
EmptyStr ={''};
if length(nos)>nu
    str=nos(1:nu,1);
elseif length(nos)<nu
    str = cell(nu,1);
    if ~isempty(nos)
        str(1:length(nos),1) = nos;
    end
    if isempty(sym)
        ld = EmptyStr(ones(nu-length(nos),1),1);
        str(length(nos)+1:nu,1) = ld;
    else
        for k=length(nos)+1:nu
            str{k,1}=[sym,int2str(k)];
        end
        if length(unique(str))~=length(str)
            for k=1:nu
                str{k,1}=[sym,int2str(k)];
            end
        end
    end
end

   
   
   