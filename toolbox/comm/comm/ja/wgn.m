% WGN   ���F�K�E�X�m�C�Y�̍쐬
%
% Y = WGN(M,N,P) �́AM �s N ��̔��F�K�E�X�m�C�Y�𐶐����܂��B
% P �́A�f�V�x�����b�g(dBW)�P�ʂŁA�o�̓m�C�Y�̃p���[��ݒ肵�܂��B
%
% Y = WGN(M,N,P,IMP) �́A�I�[���P�ʂŁA���׃C���s�[�_���X��ݒ肵�܂��B
%
% Y = WGN(M,N,P,IMP,STATE) �́ARANDN �̏�Ԃ� STATE �Ƀ��Z�b�g���܂��B
% ���l�����̌�ɁA���Ɏ����t���I�ȃt���O��ݒ�ł��܂��B
%
% Y = WGN(..., POWERTYPE) �́AP �̒P�ʂ�ݒ肵�܂��BPOWERTYPE �́A'dBW', 
% 'dBm', 'linear' �̂����ꂩ�ł��B���`�p���[�̒P�ʂ̓��b�g�ł��B
%
% Y = WGN(..., OUTPUTTYPE) �́A�o�̓^�C�v��ݒ肵�܂��BOUTPUTTYPE �́A
% 'real'�A�܂��́A'complex' �̂ǂ��炩��ݒ�ł��܂��B�o�̓^�C�v�����f��
% �̏ꍇ�AP �́A�����v�f�Ƌ����v�f�̊Ԃœ�������܂��B
%
% ���F 50�I�[���̕��ׂŁA5�f�V�x��(dBm)�̃p���[�������f�m�C�Y��
%        1024�s1��̃x�N�g�����쐬
%          Y = WGN(1024, 1, 5, 50, 'dBm', 'complex');
%
% ���F 1�I�[���̕��ׂŁA10�f�V�x�����b�g(dBW)�̃p���[�������f�m�C�Y��
%        256�s5��̍s����쐬
%          Y = WGN(256, 5, 10, 'real');
%
% ���F 75�I�[���̕��ׂŁA3���b�g�̃p���[�������f�m�C�Y��1�s10���
%        �x�N�g�����쐬
%          Y = WGN(1, 10, 3, 75, 'linear', 'complex');
%
% �Q�l�F RANDN, AWGN.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2003/06/23 04:35:23 $
