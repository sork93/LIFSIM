%*********************APARTADO 4**************************************
% 
% A partir del diagrama de bloques del enunciado, se han obtenido en el
% archivo Apartado_4_desarrollo.nb de Wolfram Mathematica las funciones de
% transferencia en lazo cerrado. A partir de ellos y utilizando los datos
% de las funciones de transferencia del trabajo 1, las funciones de 
% transferencia del actuador y del sensor, y Kdl obtenido en el apartado 3
% se obtienen las expresiones de la Funcion de transferencia en lazo
% cerrado. 

% clc
close all
clear all
global TF


%% Funcion de transferencia del actuador Tlag = 0.05
%Primer orden

TF.actuador = tf([1],[0.05 1]);

%Segundo orden: Sacado del actuador del modelo ' aeroblk_HL20 '
wn_act=44;
z_act=   0.707106781186547;
TF.actuador = tf([1],[1/wn_act^2 2*z_act/wn_act 1]);

%TF.actuador = tf (1,1);

%% Funcion de transferencia del sensor Tlag = 0.1
%Primer orden
Tlag = 0.1;
TF.sensor = tf([1],[Tlag 1]);
%TF.sensor = tf(1,1);


%% Funciones de transferencia del trabajo 1

% TF_T1=load('TF_OL.mat');
% 
% 
% % Guardamos los valores en TF
% 
% TF.Den =      tf(TF_T1.TF.long.Den,[1]);
% TF.Nude =     tf(TF_T1.TF.long.Nums(1,:),[1]);
% TF.Nalfade =  tf(TF_T1.TF.long.Nums(2,:),[1]);
% TF.Nthetade = tf(TF_T1.TF.long.Nums(3,:),[1]);
% TF.Nqde     = tf(TF_T1.TF.long.Nums(4,:),[1]);


%% LIBIS Transfer functions

TF_T1 = load('LibisTransferFunctions.mat');

TF.Den =      tf(TF_T1.LibisTF.long.Denominator,[1]);
TF.Nude =     tf(TF_T1.LibisTF.long.Numerators(1),[1]);
TF.Nalfade =  tf(TF_T1.LibisTF.long.Numerators(2),[1]);
TF.Nthetade = tf(TF_T1.LibisTF.long.Numerators(3),[1]);
TF.Nqde     = tf(TF_T1.LibisTF.long.Numerators(4),[1]);



%% Funcion transferencia Direct Link
vEstacionario=TF.Nthetade.Numerator{1}(end)/TF.Den.Numerator{1}(end);
% vEstacionario=-4.4217;
K_DL=  1;%1/vEstacionario; No usamos el valor estacionario puesto que es inestable
TF.DirectLink = tf([K_DL], [1]);

%% Funciones de transferencia Lazo Cerrado
% TFCL definiendo valores de Ganancias de realimentacion

% De las Fs utilizadas en el barrido en bucle abierto obtenemos
% las ganancias de realimentacion 

% F_alfa = [-0.5 -0.2 0.0 0.5 1.0 2.0 3.0 4.0];
F_q    = [-0.5 -0.2 0.0 0.5 1.0 2.0 3.0 4.0];
% 
% F_q    = [-0.1 -0.02 0.0 0.02 0.1 0.2 0.3 0.4]+1;
% 
F_alfa = [-0.1 -0.05 -0.03 -0.02 0 0.1 0.2 0.4];
F_alfa = F_alfa+1;

% F_q    = [-0.1 -0.05 0.0 0.05 0.1 0.2 0.3 0.4];


% 

% kdealfa=-(F_alfa-1)*C_malfa/C_mdeltae;
kdealfa=[0];
% kdealfa = linspace(-15*0.001,15*0.001,4);


% kdeq=-(F_q-1)*C_mq_dim/C_mdeltae;
kdeq=[0.001, -60*0.001];
% kdeq = linspace(-30*0.001,30*0.001,4);
% kdeq = linspace(-30*0.001,30*0.001,4);
kdeq = [0];

