function [Value,error_str] = datachk(Value,str)
%DATACHK  Auxiliary function to @IDDATA/SET
%   Checks if Value contains a matrix of numeric data.
%   Makes it into a cell if it isn't

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2001/04/06 14:22:00 $

error_str=[];
str2=[str,' must be a 2D matrix of double or a cell array of such matrices.'];
if ~isa(Value,'cell'),Value={Value};end
[nr1,nc1]=size(Value{1});     
[l1,l2]=size(Value);if l1>l2,Value=Value.';end
if min(l1,l2)>1
   error_str=['If ',str,' is a cell array, it must be of dimension 1 by Ne']
else 
   for kk=1:length(Value)
       if ~isa(Value{kk},'double')| ndims(Value{kk})>2
           error_str=str2;
       end
       [nr,nc]=size(Value{kk});
       if nc~=0&nc~=nc1&(strcmp(str,'OutputData')|strcmp(str,'InputData'))
          error_str=['For multiple experiments, each cell in ',str,' must have the same number of columns'];
       end
       if nr<nc&(strcmp(str,'OutputData')|strcmp(str,'InputData'))
          warning(sprintf(['You have more channels than data.\n',...
                'Check if data matrix should be transposed.']));
       end  
    end
end
    
