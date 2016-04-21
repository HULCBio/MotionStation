function int_table = cdma2k_inttable(numSamp, rc);
% Generates interleaver table for Radio Configuration 3
% NumSamp is the total number of samples at the input of the interleaver
% and rc is an integer number corresponding to the Radio Configuration
%
% int_table = cdma2k_inttable(numSamp, rc);

% Copyright 2004 The MathWorks, Inc.


intPar = [48 4 3; 96 5 3; 192 6 3; 384 6 6; 768 6 12; 1536 6 24; 3072 6 48]; % not completed

%-- Get m, J parameters
pos = find(intPar(:,1)==numSamp);
m = intPar(pos,2);
J = intPar(pos,3); 

switch(rc)
    
    case 3,
        
        % Even interleaved Symbol
        i = [0:2:numSamp-2]';
        x = i/2;
        Aeven = 2^m*(mod(x,J))+ bi2de(de2bi(floor(x/J),m,'left-msb'),'right-msb');
        
        % Odd interleaved Symbol
        i = [1:2:numSamp-1]';
        x= numSamp - (i+1)/2;
        Aodd =  2^m*(mod(x,J))+ bi2de(de2bi(floor(x/J),m,'left-msb'),'right-msb');
        
       int_table = reshape([Aeven Aodd]',numSamp,[]) + 1;
        
    otherwise
        int_table = [];
end

%end of cdma2k_inttable 
