% IMP2SS   �C���p���X�����ɂ��V�X�e������(Kung�̓��ْl�����A���S���Y��)
%
% [A,B,C,D,TOTBND,SVH] = IMP2SS(Y)
% [A,B,C,D,TOTBND,SVH] = IMP2SS(Y,TS,NU,NY,TOL)
% [SS_,TOTBND,SVH] = IMP2SS(IMP_)
% [SS_,TOTBND,SVH] = IMP2SS(IMP_,TOL) 
% �֐�IMP2SS�́A�^����ꂽ�C���p���X�����̋ߎ��I�ȏ�ԋ�Ԏ������o�͂��܂��B
%                 IMP_=MKSYS(Y,TS,NU,NY,'imp')
% 
% ����́AS. Kung(Proc. Asilomar Conf. on Circ. Syst. & Computers, 1978)��
% ���񏥂��ꂽHankel���ْl�������g���Ă��܂��B�A���n�̎����́ATS�����̏�
% ���A�tTustin�ϊ����g���Čv�Z����܂��B����ȊO�ł́A���U�n�̎������o�͂�
% ��܂��B
%
%  ����:  Y --- �s�P�ʂ̃C���p���X����H1,...,HN
%                 Y=[H1(:)'; H2(:)'; H3(:)'; ...; HN(:)']
%  �I�v�V��������:
%           TS  ---  �T���v�����O�Ԋu(�f�t�H���gTS=0)
%           NU  ---  ���͐� (�f�t�H���gNU=1)
%           NY  ---  �o�͐� (�f�t�H���gNY= size(Y)*[1;0]/nu)
%           TOL ---  �덷�͈͂�Hinfnorm(�f�t�H���gTOL=0.01*S(1))
%  �o��: (A,B,C,D) ���U��ԋ�Ԏ���
%         TOTBND  ������m�����̌덷�͈�2*Sum([S(NX+1),S(NX+2),...])
%         SVH  �n���P�����ْl[S(1);S(2);... ]



% Copyright 1988-2002 The MathWorks, Inc. 
