%{
    Trabalho Prático 2 - Sinais e Sistemas
    
    Turma: LT21N
    Grupo: 0.1
        Nuno Brito - A46948
        Tiago Moreno - A28421
        Rafael Romão - A48863

    Data de entrega: 2022-01-23
%}

clc; close all; clear;

%%
% Problema 1
% Alínea 1.2
% Situação: [Resolvido]
%{
    Observações:
        A -> Amplitude
        
        Acrescentar e-3 se for para apresentar em milisegundos (TODO: talvez corrigir isto no futuro):
        tau -> tau
        fp -> frequência fundamental
        inicial -> valor inicial da função linspace
        final -> valor final da função linspace
%}
clc, clear, close all

A = 10;
tau = 10;
fp = 1;

syms t

% Expressões do problema 1
% vi(t)
v1t = (t+A) * (heaviside(t+10) - heaviside(t)) + (-t+A) * (heaviside(t) - heaviside(t-10));
v2t = subs(v1t, t, 2*t);
v3t = subs(v1t, t, (t-(tau/2)));
v4t = v1t * sin(2*pi*fp*t);
% wi(t)
w1t = A*(heaviside(t+(tau/2))-heaviside(t-(tau/2)));
w2t = subs(w1t, t, t+tau);
w3t = w1t * cos(2*pi*fp*t);
w4t = (t/tau) * w1t;

% Variável auxiliar para sair do while
aux = true;

while aux
    escolha_func = input('Qual a função que deseja ver representada? (v / w): ', 's');
    escolha_i = input('Qual o número i que deseja ver respresentada? (1, 2, 3, 4): ');
    
    switch escolha_i
        case 1
            if escolha_func == 'v'
                helper(1, v1t, -10, 10, escolha_func);
            else
                helper(1, w1t, -5, 5, escolha_func);
            end
            
        case 2
            if escolha_func == 'v'
                helper(2, v2t, -5, 5, escolha_func);
            else
                helper(2, w2t, -15, -5, escolha_func);
            end
            
        case 3
            if escolha_func == 'v'
                helper(3, v3t, -5, 15, escolha_func);
            else
                helper(3, w3t, -5, 5, escolha_func);
            end
            
        case 4
            if escolha_func == 'v'
                helper(4, v4t, -10, 10, escolha_func);
            else
                helper(4, w4t, -5, 5, escolha_func);
            end
            
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
% Problema 2
% Alínea 2.2
% Situação: [Resolvido]
%{

%}

clc, clear, close all

% Informação inicial
A = 10;
tau = 10;
fp = 1;
T0 = 40;

% Informação obtida analiticamente
kmax = 8;
sumck = 0;

% Parâmetros para linspace
inicial = -10;
final = 10;
step = 1000;

%tg = linspace(inicial,final,step)+eps;
fg = linspace(inicial*2,final*2,step)+eps;
kg=(-kmax:kmax)+eps;

syms t f k

% Função w1(t) para k=0
w1t = A*(heaviside(t+(tau/2))-heaviside(t-(tau/2)));

% Expressão fourier
w1tf = simplify(fourier(w1t, t, 2*pi*f));

% Potência de w1t
w1tpower = 1/T0 * double(int(w1t^2,t,-T0/2,T0/2));

% Expressão Ck
ck = ((5/2) * sinc(k/4))^2;

% Substituições para desenhar gráficos
w1tfg = double(subs(w1tf,f,fg));
ckg = subs(ck, k, kg);

% Calcular a soma dos Ck
for k = -kmax:kmax
    cksumthis = double((((5/2) * sinc(k/4))^2));
    sumck = cksumthis + sumck;
end

% Desenhar gráfico dos Ck e do argumento
subplot(1,2,1); stem(kg,abs(ckg),'filled'); grid on; title('abs(Ckg)');
subplot(1,2,2); stem(kg,angle(ckg),'filled'); grid on; axis([-kmax kmax -pi pi]), title('arg(Ckg)');

% Relação Potência w1tpower e o somatório dos Ck
rel = (sumck / w1tpower) * 100;

% Mostra os valores das alíneas c) e d)
text = sprintf('Potência do sinal w1t: %dW', w1tpower);
disp(text)
text2 = sprintf('Potência do sinal w1tf (somatório dos Ck): %0.2fW', sumck);
disp(text2)
text3 = sprintf('Relação entre a potência de w1t e o somatório de Ck: %0.2f%%', rel);
disp(text3)

%%
% Problema 3
% Alínea 3.2.1
% Situação: [Resolvido]
%{

%}

clc, clear, close all

syms f

H1f = heaviside(f+10)-heaviside(f-10);
H2f = 1 - (heaviside(f+10^2)-heaviside(f-10^2));
H3f = H1f + H2f;
H4f = 1 - H3f;

% Variável auxiliar para sair do while
aux = true;

