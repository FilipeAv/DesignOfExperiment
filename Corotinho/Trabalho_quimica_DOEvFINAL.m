% Dados experimentais
AI = [4.5398, 26.4602, 4.5398, 26.4602, 0, 31, 15.5, 15.5, 15.5, 15.5, 15.5]'; % Álcool Isopropílico (porcentagem mássica)
CAT = [5.318, 5.318, 11.682, 11.682, 8.5, 8.5, 4, 13, 8.5, 8.5, 8.5]'; % Catalisador (porcentagem mássica)
IDT = [54, 41, 56, 30, 53, 27, 55, 49, 34, 30, 37]'; % IDT (milissegundos)

% Construindo a matriz X (incluindo o termo constante)
X = [ones(length(AI), 1), AI, CAT, AI.^2, CAT.^2, AI.*CAT];

% Matriz Y com os valores de IDT
Y = IDT;

% Passo 1: Calcular X^T * X
XtX = X' * X;

% Passo 2: Calcular X^T * Y
XtY = X' * Y;

% Passo 3: Resolver o sistema linear para encontrar os coeficientes b
b = XtX \ XtY;

% Exibindo os coeficientes
disp('Coeficientes da função:');
disp(b);

% Coeficientes da função (usando os valores obtidos em b)
b0 = b(1);
b1 = b(2);
b2 = b(3);
b3 = b(4);
b4 = b(5);
b5 = b(6);

% Função anônima para o modelo
model_func = @(c) b0 + b1*c(1) + b2*c(2) + b3*c(1).^2 + b4*c(2).^2 + b5*c(1).*c(2);

% Condições iniciais para a busca (pode ser a média dos valores)
initial_conditions = [mean(AI), mean(CAT)];

% Definindo os limites para as variáveis
lower_bounds = [0, 4];   % Limite inferior: [Álcool Isopropílico, Catalisador]
upper_bounds = [31, 13]; % Limite superior: [Álcool Isopropílico, Catalisador]

% Encontrando o ponto ótimo com restrições
options = optimoptions('fmincon','Display','iter'); % Opcional: para ver o progresso
[optimal_point, optimal_IDT] = fmincon(model_func, initial_conditions, [], [], [], [], lower_bounds, upper_bounds, [], options);

% Exibindo o ponto ótimo
disp('Ponto ótimo (Porcentagem de AI, Porcentagem de CAT):');
disp(optimal_point);

% Calculando o IDT mínimo no ponto ótimo
disp('IDT mínimo:');
disp(optimal_IDT);

% Criar o gráfico 3D
x1 = linspace(min(AI), max(AI), 100);  % Álcool Isopropílico
x2 = linspace(min(CAT), max(CAT), 100);  % Catalisador

% Criar uma grade de valores de x1 e x2
[X1, X2] = meshgrid(x1, x2);

% Calcular y (IDT) usando a equação de regressão
Y_pred = b0 + b1*X1 + b2*X2 + b3*X1.^2 + b4*X2.^2 + b5*X1.*X2;

surf(X1, X2, Y_pred);
hold on;

% Plotar os pontos experimentais no gráfico
scatter3(AI, CAT, IDT, 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'r');

% Marcar o ponto ótimo encontrado
optimal_AI = optimal_point(1);
optimal_CAT = optimal_point(2);
optimal_IDT = b0 + b1*optimal_AI + b2*optimal_CAT + b3*optimal_AI^2 + b4*optimal_CAT^2 + b5*optimal_AI*optimal_CAT;
plot3(optimal_AI, optimal_CAT, optimal_IDT, 'gp', 'MarkerSize', 10, 'MarkerFaceColor', 'g');

% Exibir rótulo do ponto ótimo
text(optimal_AI, optimal_CAT, optimal_IDT, sprintf('  Ótimo (AI: %.2f, CAT: %.2f)', optimal_AI, optimal_CAT), 'Color', 'green', 'FontSize', 10);

hold off;

% Adicionar rótulos aos eixos
xlabel('Porcentagem de Álcool Isopropílico');
ylabel('Porcentagem de Catalisador');
zlabel('IDT (Tempo de Ignição)');
title('Superfície de Resposta para o Tempo de Ignição');

% Ajustar a visualização
grid on;
view(45, 30);  % Ajusta o ângulo de visualização

%% Análise da significância dos coeficientes:

