function pontosFCC = planejarFCC(v)
    % v1: vértice inicial do paralelepípedo (menor valor nas 3 coordenadas)
    % v2: vértice oposto do paralelepípedo (maior valor nas 3 coordenadas)
    % pontosFCC: matriz contendo os pontos do planejamento cúbico de face centrada

    v1 = [min(v(:,1)), min(v(:,2)), min(v(:,3))];
    v2 = [max(v(:,1)), max(v(:,2)), max(v(:,3))];

    % 1. Definir os 8 vértices do paralelepípedo
    vertices = [
        v1(1), v1(2), v1(3);
        v2(1), v1(2), v1(3);
        v1(1), v2(2), v1(3);
        v2(1), v2(2), v1(3);
        v1(1), v1(2), v2(3);
        v2(1), v1(2), v2(3);
        v1(1), v2(2), v2(3);
        v2(1), v2(2), v2(3)
    ];

    % 2. Calcular os centros das faces (6 faces)
    centrosFaces = [
        mean(vertices([1, 2, 5, 6], :), 1); % Face inferior (X1 varia)
        mean(vertices([3, 4, 7, 8], :), 1); % Face superior (X1 varia)
        mean(vertices([1, 3, 5, 7], :), 1); % Face esquerda (X2 varia)
        mean(vertices([2, 4, 6, 8], :), 1); % Face direita (X2 varia)
        mean(vertices([1, 2, 3, 4], :), 1); % Face frontal (X3 varia)
        mean(vertices([5, 6, 7, 8], :), 1)  % Face traseira (X3 varia)
    ];

    center = mean(v,1);

    % 3. Combinar vértices e centros das faces
    pontosFCC = [v; centrosFaces; center];
    
    for i=1:size(pontosFCC, 1)
        while ~inpolyhedron(convhull(v), v, pontosFCC(i,:))
            pontosFCC(i,:) = (9*pontosFCC(i,:) + mean(v,1))./10;
        end
    end



    % 4. Visualizar o planejamento
    figure;
    scatter3(v(:, 1), v(:, 2), v(:, 3), 100, 'r', 'filled'); % Vértices
    hold on;
    scatter3(centrosFaces(:, 1), centrosFaces(:, 2), centrosFaces(:, 3), 100, 'b', 'filled'); % Centros das faces
    scatter3(center(1), center(2), center(3), 100, 'r', 'filled');
    title('Planejamento Cúbico de Face Centrada');
    xlabel('X1');
    ylabel('X2');
    zlabel('X3');
    legend('Vértices', 'Centros das Faces');
    grid on;
    axis equal;
end
