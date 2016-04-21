function [y1,y2]=convsample(x1,x2)

if nargin==1
    
    if isa(x1,'char')
        
        index=find(x1==',');
        if isempty(index)
            y2=str2num(x1);
            y1=0;
        else
            y1=str2num(x1(1:index-1));
        	y2=str2num(x1(index+1:end));
        end
        
    end
    
    if isa(x1,'double')
        
        y1=num2str(x1);
        
    end
    
end

if nargin==2
    
    if x1~=0
    	y1=[num2str(x1),',',num2str(x2)];
    else
        y1=num2str(x2);
    end
    
end

        
        
        
        

%   Copyright 2000-2002 The MathWorks, Inc.
%   $Revision: 1.2.2.1 $  $Date: 2004/04/08 21:04:27 $