% kdealfa= 0.0;
% kdeq =linspace(-0.05,0.05,8);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Barrido de ganancias estables:
kdealfa =    [-0.0050*0.8,-0.0050*0.9, -0.0050, 1.1*-0.0050, 1.14*-0.0050];
kdeq = [-0.02,-0.018,-0.015,-0.01, 0.01, 0.03, 0.04];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % GA Results:
% kdealfa =    [-0.567/100];
% kdeq = [-1.602/100];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% obtenemos las ra�ces para cada combinacion de ks

for i = 1:length(kdealfa)
    
    Kdealfa=kdealfa(i);
    
    for j = 1:length(kdeq)
    
    Kdeq = kdeq(j);   
        
    TFCL.u(i,j)     = (TF.actuador*TF.DirectLink*TF.Nude)/(TF.Den-TF.actuador*(TF.sensor*Kdealfa*TF.Nalfade+TF.sensor*Kdeq*TF.Nqde));
    TFCL.alfa(i,j)  = (TF.actuador*TF.DirectLink*TF.Nalfade)/(TF.Den-TF.actuador*(TF.sensor*Kdealfa*TF.Nalfade+TF.sensor*Kdeq*TF.Nqde));
    TFCL.theta(i,j) = (TF.actuador*TF.DirectLink*TF.Nthetade)/(TF.Den-TF.actuador*(TF.sensor*Kdealfa*TF.Nalfade+TF.sensor*Kdeq*TF.Nqde));
    TFCL.q(i,j)     = (TF.actuador*TF.DirectLink*TF.Nqde)/(TF.Den-TF.actuador*(TF.sensor*Kdealfa*TF.Nalfade+TF.sensor*Kdeq*TF.Nqde));
    TFCL.TFOL(i,j)  = -TF.actuador*(TF.sensor*Kdealfa*TF.Nalfade+TF.sensor*Kdeq*TF.Nqde)/TF.Den;
    end
end

%% Barrido ganancias
% Dibujamos los polos de las funciones de transferencia

    figure (10)

%Los puntos T1, T2, T3, T4 corresponden a los l�mites de los ejes a representar

    T1 = tf([1],[1 50]); 
    T2 = tf([1],[1 -50]);
    T3 = tf([1],[1 -50i]);
    T4 = tf([1],[1 50i]);
    T  = T1*T2*T3*T4;
    pzmap(T,'w');
    grid on
    hold on
    
    
    marker = ['+','o','*','s','^','p','v','<'];
    color  = ['k','m','c','r','g','b','y','m'];
    titles = [-0.5,-0.2,0,0.5,1,2,3,4];
    title('Barrido ganancias de realimentacion','interpreter','tex')
    
  %Polos del sistema Closed Loop aumentado (Incluye actuadores etc) para diferentes combinaciones de ganacias
    
 for i = 1:length(kdealfa)
      for j = 1:length(kdeq)
          %se pintan todos los polos para esa funcion de transferencia
          %misma color y marcador
        for k=1:length(pole(TFCL.theta(i,j)))
           aux = pole(TFCL.theta(i,j)); 
           p1(i,j,k)=plot(real(aux(k)),imag(aux(k)),strcat(color(i),marker(j)));hold on 
        end

      end
 end
 
