% function csys = di2co(dsys,alpha)
%
% ���̂悤�ɒ�`���ꂽ�o�ꎟ�ϊ����g���āA���U����SYSTEM�s���A������
% SYSTEM�s��ɕϊ����܂��B
%
%         s + alpha
% z =  -  -----------
%         s - alpha
%
% �_s = j alpha�ŁAz = j�ւ̃}�b�s���O�𓾂܂��B
% ALPHA>0�̏ꍇ�A�E������(s�ɂ���)���P�ʉ~(z�ɂ���)�̊O���Ƀ}�b�s��
% �O����A���艻�������ۑ�����܂��B
%----------------------------------------------------------
% ����:����́ACO2DI�Ŏg��ꂽ���̂Ɠ����ϊ��ł͂���܂���BCO2DI�ł́A
% ���̕ϊ�
%
%          s + (1/alpha)
% z =  -  --------------
%          s - (1/alpha)
%
% ���g���܂��B���̂��߁ASYSTEM�s��SYS�ƔC�ӂ�ALPHA�ɑ΂��āASYS��CO2DI
% (DI2CO(SYS, 1/ALPHA), ALPHA)���������Ȃ�܂��B
%

% All Rights Reserved.


%   $Revision: 1.6.2.2 $  $Date: 2004/03/10 21:29:49 $
%   Copyright 1991-2002 by MUSYN Inc. and The MathWorks, Inc. 
