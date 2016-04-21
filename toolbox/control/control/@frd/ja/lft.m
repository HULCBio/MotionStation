% LFT   LTI�V�X�e���� Redheffer �X�^�[�ς��쐬
%
%
% SYS = LFT(SYS1,SYS2,NU,NY) �́A2��LTI���f�� SYS1 �� SYS2 �̃X�^�[��SYS
% ���v�Z���܂��B�X�^�[�ρA�܂��́A���`�����ϊ�(LFT)�́A���� SYS1�� SYS2 ��
% �t�B�[�h�o�b�N�����ɑΉ����܂��B
%
%                         +-------+
%             w1 -------->|       |-------> z1
%                         |  SYS1 |
%                   +---->|       |-----+
%                   |     +-------+     |
%                 u |                   | y
%                   |     +-------+     |
%                   +-----|       |<----+
%                         |  SYS2 |
%            z2 <---------|       |-------- w2
%                         +-------+
%
% �t�B�[�h�o�b�N���[�v�́ASYS2 �̍ŏ��� NU �̏o�͂� SYS1 �̍Ō�� NU��
% ����(�M�� u)�ƌ������ASYS1 �̍Ō�� NY �̏o�͂� SYS2 �̍ŏ��� NY�̓���
% (�M�� y)���������܂��B���ʂ�LTI���f�� SYS �́A���̓x�N�g��[w1;w2]���o��
% �x�N�g�� [z1;z2] �Ƀ}�b�s���O���܂��B
%
% SYS = LFT(SYS1,SYS2) �́A���̃V�X�e�����o�͂��܂��B * SYS2 �� SYS1 ����
% ���Ȃ����͐���o�͐��̏ꍇ�ASYS1 �� SYS2 �̉����� LFT�B��̐}�ł́Aw2,z2��
% �폜���܂��B * SYS1 �� SYS2 �������Ȃ����͐���o�͐��̏ꍇ�ASYS1 �� SYS2
% �̏㑤�� LFT�B��̐}�ł́Aw1,z1���폜���܂��B
%
% SYS1 �� SYS2 ���ALTI���f���̔z��̏ꍇ�ALFT�́A���Ɏ����悤�ɁA����
% ������LTI�z�� SYS ���o�͂��܂��B 
%   SYS(:,:,k) = LFT(SYS1(:,:,k),SYS2(:,:,k),NU,NY) .
%
% �Q�l : FEEDBACK, CONNECT, LTIMODELS.


% Copyright 1986-2002 The MathWorks, Inc.
