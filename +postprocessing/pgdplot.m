function pgdplot(X,S,varargin)
%pgdplot plot a pgd solution for a d-dimensional problem 
%   pgdplot({X1,X2, ... ,Xd},{Y1,...Yd}) plots a 2-dimensional matrix Y 
%   defined over X1 a space mesh and X2, ... ,Xd 1D mesh respectively. The 
%   result is a plot of sum over the col of Yi of Y1 x ... x Yd function of
%   X1 with slider to select the correct X2 ... Xd value. X1 ... Xd are
%   meshes defined with the class Mesh of that library
%
%   pgdplot( ... , 'PropertyName1',value1,'PropertyName2',value2,...) set
%   specific properties as :
%      - 'Xlabel' : allow to specify the label for each PGD directions in a cell array. 
%      - 'Ylabel' : allow to specify the quantites ploted as a string.
%      - 'Title' : set the title of the figure.
%
%   Example :
%     x = SegmentMesh(0:1);
%     t = SegmentMesh(0:1);
%
%    which gives us a PGD solution like that one :
%     u_x = [0 1;0 1;0 1;0 1];
%     u_t = [0 1;0 1;0 1;0 1];
%
%    then to plot it, just ask :
%     pgdplot({x,t},{u_x,u_t},'Xlabel',{'x','t'},'Ylabel','sol','Title','plot');
%
%   Copyright 2013 Pierre-Eric Allier

%% Check the inputs
X = X(:);
S = S(:);
d = length(X);
% Check the dimension of inputs
if iscell(X) && iscell(S) && length(X(:)) == length(S(:))   
    % Check the mesh dimensions and solution dimensions values
    for i=1:d
        if ischar(X{i}) || ischar(S{i})
            error('PGDplot:BadInput','The cell data type shouldn''t be a string.');
        elseif ~isa(X{i},'mesh.Mesh')
            error('PGDplot:BadInput','The first cell data type should be a Mesh object.');
        end
    end
else
    error('PGDplot:BadInput','The two cell array should have the same dimensions.');
end

