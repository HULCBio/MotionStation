% D2C   ���U����LTI���f����A�����Ԃɕϊ�
%
% SYSC = D2C(SYSD,METHOD) �́A���U����LTI���f�� SYSD �Ɠ����ȘA������
% ���f�� SYSC ���쐬���܂��B
% 
% ������ METHOD �́A���̒����痣�U����@��I�����܂��B
%
%   'zoh'       ���͂�0���z�[���h��K�p
%   'tustin'    �o1��(Tustin)�ߎ�
%   'prewarp'   �ϊ��O�ƕϊ���ŁA�ݒ肵��(�ՊE)���g���ŁA��������v����
%               ����̂��ƂŁATustin �ߎ����s���܂��B�ՊE���g��Wc(rad/s)
%               �́ASYSD = C2D(SYSC,TS,'prewarp',Wc) �Őݒ肷��悤�ɁA
%               4�Ԗڂ̓��͈����Ƃ��Đݒ肵�܂��B
%   'matched'   Matched pole-zero �@(SISO�V�X�e���̂�)
% 
% METHOD ���ȗ������ƁA�f�t�H���g�̎�@ 'zoh' ���p�����܂��B
%
% �Q�l : C2D, D2D, LTIMODELS.


%   Clay M. Thompson  7-19-90
%   Revised: P. Gahinet  8-27-96
%   Copyright 1986-2002 The MathWorks, Inc. 
