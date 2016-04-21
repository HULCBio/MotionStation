% SGOLAY �́ASavitzky-Golay�t�B���^��݌v���܂��B
%
% B = SGOLAY(K,F) �́ASavitzky-Golay(������)FIR �������t�B���^ B ��݌v
% ���܂��B�������̎��� K �́A�t���[���T�C�Y F �����������Ȃ���΂Ȃ��
% ����B�܂��AF �͊�łȂ���΂Ȃ�܂���B
% 
% �������̎��� K = F-1 �̏ꍇ�A�݌v�����t�B���^�́A����������Ă��܂�
% ��B
%
% SGOLAY(K,F,W) �́A���� F �̏d�݃x�N�g�� W ��ݒ肵�܂��B����́A�ŏ���
% ��I�ȍŏ����ߒ��Ŏg���鐳�̎����l�d�݂ł��B 
% 
% [B,G] = SGOLAY(...) �́A�����t�B���^�̍s��G���o�͂��܂��BG�̊e��́AP-
% 1�K�̔��W���ɑ΂�������t�B���^�ł��B�����ŁAP�͗�C���f�b�N�X�ł��B��
% ��F�̐M��X��^�����ꍇ�A���̒����l��P�K�����̐���́A���̌^���狁��
% �邱�Ƃ��ł��܂��B
%
%        ^(P)
%        X((F+1)/2) = P!*G(:,P+1)'*X
%
% �Q�l�FSGOLAYFILT, FIR1, FIRLS, FILTER



%   Copyright 1988-2002 The MathWorks, Inc.