% Select the correct plot function
switch X{1}.mesh_dim
    case 1
        plot_handle = @(fig,x,u) plot(fig,cellfun(@(node) node.coor(1),x.nodes),u);
    case 2
        plot_handle = @(fig,x,u) patch('Faces',cell2mat(cellfun(@(elem) cellfun(@(node) node.id,elem.nodes), x.elems, 'UniformOutput',false)'), ...
                                       'Vertices',cell2mat(cellfun(@(node) node.coor', x.nodes, 'UniformOutput',false)'), ...
                                       'FaceVertexCData',u,'FaceColor','interp','CDataMapping','scale');
    otherwise
        error('PGDplot:BadInput','The space mesh dimension should be below or equal to 2.');
end

% Optionnal input
i = 1;
while i < nargin - 2
    if ischar(varargin{i})
        % String command as 'Legend','Label' ...
        switch varargin{i}
            case 'Xlabel'
                if length(varargin{i+1}) == d && iscellstr(varargin{i+1})
                    x_label = varargin{i+1};
                else
                    warning('PGDplot:BadInput',['The associate Xlabel variable should be a string cell array of dimension equal to ' num2str(d) '.']);
                end
                i = i + 2;
                
            case 'Title'
                if ischar(varargin{i+1})
                    title = varargin{i+1};
                else
                    warning('PGDplot:BadInput','The associate Title variable should be a string.');
                end
                i = i + 2;
            case 'Ylabel'
                if ischar(varargin{i+1})
                    y_label = varargin{i+1};
                else
                    warning('PGDplot:BadInput','The associate Ylabel variable should be a string.');
                end
                i = i + 2;
            otherwise
                warning('PGDplot:BadInput',['Undefined ' varargin{i} ' field.']);
                i = i+1;
        end
    end
end


% Default Optionnal input
if ~exist('x_label','var')
    x_label = cell(d,1);
    for i=1:d
        x_label{i} = num2str(i);
    end
end
if ~exist('y_label','var')
    y_label = '';
end
if ~exist('title','var')
    title = '';
end

%% Figure setup
% maximum and minimum of solution
extract = @(cell,i) cellfun(@(v) v(:,i),cell,'UniformOutput',false);
w = extract(S,1);
v = pgd.outProd(w{:});
for i=2:size(S{1},2)
    w = extract(S,i);
    v = v + pgd.outProd(w{:});
end
lims = [min(v(:)) max(v(:))];


% Build GUI
figH = figure('Units', 'Pixels', 'Name', title, 'ResizeFcn' , @myResizeFcn);
axesH = axes('Units', 'Pixels');

textH = cell(d+1,1);
sliderH = cell(d+1,1);
buttonH = cell(d+1,1);

% Param and time sliders
for i=2:d
    coor = cellfun(@(node) node.coor(1),X{i}.nodes);
    textH{i} = uicontrol(      ...
      'Style'     , 'Text'   , ...
      'Units'     , 'Pixels' , ...
      'String'    , x_label{i});
    if length(coor) == 1
        slider_step = [1 1];
    else
        slider_step = [1 1]/(length(coor)-1);
    end
    sliderH{i} = uicontrol(                ...
      'Style'     , 'Slider'             , ...
      'Units'     , 'Pixels'             , ...
      'SliderStep', slider_step          , ...
      'Min'       , 1                    , ...
      'Max'       , length(coor)         , ...
      'Value'     , 1                    , ...
      'TooltipString', num2str(min(coor)), ...
      'Callback'  , {@mySliderFcn,i}     );
    buttonH{i} = uicontrol(           ...
      'Style'     , 'Pushbutton'    , ...
      'Units'     , 'Pixels'        , ...
      'String'    , '>'             , ...
      'Callback'  , {@myButtonFcn,i});
end
played = 0;
ids = num2cell(ones(d+1,1));

% Modes sliders
X = {X{:} mesh.SegmentMesh(1:size(S{1},2))};
ids{end} = size(S{1},2);

sum_modes = uicontrol(          ...
    'Style'     , 'togglebutton', ...
    'Units'     , 'Pixels'      , ...
    'Min'       , 0             , ...
    'Max'       , 1             , ...
    'Value'     , 1             , ...
    'String'    , '+'           );

if size(S{1},2) > 1
    textH{end} = uicontrol(     ...
      'Style'     , 'Text'  , ...
      'Units'     , 'Pixels', ...
      'String'    , 'm'     );
    sliderH{end} = uicontrol(           ...
      'Style'     , 'Slider'          , ...
      'Units'     , 'Pixels'          , ...
      'SliderStep', slider_step       , ...
      'Min'       , 1                 , ...
      'Max'       , size(S{1},2)      , ...
      'Value'     , size(S{1},2)      , ...
      'TooltipString', num2str(1)     , ...
      'Callback'  , {@mySliderFcn,i+1});
    buttonH{end} = uicontrol(           ...
      'Style'     , 'Pushbutton'      , ...
      'Units'     , 'Pixels'          , ...
      'String'    , '>'               , ...
      'Callback'  , {@myButtonFcn,i+1});
else
    set(sum_modes,'Visible','off');
end

% Plot
plot_data();

%% callback functions
  function myResizeFcn(varargin)
    % Figure resize callback
    %   Adjust object positions so that they maintain appropriate
    %   proportions
    
    % definition of size 
    border_x = 20;
    border_ui = 10;
    border_y = 20;
    
    ui_height = 15;
    button_width = 50;
    text_width = 20;
    
    % figure size
    fP = get(figH, 'Position');
    
    for j=1:length(sliderH)-1
        set(textH{length(sliderH) - j}, 'Position', [border_x, border_y + (border_ui+ui_height)*(j-1), text_width, ui_height]);
        set(sliderH{length(sliderH) - j}, 'Position', [border_x+border_ui+text_width, border_y + (border_ui+ui_height)*(j-1), fP(3)-2*border_x-2*border_ui-button_width-text_width, ui_height]);
        set(buttonH{length(sliderH) - j}, 'Position', [fP(3)-border_x-button_width, border_y + (border_ui+ui_height)*(j-1), button_width, ui_height]);
    end
    if size(S{1},2) > 1
        set(textH{end}, 'Position', [border_x, fP(4)- border_y - ui_height, text_width, ui_height]);
        set(sliderH{end}, 'Position', [border_x+border_ui+text_width, fP(4)- border_y - ui_height, fP(3) - 2*border_x-3*border_ui-2*button_width-text_width, ui_height]);
        set(sum_modes, 'Position', [fP(3)-border_x-border_ui-2*button_width, fP(4)- border_y - ui_height, button_width, ui_height]);
        set(buttonH{end}, 'Position', [fP(3)-border_x-button_width, fP(4)- border_y - ui_height, button_width, ui_height]);
    end
    set(axesH  , 'Position', [border_x+text_width, border_y + (border_ui+ui_height)*d, fP(3)-2*border_x-button_width-text_width, fP(4)- 3*border_y - (border_ui+ui_height)*(d+1)]);
  end

  function mySliderFcn(varargin)
    % Slider callback
    % Modifies the parameter
    
	coef = round(get(varargin{1}, 'Value'));
    id = varargin{3};
    
    coor = cellfun(@(node) node.coor(1),X{id}.nodes);
    [~,ids{id}] = min(abs(coor - coor(coef)));
    set(sliderH{id},'TooltipString', num2str(coor(ids{id})));
    set(sliderH{id},'Value',ids{id});
    
    plot_data();
  end

  function myButtonFcn(varargin)
    % Button callback
    % Play/stop the update
    
    id = varargin{3};
    
    if played == id
        stop();
    else
        if played ~=0
            stop();
        end
        played = id;
        play();
    end
  end

  function play()
  % Update frequently the figure  
      if played ~= 0 && ishandle(axesH)
          set(buttonH{played},'String','||');
          coor = cellfun(@(node) node.coor(1),X{played}.nodes);
          if length(coor) ~= ids{played}
            ids{played} = ids{played} + 1;
          else
              stop();
              return;
          end
          set(sliderH{played},'TooltipString', num2str(coor(ids{played})));
          set(sliderH{played},'Value',ids{played});

          plot_data();

          pause(0.3);
          play();
      end   
  end

  function stop()
  % Stop the update frequently the figure
      set(buttonH{played},'String','>');
      played = 0;
  end

  function plot_data()
  % Plot the data
      v = 0;
      if get(sum_modes,'Value')
          for l=1:ids{end}
              w = S{1}(:,l);
              for j=2:d
                  w = w.*S{j}(ids{j},l);
              end
              v = v + w;
          end
      else
          v = S{1}(:,ids{end});
          for j=2:d
              v = v.*S{j}(ids{j},ids{end});
          end
      end
      plot_handle(axesH, X{1}, v);
      
      xlabel(axesH,x_label{1});
      
      if X{1}.mesh_dim == 1
        set(axesH,'YLim',lims + [-1 1]*max(abs(lims))/100);
        ylabel(axesH,y_label);
      else
        bar = colorbar;
        xlabel(bar,y_label);
        caxis(lims);
      end
  end

end