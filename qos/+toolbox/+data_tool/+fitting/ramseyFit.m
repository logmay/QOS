function [T2,T2_err,detuningf,fitramsey_time,fitramsey_data]=ramseyFit(Ramsey_time,Ramsey_data,fitType,T1)

if nargin==3 && fitType==2
    error('ramsey fit in type 2 should provide T1 value!')
end
detuning=toolbox.data_tool.fitting.FFT_Peak(Ramsey_time,Ramsey_data);
if fitType==1
f=@(a,x)(a(1)+a(2)*exp(-(x/a(3))).*cos(a(4)*2*pi.*x+a(5)));
elseif fitType==2
f=@(a,x)(a(1)+a(2)*exp(-(x/a(3)).^2-x/T1).*cos(a(4)*2*pi.*x+a(5)));
end
a=[(max(Ramsey_data)+min(Ramsey_data))/2,(max(Ramsey_data)-min(Ramsey_data))/2,Ramsey_time(end)/2,detuning,1];
[b,r,J]=nlinfit(Ramsey_time,Ramsey_data,f,a);
[~,se] = toolbox.data_tool.nlparci(b,r,J,0.05);
T2=abs(b(3));
T2_err=se(3);
detuningf=b(4);


fitramsey_time=linspace(min(Ramsey_time),max(Ramsey_time),1000);
fitramsey_data=b(1)+b(2).*exp(-(fitramsey_time./b(3)).^2-fitramsey_time/T1).*cos(b(4)*2*pi.*fitramsey_time+b(5));

end