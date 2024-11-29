% Função Penalizada
function val = penalized_function_min(x, f, vertices)
    % Verifica se o ponto está dentro do polígono
    if inpolygon(x(1), x(2), vertices(:, 1), vertices(:, 2))
        val = f(x); % Avalia a função
    else
        val = 1e9; % Penaliza fortemente pontos fora
    end
end