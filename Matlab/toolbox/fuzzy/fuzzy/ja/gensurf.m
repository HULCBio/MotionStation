% GENSURF FIS �o�̓T�[�t�F�X�̍쐬
%
% �\��
%    gensurf(fis)
%    gensurf(fis,inputs,output)
%    gensurf(fis,inputs,output,grids,refinput)
%
% �ڍ�
% gensurf(fis) �́A�ŏ���2�̓��͂ƍŏ���1�̏o�͂��g���āA�^����ꂽ
% �t�@�W�B���_�V�X�e��(fis)�̏o�̓T�[�t�F�X�v���b�g���쐬���܂��B
%
% gensurf(fis,inputs,output) �́A�x�N�g�� inputs �ƃX�J�� output �ł���
% ����^���������(1�܂���2)�Əo��(1�̂�)���g���āA�v���b�g���쐬��
% �܂��B
%
% gensurf(fis,inputs,output,grids) �́AX ����(1�ԖځA����)�� Y ����(2��
% �ځA����)�̃O���b�h����ݒ肵�܂��Bgrids ��2�v�f�x�N�g���ł���ꍇ�A
% grids �� X ������ Y�����œƗ����Đݒ肷�邱�Ƃ��ł��܂��B
%
% gensurf(fis,inputs,output,grids,refinput) �́A2��葽���o�͂������
% ���Ɏg�p���邱�Ƃ��ł�����̂ł��B�x�N�g�� refinput �̒����́A���͂̐�
% �Ɠ����ł��Brefinput �ɂ́A���̓T�[�t�F�X�Ƃ��ĕ\��������͕��� NaN ��
% �ݒ肵�A���̓��͒l�����̂܂܂ɌŒ肵�Ă��������B
%
% [x,y,z] = gensurf(...) �́A�o�̓T�[�t�F�X���`����ϐ����o�͂��A����
% �I�ȃv���b�g���s���܂���B
%
% ���
%    a = readfis('tipper');
%    gensurf(a)
%
% �Q�l    SURFVIEW, EVALFIS.



%   Copyright 1994-2002 The MathWorks, Inc. 
