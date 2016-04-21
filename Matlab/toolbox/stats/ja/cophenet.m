% COPHENET   Cophenetic �W��
%
% C = COPHENETIC(Z,Y) �́AZ �̒��̃N���X�^�c���[�̋����� Y �̒��̋���
% �Ƃ̊Ԃ��� Cophenetic �W�����v�Z���܂��BZ �́A�֐� LINKAGE �����
% �o�͂ł��BY �́A�֐� PDIST ����̏o�͂ł��B
% 
% Cophenetic �W���́A���̂悤�ɒ�`����܂��B
% 
%                     sum((Z(i,j)-z)*(Y(i,j)-y)) 
%                     i<j             
%        c =   -----------------------------------------
%              sqrt(sum((Z(i,j)-z)^2)*sum((Y(i,j)-y)^2))
%                   i<j               i<j
%            
% Y(i,j) �́A�ϑ� i �� j �̋����ŁAy �́AY �̕��ϒl�ł��B
% Z(i,j) �́A�ڍ����_�ŁA�ϑ� i �� j �̋����ŁAz = mean(Z) �ł��B
% 
% ���:
%
%      X = [rand(10,3); rand(10,3)+1; rand(10,3)+2];
%      Y = pdist(X);
%      Z = linkage(Y,'average');
%      c = cophenet(Z,Y);
%
% �Q�l : PDIST, LINKAGE, INCONSISTENT, DENDROGRAM, CLUSTER, CLUSTERDATA.


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.6 $
