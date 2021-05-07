%t=0:0.1:6;
%x=t.*exp(-t);
%xp=repmat(x,1,4);
%tp=linspace(-6,18,length(xp));
%plot(tp,xp)
%legend('x(t) en 4 periodos')
%title('Gr�fica 1')

%t0=0;
%T=6;
%w=2*pi/T;
%syms t
%x=t*exp(-t);
%k=-40:40;
%a=(1/T)*int(x*exp(-j*k*w*t),t,t0,t0+T);
%xx=sum(a.*exp(j*k*w*t));
%ezplot(xx,[-6 18]);
%legend('Se�al aproximada en 4 periodo usando a_k')
%title('Gr�fica 2')

a0=(1/T)*int(x,t0,t0+T);
n=1:81;
b=(2/T)*int(x*cos(n*w*t),t,t0,t0+T);
c=(2/T)*int(x*sin(n*w*t),t,t0,t0+T);
xx=a0+sum(b.*cos(n*w*t))+sum(c.*sin(n*w*t))
ezplot(xx, [-6 18]);
legend('Se�al aproximada en 4 periodos usando b_k, c_k')
title('Gr�fica 3')