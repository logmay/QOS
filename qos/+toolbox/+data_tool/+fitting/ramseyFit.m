function [T2,T2_err,detuningf,fitramsey_time,fitramsey_data,detuningf_err]=ramseyFit(Ramsey_time,Ramsey_data,fitType,T1)

if nargin==3 && fitType==2
    error('ramsey fit in type 2 should have T1 value provided!')
end
detuning=toolbox.data_tool.fitting.FFT_Peak(Ramsey_time,Ramsey_data);
if fitType==1
    f=@(a,x)(a(1)+a(2)*exp(-(x/a(3))).*cos(a(4)*2*pi.*x+a(5)));
elseif fitType==2
    f=@(a,x)(a(1)+a(2)*exp(-(x/a(3)).^2-x/2/T1).*cos(a(4)*2*pi.*x+a(5)));
end
a=[(max(Ramsey_data)+min(Ramsey_data))/2,(max(Ramsey_data)-min(Ramsey_data))/2,Ramsey_time(end)/4,detuning,1e-6];
[b,r,J]=nlinfit(Ramsey_time,Ramsey_data,f,a);
[~,se] = toolbox.data_tool.nlparci(b,r,J,0.05);
T2=abs(b(3));
T2_err=se(3);
detuningf=b(4);
detuningf_err=se(4);


fitramsey_time=linspace(min(Ramsey_time),max(Ramsey_time),1000);
if fitType==1
    fitramsey_data=b(1)+b(2).*exp(-(fitramsey_time./b(3))).*cos(b(4)*2*pi.*fitramsey_time+b(5));
else
    fitramsey_data=b(1)+b(2).*exp(-(fitramsey_time./b(3)).^2-fitramsey_time/2/T1).*cos(b(4)*2*pi.*fitramsey_time+b(5));
end
end

% function [T2,T2_err,detuningf,fitramsey_time,fitramsey_data,detuningf_err]=ramseyFit(Ramsey_time,Ramsey_data,fitType,T1)
% 
% if nargin==3 && fitType==2
%     error('ramsey fit in type 2 should have T1 value provided!')
% end
% detuning=toolbox.data_tool.fitting.FFT_Peak(Ramsey_time*1e6,Ramsey_data);
% if fitType==1
%     f=@(a,x)(a(1)+a(2)*exp(-(x/a(3))).*cos(a(4)*2*pi.*x+a(5)));
% elseif fitType==2
%     f=@(a,x)(a(1)+a(2)*exp(-(x/a(3)).^2-x/T1).*cos(a(4)*2*pi.*x+a(5)));
% end
% a=[(max(Ramsey_data)+min(Ramsey_data))/2,(max(Ramsey_data)-min(Ramsey_data))/2,Ramsey_time(end)*1e6,detuning,1];
% [b,r,J]=nlinfit(Ramsey_time*1e6,Ramsey_data,f,a);
% [~,se] = toolbox.data_tool.nlparci(b,r,J,0.05);
% T2=abs(b(3))/1e6;
% T2_err=se(3)/1e6;
% detuningf=b(4)*1e6;
% detuningf_err=se(4)*1e6;
% 
% 
% fitramsey_time=linspace(min(Ramsey_time),max(Ramsey_time),1000)*1e6;
% if fitType==1
%     fitramsey_data=b(1)+b(2).*exp(-(fitramsey_time./b(3))).*cos(b(4)*2*pi.*fitramsey_time+b(5));
% else
%     fitramsey_data=b(1)+b(2).*exp(-(fitramsey_time./b(3)).^2-fitramsey_time/T1).*cos(b(4)*2*pi.*fitramsey_time+b(5));
% end
% fitramsey_time=fitramsey_time/1e6;
% end