% SOS2SS �́A2���\������ԋ�Ԍ^�֕ϊ����܂��B
%
% [A,B,C,D] = SOS2SS(SOS,G) �́A�Q�C�� G ��2���\���̍s�� SOS ��^���āA
% ���U���ԃV�X�e���̏�ԋ�ԍs�� A,B,C,D ���o�͂��܂��B
%
% SOS �́A�e�s�Ɋe�X��2���\���f�ʂ̌W�������� L �s6��̍s��ł��B
%
%     SOS = [ b01 b11 b21  1 a11 a21 
%             b02 b12 b22  1 a12 a22
%             ...
%             b0L b1L b2L  1 a1L a2L ]
%
% �V�X�e���̓`�B�֐��́A2���\���V�X�e���̓`�B�֐��ƃQ�C�� G �̐ςɂȂ��
% ���BG ���ݒ肳��Ă��Ȃ��ꍇ�A�f�t�H���g��1���g���܂��BSOS �s��̊e
% �s�́A�ȉ���2���\���`���̗��U�`�B�֐���\���Ă��܂��B
%
%     b0k +  b1k z^-1 +  b2k  z^-2
%     ----------------------------
%     1 +  a1k z^-1 +  a2k  z^-2
%
% k �́A�s�̃C���f�b�N�X�ł��B
%
% �Q�l�F   SS2SOS, ZP2SOS, SOS2ZP, SOS2TF 



%   Copyright 1988-2002 The MathWorks, Inc.
