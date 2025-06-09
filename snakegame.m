function controlled_snake_game()
    clc;
    close all;

    % Game grid setup
    gridSize = 20;
    gridCount = 20;

    % Snake initial setup
    direction = [1 0];  % Starts moving right
    snake = [10 10; 9 10; 8 10];
    food = generateFood(snake, gridCount);
    score = 0;

    foodEaten = 0;        % Count how many foods eaten
    foodValue = 1;        % Initial score per food

    maxSpeed = 2.5;               % Max blocks per second
    minDelay = 1 / maxSpeed;      % Minimum delay
    maxDelay = 1.0;               % Initial delay
    delay = maxDelay;             % Current delay

    % Create figure
    fig = figure('Name', 'Snake Game ', ...
        'KeyPressFcn', @keyHandler, ...
        'NumberTitle', 'off', ...
        'Color', 'k', ...
        'MenuBar', 'none', ...
        'ToolBar', 'none', ...
        'Resize', 'off', ...
        'Position', [100 100 gridSize*gridCount gridSize*gridCount]);

    ax = axes('Parent', fig, ...
        'Position', [0 0 1 1], ...
        'XLim', [0 gridCount], ...
        'YLim', [0 gridCount], ...
        'XTick', [], 'YTick', [], ...
        'Color', 'k');
    axis square;

    drawGame();  % Initial draw

    % Main game loop
    while ishandle(fig)
        % Adjust speed gradually until 5 foods eaten
        if score < 5
            delay = max(minDelay, maxDelay - score * ((maxDelay - minDelay) / 5));
        end

        % Stop speed increase if snake fills two rows
        if size(snake, 1) >= 2 * gridCount
            delay = minDelay;
        end

        pause(delay);

        newHead = snake(1,:) + direction;

        % Collision detection
        if isOutOfBounds(newHead, gridCount) || ismember(newHead, snake, 'rows')
            msgbox(['Game Over! Score: ' num2str(score)], 'Game Over');
            break;
        end

        snake = [newHead; snake];

        if isequal(newHead, food)
            foodEaten = foodEaten + 1;
            score = score + foodValue;
            food = generateFood(snake, gridCount);
            beep;

            % Increase foodValue every 3 food items
            if mod(foodEaten, 3) == 0
                foodValue = foodValue * 2;
            end
        else
            snake(end,:) = [];
        end

        drawGame();
    end

    % --- Drawing Function ---
    function drawGame()
        cla;
        % Draw food
        rectangle('Position', [food - 1, 1, 1], 'FaceColor', 'r');
        % Draw snake head
        rectangle('Position', [snake(1,:) - 1, 1, 1], 'FaceColor', 'y');
        % Draw snake body
        for i = 2:size(snake, 1)
            rectangle('Position', [snake(i,:) - 1, 1, 1], 'FaceColor', 'g');
        end
        % Show score, speed, and food value
        title(['Score: ', num2str(score), ...
               ' | Speed: ', num2str(round(1/delay, 2)), ...
               ' blocks/sec | Food Value: ', num2str(foodValue)], ...
               'Color', 'w', 'FontSize', 12);
        drawnow;
    end

    % --- Key Handler ---
    function keyHandler(~, event)
        key = lower(event.Key);
        switch key
            case {'uparrow', 'w', '8'}
                if ~isequal(direction, [0 -1])
                    direction = [0 1];
                end
            case {'downarrow', 's', '2'}
                if ~isequal(direction, [0 1])
                    direction = [0 -1];
                end
            case {'leftarrow', 'a', '4'}
                if ~isequal(direction, [1 0])
                    direction = [-1 0];
                end
            case {'rightarrow', 'd', '6'}
                if ~isequal(direction, [-1 0])
                    direction = [1 0];
                end
        end
    end
end

% --- Generate Food Function ---
function food = generateFood(snake, gridCount)
    while true
        food = randi([1 gridCount], 1, 2);
        if ~ismember(food, snake, 'rows')
            break;
        end
    end
end

% --- Wall Collision Check ---
function result = isOutOfBounds(position, gridCount)
    result = position(1) < 1 || position(1) > gridCount || ...
             position(2) < 1 || position(2) > gridCount;
end
