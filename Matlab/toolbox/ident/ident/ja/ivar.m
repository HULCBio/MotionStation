% IVAR �́A�X�J�����n��� AR ����⏕�ϐ��@���g���Čv�Z���܂��B
% 
%   MODEL = IVAR(Y,NA)
%
%   MODEL : ���n�񃂃f��
% 
%   A(q) y(t) =  v(t)
% 
% �̊֘A�����\�����Ƌ��� AR ����IV �@���g�������茋�ʂ��o��(MODEL �̐�
% �m�ȍ\���́AHELP IDPOLY ���Q��)�B
%
%   Y     : ���n���P�o�� IDDATA �I�u�W�F�N�g�Ƃ��Đݒ�B�ڍׂ́AHELP 
%           IDDATA ���Q�ƁB
%
%   NA    : AR ���̎���(A(q)-������)
%
% ��̃��f���̒��ŁAv(t) �́A�C�ӂ̃v���Z�X�ŁA���� NC �̈ړ����ωߒ�(��
% �ς���)�Ɖ��肳��Ă��܂��BNC �̃f�t�H���g�l�́ANA �ł��BNC �̑��̒l�́A
%    MODEL = IVAR(Y,NA,NC)
% 
% ���g���ē����܂��B
%
%   TH = IVAR(Y,NA,NC,maxsize)
% 
% ���g�����ƂŁAmaxsize ��葽���v�f�����s��́A���̃A���S���Y���ł͍�
% �����܂���B
%
% �Q�l�F AR.



%   Copyright 1986-2001 The MathWorks, Inc.
