% CONVENC  �o�C�i���f�[�^����ݍ��ݕ�����
%
% CODE = CONVENC(MSG,TRELLIS) �́AMATLAB �\���� TRELLIS �Œ�`�������
% ���ݕ�������g���āA�o�C�i���x�N�g�� MSG �𕄍������܂��BTRELLIS �\��
% �̂Ɋւ��ẮAPOLY2TRELLIS �� ISTRELLIS ���Q�Ƃ��Ă��������B�������
% ��Ԃ̓I�[���[������n�܂�܂��BMSG �̊e�V���{���́A
% log2(TRELLIS.numInputSymbols)�r�b�g����\������Ă��܂��BMSG �́A
% �P���A�܂��́A�����̃V���{�����܂�ł��܂��BCODE �́AMSG �Ɠ���������
% �x�N�g��(��x�N�g���A�܂��́A�s�x�N�g��)�ŁA���̃V���{���̊e�X�́A
% log2(TRELLIS.numInputSymbols) �r�b�g����\������Ă��܂��B
%
% CODE = CONVENC(MSG,TRELLIS,INIT_STATE) �́A������̃��W�X�^���AINIT_STATE 
% �Őݒ肳����ԂŎn�܂邱�ƈȊO�́A��̃V���^�b�N�X�Ɠ����ł��B
% INIT_STATE �́A0��TRELLIS.numStates - 1�̊Ԃ̐����ł��BINIT_STATE ��
% �f�t�H���g�l���g���ɂ́A0�܂���[]�Ǝw�肵�Ă��������B
%
% [CODE FINAL_STATE] = CONVENC(...) �́A���̓��b�Z�[�W������������A
% ������̍ŏI��� FINAL_STATE ���o�͂��܂��B
%
% ���F
%      t = poly2trellis([3 3],[4 5 7;7 4 2]);
%      msg = [1 1 0 1 0 0 1 1];
%      [code1 state1]=convenc([msg(1:end/2)],t);
%      [code2 state2]=convenc([msg(end/2+1:end)],t,state1);
%      [codeA stateA]=convenc(msg,t);
%    
% �������ʂ��A[code1 code2] �� codeA �ɏo�͂���܂��B�ŏI��� state2 �� 
% stateA ���܂����������̂ł��B
%
% �Q�l�F VITDEC, POLY2TRELLIS, ISTRELLIS.


% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.5.4.1 $  $Date: 2003/06/23 04:34:17 $
% Calls convcore.c