%  plot(real(pole(TFCL.theta(:,j))),imag(pole(TFCL.theta(:,j))))
%  %%
%  
%  x01 = esort(real(pole(TFCL.theta(1,1))));
%   x02 = esort(imag(pole(TFCL.theta(1,1))));
%   X0 = [x01,x02]
%   
%  x1 = real(pole(TFCL.theta(1,1)));
%  x2 = imag(pole(TFCL.theta(1,1)));
%  X= [x1,x2]
%  
%   y1 = real(pole(TFCL.theta(1,2)));
%  y2 = imag(pole(TFCL.theta(1,2)));
%  Y=[y1,y2]
%  
%   [n,d] = knnsearch(Y,X0)
%  
%  
%  Y=[1,2;1,1;0,0;0,1;100,3]
% %  Y=[1,1.01]
%  [n,d] = knnsearch(X,Y)
 
 %%
 % Polos del sistema en Open Loop SIN AUMENTAR. (sin actuadores, etc)
 
         for k=1:length(pole(1/TF.Den))
           aux = pole(1/TF.Den); 
           pOL(k)=plot(real(aux(k)),imag(aux(k)),strcat('k','.'));hold on 
         end
         
         
 % Construcci�n de la leyenda:
          for j = 1:length(kdealfa)
             legendAlfa{j}= strcat('k_\delta_e_\alpha =  ',num2str(kdealfa(j)));
          end    
         
         for j = 1:length(kdeq)
             legendQ{j}= strcat('k_\delta_e_q =  ',num2str(kdeq(j)));
         end
         
         legendVec = cat(1,'Open Loop sin aumentar',legendAlfa', legendQ');
         plotsVec       = cat(1,pOL(1),p1(:,1,1),p1(1,:,2)');
         
         legend(plotsVec, legendVec)

         
%  legend([p1(1,1,1) p1(2,2,1) p1(3,3,1) p1(4,4,1) p1(5,5,1) p1(6,6,1) p1(7,7,1) p1(8,8,1)],...
%      'k_\delta_e_\alpha = 0.4299 k_\delta_e_q = 0.3027','k_\delta_e_\alpha  = 0.3439 k_\delta_e_q = 0.2422',...
%      'k_\delta_e_\alpha  = 0.2866 k_\delta_e_q = 0.2018','k_\delta_e_\alpha  = 0.1433 k_\delta_e_q = 0.1009',...
%      'k_\delta_e_\alpha  = 0.0 k_\delta_e_q = 0.0','k_\delta_e_\alpha  = -0.2866 k_\delta_e_q = -0.2018',...
%      'k_\delta_e_\alpha = -0.5731 k_\delta_e_q = -0.4036','k_\delta_e_\alpha  = -0.8597 k_\delta_e_q = -0.6055',...
%      'interpreter','tex','Location','northeast')

%  legend([p1(1,1,1) p1(2,2,1) p1(3,3,1) p1(4,4,1) p1(5,5,1) p1(6,6,1) p1(7,7,1) p1(8,8,1)],...
%      'k_\delta_e_\alpha = 0.0287 k_\delta_e_q = 0.3027','k_\delta_e_\alpha  = 0.0143 k_\delta_e_q = 0.2422',...
%      'k_\delta_e_\alpha  = 0.0086 k_\delta_e_q = 0.2018','k_\delta_e_\alpha  = 0.0057 k_\delta_e_q = 0.1009',...
%      'k_\delta_e_\alpha  = 0.0 k_\delta_e_q = 0.0','k_\delta_e_\alpha  = -0.0287 k_\delta_e_q = -0.2018',...
%      'k_\delta_e_\alpha = -0.0573 k_\delta_e_q = -0.4036','k_\delta_e_\alpha  = -0.1146 k_\delta_e_q = -0.6055',...
%      'interpreter','tex','Location','northeast')

return

 %% DIAGRAMAS DE NICHOLS 
 close all
 

%**************************************************************************
%Representaci�n Gr�fica Manual
%**************************************************************************
% Respuesta en frecuencias
% Rango de Frecuencias
OmegaIni = 0.01;
OmegaFin = 100;
Nomega   = 10000;
% Escala logaritmica
vOmega  = logspace(log10(OmegaIni),log10(OmegaFin),Nomega);

 for i = 1:length(kdealfa)
      for j = 1:length(kdeq)
          %se pintan todos los polos para esa funcion de transferencia
          %misma color y marcador

         
% 
%     titles={'Elevador a Velocidad';'Elevador a \alpha';...
%         'Elevador a \theta';'Elevador a q'};
 [Gm.TFOL(i,j),Pm.TFOL(i,j),Wgm.TFOL(i,j),Wpm.TFOL(i,j)] = margin(TFCL.TFOL(i,j)) ;
     Gm_dB.TFOL(i,j) = 20*log10(Gm.TFOL(i,j));
%      [Gm.u(i,j),Pm.u(i,j),Wgm.u(i,j),Wpm.u(i,j)] = margin(TFCL.TFOL(i,j)) ;
%      Gm_dB.u(i,j) = 20*log10(Gm.u(i,j));
%       [Gm.theta(i,j),Pm.theta(i,j),Wgm.theta(i,j),Wpm.theta(i,j)] = margin(TFCL.TFOL(i,j)) ;
%      Gm_dB.theta(i,j) = 20*log10(Gm.theta(i,j));
%       [Gm.q(i,j),Pm.q(i,j),Wgm.q(i,j),Wpm.q(i,j)] = margin(TFCL.TFOL(i,j)) ;
%      Gm_dB.q(i,j) = 20*log10(Gm.q(i,j));

% figure(1)
% bode(TFCL.TFOL(i,j)) 
% hold all

  
    [vMagBodeTemp(i,j,:), vPhaseBodeTemp(i,j,:)] = bode(TFCL.TFOL(i,j),vOmega);
    vMagBodedB(i,j,:)    =  squeeze(20*log10(vMagBodeTemp(i,j,:)));
    vPhaseBodeDeg(i,j,:) =  squeeze(vPhaseBodeTemp(i,j,:));
    x_bode=squeeze(vPhaseBodeDeg(i,j,:));
    y_bode=squeeze(vMagBodedB(i,j,:));
    
    figure(i+1)
%     figure(i+j+8);
    plot(x_bode,y_bode,color(j));%,'Linewidth',2);
    grid on; hold all; 
    setFigureDefaults();
