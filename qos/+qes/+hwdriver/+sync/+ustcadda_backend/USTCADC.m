% 	FileName:USTCADC.m
% 	Author:GuoCheng
% 	E-mail:fortune@mail.ustc.edu.cn
% 	All right reserved @ GuoCheng.
% 	Modified: 2017.2.26
%   Description:The class of ADC
classdef USTCADC < handle
    properties(SetAccess = private)
        netcard_no;         %��λ��������
        mac = zeros(1,6);   %��λ��������ַ
        isopen;             %�򿪱�ʶ
        status;             %��״̬
    end

    properties(SetAccess = private)
        name = '';              %ADC����
        sample_rate = 1e9;      %ADC�����ʣ�δʹ��
        channel_amount = 2;     %ADCͨ����δʹ�ã�ʵ��ʹ��I��Q����ͨ����
        sample_depth = 2000;    %ADC�������
        sample_count = 100;     %ADCʹ�ܺ��������
    end
    
    properties (GetAccess = private,Constant = true)
        driver = 'USTCADCDriver';
        driverh = 'USTCADCDriver.h';
    end
    
    methods
        function obj = USTCADC(num)
            obj.netcard_no = num;
            obj.isopen = false;
            obj.status = 'close';
            driverfilename = [obj.driver,'.dll'];
            if(~libisloaded(obj.driver))
                loadlibrary(driverfilename,obj.driverh);
            end
        end
        
        function Open(obj)
            if ~obj.isopen
                ret = calllib(obj.driver,'OpenADC',int32(obj.netcard_no));
                if(ret == 0)
                    obj.status = 'open';
                    obj.isopen = true;
                else
                   error('USTCADC:OpenError','Open ADC failed!');
                end 
                obj.Init()
            end
        end
        
        function Init(obj)
            obj.SetMacAddr(obj.mac');
            obj.SetSampleDepth(obj.sample_depth);
            obj.SetTrigCount(obj.sample_count);
        end
        
        function Close(obj)
            if obj.isopen
                ret = calllib(obj.driver,'CloseADC');
                if(ret == 0)
                    obj.status = 'close';
                    obj.isopen = false;
                else
                   error('USTCADC:CloseError','Close ADC failed!');
                end 
            end
        end
        
        function SetSampleDepth(obj,depth)
             if obj.isopen
                data = [0,18,depth/256,mod(depth,256)];
                pdata = libpointer('uint8Ptr', data);
                [ret,~] = calllib(obj.driver,'SendData',int32(4),pdata);
                if(ret ~= 0)
                   error('USTCADC:SendPacket','SetSampleDepth failed!');
                end 
            end
        end
        
        function ClearBuff(obj)
             if obj.isopen
                ret = calllib(obj.driver,'ClearBuff');
                if(ret ~= 0)
                   error('USTCADC:ClearBuff','ClearBuff failed!');
                end 
            end
        end
        
        function SetTrigCount(obj,count)
             if obj.isopen
                data = [0,19,count/256,mod(count,256)];
                pdata = libpointer('uint8Ptr', data);
                [ret,~] = calllib(obj.driver,'SendData',int32(4),pdata);
                if(ret ~= 0)
                   error('USTCADC:SendPacket','SetTrigCount failed!');
                end 
            end
        end
        
        function SetMacAddr(obj,mac)
           if obj.isopen
                data = [0,17];
                data = [data,mac];
                pdata = libpointer('uint8Ptr', data);
                [ret,~] = calllib(obj.driver,'SendData',int32(length(mac)+2),pdata);
                if(ret ~= 0)
                   error('USTCADC:SendPacket','SetMacAddr failed!');
                end 
            end
        end
        
        function ForceTrig(obj)
           if obj.isopen
                data = [0,1,238,238,238,238,238,238];
                pdata = libpointer('uint8Ptr', data);
                [ret,~] = calllib(obj.driver,'SendData',int32(8),pdata);
                if(ret ~= 0)
                   error('USTCADC:SendPacket','ForceTrig failed!');
                end 
           end
        end
        
        function EnableADC(obj)
           if obj.isopen
                data = [0,3,238,238,238,238,238,238];
                pdata = libpointer('uint8Ptr', data);
                [ret,~] = calllib(obj.driver,'SendData',int32(8),pdata);
                if(ret ~= 0)
                   error('USTCADC:SendPacket','EnableADC failed!');
                end
           end
        end
        
        function [ret,I,Q] = RecvData(obj,row,column)
            if obj.isopen
                I = zeros(row*column,1);
                Q = zeros(row*column,1);
                pI = libpointer('uint8Ptr', I);
                pQ = libpointer('uint8Ptr', Q);
                [ret,I,Q] = calllib(obj.driver,'RecvData',int32(row*column),int32(column),pI,pQ);
            end
        end
        
        function set(obj,properties,value)
            switch properties
                case 'mac';
                    mac_str = regexp(value,'-', 'split');
                    obj.mac = hex2dec(mac_str);
                case 'name'; obj.name = value;
                case 'sample_rate'; obj.sample_rate = value;
                case 'channel_amount';obj.channel_amount = value;
            end
        end
        
        function value = get(obj,properties)
            switch properties
                case 'mac';value = obj.mac;
                case 'name'; value = obj.name;
                case 'sample_rate'; value = obj.sample_rate;
                case 'channel_amount';value = obj.channel_amount;
            end
        end
     end
end