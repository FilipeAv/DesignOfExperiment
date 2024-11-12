function [outputArg1, outputArg2, outputArg3] = hiddenLaw(X1, X2, X3, stderr)
%Simula experimento
%   Simula medições em laboratório para condições descritas por X1 e X2 e
%   erro padrão stderr
%   X1 e X2: vetores com valores das variáveis independentes nas condições
%   dos experimentos

% Função anônima oculta
y = @(c) 30 + 4*c(1) - c(2) - c(1).^2 + 9*c(1).*c(2).c(3);
% Construção da matriz de entradas:
X = [X1(:) X2(:) X3(:)];

% Valores verdadeiros (médias) das respostas
Ym = y(X);

% Respostas medidas com base em ma distribução normal com desvio padrão
% "stderr"
Y = normrnd(Ym, stderr);
outputArg1 = Y;

% Verdadeiro mínimo da função
[pto_min, min] = fmincon(y, [11 22 25], [], [], [], [], [2 4 0], [20 40 50], [], []);
outputArg2 = pto_min;
outputArg3 = min;



end