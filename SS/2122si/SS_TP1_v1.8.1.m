%{
    Trabalho Prático 1 - Sinais e Sistemas
    
    Turma: LT21N
    Grupo: 0.1
        Nuno Brito - A46948
        Tiago Moreno - A28421
        Rafael Romão - A48863

    Data de entrega: 2021-11-22
%}

clc; close all; clear;

%%
% Problema 2 - Parte 1 - Alínea a)
% Situação: [RESOLVIDO]

clc; close all; clear;

% Parâmetros para linspace
% Intervalo [-1,3] para enquadrar as funções que estão contidas no intervalo [0,2]
inicial = -1;
step = 1000;
final = 3;

t = linspace(inicial,final,step)+eps;

%   Construção de funções
x0t = heaviside(t) - heaviside(t-2);
x1t = t .* (heaviside(t) - heaviside(t-1)) + (-t+2) .* (heaviside(t-1) - heaviside(t-2));
x2t = - (heaviside(t) - heaviside(t-1)) + (heaviside(t-1) - heaviside(t-2));
x3t = (t-1) .* (heaviside(t) - heaviside(t-1)) + (-t+3) .* (heaviside(t-1) - heaviside(t-2));

%   Representação gráfica de funções
figure
subplot(2,2,1), hold on, plot(t,x0t,'b-'), grid on, title('Função x0t'), xlabel('t'), ylabel('x0t'), hold off;
subplot(2,2,2), hold on, plot(t,x1t,'b-'), grid on, title('Função x1t'), xlabel('t'), ylabel('x1t'), hold off;
subplot(2,2,3), hold on, plot(t,x2t,'b-'), grid on, title('Função x2t'), xlabel('t'), ylabel('x2t'), hold off;
subplot(2,2,4), hold on, plot(t,x3t,'b-'), grid on, title('Função x3t'), xlabel('t'), ylabel('x3t'), hold off;

%%

% Problema 2 - Parte 2 - Alínea b)
% Situação: [RESOLVIDO] [Verificar diracs]
%{
    Observações:
        Variáveis:
        tg - vector que contém os vários pontos
        t - variável tempo
        k - indíce da função
        x - recebe a função pedida por cada um dos cases
%}

clc; close all; clear;

% Variável auxiliar para sair do while
aux = true;

% Construção de funções
syms t;
x0t = heaviside(t) - heaviside(t-2);
x1t = t .* (heaviside(t) - heaviside(t-1)) + (-t+2) .* (heaviside(t-1) - heaviside(t-2));
x2t = x0t * sign(t-1);
x3t = x1t + x2t;

% Função para apresentar ao utilizador os gráficos do sinal escolhido
% A função solver recebe o valor de k, a função xkt e os pârametros iniciais e finais de linspace
while aux

    escolha = input('Indique qual o sinal [k = 0, 1, 2, 3] que deseja ver as resoluções das alíneas a, b, c e d: ');

    switch escolha
        % A função solver recebe como pârametros o valor de k e a função xkt
        case 0
            solver(0, x0t, -13, 5, 0,1,"^",2,-1,"v",0,0,".");

        case 1
            solver(1, x1t, -2, 5, 0,0,".",0,0,".",0,0,".");

        case 2
            solver(2, x2t, -8, 3, 0,-1,"v",1,2,"^",2,-1,"v");

        case 3
            solver(3, x3t,-3, 5, 0,-1,"v",1,2,"^",2,-1,"v");

        otherwise
            disp('Valor inválido!')
    end

    % Condição de saída
    sair = lower(input('Deseja sair [S/N]?', 's'));
    if(strcmp(sair, 's'))
        aux = false;
    end
    
end

%%

% Problema 2 - Parte 2 - Alínea c)
%{
    Observações:
        Variáveis:
        tg - vector que contém os vários pontos
        t - variável tempo
        k - indíce da função
        x - recebe a função pedida por cada um dos cases
%}

clc; close all; clear;

% Construção de funções
syms t;
x0t = heaviside(t) - heaviside(t-2);
x1t = t .* (heaviside(t) - heaviside(t-1)) + (-t+2) .* (heaviside(t-1) - heaviside(t-2));
x2t = x0t * sign(t-1);
x3t = x1t + x2t;

% Cálculo do produto interno
prod_00 = double(int(x0t * x0t,t,0,2));  % < x0(t), x0(t) >
prod_01 = double(int(x0t * x1t,t,0,2));  % < x0(t), x1(t) >
prod_02 = double(int(x0t * x2t,t,0,2));  % < x0(t), x2(t) >
prod_03 = double(int(x0t * x3t,t,0,2));  % < x0(t), x3(t) >

prod_11 = double(int(x1t * x1t,t,0,2));  % < x1(t), x1(t) >
prod_12 = double(int(x1t * x2t,t,0,2));  % < x1(t), x2(t) >
prod_13 = double(int(x1t * x3t,t,0,2));  % < x1(t), x3(t) >

prod_22 = double(int(x2t * x2t,t,0,2));  % < x2(t), x2(t) >
prod_23 = double(int(x2t * x3t,t,0,2));  % < x2(t), x3(t) >

prod_33 = double(int(x3t * x3t,t,0,2));  % < x3(t), x3(t) >

disp('  Energia')
T=table(prod_00, prod_11, prod_22, prod_33);
T.Properties.VariableNames = {'< x0(t), x0(t) >', '< x1(t), x1(t) >', '< x2(t), x2(t) >', '< x3(t), x3(t) >'};
disp(T)

disp('  Ortogonais')
T=table(prod_02, prod_12);
T.Properties.VariableNames = {'< x0(t), x2(t) >', '< x1(t), x2(t) >'};
disp(T)

