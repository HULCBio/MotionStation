% SS2SOS �́A��ԋ�Ԍ^��2���\���֕ϊ����܂��B
%
% [SOS,G] = SS2SOS(A,B,C,D) �́A�P���͒P�o�͏�ԋ�ԍs�� A�AB�AC�AD �Ɠ�
% ����2���\���̍s�� SOS �ƃQ�C�� G �����߂܂��BA�AB�AC�AD �ɂ���ė^����
% ���V�X�e���̋ɂƗ�_�́A���𕡑f���̑g�ɂȂ�܂��B�V�X�e���͈��肵��
% ����K�v������܂��B
%
% [SOS,G] = SS2SOS(A,B,C,D,IU)�́A�����͒P�o�͂̏�ԋ�ԃV�X�e��A�AB�AC�A
% D�ɑ΂��āA�ǂ̓��͂�ϊ��Ɏg�p���邩�����肷��X�J�� IU ��ݒ肵�܂��B
% 
% SOS �́A���̂悤�� L �s6��̍s��ƂȂ�܂��B
%
%     SOS = [ b01 b11 b21  1 a11 a21 
%             b02 b12 b22  1 a12 a22
%             ...
%             b0L b1L b2L  1 a1L a2L ]
%
% �s�� SOS �̊e�s�́A2���\���̓`�B�֐���\���Ă��܂��B
%
%               b0k +  b1k z^-1 +  b2k  z^-2
%     Hk(z) =  ----------------------------
%                1 +  a1k z^-1 +  a2k  z^-2
% 
% k �́A�s�C���f�b�N�X�ł��B
%
% G �́A�V�X�e���S�̂̃Q�C���ł��BG ���w�肳��Ȃ��ꍇ�A�ŏ��̍\���ɑg��
% ���܂�Ă��܂��B2���\���̃V�X�e�� H(Z) �́A�ȉ��̂悤�ɕ\����܂��B    
%     H(z) = G*H1(z)*H2(z)*...*HL(z)
%
% SS2SOS(...,DIR_FLAG) �́ASOS �̍s�̏�����ݒ肵�܂��BDIR_FLAG = 
% 'UP ' �̏ꍇ�ASOS �̍ŏ��̍s�́A���_�ɍł��߂��ɂ��܂݁A�Ō�̍s�́A
% �P�ʉ~�ɍł��߂��ɂ��܂݂܂��BDIR_FLAG = 'DOWN ' �̏ꍇ�A���̏��Ԃ́A
% 'UP' �̋t�ɂȂ�܂��B�܂��ADIR_FLAG �̃f�t�H���g�́A'UP' �ł��B
%
% SS2SOS(...DIR_FLAG,SCALE) �́A���ׂĂ�2���\���̃Q�C���ƕ��q�W����
% �΂��āA��]����X�P�[�����O���s���܂��BSCALE �ɂ́A�ȉ���3���w�肷
% �邱�Ƃ��ł��܂��B
%
%   SCALE = 'NONE' �̏ꍇ�A�X�P�[�����O��K�p���܂���B
%   SCALE = 'INF' �̏ꍇ�A������m������K�p���܂��B
%   SCALE = 'TWO' �̏ꍇ�A2�m������K�p���܂��B
% 
% SCALE ���f�t�H���g�́A'NONE' �ł��B���Ԃ�ݒ肷����� 'UP' �𖳌���m
% �����̃X�P�[�����O�@�Ƌ��Ɏg�p���邱�Ƃɂ��A�����̒��ŃI�[�o�t���[��
% �\�����ŏ����ɂ��܂��B����A����'DOWN' ��2�m�����ɂ��X�P�[�����O�@
% �Ƌ��Ɏg�p���邱�Ƃɂ��A�s�[�N�̊ۂ߃m�C�Y���ŏ��ɂ��܂��B
%
% �Q�l�F   ZP2SOS, SOS2ZP, SOS2TF, SOS2SS, tf2SOS, CPLXPAIR.



%   Copyright 1988-2002 The MathWorks, Inc.
