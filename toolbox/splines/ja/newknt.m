% NEWKNT   �V�����u���[�N�|�C���g�̕��z
%
% [NEWKNOTS,DISTFN] = NEWKNT(F,NEWL) �́A(F �Ɠ��������̃X�v���C����
% �΂���)�ߓ_�� NEWKNOTS ���o�͂��܂��B���̗�́AF �̍��������Ɋ֘A����
% ����̐��`�P���֐�(����pp-�^�� DISTFN �ɏo�͂���܂�)�����������z����
% �悤�ɂ��āAF �̊�{��Ԃ�NEWL�̗v�f�ɐؒf���܂��B
%
% ���̖ړI�́A�֐� g �� F �ɂ����郉�t�ȋߎ����Ag �Ɋւ���\���ȏ���
% �܂ނƉ��肵�A�K�؂ȋߎ��ɓK�����ߓ_���I�Ԃ��Ƃł��B
% 
% ���Ƃ��΁A
%
%      sp = spap2(augknt(linspace(X(1),X(end),M+1),K),K,X,Y);
%
% �ɂ���ē���ꂽM-1�̓��Ԋu�̓����̐ߓ_������K���̃X�v���C���ɂ���āA
% �^����ꂽ�f�[�^ X,Y �̍ŏ����ߎ��𓾂���ŁA
%
%      sp = spap2(newknt(sp),K,X,Y);
%
% �ɂ����(�����v�f�̐�������)���K�؂ȋߎ��𓾂邱�Ƃ��ł��܂��B
%
% �Q�l : OPTKNT, APTKNT, AVEKNT.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