disp('  Outras energias')
T=table(prod_01, prod_03, prod_13, prod_23);
T.Properties.VariableNames = {'< x0(t), x1(t) >', '< x0(t), x3(t) >', '< x1(t), x3(t) >', '< x2(t), x3(t) >'};
disp(T)


%%

% Problema 2 - Parte 2 - Alínea d)
%{
    Observações:
        Variáveis:
        tg - vector que contém os vários pontos
        t - variável tempo
        k - indíce da função
        x - recebe a função pedida por cada um dos cases
%}
% Situação: [RESOLVIDO]

clc; close all; clear;

% Parâmetros para linspace
inicial = -1;
step = 1000;
final = 3;

tg = linspace(inicial,final,step)+eps;

% Construção de funções
syms t;
x0t = heaviside(t) - heaviside(t-2);
x1t = t .* (heaviside(t) - heaviside(t-1)) + (-t+2) .* (heaviside(t-1) - heaviside(t-2));
x2t = x0t * sign(t-1);
x3t = x1t + x2t;

prod_00 = double(int(x0t * x0t,t,0,2));  % < x0(t), x0(t) >
prod_03 = double(int(x0t * x3t,t,0,2));  % < x0(t), x3(t) >
prod_22 = double(int(x2t * x2t,t,0,2));  % < x2(t), x2(t) >
prod_23 = double(int(x2t * x3t,t,0,2));  % < x2(t), x3(t) >

% Cálculo de alfa e beta
alfa = (prod_03 / prod_00);
beta = (prod_23 / prod_22);

% Cálculo da função erro
x3a = (alfa * x0t) + (beta * x2t);
et = x3t - x3a;

% sinal x3t, x0t, x2t, sinal de erro et e x3aprox

% Construção de gráficos
x3tg = subs(x3t,t,tg);
x0tg = subs(x0t,t,tg);
x2tg = subs(x2t,t,tg);
etg  = subs(et,t,tg);
x3ag = subs(x3a,t,tg);

disp('A base < x0t, x2t> não é ortogonal, pelo que os cálculos serão executados e os gráficos apresentados.')

% Representação gráfica de funções
figure
subplot(3,2,1), hold on, plot(tg,x3tg,'b'), grid on, title('Função x3t'), xlabel('t (s)'), ylabel('Amplitude'), hold off;
subplot(3,2,2), hold on, plot(tg,x0tg,'b'), grid on, title('Função x0t'), xlabel('t (s)'), ylabel('Amplitude'), hold off;
subplot(3,2,3), hold on, plot(tg,x2tg,'b'), grid on, title('Função x2t'), xlabel('t (s)'), ylabel('Amplitude'), hold off;
subplot(3,2,4), hold on, plot(tg,etg,'b'),  grid on, title('Função et'),  xlabel('t (s)'), ylabel('Amplitude'), hold off;
subplot(3,2,5), hold on, plot(tg,x3ag,'b'), grid on, title('Função x3a'), xlabel('t (s)'), ylabel('Amplitude'), hold off;

%%

% Função solver que recebe o valor de k, xkt e parâmetros iniciais e finais do linspace

function solver(k,x,inicial,final,s1,s2,sd1,s3,s4,sd2,s5,s6,sd3)

    % Parâmetros para linspace (para além dos que são recebidos pela função
    step = 1000;

    tg = linspace(inicial,final,step)+eps;

    syms t;

    % Construção de funções de resolução das alíneas a, b, c e d
    % Cálculo do gráfico de xk(t)
    xg = subs(x,t,tg);

    % Cálculo do Zk(t)
    a = - (k + 1) / 4; 
    b = ((-1)^k) * 4 * a;
    zkt = a * t + b;
    zktf = subs(x,t,zkt);
    zktfg = subs(zktf,t,tg);

    % Cálculo do Xkp(t)
    xkpt = ((x + subs(x,t,-t)) / 2);
    xkptg = subs(xkpt,t,tg);

    % Cálculo do Xki(t)
    xkit = ((x - subs(x,t,-t)) / 2);
    xkitg = subs(xkit,t,tg);

    % Cálculo da derivada de Uk(t)
    ukt = simplify(diff(x));
    uktg = subs(ukt,t,tg);

    % Cálculo da primitiva de Vk(t)
    vkt = int(x, t);
    vktg = subs(vkt,t,tg);

    % Construção de gráficos
    figure
    subplot(3,2,1), hold on, plot(tg,xg,'b'),    grid on, title(['Função x', num2str(k), 't']),  xlabel('t (s)'), ylabel('Amplitude'), hold off;
    subplot(3,2,2), hold on, plot(tg,zktfg,'b'), grid on, title(['Função z', num2str(k), 't']),  xlabel('t (s)'), ylabel('Amplitude'), hold off;
    subplot(3,2,3), hold on, plot(tg,xkptg,'b'), grid on, title(['Função xp', num2str(k), 't']), xlabel('t (s)'), ylabel('Amplitude'), hold off;
    subplot(3,2,4), hold on, plot(tg,xkitg,'b'), grid on, title(['Função xi', num2str(k), 't']), xlabel('t (s)'), ylabel('Amplitude'), hold off;
    subplot(3,2,5), hold on, plot(tg,uktg,'b'),  stem(s1,s2,sd1), stem(s3,s4,sd2), stem(s5,s6,sd3), grid on, title(['Função u', num2str(k), 't']),  xlabel('t (s)'), ylabel('Amplitude'), hold off;
    subplot(3,2,6), hold on, plot(tg,vktg,'b'),  grid on, title(['Função v', num2str(k), 't']),  xlabel('t (s)'), ylabel('Amplitude'), hold off;

end
