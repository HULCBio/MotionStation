%  function dsys = co2di(csys,alpha)
%
% ���̂悤�ɒ�`���ꂽ�o�ꎟ�ϊ����g���āA�A������SYSTEM�s��𗣎U����
% SYSTEM�s��ɕϊ����܂��B
%
%          1     z-1
%   s = ------- -----
%        alpha   z+1
%
%                    j
% �_ z = j�́As = -------�ւ̃}�b�s���O�𓾂܂��B
%                  alpha
%
% ALPHA>0�̏ꍇ�A�E������(s�ɂ���)���P�ʉ~(z�ɂ���)�̊O���Ƀ}�b�s��
% �O����A���艻�������ۑ�����܂��B
%----------------------------------------------------------
% ����:����́ADI2CO�Ŏg��ꂽ���̂Ɠ����ϊ��ł͂���܂���BDI2CO�ł́A
% ���̕ϊ�
%
%            z-1
% s = alpha -----
%            z+1
%
% ���g���܂��B���̂��߁ASYSTEM�s��SYS��C�ӂ�ALPHA�ɑ΂��āASYS��CO2DI
% (DI2CO(SYS, 1/ALPHA), ALPHA)���������Ȃ�܂��B
%

% All Rights Reserved.


%   $Revision: 1.6.2.2 $  $Date: 2004/03/10 21:29:36 $
%   Copyright 1991-2002 by MUSYN Inc. and The MathWorks, Inc. 
