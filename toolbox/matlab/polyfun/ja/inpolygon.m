% INPOLYGON   ���p�`���̓_�̌��o
% 
% IN = INPOLYGON(X�AY�AXV�AYV) �́AX �� Y �Ɠ����T�C�Y�̍s�� IN ���o��
% ���܂��B�x�N�g�� XV �� YV �Ŏw�肳��钸�_�������p�`���ɓ_
% (X(p,q)�AY(p,q))������ꍇ�́AIN(p,q) = 1�ł��B�_�����p�`�̋��E���
% ����ꍇ�́AIN(p,q) ��0.5�ł��B�_�����p�`�̊O�ɂ���ꍇ�́A
% IN(p,q) = 0�ł��B
%
% [IN ON] = INPOLYGON(X,Y,XV,YV) ��2�ڂ̍s�� ON ���o�͂��܂��B
% ����́AX �� Y �̃T�C�Y�ł��B�_(X(p,q), Y(p,q)) �����p�`�̈�̒[��
% ����ꍇ�́AON(p,q) = 1 �ŁA�����łȂ��ꍇ�́AON(p,q) = 0 �ł��B
%
% ���:
%       xv = rand(6,1); yv = rand(6,1);
%       xv = [xv ; xv(1)]; yv = [yv ; yv(1)];
%       x = rand(1000,1); y = rand(1000,1);
%       in = inpolygon(x,y,xv,yv);
%       plot(xv,yv,x(in),y(in),'.r',x(~in),y(~in),'.b')
%
%   ���� X,Y,XV,YV �̃T�|�[�g�N���X
%      float: double, single

%   Copyright 1984-2004 The MathWorks, Inc.