% function weight = fow(dcval,bw,ginf)
%
% ���̃v���p�e�B���������1���V�X�e��WEIGHT���쐬���܂��B
%
% WEIGHT(0) = dcval
% WEIGHT(inf) = ginf
% |WEIGHT(j*abs(bw))| = 1
%
% ���̂����̂����ꂩ�łȂ���΂Ȃ�܂���B
%
% |dcval| < 1 < |ginf|
%  �܂���
% |dcval| > 1 > |ginf|

%   $Revision: 1.6.2.2 $  $Date: 2004/03/10 21:30:30 $
%   Copyright 1991-2002 by MUSYN Inc. and The MathWorks, Inc. 
