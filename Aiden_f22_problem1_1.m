classdef Aiden_f22_problem1_1 < PROBLEM
    % <2024><multi><real><constrained> 测试系统2：考虑电热冷场景  添加初始化复数个体，逆变换

    properties
        T = 24; %；每个出力设备优化的时间点长度
        complex_D;
    end
    methods
        % Default settings of the problem
        function Setting(obj)
            obj.M = 2; % 目标数量
            obj.D = 120; % 维度
            % 伴生能源设备出力上限
            Hrto_min = 10;
            Hwshp_min = 10;
            Hrto_max = 150;
            Hwshp_max = 120;
            Pw = [120 110 120 100 110 100 85 75 65 60 50 45 55 45 45 40 50 70 80 90 90 120 150 140];
            Ppv = [0 0 0 0 0 0 100 140 124 150 178 180 190 205 200 188 178 150 0 0 0 0 0 0];

            % 设置上下界
            L1 = zeros(1, obj.D);
            U1 = Pw; % 风电上界
            U1(25:48) = Ppv; % 光伏上界
            L1(49:72) = Hrto_min; U1(49:72) = Hrto_max;% 乏风氧化装置上界
            L1(73:96) = Hwshp_min; U1(73:96) = Hwshp_max; % 水源热泵上界
            U1(97:120) = 280;  %电制冷机

            obj.lower = L1;
            obj.upper = U1;
            obj.encoding = ones(1, obj.D);
        end

        % Calculate objective values
        function PopObj = CalObj(~,x)
            % 参数设置
            Ce=[0.1 0.1 0.1 0.2 0.2   0.2 0.4 0.6 0.6 0.6   1.0 1.0 1.0 1.0 0.6   0.4 0.4 0.4 0.4 0.4   0.4 0.4 0.1 0.1];
            Cg=[0.2 0.2 0.2 0.2 0.2   0.2 0.2 0.2 0.2 0.2   0.2 0.2 0.2 0.2 0.2   0.2 0.2 0.2 0.2 0.2   0.2 0.2 0.2 0.2];
            Lc1=[135 168 175 180 150   150 145 140 140 135   145 155 155 155 160   160 130 150 150 120   120 150 150 150];
            Le1=[410 414 443 395 385   375 385 488 490 545   555 545 530 515 515   510 510 550 550 570    580 550 500 470];
            Lh1=[650 640 630 630 640   650 670 680 690 690   690 680 670 660 650   660 670 660 650 680   680 670 670 670];
            Pw=[120 110 120 100 110   100 85 75 65 60    50 45 55 45 45   40 50 70 80 90   90 120 150 140];
            Ppv=[0	0 0	0 0	     0 100 140 124 150     178 180 190 205 200    188	178	150	0 0	  0	0 0	0];


            %% 设备能效参数
            eta_chp1=0.4;%%%燃气轮机热效率
            eta_chp2=0.5;%%%燃气轮机电效率0.5
            eta_vohp=3.3;%%%乏风氧化装置系数
            eta_wshp=3.5;%%%水源热泵系数
            eta_ec=0.65;%%%电制冷机能效系数
            eta_ac=0.7;%%%吸收式制冷机能效系数
            %% 设备运维成本系数
            Pom_wt=0.25;
            Pom_pv=0.3;
            Pom_vohp=0.55;
            Pom_wshp=0.6;
            Pom_ac=0.3;
            Pom_ec=0.2;

            Pom_gt=0.1;
            %% 弃能源成本系数
            Pab_pv=0.8;
            Pab_wt=0.6;
            Pab_rto=0.7;
            Pab_wshp=0.75;

            %% 伴生能源设备出力上限
            Hrto_max=150;
            Hwshp_max=120;
            %% 能源供应端优化变量
            Pwt1=x(:,1:24);%风电功率
            Ppv1=x(:,25:48);%光伏
            P_vohp=x(:,49:72);%乏风装置
            P_wshp=x(:,73:96);%气源热泵
            P_ec=x(:,97:120);%电制冷机

            %% 经济成本目标函数值计算
            %%购能成本+运维成本
            H_ac = (-eta_ec*P_ec+Lc1)/eta_ac;
            H_chp=-eta_vohp*P_vohp-eta_wshp*P_wshp+H_ac+Lh1;
            pc = Ce .* (-(H_chp/eta_chp2*eta_chp1)-Ppv1-Pwt1+P_ec+Le1+P_vohp+P_wshp) +...
                 Cg .* (H_chp/eta_chp2);
            om = Pom_wt*Pwt1 + Pom_pv*Ppv1 + Pom_gt*(H_chp/eta_chp2) + ...
                 Pom_ec*eta_ec*P_ec + Pom_ac*eta_ac*H_ac + Pom_vohp*eta_vohp*P_vohp + Pom_wshp*eta_wshp*P_wshp;
            f1 = sum(pc, 2)+sum(om, 2);
            %%弃能源成本
            ae = Pab_wt*(Pw-Pwt1)+Pab_pv*(Ppv-Ppv1)+Pab_rto*(Hrto_max-P_vohp)+Pab_wshp*(Hwshp_max-P_wshp);
            f2 = sum(ae,2);

            PopObj(:,1) = f1;
            PopObj(:,2) = f2;
        end

        % Calculate constraint violations
        function PopCon = CalCon(~,x)
            %% 能效参数
            eta_chp1=0.4;%%%燃气轮机电效率
            eta_chp2=0.5;%%%燃气轮机热效率
            eta_vohp=3.3;%%%乏风氧化装置系数
            eta_wshp=3.5;%%%水源热泵系数
            eta_ec=0.65;%%%电制冷机能效系数
            eta_ac=0.7;%%%吸收式制冷机能效系数
            %%%%负荷参数
            Lc1=[135 168 175 180 150   150 145 140 140 135   145 155 155 155 160   160 130 150 150 120   120 150 150 150];
            Le1=[410 414 443 395 385   375 385 488 490 545   555 545 530 515 515   510 510 550 550 570    580 550 500 470];
            Lh1=[650 640 630 630 640   650 670 680 690 690   690 680 670 660 650   660 670 660 650 680   680 670 670 670];
            %% 能源供应端优化变量
            Pwt1=x(:,1:24);%风电功率
            Ppv1=x(:,25:48);%光伏
            P_vohp=x(:,49:72);%乏风装置
            P_wshp=x(:,73:96);%气源热泵
            P_ec=x(:,97:120);%电制冷
            NP=size(x,1);
            T=24;

            % 冷平衡计算Qac出力
            H_ac = (-eta_ec * P_ec + Lc1) / eta_ac;

            % 热平衡计算CHP出力
            G_CHP = (-eta_vohp * P_vohp - eta_wshp * P_wshp + H_ac + Lh1) / eta_chp2;

            % 电平衡计算电网
            Pgrid = -eta_chp1 * G_CHP - Ppv1 - Pwt1 + P_ec + Le1 + P_vohp + P_wshp;

            % 电网上下限约束
            dp1 = max(0, -Pgrid);  % Pgrid < 0 的部分
            dp2 = max(0, Pgrid - 800);  % Pgrid > 800 的部分
            fa1 = sum(dp1 + dp2, 2);  % 对每个样本求和

            % 吸收式制冷机上下限约束
            dp3 = max(0, -H_ac);  % Qac < 0 的部分
            dp4 = max(0, H_ac - 260);  % Qac > 260 的部分
            fa2 = sum(dp3 + dp4, 2);  % 对每个样本求和

            % 燃气轮机上下限约束
            dp5 = max(0, -G_CHP);  % Pgt < 0 的部分
            dp6 = max(0, G_CHP - 300);  % Pgt > 300 的部分
            fa3 = sum(dp5 + dp6, 2);  % 对每个样本求和

            % 爬坡约束计算
            Pgt_diff = abs(G_CHP(:, 2:T) - G_CHP(:, 1:T-1));  % 计算Pgt的变化量
            dp7 = max(0, Pgt_diff - 50);  % 超过50的部分
            fa4 = sum(dp7, 2);  % 对每个样本求和

            % Constraints in decision space
            PopCon = [fa1, fa2, fa3, fa4];  % 组合所有约束
            PopCon(abs(PopCon) < 1e-5) = 0;
        end

        function R = GetOptimum(obj,~)
            dataFolderPath = fullfile(pwd, 'Data');
            % matFilePath = fullfile(dataFolderPath, 'ech_20_true_PF.mat');
            matFilePath = fullfile(dataFolderPath, 'multicplex1.mat');
            data = load(matFilePath);  % 确保 'Data.mat' 在当前工作目录下
            if isfield(data, 'PF')
                % 提取第 121 和 122 列的内容
                R = data.PF;
            else
                error('ech_true_PF.mat 文件中未找到变量 "Data"');
            end
        end
    end
end
