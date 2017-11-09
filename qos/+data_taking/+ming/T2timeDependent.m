path='E:\Data\matlab\20170921_YYS_3bit';
starttime='01-Sep-2017 00:00:00';
fitType=1;
T1=5;
T2_threshold=15;
T2_err_threshold=1;

import qes.*
T2=[];
T2_err=[];
T2_date=[];
files=dir([path,'\q2_Ramsey_*.mat']);
jj=1;
warning off all
for ii=1:numel(files)
    if(files(ii).datenum>datenum(starttime))
        try
            [T2_,T2_err_]=toolbox.data_tool.fitting.reFitRamsey([path '\' files(ii).name ],fitType,T1,0,0);
            if size(T2_,2)==1 && T2_<T2_threshold*1e3 && T2_err_<T2_err_threshold*1e3
                T2(jj)=T2_;
                T2_err(jj)=T2_err_;
                T2_date(jj)=files(ii).datenum;
                jj=jj+1;
            end
        end
    end
end

figure;errorbar(T2_date,T2,T2_err,'.')
datetick('x',6)
axis tight
xlabel('Date')
ylabel('T_2* (ns)')