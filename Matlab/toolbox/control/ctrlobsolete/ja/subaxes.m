% SUBAXES   �����^�C����ɍ쐬
% 
% [SubAxes,OtherAxes,NumDeleted] = SUBAXES(P,M,Position,FIG,Offset) �́A
% FIG �E�C���h�D�̐��K���\���Ŏw�肳�ꂽ Position �������Ȏ��� P �s M ��
% �̍s��ɕ������A���ꂼ��̎��n���h���ԍ�����̃x�N�g���ɂ܂Ƃ߂ďo��
% ���܂��B���́A������ɏ����t�����܂��BOtherAxes �́Afigure�̒���
% ���̎��̃x�N�g���ŁANumDeleted �́ASUBAXES �ō폜���ꂽ���̔ԍ��ł��B
%
% �I�v�V�����̈��� Position �� FIG �̃f�t�H���g�́A���ꂼ��Aget(FIG,
% 'DefaultAxesPosition') �� newfig �ł��BOffset �́A�}�����ꂽ���� Pos-
% ition �Ŏw�肳�ꂽ�O���G�b�W����̊����ł��B�f�t�H���g�ł́AOffset �� 
% [0.01 0.01] �ł��B�ŏ��̗v�f�͐��������̃I�t�Z�b�g�ŁA2�Ԗڂ̗v�f�͐�
% �������̃I�t�Z�b�g�ł��Bp = 1 �̏ꍇ�AOffset(2) = 0 �ɂȂ�܂��Bm = 1 
% �̏ꍇ�AOffset(1) = 0 �ɂȂ�܂��B����ŁAsubaxes(1,1) �́A�������
% ����Ƃ��čl�����ꍇ�Ɠ����ʒu�Ɏ���^���܂��B
%
% �T�u���̑g�����������̓����ʒu�ɑ��݂���ꍇ�ASUBAXES �́A�����̎���
% �n���h�����o�͂��܂��B���̊֐��́A�Â������폜�����A�V���������쐬����
% ����B
%
% ����ASUBAXES �́APosition �ƌ������鎲���폜���܂����APosition �Ō���
% �Ɉ�v����(�P)���͍폜���܂���B
%
% ���ӁF
% ���ׂĂ̎��̒P�ʂ́A���K������Ă���Ɖ��肵�܂��B
% Box �v���p�e�B�� on �ɂȂ��Ă��鎲���쐬���܂��B
% X/YTickLabelMode �Ɋւ���m�����K�����Ă��������B


%       Author(s): A. Potvin, 10-1-94
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $  $Date: 2003/06/26 16:08:26 $
