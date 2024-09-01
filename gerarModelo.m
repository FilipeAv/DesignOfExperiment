function [outputArg1,outputArg2,outputArg3,outputArg4,outputArg5,outputArg6, outputArg7, outputArg8] = gerarModelo(X1, X2, Y, IC, lower_bounds, upper_bounds)
%   Gera modelo baseado em matrizes de inputs e outputs
%   Generalização do script do Corotinho, sem elementos de interface
%   gráfica

    % Construindo a matriz X (incluindo o termo constante)
    X = [ones(length(X1), 1), X1, X2, X1.^2, X2.^2, X1.*X2];

    % Passo 1: Calcular X^T * X
    XtX = X' * X;

    % Passo 2: Calcular X^T * Y
    XtY = X' * Y;

    % Passo 3: Resolver o sistema linear para encontrar os coeficientes b
    b = XtX \ XtY;

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
    if isempty(IC)
        initial_conditions = [mean(X1), mean(X2)];
    else
        initial_conditions = IC;
    end

    % Encontrando o ponto ótimo com restrições
    options = optimoptions('fmincon','Display','iter'); % Opcional: para ver o progresso
    [optimal_point, optimal_Y] = fmincon(model_func, initial_conditions, [], [], [], [], lower_bounds, upper_bounds, [], options);

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
   
    outputArg1 = optimal_point;
    outputArg2 = optimal_Y;
    outputArg3 = b;
    outputArg4 = stderr;
    outputArg5 = p_values;
    outputArg6 = t_values;
    outpputArg7 = SSR;
    outputArg8 = SST;
    
end

