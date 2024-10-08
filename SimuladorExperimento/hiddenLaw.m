function [outputArg1, outputArg2, outputArg3] = hiddenLaw(X1, X2, stderr)
%Simula experimento
%   Simula medições em laboratório para condições descritas por X1 e X2 e
%   erro padrão stderr
%   X1 e X2: vetores com valores das variáveis independentes nas condições
%   dos experimentos

% Função anônima oculta
y = @(X) 2 + -0.5*(X(:,1)-5) - 0.8*(X(:,2) - 5) + 0.1*(X(:,1) - 5).^2 + 0.1*(X(:,2) - 5).^2 - 0.05*(X(:,1) - 5).*(X(:,2) - 5);
% Construção da matriz de entradas:
X = [X1(:) X2(:)];

% Valores verdadeiros (médias) das respostas
Ym = y(X);

% Respostas medidas com base em ma distribução normal com desvio padrão
% "stderr"
Y = normrnd(Ym, stderr);
outputArg1 = Y;

% Verdadeiro mínimo da função
[pto_min, min] = fmincon(y, [11 22], [], [], [], [], [2 4], [20 40], [], []);
outputArg2 = pto_min;
outputArg3 = min;



end