% Número de observações e variáveis
n = length(Y);
p = size(X, 2);

% Estimar os valores preditos
Y_pred = X * b;

% Calcular os resíduos
residuals = Y - Y_pred;

% Estimar o erro padrão dos resíduos
sigma2 = sum(residuals.^2) / (n - p);

% Calcular a matriz de variâncias e covariâncias dos coeficientes
cov_matrix = sigma2 * inv(XtX);

% Erro padrão dos coeficientes
stderr = sqrt(diag(cov_matrix));

% Calcular os valores t
t_values = b ./ stderr;

% Calcular os valores p para os testes t (H0: coeficiente = 0)
p_values = 2 * (1 - tcdf(abs(t_values), n - p));

% Exibir os valores t e p
table(b, stderr, t_values, p_values, 'VariableNames', {'Coeficiente', 'ErroPadrao', 'TValue', 'PValue'})

%% Análise Anova

% Soma dos quadrados total (SST)
SST = sum((Y - mean(Y)).^2);

% Soma dos quadrados explicada pelo modelo (SSR)
SSR = sum((Y_pred - mean(Y)).^2);

% Soma dos quadrados dos resíduos (SSE)
SSE = sum((Y - Y_pred).^2);

% Graus de liberdade
df_total = n - 1;
df_model = p - 1;
df_residual = n - p;

% Mean Square (MS)
MS_model = SSR / df_model;
MS_residual = SSE / df_residual;

% Estatística F
F_value = MS_model / MS_residual;

% Valor p para o teste F (H0: Todos os coeficientes = 0)
p_F = 1 - fcdf(F_value, df_model, df_residual);

% Exibir a tabela ANOVA
anova_table = table([df_model; df_residual; df_total], [SSR; SSE; SST], [MS_model; MS_residual; NaN], [F_value; NaN; NaN], [p_F; NaN; NaN], ...
    'VariableNames', {'DF', 'SumSquares', 'MeanSquares', 'FValue', 'PValue'}, ...
    'RowNames', {'Modelo', 'Resíduos', 'Total'});
disp(anova_table);

% Soma dos quadrados total (SST)
SST = sum((Y - mean(Y)).^2);

% Soma dos quadrados explicada pelo modelo (SSR)
SSR = sum((Y_pred - mean(Y)).^2);

% Coeficiente de determinação R^2
R_squared = SSR / SST;

% Exibir o valor de R^2
disp('Coeficiente de Determinação (R^2):');
disp(R_squared);

%% Explicações do algoritmo

% Output 1: Tabela com os coeficientes da equação
% Ou seja, y = 110.6534 + -0.8408*X1 + -14.3185*X2 + 0.0248*X1.^2 + 0.8868*X2.^2 + -0.0932*X1.*X2;

% Output 2: Tabela com o algoritmo de otmização
% Iter: Número da iteração atual do algoritmo de otimização.
% F-count: Número total de avaliações da função objetivo até a iteração atual.
% f(x): Valor da função objetivo na iteração atual.
% Feasibility: Medida de quão bem a solução atual satisfaz as restrições (0 indica solução viável).
% First-order optimality: Magnitude do gradiente da função objetivo, indicando proximidade do ótimo.
% Norm of step: Tamanho do passo dado pelo algoritmo na iteração atual.

% Output 3: Ponto ótimo

% Output 4: Análise de regressão linear
% Coeficiente: Valor que quantifica o efeito de cada variável independente no IDT.
% ErroPadrão: Medida da precisão da estimativa do coeficiente.
% TValue: Estatística de teste usada para avaliar a significância de cada coeficiente.
% PValue: Probabilidade de que o coeficiente seja significativamente diferente de zero.

% Output 5: Análise de Variância (ANOVA)
% DF: Graus de liberdade para o modelo e os resíduos.
% SumSquares: Soma dos quadrados que mede a variação explicada pelo modelo e pelos resíduos.
% MeanSquares: Soma dos quadrados dividida pelos graus de liberdade, usada para calcular o valor F.
% FValue: Razão entre o quadrado médio do modelo e o quadrado médio dos resíduos, indicando a significância do modelo.
% PValue: Probabilidade de que a variabilidade explicada pelo modelo seja devido ao acaso (baixa probabilidade indica um modelo significativo).

% Output 6: Coeficiente de Determinação (R^2):
% Valor de R^2 representa a porcentagem da variabilidade que é explicada pelo modelo