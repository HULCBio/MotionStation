% FNDIR   �֐��̕�������
%
% FNDIR(F,DIRECTION) �́AF �Ɋ܂܂��(�����ē���������)�֐��� DIRECTION 
% �����̔���(��pp-�^)���o�͂��܂��B
% F �ɂ��邪m�ϐ��̏ꍇ�ADIRECTION �́Am�v�f�̃x�N�g��(�̃��X�g)�A����
% �킿�A���� nd �ɑ΂��đ傫�� [m,nd] �łȂ���΂Ȃ�܂���B
%
% F �ɂ���֐����Am�ϐ���d�̒l�����Ɖ��肷��ƁAFDIR ��(prod(d)*nd)��
% �̒l�����֐����L�q���܂��B�_ X �ɂ����邻�̊֐��̒l V �́A�傫�� 
% [d,nd] �̔z��Ƃ��Đ��`����Ă���A����j�Ԗڂ�'��' V(:,j) �ɑ΂��āA
% �_ X �ɂ����� F �ɂ���֐��� DIRECTION(:,j) ����(j=1:nd)�̔�����^��
% �܂��B
% �o�͂����֐����AF �̃^�[�Q�b�g�̎��������S�ɔ��f���邱�Ƃ����߂�
% ����Ɉȉ��̕��@���g�p���Ă��������B
%
%      fdir = fnchg( fndir(f,direction), ...
%                    'dim',[fnbrk(f,'dim'),size(direction,2)] );
%
% FNDIR �́A�L���X�v���C���ɑ΂��Ă͋@�\���܂���B����� FNTLR ���g�p
% ���Ă��������B
%
% ���: f ��m�ϐ���d�v�f�̃x�N�g���l�̊֐����L�q���Ax ���̈���̂�����
%       ���̓_�ł���ꍇ�A
%
%      reshape(fnval(fndir(f,eye(d)),x),d,m)
%
% �́A���̓_�ł̊֐��̃��R�r�A���ł��B�֘A�����Ƃ��āA���̃X�e�[�g
% �����g�ł́A�W���̃��b�V���ł�Franke�֐�(�ւ̓K�؂ȋߎ�)�̌��z��
% �v���b�g���܂��B
%
%    xx = linspace(-.1,1.1,13); yy = linspace(0,1,11);
%    [x,y] = ndgrid(xx,yy); z = franke(x,y);
%    pp2dir = fndir(csapi({xx,yy},z),eye(2));
%    grads = reshape(fnval(pp2dir,[x(:) y(:)].'),[2,length(xx),length(yy)]);
%    quiver(x,y,squeeze(grads(1,:,:)),squeeze(grads(2,:,:)))
%
% �Q�l : FNDER, FNTLR, FNINT.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
