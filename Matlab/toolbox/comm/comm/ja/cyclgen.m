% CYCLGEN ���񕄍��̃p���e�B�`�F�b�N�s��A�����s��𐶐�
%
% H = CYCLGEN(N, P) �́A�R�[�h���[�h�̒��� N �Ɛ��������� P �ɑ΂���p��
% �e�B�`�F�b�N�s����쐬���܂��B�x�N�g�� P �́A���x�L�̏��ɐ�����������
% �o�C�i���W����^���܂��BP �������� X^N-1 �̌W���ł���ꍇ�A������ P �́A
% ���񕄍��݂̂𐶐����邱�Ƃ��\�ł��B���̕������̃��b�Z�[�W�̒�����
% K = N - M �ł��B���̂Ƃ��AM �� P �̎����ł��B�p���e�B�`�F�b�N�s���
% M�sN��̍s��ł��B
% 
% H = CYCLGEN(N, P, OPT) �́AOPT �Ŏw�肵���w���Ɋ�Â��āA�p���e�B�`�F�b�N
% �s����쐬���܂��B
% OPT = 'nonsys' �̏ꍇ�A���̊֐��͔�g�D����p���e�B�`�F�b�N�s����쐬
% ���܂��B
% OPT = 'system' �̏ꍇ�A���̊֐��͑g�D����p���e�B�`�F�b�N�s����쐬
% ���܂��B���̃I�v�V�����̓f�t�H���g�ł��B
% 
% [H, G] = CYCLGEN(...) �́A�����s�� G �ƃp���e�B�`�F�b�N�s��H���쐬
% ���܂��B�����s��́AK = N - M �� K �s N ��̍s��ł��B
% 
% [H, G, K] = CYCLGEN(...) �́A���b�Z�[�W�̒��� K ���o�͂��܂��B
% 
% �Q�l�F ENCODE, DECODE, BCHPOLY, CYCLPOLY.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $
