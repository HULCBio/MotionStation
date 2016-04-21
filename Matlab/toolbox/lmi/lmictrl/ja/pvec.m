% �s�m�����╨���p�����[�^�̗ʂ�ݒ肵�܂��B
%
% PVEC�́A�s�m�����A�܂��́A���σp�����[�^�x�N�g��
%
%               p = ( p1, p2, ... , pk )
% 
% �̒l�͈̔͂�ω�����ݒ肵�܂��BPVEC�ɂ���Ċi�[���ꂽ�f�[�^�́A�p����
% �[�^�ˑ��V�X�e���̋L�q�Ŏg�p����܂�(PSYS���Q��)�B
%
% 2�̃^�C�v�̃p�����[�^�͈͂�ݒ肷�邱�Ƃ��ł��܂��B
%
% PV = PVEC('box',RANGE,RATE)
% 
% �{�b�N�X���̒l�Ƃ��ăp�����[�^�x�N�g����ݒ肵�܂��BK�s2��s��RANGE��
% RATE�́Apj�̏���Ɖ����A�ω���dpj/dt��ݒ肵�܂��B
%
%            RANGE(j,1)  <=    pj    <=  RANGE(j,2)
%            RATE(j,1)   <=  dpj/dt  <=  RATE(j,2)
%
% RATE���ȗ������ƁAp�́A���s�ςƉ��肳��܂��B
% �C�ӂ̑����ŕω�������s�A���ɕω�����Ȃ�΁ARATE(j,1) = -Inf�ARATE
% (j,2) = Inf�Ɛݒ肵�Ă��������B
%
% PV = PVEC('pol', [V1 V2 ... VN] )
% �p�����[�^��Ԃ̃|���g�[�v���̒l�Ƃ��ăp�����[�^�x�N�g����ݒ肵�܂��B
% ���̃|���g�[�v�̒[�_�́AP��"�[��"�lV1,V2,...,VN�ł��B
%
% �Q�l�F    PVINFO, PSYS.



% Copyright 1995-2002 The MathWorks, Inc. 
