% LATC2TF ���e�B�X�t�B���^��`�B�֐��ɕϊ�
% [NUM,DEN] = LATC2TF(K,V) �́A���e�B�X�W��K�ƃ��_�[�W��V������IIR�t�B��
% �^���番�qNUM�A����DEN�����`�B�֐������߂܂��B
%
% [NUM,DEN] = LATC2TF(K,'allpole') �ł́AK�͑S��IIR���e�B�X�t�B���^�Ɋ�
% �A���Ă���Ɖ��肵�܂��B
%
% [NUM,DEN] = LATC2TF(K,'allpass') �ł́AK�̓I�[���p�X��IIR���e�B�X�t�B
% ���^�Ɋ֘A���Ă���Ɖ��肵�܂��B
%
% NUM = LATC2TF(K)��NUM = LATC2TF(K,'fir')�́AK��FIR�t�B���^�\����
% �֘A���A�\���̏�o�͂����p�����Ɖ��肵�܂�
% (FIR�ɑ΂���LATCFILT�̑��o�͂ɑΉ�)�B
%
% NUM = LATC2TF(K,'min')�́Aabs(K) <= 1�̂Ƃ��AK���ŏ��ʑ�FIR���e�B�X
% �t�B���^�\���Ɋ֘A����Ɖ��肵�܂��B
%
% NUM = LATC2TF(K,'max'),�́Aabs(K) <= 1�̂Ƃ��AK���ő�ʑ�FIR���e�B�X 
% �t�B���^�\���Ɋ֘A���A�\���̉��o�͂����p�����Ɖ��肵�܂�(FIR�ɑ΂�
% ��LATCFILT�̑��o�͂ɑΉ�)�B
%
% �Q�l�FLATCFILT, TF2LATC.



%   Copyright 1988-2002 The MathWorks, Inc.
