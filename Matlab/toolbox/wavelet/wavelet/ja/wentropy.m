% WENTROPY�@ �G���g���s�[(�E�F�[�u���b�g�p�P�b�g)�̎Z�o
%
% E = WENTROPY(X,T,P) �́A�x�N�g���܂��͍s�� X �̃G���g���s�[ E ���Z�o
% ���܂��B������̏ꍇ�ɂ����Ă��A�o�� E ��1�̎����l�ł��B
%
% T �́A�G���g���s�[�̃^�C�v������������ł��B
%   T = 'shannon'�A'threshold'�A'norm',
%   'log energy' (�܂��� 'logenergy')�A'sure'�A'user'.
% �܂��́A
%   T = FunName (�����ŁA�ȑO�ɏ�Ƀ��X�g���ꂽ�G���g���s�[�^�C�v����
%       �����A�C�ӂ̑��̕�����)�BFunName �́A���[�U�̃G���g���s�[�֐�
%       ��M-�t�@�C�����ł��B
%
% P �́AT �̒l�Ɉˑ�����I�v�V�����p�����[�^�ł��B
%   T = 'shannon'�A�܂��́A'log energy' �̏ꍇ�AP �͗p�����܂���B
%   T = 'threshold'�A�܂��́A'sure' �̏ꍇ�AP �̓X���b�V���z�[���h�l��
%   �Ȃ�A���̐��Őݒ肳��˂΂Ȃ�܂���B
%   T = 'norm' �̏ꍇ�AP �ׂ͂����ŁA1 < =  P �𖞂����Ȃ���΂Ȃ�܂���B
%   T = 'user' �̏ꍇ�AP �͒P����� X �����A���[�U���g�̃G���g���s�[
%   �֐��� M-�t�@�C����������������ƂȂ�܂��B
%   T = FunName �̏ꍇ�AP �́A����̂Ȃ��I�v�V�����p�����[�^�ɂȂ�܂��B
%
% E = WENTROPY(X,T) �́AE = WENTROPY(X,T,0) �Ɠ����ł��B

 

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Copyright 1995-2002 The MathWorks, Inc.
