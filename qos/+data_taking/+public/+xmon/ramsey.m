function varargout = ramsey(varargin)
% ramsey
% mode: df01,dp,dz
% df01(default): detune by detuning iq frequency(sideband frequency)
% dp: detune by changing the second pi/2 pulse tracking frame
% dz: detune by z detune pulse
% 
% <_o_> = ramsey('qubit',_c&o_,'mode',m...
%       'time',[_i_],'detuning',<_f_>,'phaseOffset',<_f_>,...
%       'notes',<_c_>,'gui',<_b_>,'save',<_b_>)
% _f_: float
% _i_: integer
% _c_: char or char string
% _b_: boolean
% _o_: object
% a&b: default type is a, but type b is also acceptable
% []: can be an array, scalar also acceptable
% {}: must be a cell array
% <>: optional, for input arguments, assume the default value if not specified
% arguments order not important as long as they form correct pairs.


% Yulin Wu, 2016/12/27
    
    import qes.util.processArgs
    import data_taking.public.xmon.*
    args = processArgs(varargin,{'mode', 'df01','dataTyp','P','phaseOffset',0,'fit',false...
        'gui',false,'notes','','detuning',0,'detuneAmp',0,'save',true});
    switch args.mode
        case 'df01'
            e = ramsey_df01('qubit',args.qubit,'dataTyp',args.dataTyp,'phaseOffset',args.phaseOffset,...
                'time',args.time,'detuning',args.detuning,...
                'notes',args.notes,'gui',args.gui,'save',args.save);
        case 'dp'
            e = ramsey_dp('qubit',args.qubit,'dataTyp',args.dataTyp,'phaseOffset',args.phaseOffset,...
                'time',args.time,'detuning',args.detuning,...
                'notes',args.notes,'gui',args.gui,'save',args.save);
        case 'dz'
            e = ramsey_dz('qubit',args.qubit,'dataTyp',args.dataTyp,'phaseOffset',args.phaseOffset,...
                'time',args.time,'detuning',args.detuning,'detuneAmp',args.detuneAmp,...
                'notes',args.notes,'gui',args.gui,'save',args.save);
        otherwise
            throw(MException('QOS_spin_echo:illegalModeTyp',...
                sprintf('available modes are: df01, dz and dp, %s given.', args.mode)));
    end
    varargout{1} = e;
    if args.fit % Add by GM, 170623
        Ramsey_data0=e.data{1,1};
        Ramsey_time=args.time/2;
        
        for II=1:size(Ramsey_data0,1)
            Ramsey_data=Ramsey_data0(II,:);
            detuning=toolbox.data_tool.fitting.FFT_Peak(Ramsey_time,Ramsey_data);
            T1=args.T1*1000;

            Ramsey_length2=linspace(min(Ramsey_time),max(Ramsey_time),1000);
            f=@(a,x)(a(1)+a(2)*exp(-(x/a(3)).^2-x/T1).*cos(a(4)*2*pi.*x+a(5)));
            a=[(max(Ramsey_data)+min(Ramsey_data))/2,(max(Ramsey_data)-min(Ramsey_data))/2,Ramsey_time(end)/2,detuning,1];
            [b,r,J]=nlinfit(Ramsey_time,Ramsey_data,f,a);
            [~,se] = toolbox.data_tool.nlparci(b,r,J,0.05);
            decay(II)=abs(b(3));
            decay_err(II)=se(3);
            deltaf(II)=b(4);
        end
        if size(Ramsey_data0,1)==1
            hf=figure;
            plot(Ramsey_time,Ramsey_data,'o',Ramsey_length2,b(1)+b(2).*exp(-(Ramsey_length2./b(3)).^2-Ramsey_length2/T1).*cos(b(4)*2*pi.*Ramsey_length2+b(5)),'linewidth',2,'MarkerFaceColor','r');
            title(['T_2^*=' num2str(decay/1e3,'%.2f') '\pm' num2str(decay_err/1e3,'%.1f') 'us, detuning freq=' num2str(1e3*deltaf,'%.2f') 'MHz'])
            xlabel('Pulse delay (ns)');
            ylabel('P');
        else
            hf=figure;
            h1=errorbar(args.detuneAmp,decay/1e3,decay_err/1e3);
            ylim([0,Ramsey_time(end)*2/1e3])
            ylabel('T2* (us)')
            xlabel('Detune Amp')
            set(h1,'LineStyle','-','Marker','o','MarkerFaceColor','b')
        end
        if args.save
            QS = qes.qSettings.GetInstance();
            dataSvName = fullfile(QS.loadSSettings('data_path'),...
                [args.qubit '_T2_fit_',datestr(now,'yymmddTHHMMSS'),...
                num2str(ceil(99*rand(1,1)),'%0.0f'),'_.fig']);
            saveas(hf,dataSvName);
        end
    end
end