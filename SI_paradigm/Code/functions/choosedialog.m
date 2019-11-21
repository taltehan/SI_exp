function choice = choosedialog(title, text, input)
% title: str
% text: str
% input: vertival cell array
% example: color = choosedialog('Colors', 'Select a color', {'Red';'Green';'Blue'})

d = dialog('Position',[300 300 250 150],'Name',title);
txt = uicontrol('Parent',d,...
    'Style','text',...
    'Position',[20 80 210 40],...
    'String',text);

popup = uicontrol('Parent',d,...
    'Style','popup',...
    'Position',[75 70 100 25],...
    'String',input,...
    'Callback',@popup_callback);

btn = uicontrol('Parent',d,...
    'Position',[89 20 70 25],...
    'String','OK',...
    'Callback','delete(gcf)');

choice = input{1};

% Wait for d to close before running to completion
uiwait(d);

    function popup_callback(popup,event)
        idx = popup.Value;
        popup_items = popup.String;
        choice = char(popup_items(idx,:));
    end
end