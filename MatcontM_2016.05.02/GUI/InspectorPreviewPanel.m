classdef InspectorPreviewPanel < handle
    %INSPECTORPREVIEWPANEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        handle
        eventlistener = {};
        layoutstructure
        
        workspace = struct();
        
        selectionChangedFunctions = {}
        initialiseFunctions = {}
        currentType = 0;
    end
    
    methods
        function obj = InspectorPreviewPanel(parent, model , varargin)
            obj.handle = uipanel(parent, 'Unit' , 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95] ,'DeleteFcn' , @(o,e) obj.destructor(), 'ResizeFcn' , @(o,e) obj.onResize(o) ,varargin{:});
            
            obj.eventlistener{1} = model.addlistener('selectionChanged' , @(o,e) obj.selectionChanged(model));
            obj.eventlistener{2} = model.addlistener('previewTypeChanged' , @(o,e) obj.previewTypeChanged(model));
            
            obj.selectionChangedFunctions{1} = @(model) selectionChanged_System(obj, model);
            obj.selectionChangedFunctions{2} = @(model) selectionChanged_Diagram(obj,model);
            obj.selectionChangedFunctions{3} = @(model) selectionChanged_Curve(obj,model);
            obj.selectionChangedFunctions{4} = @(model) selectionChanged_Point(obj,model);
            obj.selectionChangedFunctions{5} = @(model) selectionChanged_Manifolds(obj,model);
            obj.selectionChangedFunctions{6} = @(model) selectionChanged_ConOrbits(obj,model);
            
            obj.initialiseFunctions{1} = @(model) obj.initialise_System(model);
            obj.initialiseFunctions{2} = @(model) obj.initialise_Diagram(model);
            obj.initialiseFunctions{3} = @(model) obj.initialise_Curve(model);
            obj.initialiseFunctions{4} = @(model) obj.initialise_Point(model) ;
            obj.initialiseFunctions{5} = @(model) obj.initialise_Manifolds(model) ;
            obj.initialiseFunctions{6} = @(model) obj.initialise_ConOrbits(model) ;
            
            obj.previewTypeChanged(model);
            obj.selectionChanged(model);
        end
        
        function selectionChanged(obj, previewmodel)
            if (~isempty(previewmodel.getInfoObject()))
                feval( obj.selectionChangedFunctions{obj.currentType}  ,  previewmodel);
            end
        end
        
        function previewTypeChanged(obj,previewmodel)
            obj.clearPanel();
            obj.currentType = previewmodel.getType();
            feval(obj.initialiseFunctions{obj.currentType} , previewmodel);
        end
        

        function onResize(obj,handle)
            units = get(handle, 'Units');
            set(handle,'Units' , 'Pixels');
            pos = get(handle, 'Position');
            if (~isempty(pos)) 
                obj.layoutstructure.makeLayoutHappen( get(handle, 'Position'));
            end
            set(handle,'Units' , units);
        end
        
        function initialise_System(obj,previewmodel)
            mainnode = LayoutNode(-1,-1,'vertical');
            obj.layoutstructure = mainnode;
            
            obj.workspace.tablehandle = uitable(obj.handle ,'Unit', 'Pixels');
            
            mainnode.addHandle( 1, 1 , obj.workspace.tablehandle , 'minsize' , [Inf,Inf]);
            obj.layoutstructure.makeLayoutHappen(  get(obj.handle , 'Position'));
        end
        
        function selectionChanged_System(obj,previewmodel)
            system = previewmodel.getInfoObject();
            fillSystemTable(obj.workspace.tablehandle , system);
        end
        function initialise_ConOrbits(obj,previewmodel)
            obj.layoutstructure = LayoutNode(-1,-1,'vertical');
            obj.workspace.tablehandle = uitable(obj.handle , 'Unit' , 'Pixels');
            obj.layoutstructure.addHandle( 1, 1 , obj.workspace.tablehandle , 'minsize' , [Inf,Inf]);
            obj.layoutstructure.makeLayoutHappen(  get(obj.handle , 'Position'));        
        end
        function selectionChanged_ConOrbits(obj,previewmodel)
            conorbit =  previewmodel.getInfoObject();
            rowname = num2cell(1:conorbit.getNrPoints());
            if (conorbit.hasBorderPoints())
               rowname = [ {'FP'} , rowname , {'FP'} ]; 
            end
            
            set(obj.workspace.tablehandle , 'Data' , num2cell(conorbit.getAllPoints()') ...
                ,'ColumnName' , previewmodel.session.getSystem().getCoordinateList() ...
                 ,'RowName' , rowname);
            
        end
        function initialise_Manifolds(obj,previewmodel)
            obj.layoutstructure = LayoutNode(-1,-1,'vertical');
            obj.workspace.tablehandle = uitable(obj.handle , 'Unit' , 'Pixels');
            obj.layoutstructure.addHandle( 1, 1 , obj.workspace.tablehandle , 'minsize' , [Inf,Inf]);
            obj.layoutstructure.makeLayoutHappen(  get(obj.handle , 'Position'));
            
        end
        function selectionChanged_Manifolds(obj,previewmodel)
            manifold =  previewmodel.getInfoObject();
            fillManifoldTable(obj.workspace.tablehandle , manifold);
        end             
        
        function initialise_Diagram(obj,previewmodel)
            mainnode = LayoutNode(-1,-1,'vertical');
            obj.layoutstructure = mainnode;
            obj.workspace.listhandle = uicontrol(obj.handle,'Unit', 'Pixels', 'Style', 'edit' , 'BackgroundColor' , 'white' , 'Max' , 10 , 'Enable' , 'inactive' );
            mainnode.addHandle( 1, 1 , obj.workspace.listhandle , 'minsize' , [Inf,Inf]);
            obj.layoutstructure.makeLayoutHappen(  get(obj.handle , 'Position'));
        end
        
        function selectionChanged_Diagram(obj,previewmodel)
            list = previewmodel.getInfoObject();
            set(obj.workspace.listhandle, 'String' , list);
        end        
        
        function initialise_Curve(obj,previewmodel)
            mainnode = LayoutNode(-1,-1,'vertical');
            mainnode.setOptions('Add',true);
            obj.layoutstructure = mainnode;
            
            %
            subnode = LayoutNode(1,1);
            subnode.addHandle(1,1, uicontrol(obj.handle,'Style' , 'text', 'Unit', 'Pixels','BackgroundColor' , [0.95 0.95 0.95], ...
                'String' , 'Npoints' , 'HorizontalAlignment' , 'left'  ),'halign' , 'l');
            obj.workspace.npointshandle = uicontrol(obj.handle,'Style' , 'text', 'Unit','Pixels','BackgroundColor' , [0.95 0.95 0.95],  'String' , '                         ');
            subnode.addHandle(1,1,obj.workspace.npointshandle,'halign' , 'l');
            mainnode.addNode(subnode);
            %
            subnode = LayoutNode(1,1);
            subnode.addHandle(1,1, uicontrol(obj.handle,'Style' , 'text', 'Unit','Pixels','BackgroundColor' , [0.95 0.95 0.95],  ...
                'String' , 'Initial Pointtype', 'HorizontalAlignment' , 'left'  ),'halign' , 'l');
            obj.workspace.pthandle = uicontrol(obj.handle,'Style' , 'text', 'Unit', 'Pixels','BackgroundColor' , [0.95 0.95 0.95], 'String' , '                         ');
            subnode.addHandle(1,1,obj.workspace.pthandle,'halign' , 'l');
            mainnode.addNode(subnode);
            %
            subnode = LayoutNode(1,1);
            subnode.addHandle(1,1, uicontrol(obj.handle,'Style' , 'text', 'Unit', 'Pixels', 'BackgroundColor' , [0.95 0.95 0.95], ...
                'String' , 'Curvetype' , 'HorizontalAlignment' , 'left' ),'halign' , 'l');
            obj.workspace.cthandle = uicontrol(obj.handle,'Style' , 'text', 'Unit','Pixels','BackgroundColor' , [0.95 0.95 0.95],  'String' , '                         ');
            subnode.addHandle(1,1,obj.workspace.cthandle,'halign' , 'l');
            mainnode.addNode(subnode);
            %            
            
            obj.workspace.table = uitable(obj.handle,'Unit', 'Pixels', 'RowName' , [] , 'ColumnName' , {'Type' , 'Index' , 'Message'});
            mainnode.addHandle(7 , 1 , obj.workspace.table , 'minsize' , [Inf,Inf]);
            
            
            obj.layoutstructure.makeLayoutHappen(  get(obj.handle , 'Position') );
        end
        
        function selectionChanged_Curve(obj,previewmodel)
            infostruct =  previewmodel.getInfoObject();
            set(obj.workspace.npointshandle , 'String' , num2str(infostruct.npoints));
            set(obj.workspace.pthandle , 'String' , infostruct.pointtype);
            set(obj.workspace.cthandle , 'String' , infostruct.curvetype);
            set(obj.workspace.table , 'Data' , infostruct.slist);
            s_tableresizer(obj.workspace.table);
        end
        
        function initialise_Point(obj,previewmodel)
            mainnode = LayoutNode(-1,-1,'vertical');
            obj.layoutstructure = mainnode;
            

	    obj.workspace.numeric = NumericMinipanel(previewmodel.current.passon.system , previewmodel.current.curve.getCurveType() , obj.handle);
	    mainnode.addHandle(1,1,obj.workspace.numeric.panelhandle , 'minsize' , [Inf,Inf]);
            obj.layoutstructure.makeLayoutHappen(  get(obj.handle , 'Position') );
        end
        
        function selectionChanged_Point(obj,previewmodel)
            numeric = obj.workspace.numeric;
            infostr = previewmodel.getInfoObject();
	    fields = fieldnames(infostr);
            for i = 1:length(fields)
                cells = infostr.(fields{i});
                keys = cells(:,1);
                for j = 1:length(keys)
                    numeric.setValue( fields{i} , keys{j} , cells{j,2});
                end
            end
            
        end
        function clearPanel(obj)
            obj.workspace = struct();
            if ~isempty(obj.handle); delete(allchild(obj.handle)); end;
            if (~isempty(obj.layoutstructure))
                obj.layoutstructure.destructor();
                obj.layoutstructure = [];
            end
        end
        
        function destructor(obj)
        end
        
    end
    
end

function fillSystemTable(tablehandle, system )

name = system.getName();
coords = system.getCoordinateList();
params = system.getParameterList();
derivatives = system.getDerInfo();
equations = system.getEquations();

table = cell( 1+1+1+1+ size(equations,1) , 2);
table{1,1}  = 'Name';
table{2,1} = 'Coordinates';
table{3,1} = 'Parameters';
table{4,1} = 'Derivatives';
table{5,1} = 'Equations';

table{1,2} = name;
table{2,2} = cellarray2singlestr(coords);
table{3,2} = cellarray2singlestr(params);
table{4,2} = derivatives;
for i = 1:size(equations,1)
    table{4+i , 2} = equations(i,:);
end
col1w = maxChar(table(:,1)) * 7;
col2w = maxChar(table(:,2)) * 7;

set(tablehandle, 'Units' , 'pixels' , 'ColumnWidth' , {col1w , col2w} ,  'Data' , table , 'RowName', [] , 'ColumnName' , [] );

end
function fillManifoldTable(tablehandle , manifold)
optnames = fieldnames(manifold.optM);

table = cell(8 + length(optnames) ,2);
table{1,1} = 'name';
table{1,2} = manifold.name;
table{2,1} = 'type';
if (manifold.isStable())
   table{2,2} = 'Stable Manifold'; 
else
    table{2,2} = 'Unstable Manifold';
end
[coord, param] = manifold.getInitFixedPoint();
table{3,1} = 'Init FP';
table{3,2} = vector2string(coord);
table{4,1} = 'Init Parameters';
table{4,2} = vector2string(param);

table{5,1} = 'points';
table{5,2} = num2str(size(manifold.points , 2));
table{6,1} = 'arclen';
table{6,2} = num2str(manifold.arclen , '%.16g');
table{8,1} = '[Options]';
for i = 1:length(optnames);
   table{i+8 , 1} = optnames{i};
    val = manifold.optM.(optnames{i});
    if (isnumeric(val))
        val = num2str(val , '%.16g');
    end
   table{i+8 , 2} = val;
    
end
col1w = maxChar(table(:,1)) * 9;
col2w = maxChar(table(:,2)) * 9;
set(tablehandle, 'Units' , 'pixels' , 'ColumnWidth' , {col1w , col2w} ,  'Data' , table , 'RowName', [] , 'ColumnName' , [] );
end



function m = maxChar(cellstr)
l = zeros(1, length(cellstr));
for i = 1:length(cellstr)
   l(i) = length(cellstr{i}); 
end
m = max(l);
end
function str = cellarray2singlestr(array)
str = '';
if (~isempty(array))
    str = array{1};
end
for i = 2:length(array)
    str = [str ', ' array{i}];
end
end
function s_tableresizer(handle)
    data = get(handle,'Data');
    col1 = maxChar(data(:,1)) * 7 + 40;
    col2 = maxChar(data(:,2)) * 7 + 40;
    col3 = maxChar(data(:,3)) * 7;
    
    set(handle , 'ColumnWidth' , {col1,col2,col3});
end
