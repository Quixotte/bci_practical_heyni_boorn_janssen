function [S] = brainracer(varargin)
%MATLABTETRIS A MATLAB version of the classic game Tetris.
% A matlab game where a car is racing on a road. Subscribes to the events
% on the blackboard. Only listens to the events 'left' and 'right'
%
% Pushing the following keys has the listed effect:
%
% Key     Effect
% ------------------
% n       Starts a new game in the middle of any game.
% p       Pauses/Unpauses game play.
% s       Starts the new game (alternative to pushing the start button).
%
% Other tips:
%


f_clr = [.741 .717 .42];
S.fig = figure('units','pixels',...
               'name','Brainracer',...
               'menubar','none',...
               'numbertitle','off',...
               'position',[100 100 650 720],...
               'keypressfcn',@fig_kpfcn,...%
               'color',f_clr,...
               'busyaction','cancel',...
               'renderer','opengl');
center = 325;
car_width = 300;

S.axs = axes('units','pix',...
             'position',[325-(car_width/2) 0 car_width 100],...
             'ycolor',f_clr,...
             'xcolor',f_clr,...
             'color',f_clr,...
             'xtick',[],'ytick',[],...
             'xlim',[-.1 7.1],...
             'ylim',[-.1 7.1],...
             'visible','off');           

r_col = [(65/255) (79/255) (205/255)];
S.rct = rectangle('pos',[0 0 7 7],...
                  'curvature',.3,...
                  'facecolor',r_col,...
                  'edgecolor','r',...
                  'linewidth',2); % This is used below the preview.


left_road_center_start = center - 25;
left_road_center_stop = center - 225;
start_y = 400;
stop_y = 0;
start_size = 25;
stop_size = 200;

[car_image, map, alpha_green] = imread('images/car_after_crop.png');
[our_car_image, map, alpha_yellow] = imread('images/cabrio.jpg');  
street_image=imread('images/street.png');
incoming_car_pos = [1, 0]; %false = left, true = right
our_car_pos = 1;
incoming_index = 0;
running = true;
max_i = 25;
while(running)
    tic
    incoming_index = incoming_index + 1;
    if incoming_index > size(incoming_car_pos)
        incoming_index = 1;
    end
    for i = 0:max_i
        clf('reset');
        set(S.fig, 'keypressfcn',@fig_kpfcn);
        % This creates the 'background' axes
        ha = axes('units','normalized', ...
                'position',[0 0 1 1]);
        % Move the background axes to the bottom
        uistack(ha,'bottom');
        % Load in a background image and display it using the correct colors
        % The image used below, is in the Image Processing Toolbox.  If you do not have %access to this toolbox, you can use another image file instead.

        hi = imagesc(street_image);
        colormap gray
        % Turn the handlevisibility off so that we don't inadvertently plot into the axes again
        % Also, make the axes invisible
        set(ha,'handlevisibility','off', ...
                    'visible','off');
        
        current_x = left_road_center_start - (left_road_center_start - left_road_center_stop)/max_i*i;
        current_size = 25 + (i/max_i)*(stop_size-start_size);
        if incoming_car_pos(incoming_index) == 1
            current_x = mirror(current_x, current_size);
        end
        current_y = start_y/max_i*(max_i-i);
        S.car_pos = axes('units','pix',...
                 'position',[current_x current_y current_size current_size],...
                 'ycolor',[0 1 1],...
                 'xcolor',[1 1 1],...
                 'color',[1 1 1],...
                 'xtick',[],'ytick',[],...
                 'xlim',[-.1 7.1],...
                 'ylim',[-.1 7.1],...
                 'visible','off');

        h = imshow(car_image);
        set(h, 'AlphaData', alpha_green);
        
        current_size = stop_size;
        current_x = left_road_center_stop;
        if our_car_pos == 1
            current_x = mirror(current_x, current_size);
        end
        
        current_y = stop_y;
        
        S.car_pos = axes('units','pix',...
                 'position',[current_x current_y current_size current_size],...
                 'ycolor',[0 1 1],...
                 'xcolor',[1 1 1],...
                 'color',[1 1 1],...
                 'xtick',[],'ytick',[],...
                 'xlim',[-.1 7.1],...
                 'ylim',[-.1 7.1],...
                 'visible','off');

        h = imshow(our_car_image);
        set(h, 'AlphaData', alpha_yellow);
        drawnow()
    end
    toc
end
close all

function [new_x] = mirror(x, current_size)
    new_x = center - ((x + current_size)-center);
end

function [] = fig_kpfcn(varargin)
% Figure (and pushbutton) keypressfcn
    switch varargin{2}.Key
        case 'rightarrow'
            fprintf('wopwop, rightarrow');
            our_car_pos = 1;
        case 'leftarrow'
            fprintf('wopwop, leftarrow');
            our_car_pos = 0;
        case 'q'
            fprintf('user wants to stop');
            running = false;
        otherwise
    end
    set(S.fig, 'Visible', 'on');
    drawnow;
end

end