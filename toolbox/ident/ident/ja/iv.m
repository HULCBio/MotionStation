% IV   �⏕�ϐ��@���g���āA�P�o�� ARX ���f�����v�Z
%
%   MODEL = IV(Z,NN,NF,MF)
%
%   MODEL : ���� ARX ���f��
%   
%              A(q) y(t) = B(q) u(t-nk) + v(t)
%   
%           �̊֘A����\�������܂� IV ���茋�ʂ̏o�́BMODEL �̏ڍׂȍ\
%           ���́AHELP IDPOLY ���Q�ƁB
%
%   Z     : �P�o�� IDDATA �I�u�W�F�N�g�Ƃ��ĕ\�����o�� - ���̓f�[�^�B��
%           �ׂ́AHELP IDDATA ���Q�ƁB
%
%   NN    : NN = [na nb nk] �́A��̃��f���Ɋ֘A���������ƒx���ݒ�
%   NF �� MF �́A���̌`���̕⏕�ϐ� X ��ݒ肵�܂��B
%   
%          NF(q) x(t) = MF(q) u(t)
%
% �⏕�ϐ��̎����I�ȑI���ɂ��ẮAIV4 ���Q�Ƃ��Ă��������B
%
%   MODEL = IV(Z,NN,NF,MF,maxsize)
%
% �́A�A���S���Y���Ɋ֘A�����������̃p�����[�^�ɃA�N�Z�X���邱�Ƃ��ł�
% �܂��B
% �����̐����̏ڍׂ́AIDPROPS ALGORITHM ���Q�Ƃ��Ă��������B

%   Copyright 1986-2001 The MathWorks, Inc.
