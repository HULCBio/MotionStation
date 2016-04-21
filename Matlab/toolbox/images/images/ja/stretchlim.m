% STRETCHLIM �@Find limits to contrast stretch an image.
% LOW_HIGH = STRETCHLIM(I,TOL) �́A�C���[�W�̃R���g���X�g�𑝉����邽
% �߂ɁAIMADJUST �Ŏg�p�ł��鋭�x�̑g���o�͂��܂��B
%
% TOL = [LOW_FRACT HIGH_FRACT] �́A�Ⴂ���x�ƍ������x�ŖO�a����悤�ɁA
% �C���[�W�̕������w�肵�܂��B
%
% TOL ���X�J���̏ꍇ�ATOL = LOW_FRACT �� HIGH_FRACT = 1 - LOW_FRACT �ŁA
% �Ⴂ���x�l�ƍ������x�l�œ��������ɂȂ�悤�ɂ��܂��B
%
% �������ȗ�����ƁATOL �́A�f�t�H���g�ŁA[0.01 0.99]�A2% �̖O�a������
% �܂��B
%
% TOL = 0 �̏ꍇ�ALOW_HIGH = [min(I(:)) max(I(:))] �ł��B
%
% LOW_HIGH = STRETCHLIM(RGB,TOL) �́ARGB �C���[�W�̊e���ʂ̍ʓx�� 2 �s 
% 3 ��̋��x�C���[�W�ɏo�͂��܂��BTOL �́A�e���ʂ̍ʓx�ɑ΂��āA������
% �����w�肵�܂��B
%
% �N���X�T�|�[�g
% -------------
% ���̓C���[�W�́A�N���X uint8, uint16, double �̂�����ł��\���܂���B
% �o�͋��x�́A�N���X double �ŁA0 �� 1 �̊Ԃ̐��ł��B
%
% ���
% -------
%       I = imread('pout.tif');
%       J = imadjust(I,stretchlim(I),[]);
%       imshow(I), figure, imshow(J)
%
% �Q�l�F BRIGHTEN, HISTEQ, IMADJUST.



%   Copyright 1993-2002 The MathWorks, Inc.  
