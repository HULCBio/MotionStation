% ROIFILT2   �C���[�W�̑I�������Ώۗ̈�̃t�B���^�����O
% J = ROIFILT2(H,I,BW) �́AI �̒��̃f�[�^��2�����t�B���^ H ��K�p
% ���܂��BBW �́A�t�B���^�����O���Ƀ}�X�N�Ƃ��Ďg�� I �Ɠ����傫��
% �̃o�C�i���C���[�W�ł��BROIFILT2 �́ABW ��1�̕����ɑΉ�����s�N�Z
% ���Ƀt�B���^�������s�����l�� BW ��0�̕����ɑΉ�����s�N�Z���Ƀt�B
% ���^������K�p���Ȃ��l�Ƃ����킹���C���[�W���o�͂��܂��B���̍\��
% �ŁAROIFILT2 �́A�t�B���^�����s���邽�߂� IMFILTER ���Ăяo���܂��B
%
% J = ROIFILT2(I,BW,FUN) �́A�֐� FUN ���g���� I �̃f�[�^����������
% ���B���ʏo�͂���� J �́ABW ��1�̕����ɑΉ�����s�N�Z���ɑ΂��Čv
% �Z���ꂽ�l�������ABW ��0�̕����ɑΉ�����s�N�Z���� I �Ɠ����l��
% ���������̂ł��B
%
% FUN�́A4�̕��@�̂����ꂩ�Ŏw�肳���֐��ł��B4�̕��@�Ƃ́A
% �C�����C���I�u�W�F�N�g�A@�A �֐������܂ޕ�����AMATLAB�̎����܂ޕ�����
% �Ƃ��Ďw�肷��ꍇ������܂��B
%
% J = ROIFILT2(I,BW,FUN,P1,P2,...) �́A�⏕�I�ȃp�����[�^ P1,P2,... 
% �� FUN �ɓn���܂��B
%
% �N���X�T�|�[�g
% -------------
% �t�B���^ H ���܂񂾍\���ɑ΂��āA���̓C���[�W�́Auint8�Auint16�A��
% ���� double�̂�����̃N���X���T�|�[�g���Ă��܂��B�o�͔z�� J �́A�N
% ���X double �ł��B�֐����܂񂾍\���ɑ΂��āAI �� FUN �ɂ��T�|�[
% �g����Ă���N���X�ŁAJ �̃N���X�́AFUN ����̏o�͂̃N���X�Ɉˑ���
% �܂��B
%
% ���
% ----
%       I = imread('eight.tif');
%       c = [222 272 300 270 221 194];
%       r = [21 21 75 121 121 75];
%       BW = roipoly(I,c,r);
%       H = fspecial('unsharp');
%       J = roifilt2(H,I,BW);
%       imshow(I), figure, imshow(J)
%
% �Q�l  IMFILTER, FILTER2, FUNCTION_HANDLE, INLINE, ROIPOLY.



%   Copyright 1993-2002 The MathWorks, Inc.
