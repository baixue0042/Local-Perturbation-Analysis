function out = BYK
out{1} = @init;
out{2} = @fun_eval;
out{3} = @jacobian;
out{4} = @jacobianp;
out{5} = @hessians;
out{6} = @hessiansp;
out{7} = @der3;
out{8} = [];
out{9} = [];

% --------------------------------------------------------------------------
function dydt = fun_eval(t,kmrgd,Q1,Q2,Q3,Q4,Q5,Q6,K)
z=1-kmrgd(1)-kmrgd(2)-kmrgd(3);;
dydt=[2*Q1*z^2-2*Q5*kmrgd(1)^2-Q3*kmrgd(1)*kmrgd(2);;
Q2*z-Q6*kmrgd(2)-Q3*kmrgd(1)*kmrgd(2);;
Q4*z-K*Q4*kmrgd(3);;];

% --------------------------------------------------------------------------
function [tspan,y0,options] = init
handles = feval(BYK);
y0=[0,0,0];
options = odeset('Jacobian',handles(3),'JacobianP',handles(4),'Hessians',handles(5),'HessiansP',handles(6));
tspan = [0 10];

% --------------------------------------------------------------------------
function jac = jacobian(t,kmrgd,Q1,Q2,Q3,Q4,Q5,Q6,K)
jac=[ 2*Q1*(2*kmrgd(3) + 2*kmrgd(1) + 2*kmrgd(2) - 2) - Q3*kmrgd(2) - 4*Q5*kmrgd(1) , 2*Q1*(2*kmrgd(3) + 2*kmrgd(1) + 2*kmrgd(2) - 2) - Q3*kmrgd(1) , 2*Q1*(2*kmrgd(3) + 2*kmrgd(1) + 2*kmrgd(2) - 2) ; - Q2 - Q3*kmrgd(2) , - Q2 - Q6 - Q3*kmrgd(1) , -Q2 ; -Q4 , -Q4 , - Q4 - K*Q4 ];
% --------------------------------------------------------------------------
function jacp = jacobianp(t,kmrgd,Q1,Q2,Q3,Q4,Q5,Q6,K)
jacp=[ 2*(kmrgd(3) + kmrgd(1) + kmrgd(2) - 1)^2 , 0 , -kmrgd(1)*kmrgd(2) , 0 , -2*kmrgd(1)^2 , 0 , 0 ; 0 , 1 - kmrgd(1) - kmrgd(2) - kmrgd(3) , -kmrgd(1)*kmrgd(2) , 0 , 0 , -kmrgd(2) , 0 ; 0 , 0 , 0 , 1 - kmrgd(1) - kmrgd(2) - K*kmrgd(3) - kmrgd(3) , 0 , 0 , -Q4*kmrgd(3) ];
% --------------------------------------------------------------------------
function hess = hessians(t,kmrgd,Q1,Q2,Q3,Q4,Q5,Q6,K)
hess1=[ 4*Q1 - 4*Q5 , 4*Q1 - Q3 , 4*Q1 ; 0 , -Q3 , 0 ; 0 , 0 , 0 ];
hess2=[ 4*Q1 - Q3 , 4*Q1 , 4*Q1 ; -Q3 , 0 , 0 ; 0 , 0 , 0 ];
hess3=[ 4*Q1 , 4*Q1 , 4*Q1 ; 0 , 0 , 0 ; 0 , 0 , 0 ];
hess(:,:,1) =hess1;
hess(:,:,2) =hess2;
hess(:,:,3) =hess3;
% --------------------------------------------------------------------------
function hessp = hessiansp(t,kmrgd,Q1,Q2,Q3,Q4,Q5,Q6,K)
hessp1=[ 4*kmrgd(3) + 4*kmrgd(1) + 4*kmrgd(2) - 4 , 4*kmrgd(3) + 4*kmrgd(1) + 4*kmrgd(2) - 4 , 4*kmrgd(3) + 4*kmrgd(1) + 4*kmrgd(2) - 4 ; 0 , 0 , 0 ; 0 , 0 , 0 ];
hessp2=[ 0 , 0 , 0 ; -1 , -1 , -1 ; 0 , 0 , 0 ];
hessp3=[ -kmrgd(2) , -kmrgd(1) , 0 ; -kmrgd(2) , -kmrgd(1) , 0 ; 0 , 0 , 0 ];
hessp4=[ 0 , 0 , 0 ; 0 , 0 , 0 ; -1 , -1 , - K - 1 ];
hessp5=[ -4*kmrgd(1) , 0 , 0 ; 0 , 0 , 0 ; 0 , 0 , 0 ];
hessp6=[ 0 , 0 , 0 ; 0 , -1 , 0 ; 0 , 0 , 0 ];
hessp7=[ 0 , 0 , 0 ; 0 , 0 , 0 ; 0 , 0 , -Q4 ];
hessp(:,:,1) =hessp1;
hessp(:,:,2) =hessp2;
hessp(:,:,3) =hessp3;
hessp(:,:,4) =hessp4;
hessp(:,:,5) =hessp5;
hessp(:,:,6) =hessp6;
hessp(:,:,7) =hessp7;
%---------------------------------------------------------------------------
function tens3  = der3(t,kmrgd,Q1,Q2,Q3,Q4,Q5,Q6,K)
tens31=[ 0 , 0 , 0 ; 0 , 0 , 0 ; 0 , 0 , 0 ];
tens32=[ 0 , 0 , 0 ; 0 , 0 , 0 ; 0 , 0 , 0 ];
tens33=[ 0 , 0 , 0 ; 0 , 0 , 0 ; 0 , 0 , 0 ];
tens34=[ 0 , 0 , 0 ; 0 , 0 , 0 ; 0 , 0 , 0 ];
tens35=[ 0 , 0 , 0 ; 0 , 0 , 0 ; 0 , 0 , 0 ];
tens36=[ 0 , 0 , 0 ; 0 , 0 , 0 ; 0 , 0 , 0 ];
tens37=[ 0 , 0 , 0 ; 0 , 0 , 0 ; 0 , 0 , 0 ];
tens38=[ 0 , 0 , 0 ; 0 , 0 , 0 ; 0 , 0 , 0 ];
tens39=[ 0 , 0 , 0 ; 0 , 0 , 0 ; 0 , 0 , 0 ];
tens3(:,:,1,1) =tens31;
tens3(:,:,1,2) =tens32;
tens3(:,:,1,3) =tens33;
tens3(:,:,2,1) =tens34;
tens3(:,:,2,2) =tens35;
tens3(:,:,2,3) =tens36;
tens3(:,:,3,1) =tens37;
tens3(:,:,3,2) =tens38;
tens3(:,:,3,3) =tens39;
%---------------------------------------------------------------------------
function tens4  = der4(t,kmrgd,Q1,Q2,Q3,Q4,Q5,Q6,K)
%---------------------------------------------------------------------------
function tens5  = der5(t,kmrgd,Q1,Q2,Q3,Q4,Q5,Q6,K)