while aux
    escolha_i = input('Qual o SLIT que deseja ver representado? (1, 2, 3, 4): ');

    switch escolha_i
        case 1
            slit_helper(escolha_i, H1f, -20, 20);
        case 2
            slit_helper(escolha_i, H2f, -200, 200);
        case 3
            slit_helper(escolha_i, H3f, -200, 200);
        case 4
            slit_helper(escolha_i, H4f, -200, 200);
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
% Problema 3
% Alínea 3.2.2
% Situação: [Resolvido]
%{

%}

clear, clc, close all

syms t f

%Função função SLIT A - Filtro passa baixo 1ª ordem
%Amplitude (ha(t))
A1 = 2*pi*10;
a1 = A1;

%Função ha(t)
hat = A1*exp(-a1*t)*heaviside(t);

fg = linspace(-400, 400, 1000)+eps;
Ha = simplify( fourier(hat, t, 2*pi*f));
Haf = double(subs(Ha, f, fg));


% Função função SLIT B
hbt = hat * (10*t);

% Valor do ganho dado
K = 1 / ( 2 * pi * 10);

hbtK = hbt * K;

% Derivada
tg = linspace(-200, 200, 1000)+eps;
hbtKder = simplify(diff(hbtK));
hbtKdertg = subs(hbtKder,t,tg);


Hb = simplify(fourier(hbtKder,t,2*pi*f));
Hbf = double(subs(Hb,f,fg));

% Desenhar gráfico Slit Hb
subplot(2,2,1), hold on, plot(tg,abs(Haf),'b'), grid on, title('Slit Ha Espetro'), xlabel('freq (Hz)'), ylabel('Amplitude'), hold off;
subplot(2,2,2), hold on, plot(tg,angle(Haf),'b'), grid on, title('Slit Ha Fase'), xlabel('freq (Hz)'), ylabel('Amplitude'), hold off;


% Desenhar gráfico Slit Hb
subplot(2,2,3), hold on, plot(tg,abs(Hbf),'b'), grid on, title('Slit Hb Espetro'), xlabel('freq (Hz)'), ylabel('Amplitude'), hold off;
subplot(2,2,4), hold on, plot(tg,angle(Hbf),'b'), grid on, title('Slit Hb Fase'), xlabel('freq (Hz)'), ylabel('Amplitude'), hold off;


%%
% Função solver que recebe o valor de i, funções v e w,parâmetros iniciais
% e finais do linspace e a variável escolha_func

function helper(i,x,inicial,final,escolha_func)

    % Parâmetros para linspace
    step = 1000;

    tg = linspace(inicial,final,step)+eps;
    fg = linspace(inicial*2,final*2,step)+eps;

    syms t f;
    
    % Expressão fourier
    zxif = simplify(fourier(x, t, 2*pi*f));
    
    % Expressão para gráficos
    % v/w ig(t)
    xitg = subs(x, t, tg);
    zxifg = double(subs(zxif,f,fg));
    
    % Construção de gráficos
    figure
    
    % Gráfico da função
        subplot(2,2,1), hold on, plot(tg,xitg,'b'),    grid on, 
        if escolha_func == 'v'
            title(['Função v_', num2str(i), 't']),
        else
            title(['Função w_', num2str(i), 't']),
        end
        xlabel('t (ms)'), ylabel('Amplitude'), hold off;
    
    % Gráfico da função fourier
        subplot(2,2,2), hold on, plot(fg,abs(zxifg),'b'), grid on,
        if escolha_func == 'v'
            title(['Transformada Fourier v_', num2str(i), 't']),
        else
            title(['Transformada Fourier w_', num2str(i), 't']),
        end
        xlabel('f (Hz)'), ylabel('Amplitude'), hold off;
    
    % Gráfico da fase da função fourier
        subplot(2,2,3), hold on, plot(fg,angle(zxifg),'b'), grid on,
        if escolha_func == 'v'
            title(['Fase Transformada Fourier v_', num2str(i), 't']),
        else
            title(['Fase Transformada Fourier w_', num2str(i), 't']),
        end
        xlabel('K Harmónica'), ylabel('Amplitude'), hold off;
end


%%
% Função solver para os SLITs.
% Recebe a função do slit e respetivos parametros de entrada
% O SLIT a executar é escolhido pelo utilizador

function slit_helper(i,x,inicial,final)

    % Parâmetros para linspace
    step = 1000;

    fg = linspace(inicial,final,step)+eps;

    syms f;
      
    % Expressão para gráficos
    Hfg = double ( subs(x, f, fg));
    
    % Construção de gráficos
    figure
    
    % Gráfico da função resposta em requência
    % Carateristica de amplitude
        subplot(2,1,1), hold on, plot(fg,abs(Hfg),'b'), grid on, ...
        title(['H_',num2str(i),'(f)']), xlabel('f Hz)'), ...
        ylabel('Amplitude'), hold off;
    % Carateristica de fase
        subplot(2,1,2), hold on, plot(fg,angle(Hfg),'b'), grid on, ...
        title(['arg(H_',num2str(i),'(f))']), xlabel('f (Hz)'), ...
        ylabel('Amplitude'), hold off;    
end


