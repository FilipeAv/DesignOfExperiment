clc, clearvars, close all

vertices = [8, 0;
            10, 9;
            -1, 10;
            2, 2];

f = @(x) x(1).^2 + x(2).^2;

k = convhull(vertices(:,1), vertices(:,2));
vertices = vertices(k,:);

min_val = inf; max_val = -inf;

for i = 1:size(vertices,1)
    val = f(vertices(i,:));
    if val < min_val
        min_val = val;
        min_point = vertices(i,:);
    end
    if val > max_val
        max_val = val;
        max_point = vertices(i,:);
    end
end

% Penalização para pontos fora do polígono
penalized_f_min = @(x) penalized_function_min(x, f, vertices);
penalized_f_max = @(x) penalized_function_max(x, f, vertices);

% Otimização no interior do polígono
lb = [min(vertices(:, 1)), min(vertices(:, 2))]; % Limites inferiores
ub = [max(vertices(:, 1)), max(vertices(:, 2))]; % Limites superiores

options = optimoptions('fmincon', 'Display', 'none', 'Algorithm', 'sqp');

% Encontrar o mínimo
[x_min, fval_min] = fmincon(penalized_f_min, mean(vertices), [], [], [], [], lb, ub, [], options);

% Encontrar o máximo
[x_max, fval_max] = fmincon(@(x) -penalized_f_max(x), mean(vertices), [], [], [], [], lb, ub, [], options);
fval_max = -fval_max;

% Comparar com valores nos vértices
if fval_min < min_val
    min_val = fval_min;
    min_point = x_min;
end
if fval_max > max_val
    max_val = fval_max;
    max_point = x_max;
end

% Exibir resultados
fprintf('Mínimo: %.4f em (%.4f, %.4f)\n', min_val, min_point(1), min_point(2));
fprintf('Máximo: %.4f em (%.4f, %.4f)\n', max_val, max_point(1), max_point(2));
