function pilotBits = wcdma_pilotbitgenerator(numPilotBits)
% WCDMA_PILOTBITSGENERATOR Sets up workspace variables for the 
% Time-multiplexed pilot bits generator included in the Wcdma application examples.

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.2 $  $Date: 2002/04/11 00:48:51 $

switch(numPilotBits)
    
case 2
    pilotBits = num2str([11; 00; 01; 00; 10; 11; 11; 10; 01; 11; 01; 10; 10; 00; 00]);
 
case 4
   pilotBits = num2str([1111; 1100; 1101; 1100; 1110; 1111; 1111; 1110; 1101; 1111; 1101; 1110; 1110; 1100; 1100]);

case 8
    pilotBits = num2str([11111110; 11001110; 11011101; 11001100;  
            11101101; 11111110;  11111100; 11101100;...
            11011110; 11111111;  11011101; 11101111;...
            11101100; 11001111;  11001111]);
    
case 16
    pilotBits = num2str([1111111011111110; 1100111011111100;...
            1101110111101100;  1100110011011110;...
            1110110111111111;  1111111011011101;...
            1111110011101111;  1110110011101100;...
            1101111011001111;  1111111111001111;...
            1101110111111110;  1110111111001110;...
            1110110011011101;  1100111111001100;...
            1100111111101101], '%16.0f');
end

% Convert bit string to integer
pilotBits = bin2dec(pilotBits)';