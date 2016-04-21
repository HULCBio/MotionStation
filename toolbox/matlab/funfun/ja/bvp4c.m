% BVP4C  �I�_�@�ɂ��ODEs�ɑ΂��鋫�E�l���������܂��B
% 
% SOL = BVP4C('F','G',SOLINIT)�́A��ʓI��2�_���E���� bc(y(a),y(b)) = 0
% �ɂ�鐧��̊�ŁA���[a,b]�ŁA����������� y' = F(x,y)��ϕ����܂��B
% ODEFUN�́A2�̈����X�J�� X �ƃx�N�g�� Y �����֐��ł��BODEFUN(X,Y) 
% �́Af(x,y) ��\�킷��x�N�g�����o�͂��܂��BBCFUN �́A2�̃x�N�g������
% �����֐��ł��BBCFUN(YA,YB)�@�́Abc(y(a),y(b)) ��\�킷��x�N�g�����o
% �͂��܂��BSOLINIT�́A���̃t�B�[���h�����\���̂ł��B
% 
%    x -- SOLINIT.x(1) = a�ASOLINIT.x(end) = b�����������b�V���̏����t
%         ����ꂽ �ߓ_
%    y -- �ߓ_SOLINIT.x(i)�ł̉���y(x(i))�ɑ΂��鐄��SOLINIT.y(:,i)����
%         ���ɑ΂��鏉������
% 
% BVP4C �́A���[a,b]�ŘA���ŁA���̋�Ԃł�1�K�������A���̉��������܂��B
% ���́ABVP4C �̏o�� SOL �Ɗ֐� BVPVAL ���g���āA�_ XINT �Ōv�Z����܂��B
% YINT = BVPVAL(SOL,XINT) �ƂȂ�܂��B�o�� SOL �́A���̃t�B�[���h����
% �\���̂ł��B
% 
%    SOL.x  -- BVP4C�őI������郁�b�V��
%    SOL.y  -- SOL.x�̃��b�V���_�ł�y(x)�ւ̋ߎ�
%    SOL.yp -- SOL.x �̃��b�V���_�ł�y'(x) �ւ̋ߎ�
%    SOL.solver -- 'bvp4c'
%
% SOL = BVP4C(ODEFUN,BCFUN,SOLINIT,OPTIONS) �́A�f�t�H���g�p�����[�^�� 
% �֐� BVPSET �ō쐬���ꂽ�\���� OPTIONS �̒��̒l�ƒu�������āA��q����
% ���������܂��B���s���Ԃ�啝�ɍ팸����ɂ́AOPTIONS �p�����[�^���g��
% �āA�֐��� ���R�r�A����^������AODEFUN ���x�N�g�������Ă��������B�ڍ�
% �́ABVPSET ���Q�Ƃ��Ă��������B�܂��A��L��2�̕��@�����s�������
% ���ẮASHOCKBVP ���Q�Ƃ��Ă��������B
% 
% SOL = BVP4C(ODEFUN,BCFUN,SOLINIT,OPTIONS,P1,P2...) �́A�萔�A���m�p����
% �[�^ P1, P2... ���֐� ODEFUN �� BCFUN �ɓn���AOPTIONS �̒��Ɏw�肵����
% �����ׂĂɂ��n���܂��B�I�v�V������ݒ肵�Ȃ��ꍇ�́AOPTIONS = [] �Ɛݒ�
% ���Ă��������B
%   
% �������̋��E�l���́Ay(x)�Ƌ��Ɍv�Z����関�m�̃p�����[�^�x�N�g�� p
% ���܂�ł��܂��B
% 
%       y' = f(x,y,p)
%       0  = bc(y(a),y(b),p) 
% 
% ���̂悤�Ȗ��ɑ΂��āA�t�B�[���h SOLINIT.parameters ���A���m�p�����[
% �^�̐����^���邽�߂Ɏg���܂��B�o�͂Ƃ��ẮA���܂����p�����[�^���A
% �t�B�[���h SOL.parameters �ɏo�͂���܂��B����p�����[�^�l�̑g���g����
% ���������̉� SOL �́A���̃p�����[�^�ɑ΂��ẮASOLINIT �Ƃ��Ďg������
% ���ł��܂��B��� BVPs �́A�A���I�ɉ������Ƃ��ł���ꍇ������܂��B��
% �Ȃ킿�A���𓾂邱�Ƃ��\�ȃp�����[�^�l���g���ăX�^�[�g���A�������߁A
% �ŏI�I�ɋ��߂������̂ɋ߂��p�����[�^���g�����v�Z�̐���l�Ƃ��āA�ŏ���
% �����g���܂��B���[�U����]����p�����[�^�ɑ΂��āABVP ��������܂ŁA�J
% ��Ԃ��v�Z���s���܂��B
%
% �֐� BVPINIT �́A�����̈�ʓI�ȏꍇ�A����ɕK�v�ȍ\���̂��쐬���܂��B
% ���Ȃ킿�ASOLINIT = BVPINIT(X,YINIT) �́ASILINIT.x �ŋL�q����鏉����
% �b�V�� X �ɑ΂��鐄��ƁA���[a,b]���̔C�ӂ̓_�ł̉��ɑ΂��鐄����v�Z��
% ��֐���(������)���A�܂��́A���ɑ΂���萔�x�N�g�����g��������̂�����
% ����p���� YINIT �ŋL�q����鏉�����b�V�� X �ɑ΂��鐄����s���܂��B��
% �m�p�����[�^�����݂���ꍇ�ASOLINIT = BVPINIT(X,YINIT,PARAMS)�́A���m
% �p�����[�^�p�̐���Ɋւ���x�N�g�� PARAMS ���g���Đ���ʂ�ݒ肵�܂��B
% 
% BVP4C�́A���̌`���̖��m�̃p�����[�^p���������܂ށA���قȃN���X��BVP
% �������܂��B
%       y' = S*y/x + f(x,y,p)
%       0  = bc(y(0),y(b),p) 
% ��Ԃ́A[0, b] �ŁAb > 0�ł���K�v������܂��B 
% ���̂悤�Ȗ��́A�~���`�܂��͋��`�̑Ώ̐��̂��߁APDE�̌��ʂł���ODE�̃X
% ���[�Y�ȉ��̌v�Z�̂Ƃ��ɔ������邱�Ƃ�����܂��B���قȖ��ɑ΂��āA(�萔)�s
% ��S�́ABVPSET��'SingularTerm'�I�v�V�����̒l�Ƃ��Ďw�肳��AODEFUN��f(x,y,p)
% �݂̂����s���܂��B���E�����́A�K�v����S*y(0) = 0�ƈ�v����K�v������A����
% ����́A���̏����𖞑�����K�v������܂��B
%
% BVP4C �́A���_���E�l�����������Ƃ��ł��܂��B���̂悤�Ȗ��̏ꍇ�A���
% [a,b] ���ł������̋��E����������܂��B ��ʂɂ����̓_�́A�C���^�t�F�[�X
% ��\�킵�A[a,b] �̗̈�ւ̎��R�ȕ�����^���܂��B
% BVP4C �́A������E( a ���� b )�ɗ̈���A1 ����͂��܂�C���f�b�N�X��
% �����܂��B�̈� k �ł́ABVP4C �́A���֐��� YP = ODEFUN(X,Y,K) �ƕ]�����܂��B 
% ���E�����̊֐� BCFUN(YLEFT,YRIGHT) �ł́A YLEFT(:,k) �́A�̈� k 'left' ��
% ���E�ł̉��ł���AYRIGHT(:,k) �ɂ��Ă����l�ł��B�������肪
% BVPINIT(XINIT,YINIT) �ō쐬�����ꍇ�AXINIT �́A�e���E�_�ɑ΂��āA
% double entries �����K�v������܂��BYINIT ���֐��̏ꍇ�ABVPINIT �́A
% �̈� k �� X �ł̉��ɑ΂��鏉������𓾂邽�߂ɁAY = YINIT(X,K) ���R�[��
% ���܂��BBVP4C �ɂ��o�͂������̍\���� SOL.x �́A�e���E�_�ɑ΂��āA
% double entries �������܂��BSOL.y �̑Ή������́A���E�ł� 'left' �����
% 'right' �̉������ꂼ������܂��B3�_���E�l��� ( three-point BVP )������
% ���Ƃ��āATHREEBVP ���Q�Ƃ��Ă��������B
%
% ���
%         solinit = bvpinit([0 1 2 3 4],[1 0]);
%         sol = bvp4c(@twoode,@twobc,solinit);
%
% �́A�����������Ƌ��E�l�A���[0, 4]�ŁA�֐� twoode �� twobc ���g���āA
% �����������܂��B���̗��́A�������b�V���Ƃ��āA[0 1 2 3 4] ���g���A
% ���b�V���_�ł̉�v�f�̏����ߎ��Ƃ��āA[1 0] ���g���܂��B
% 
%         xint = linspace(0,4);
%         yint = bvpval(sol,xint);
% 
% �́A��� [0,4] �ŁA���Ԋu��100�敪���ꂽ�_�ŉ����v�Z���܂��B���̍ŏ���
% �����́A���̃X�e�[�g�����g�Ńv���b�g����܂��B
% 
%         plot(xint,yint(1,:));
% 
% ���̗��́ATWOBVP, FSBVP, SHOCKBVP, MAT4BVP, EMDENBVP, THREEBVP ��
% �Q�Ƃ��Ă��������B   
%
% �Q�l BVPSET, BVPGET, BVPINIT, DEVAL, @.

% BVP4C �́A3�X�e�[�W�� LobattoIIIa ���������s����L�������R�[�h�ł��B
% ����́A�I�_������\�킵�A�I�_������ (collocation polynomial) �́A
% [a,b] �ň�l��4���̐��x������C1�A���ȉ���^���܂��B
% (���_���E�l���ɑ΂��āA���͊e�̈���� C1�A���ł����A�A�����́A
% ���E�ł͎����I�ɂ͉ۂ���Ă��܂���B) 
% ���b�V���̑I���ƌ덷����́A�A���ȉ��̎c���Ɋ�Â��܂��B
% �㐔�������n���쐬�����ꍇ�ɁA��͓I�ɊȖ񉻂���܂��B

%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2003 The MathWorks, Inc. 

