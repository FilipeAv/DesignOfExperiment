function criarInterfaceGrafica()
    % Criar a figura principal da interface
    fig = uifigure('Name', 'Interface para Gráfico de IDT', 'Position', [100 100 800 450]);
    
    % Criar campos de entrada para AI
    uilabel(fig, 'Position', [20 380 100 22], 'Text', 'Valores de AI:');
    aiField = uieditfield(fig, 'text', 'Position', [130 380 200 22]);

    % Criar campos de entrada para CAT
    uilabel(fig, 'Position', [20 340 100 22], 'Text', 'Valores de CAT:');
    catField = uieditfield(fig, 'text', 'Position', [130 340 200 22]);

    % Criar campos de entrada para IDT
    uilabel(fig, 'Position', [20 300 100 22], 'Text', 'Valores de IDT:');
    idtField = uieditfield(fig, 'text', 'Position', [130 300 200 22]);

    % Criar botão para gerar o gráfico
    btn = uibutton(fig, 'push', 'Text', 'Gerar Gráfico', 'Position', [130 250 200 22], ...
        'ButtonPushedFcn', @(btn,event) gerarGrafico(aiField, catField, idtField));
    
    % Criar eixo para mostrar o gráfico
    ax = uiaxes(fig, 'Position', [350 50 400 300]);
    title(ax, 'Gráfico de IDT');
    xlabel(ax, 'AI');
    ylabel(ax, 'CAT');
    zlabel(ax, 'IDT');
    view(ax, [45 30]);

    % Criar tabela para exibir os resultados da ANOVA
    anovaTable = uitable(fig, 'Position', [20 50 300 150], 'ColumnName', {'DF', 'SumSquares', 'MeanSquares', 'FValue', 'PValue'});

    % Criar rótulo para exibir o valor de R^2
    r2Label = uilabel(fig, 'Position', [20 20 300 22], 'Text', 'R^2:');
    
    % Função callback para gerar o gráfico e calcular ANOVA
    function gerarGrafico(aiField, catField, idtField)
        % Obter os valores dos campos de entrada
        AI = str2num(aiField.Value); %#ok<ST2NM>
        CAT = str2num(catField.Value); %#ok<ST2NM>
        IDT = str2num(idtField.Value); %#ok<ST2NM>
        
        % Verificar se os dados foram inseridos corretamente
        if isempty(AI) || isempty(CAT) || isempty(IDT)
            uialert(fig, 'Por favor, insira valores válidos para AI, CAT e IDT.', 'Erro');
            return;
        end
        
        if length(AI) ~= length(CAT) || length(CAT) ~= length(IDT)
            uialert(fig, 'Os vetores AI, CAT e IDT devem ter o mesmo número de elementos.', 'Erro');
            return;
        end
        
        % Garantir que os vetores são colunas
        AI = AI(:);
        CAT = CAT(:);
        IDT = IDT(:);
        
        % Construir a matriz X
        X = [ones(length(AI), 1), AI, CAT, AI.^2, CAT.^2, AI.*CAT];
        
        % Resolver o sistema linear para encontrar os coeficientes b
        Y = IDT;
        XtX = X' * X;
        XtY = X' * Y;
        b = XtX \ XtY;
        
        % Criar o gráfico de IDT
        x1 = linspace(min(AI), max(AI), 100);
        x2 = linspace(min(CAT), max(CAT), 100);
        [X1, X2] = meshgrid(x1, x2);
        Y_pred = b(1) + b(2)*X1 + b(3)*X2 + b(4)*X1.^2 + b(5)*X2.^2 + b(6)*X1.*X2;
        
        % Exibir o gráfico
        surf(ax, X1, X2, Y_pred);
        hold(ax, 'on');
        scatter3(ax, AI, CAT, IDT, 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'r');
        
        % Função anônima para o modelo (usada na otimização)
        model_func = @(c) b(1) + b(2)*c(1) + b(3)*c(2) + b(4)*c(1).^2 + b(5)*c(2).^2 + b(6)*c(1).*c(2);
        
        % Definindo os limites para as variáveis
        lower_bounds = [min(AI), min(CAT)];   % Limite inferior: [Álcool Isopropílico, Catalisador]
        upper_bounds = [max(AI), max(CAT)]; % Limite superior: [Álcool Isopropílico, Catalisador]
        
        % Condições iniciais para a busca (pode ser a média dos valores)
        initial_conditions = [mean(AI), mean(CAT)];
        
        % Encontrando o ponto ótimo com restrições
        options = optimoptions('fmincon','Display','off'); % Opcional: para ver o progresso
        [optimal_point, optimal_IDT] = fmincon(model_func, initial_conditions, [], [], [], [], lower_bounds, upper_bounds, [], options);
        
        % Marcar o ponto ótimo no gráfico
        plot3(ax, optimal_point(1), optimal_point(2), optimal_IDT, 'gp', 'MarkerSize', 10, 'MarkerFaceColor', 'g');
        
        % Exibir rótulo do ponto ótimo
        text(ax, optimal_point(1), optimal_point(2), optimal_IDT, sprintf('  Ótimo (AI: %.2f, CAT: %.2f)', optimal_point(1), optimal_point(2)), 'Color', 'green', 'FontSize', 10);
        
        % Calcular ANOVA
        n = length(Y);
        p = size(X, 2);
        residuals = Y - X*b;
        SSE = sum(residuals.^2);
        SST = sum((Y - mean(Y)).^2);
        SSR = SST - SSE;
        df_model = p - 1;
        df_residual = n - p;
        MS_model = SSR / df_model;
        MS_residual = SSE / df_residual;
        F_value = MS_model / MS_residual;
        p_F = 1 - fcdf(F_value, df_model, df_residual);
        
        % Calcular o coeficiente de determinação R^2
        R_squared = SSR / SST;
        
        % Atualizar a tabela ANOVA
        anova_data = {df_model, SSR, MS_model, F_value, p_F;
                      df_residual, SSE, MS_residual, NaN, NaN;
                      n - 1, SST, NaN, NaN, NaN};
        anovaTable.Data = anova_data;
        anovaTable.RowName = {'Modelo', 'Resíduos', 'Total'};
        
        % Exibir o valor de R^2
        r2Label.Text = sprintf('R^2: %.4f', R_squared);
        
        hold(ax, 'off');
    end
end