% %     set(gca,'Xlim',[min(vPhaseBodeDeg(i,:)) max(vPhaseBodeDeg(i,:))],'FontSize',10,'FontName','Times new Roman','box','on');
%      xlabel('Freq (rd/s)','FontSize',20);
     xlabel('Phase (Deg)');
%     ylabel('Mag(dB)','FontSize',20)
     ylabel('Mag(dB)')
   hold on;set(gca,'XTick',[-720:45:720]);
   hold on;set(gca,'YTick',[-100:10:100]);
   

%     set(gcf,'Color',[1 1 1]);
% %     title(titles(i));
%     
% %     format_Grafico = strcat('Diagrama de Nichols long ',num2str(i));
% %     format_Grafico = [pwd filesep 'figuras' filesep format_Grafico];
% % 
% %     saveas(gcf,format_Grafico,'epsc');  
%    
      end
 end

 %% Respuesta de las variables a rampa
 
TimeEnd     = 100;
StepSize    = 0.01;
vTime       = [0:StepSize:TimeEnd];  %Querry points
    vInpTime    = [0 1/5 3 TimeEnd];
% vInpTime    = [0 10 15 TimeEnd];
vInp        = [0 1 1 1];             %Sample pints values
vInput      = interp1(vInpTime,vInp,vTime);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Elegir �ndices i,j de las ganancias !!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=4;
j=4;
TFlongvector= [TFCL.u(i,j), TFCL.alfa(i,j), TFCL.theta(i,j), TFCL.q(i,j)];
%Longitudinal estacionaria
for i=1:4
    vTime       = [0:StepSize:TimeEnd];
    vInpTime    = [0 1/5 3 TimeEnd]; %Sample points
    vInput      = interp1(vInpTime,vInp,vTime);

    vOut_long = lsim(TFlongvector(i),vInput,vTime);

    figure(i+2)
    titles={'Respuesta temporal u vs rampa elevador',...
        'Respuesta temporal \alpha vs rampa elevador',...
        'Respuesta temporal \theta vs rampa elevador',...
         'Respuesta temporal \q vs rampa elevador',};
    ylabels={'\Delta u ','\Delta\alpha ','\Delta\theta ','\Delta q '};

    plot(vTime,vInput,'r');
    grid on;hold all;
    
    plot(vTime,vOut_long,'b');

    grid on;hold all;
    title(titles(i))
    xlabel('Tiempo(s)');
    ylabel(ylabels(i),'interpreter','tex');
    legend({'Input','Output'})
    set(gcf,'Color',[1 1 1]);
    
