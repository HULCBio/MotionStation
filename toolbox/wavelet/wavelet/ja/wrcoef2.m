% WRCOEF2    2�����̃E�F�[�u���b�g�W������P��u�����`���č\��
% WRCOEF2 �́A�C���[�W�̌W�����č\�����܂��B
%
% X = WRCOEF2('type',C,S,'wname',N) �́A���x�� N �ŃE�F�[�u���b�g�����\�� [C,S]
% (WAVEDEC2 ���Q��)���x�[�X�ɂ��āA�č\�������W���s����v�Z���܂��B'wname' �́A
% �E�F�[�u���b�g��������������ł��B'type' = a �̏ꍇ�A Approximation �W�����č\
% ������܂��B�܂��A'type' = 'h' ('v' �܂��� 'd')�̏ꍇ�A����(�����܂��͑Ίp)��
% ���� Detail �W�����č\������܂��B
%
% ���x�� N �́A�ȉ��͈̔͂̐����łȂ���΂Ȃ�܂���B
% 'type' = 'a' �̏ꍇ�A0 < =  N < =  size(S,1)-2  
% 'type' = 'h'�A'v' �܂��� 'd' �̏ꍇ�A1 < =  N < =  size(S,1)-2 
%
% �E�F�[�u���b�g����^�������ɁA�t�B���^��ݒ肷�邱�Ƃ��ł��܂��B
% X = WRCOEF2('type',C,S,Lo_R,Hi_R,N) �ɑ΂��āA
%   Lo_R �́A�č\�����[�p�X�t�B���^�ł��B
%   Hi_R �́A�č\���n�C�p�X�t�B���^�ł��B
%
% X = WRCOEF2('type',C,S,'wname')�A�܂��́AX = WRCOEF2('type',C,S,Lo_R,Hi_R) �́A
% �ő僌�x�� N = size(S,1)-2 �̌W�����č\�����܂��B
%
% �Q�l�F APPCOEF2, DETCOEF2, WAVEDEC2.



%   Copyright 1995-2002 The MathWorks, Inc.