%     vEstacionario_rampa(i)=vOut_long(length(vTime));
%     plot(vTime,ones(size(vTime))*vEstacionario_rampa(i),'--','LineWidth',1);
%     
%     overshoot_long(i)= -vEstacionario_rampa(i)+max(vOut_long);
%     undershoot_long(i)= -vEstacionario_rampa(i)+min(vOut_long);

    setFigureDefaults()
    format_Grafico = strcat('TFCLRespuestaRampa',num2str(i));
    format_Grafico = [pwd filesep 'Figuras' filesep format_Grafico];
    saveas(gcf,format_Grafico,'epsc'); 


end

%% Delay-time
close all

i=4;
j=4;

TFlongvector= [TFCL.u(i,j), TFCL.alfa(i,j), TFCL.theta(i,j), TFCL.q(i,j)];

TimeEnd = 100;
% Calculo de la derivada
TF.Global=TFCL.theta(i,j);
TF.Global_dot=TFCL.q(i,j);

% Vectores de tiempo, input
StepSize=0.0001;
vTime       = [0:StepSize:TimeEnd];
vInpTime    = [0 1/5 3 TimeEnd]; %Sample points
vInput      = interp1(vInpTime,vInp,vTime);

%Obtencion de la respuesta
vOut_long = lsim(TF.Global,vInput,vTime);
respuesta(i,j,:)=vOut_long;
vOut_long_dot = lsim(TF.Global_dot,vInput,vTime);


%Representacion grafica
figure(5)
setFigureDefaults()
titles={'Rise time, Delay time \theta vs rampa elevador','Interpreter','Latex'};
ylabels={'\Delta\theta '};

%Plot input
pinput=plot(vTime,vInput,'r');
grid on;hold all;

%Plot output y derivada
presponse=plot(vTime,vOut_long,'b');
presponsedot=plot(vTime,vOut_long_dot,'c');

%Maximo de la derivada
[y_dot_max, x_m_max] = max(vOut_long_dot);
m = y_dot_max;
x = vTime(x_m_max);
y =  vOut_long(x_m_max);

%Plot de la recta tangente
n =y-m*x;
x_tang=linspace(0,1,10000); 
y_tang=n+m*x_tang;
plot(x_tang, y_tang,'--k','LineWidth',1 )
 
%Buscar corte con el eje y, Time Delay
x_time=find(abs(y_tang)<0.001);
timeDelay=x_tang(x_time(round(length(x_time)/2)));
plot(linspace(0,timeDelay,1000),zeros(1000),'g')


%Rise time
Kest= TF.Global.Numerator{1,1}(end)/TF.Global.Denominator{1,1}(end);

% Kest=vOut_long(end);
[pks,locs]=findpeaks(-(abs(vOut_long-0.1*Kest)));
x_01=locs(1);
% [y_01, x_01]= min(abs(vOut_long-0.1*Kest));
[pks,locs]=findpeaks(-(abs(vOut_long-0.9*Kest)));
x_09=locs(1);
% [y_09, x_09]= min(abs(vOut_long-0.9*Kest));
riseTime=vTime(x_09)-vTime(x_01);
y_height=-0.1;
plot(linspace(vTime(x_01),vTime(x_09),100),linspace(y_height,y_height,100),'m')
plot(vTime(x_09),y_height,'xm');plot(vTime(x_01),y_height,'xm');

tD(i,j)=timeDelay;
rT(i,j)=riseTime;



    xlim([0,1.6])
ylim([-0.2,0.6])
grid on;hold all;
title(titles(1))
xlabel('Tiempo(s)');
ylabel(ylabels(1));
% legend({'Input','Output(\theta)','\Delta q','Tangente',strcat('Time Delay= ',num2str(timeDelay),'s'),strcat('Rise Time= ',num2str(riseTime),'s')},'location','best')
legend([pinput,presponse,presponsedot],'Input','Ramp Response','Ramp Response dot','Time Delay','Rise Time','location','best','Interpreter','tex')

set(gcf,'Color',[1 1 1]);


%Plot puntos relevantes
plot( timeDelay,0,'k+','LineWidth',1);
plot(vTime(x_m_max),y_dot_max,'+');
plot(linspace(vTime(x_01),vTime(x_09),100),linspace(y_height,y_height,100),'m')
plot(vTime(x_09),y_height,'xm');plot(vTime(x_01),y_height,'xm');
plot(linspace(vTime(x_01),vTime(x_01),100),linspace(y_height,0.1,100),'-k','linewidth',0.1)
plot(linspace(vTime(x_09),vTime(x_09),100),linspace(y_height,0.9,100),'-k','linewidth',0.1)
    
%     vEstacionario_rampa(i)=vOut_long(length(vTime));
%     plot(vTime,ones(size(vTime))*vEstacionario_rampa(i),'--','LineWidth',1);
%     
%     overshoot_long(i)= -vEstacionario_rampa(i)+max(vOut_long);
%     undershoot_long(i)= -vEstacionario_rampa(i)+min(vOut_long);


setFigureDefaults()
format_Grafico = strcat('TFCLDelayTime51');
format_Grafico = [pwd filesep 'Figuras' filesep format_Grafico];
saveas(gcf,format_Grafico,'epsc'); 

figure(2)
pzmap(TF.Global)

%%
damp(4,4)=0.859;
damp(3,4)=0.874;
damp(2,4)=0.761;
damp(1,4)=0.475;
damp(5,4)=0.835;
damp(4,3)=0.704;
damp(4,2)=0.659;
damp(4,1)=0.602;
damp(4,5)=0.808;
damp(4,6)=0.37;
damp(3,3)=0.703;
damp(2,3)=0.694;
damp(1,3)=0.57;
damp(1,2)=0.571;
damp(2,2)=0.648;

f(4,4)=7.9;
f(3,4)=7.17;
f(2,4)=5.53;
f(1,4)=5.81;
f(5,4)=8.81;
f(4,3)=9.5;
f(4,2)=10;
f(4,1)=10.6;
f(4,5)=3.36;
f(4,6)=2.57;
f(3,3)=9.23;
f(2,3)=8.64;
f(1,3)=7.27;
f(1,2)=8.09;
f(2,2)=9.29;


for i=[1:1:5]
    for j=[1:1:6]
        scatter3(f(i,j),damp(i,j),rT(i,j),'filled');hold on
    end
end

%%
% for i=[1:1:5]
%     for j=[1:1:6]
%         plot(vTime,squeeze(respuesta(i,j,:)));hold on
%     end
% end
close all
figure(5)

i=4;
    for j=[1:1:5]
%         'Kdeq=',num2str(kdeq(j)),
              pl(j)=plot(vTime,squeeze(respuesta(i,j,:)),'DisplayName',strcat(' \xi=',num2str(damp(i,j))...
                  ,' Freq(rad/s)=',num2str(f(i,j)),' delayTime(s)=',num2str(tD(i,j)),' riseTime(s)=',num2str(rT(i,j))));hold on
    end
title('Respuesta a Kdea=0.0057')
xlabel('Tiempo(s)');
ylabel(ylabels(1));
legend('show','Location','best')
grid on
xlim([0,20])
setFigureDefaults()

figure(6)
j=4;
    for i=[1:1:5]
%         'Kdeq=',num2str(kdeq(j)),
              pl(j)=plot(vTime,squeeze(respuesta(i,j,:)),'DisplayName',strcat(' \xi=',num2str(damp(i,j))...
                  ,' Freq(rad/s)=',num2str(f(i,j)),' delayTime(s)=',num2str(tD(i,j)),' riseTime(s)=',num2str(rT(i,j))));hold on
    end

title('Respuesta a Kdeq=0.1009')
xlabel('Tiempo(s)');
ylabel(ylabels(1));
legend('show','Location','best')
xlim([0,40])
grid on
setFigureDefaults()