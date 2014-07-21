classdef test_GraphObjectCollection< TestCase
%
%   $Rev: 268 $ ($Date: 2014-03-13 14:11:31 +0000 (Thu, 13 Mar 2014) $)
%
    properties 
        fig;
        gr_obj;
        h0;
    end
    methods       
        % 
        function this=test_GraphObjectCollection(name)
            this = this@TestCase(name);
        end
        function setUp(this)   
     
            if ispc
                this.fig=figure('MenuBar','none','Resize','on',...
                                    'Position',[5    33   550   770],...
                                     'NumberTitle','off');
            else
               this.fig=figure('MenuBar','none','Resize','on',...
                                  'Position',[5    33   696   820],...
                                  'NumberTitle','off');                              
            end
            h=uicontrol('Parent',this.fig,'Style','text','String','2Theta::  min:','HorizontalAlignment','left','Visible','on'); 
            frame = get(this.fig,'Position');
            pos   = [0,0,80,30];
            pos(1) = frame(3)/2;
            pos(2) = frame(4)/2;            
            this.gr_obj = graph_objects_collection('slice_window',h,pos);
            this.h0      = h;
        end  
        
        function tearDown(this)
             delete(this.gr_obj);
             close(this.fig);
         end
        % tests 
        function test_ishandle_exist(this)
            assertEqual(true,is_handle_exist(this.gr_obj,this.h0));
        end
        %
        function test_add_bottom_ignored(this)     
            % old r_min,r_max
            r_mi_o = this.gr_obj.r_min;
            r_ma_o = this.gr_obj.r_max;            
            % tested function
             REZ=add_bottom(this.gr_obj,this.h0);
            % does not add new handle as the same already there
             assertEqual(1,numel(REZ.handles))
            % moved bottom ignored
             assertEqual(r_mi_o, REZ.r_min);
             assertEqual(r_ma_o, REZ.r_max);              
        end
        %
        function test_add_right_ignored(this)
            % old r_min,r_max
            r_mi_o = this.gr_obj.r_min;
            r_ma_o = this.gr_obj.r_max;            
            % tested function
             REZ=add_right(this.gr_obj,this.h0);
            % does not add new handle as the same already there
            assertEqual(1,numel(REZ.handles))
            % moved right ignored
             assertEqual(r_mi_o, REZ.r_min);
             assertEqual(r_ma_o, REZ.r_max);              
        end                 
        %
        function test_add_right(this)
            % old r_min,r_max
            r_mi_o = this.gr_obj.r_min;
            r_ma_o = this.gr_obj.r_max;            
            % tested function
            h=uicontrol('Parent',this.fig,'Style','text','String','2Theta::  min:','HorizontalAlignment','left','Visible','on'); 
            REZ=add_right(this.gr_obj,h);
            % adds new handle 
            assertEqual(2,numel(REZ.handles))
            pos = get(h,'Position');
            % added right
             assertEqual(r_mi_o, this.gr_obj.r_min);
             assertEqual(r_ma_o(2), REZ.r_max(2));              
             assertEqual(r_ma_o(1)+pos(3), REZ.r_max(1)); 
        end                 
     %
        function test_add_bottom(this)
            % old r_min,r_max
            r_mi_o = this.gr_obj.r_min;
            r_ma_o = this.gr_obj.r_max;            
            % tested function
            h=uicontrol('Parent',this.fig,'Style','text','String','2Theta::  min:','HorizontalAlignment','left','Visible','on'); 
            REZ=add_bottom(this.gr_obj,h);
            % adds new handle 
            assertEqual(2,numel(REZ.handles))
            pos = get(h,'Position');
            % added right
             assertEqual(r_ma_o, this.gr_obj.r_max);
             assertEqual(r_mi_o(1), REZ.r_min(1));              
             assertEqual(r_mi_o(2)-pos(4), REZ.r_min(2)); 
        end                   
        %
         function test_add_object_bottom(this)
            % old r_min,r_max
            r_mi_o = this.gr_obj.r_min;
            r_ma_o = this.gr_obj.r_max;            
            % tested function
            pos   = [100,100,50,30];            
            h=uicontrol('Parent',this.fig,'Style','text','String','AAAA','HorizontalAlignment','left','Visible','off'); 
            
            newBlock =  graph_objects_collection('test_add_object_bottom',h,pos);           
            h=uicontrol('Parent',this.fig,'Style','text','String','BBBB','HorizontalAlignment','left','Visible','off');             
            newBlock =add_right(newBlock,h);
            make_visible(newBlock);
            % adds new handle 
            gap=[5,5];
            REZ = add_collection(this.gr_obj,newBlock,[0,-1],gap);
            make_visible(REZ);

         end                           
         function test_add_object_top(this)
            % old r_min,r_max
            r_mi_o = this.gr_obj.r_min;
            r_ma_o = this.gr_obj.r_max;            
            % tested function
            pos   = [100,100,50,30];            
            h=uicontrol('Parent',this.fig,'Style','text','String','AAAA','HorizontalAlignment','left','Visible','off'); 
            
            newBlock =  graph_objects_collection('test_add_object_top',h,pos);           
            h=uicontrol('Parent',this.fig,'Style','text','String','BBBB','HorizontalAlignment','left','Visible','off');             
            newBlock =add_right(newBlock,h);
            make_visible(newBlock);
            % adds new handle 
            gap=[5,5];
            REZ = add_collection(this.gr_obj,newBlock,[0,1],gap);
            make_visible(REZ);
         end                           
         function test_add_object_left(this)
            % old r_min,r_max
            r_mi_o = this.gr_obj.r_min;
            r_ma_o = this.gr_obj.r_max;            
            % tested function
            pos   = [100,100,50,30];            
            h=uicontrol('Parent',this.fig,'Style','text','String','AAAA','HorizontalAlignment','left','Visible','off'); 
            
            newBlock =  graph_objects_collection('test_add_object_left',h,pos);           
            h=uicontrol('Parent',this.fig,'Style','text','String','BBBB','HorizontalAlignment','left','Visible','off');             
            newBlock =add_right(newBlock,h);
            make_visible(newBlock);
            % adds new handle 
            gap=[5,5];
            REZ = add_collection(this.gr_obj,newBlock,[-1,0],gap);
            make_visible(REZ);

         end                           
         function test_add_object_right(this)
            % old r_min,r_max
            r_mi_o = this.gr_obj.r_min;
            r_ma_o = this.gr_obj.r_max;            
            % tested function
            pos   = [100,100,50,30];            
            h=uicontrol('Parent',this.fig,'Style','text','String','AAAA','HorizontalAlignment','left','Visible','off'); 
            
            newBlock =  graph_objects_collection('test_add_object_right',h,pos);           
            h=uicontrol('Parent',this.fig,'Style','text','String','BBBB','HorizontalAlignment','left','Visible','off');             
            newBlock =add_right(newBlock,h);
            make_visible(newBlock);
            % adds new handle 
            gap=[5,5];
            REZ = add_collection(this.gr_obj,newBlock,[1,0],gap);
            make_visible(REZ);

         end                           
                  
         function test_min_max(this)
             hb=cell(4,1);
             hb{1}=uicontrol('Parent',this.fig,'Style','text','String','AAAA','HorizontalAlignment','left','Visible','off','Position',[0,0,10,20]); 
             hb{2}=uicontrol('Parent',this.fig,'Style','text','String','BBBB','HorizontalAlignment','left','Visible','off','Position',[10,0,10,20]);              
             hb{3}=uicontrol('Parent',this.fig,'Style','text','String','CCCC','HorizontalAlignment','left','Visible','off','Position',[0,20,10,20]);                           
             a_class = graph_objects_collection('test_min_max');             
             [r_min,r_max,a_class]=find_min_max(a_class,hb);
             assertEqual(r_min,[0,0]);
             assertEqual(r_max,[20,40]);             
             hb{4}=uicontrol('Parent',this.fig,'Style','text','String','CCCC','HorizontalAlignment','left','Visible','off','Position',[0,20,10,20]);                                        

             [r_min,r_max,a_class]=find_min_max(a_class,hb);
             assertEqual(r_min,[0,0]);
             assertEqual(r_max,[20,40]);             
             assertEqual(r_min,a_class.r_min);
             assertEqual(r_max,a_class.r_max);            

             [r_min,r_max]=find_min_max(a_class,{hb{1:2}},'not_relate2class_min_max');
             assertEqual(r_min,[0,0]);
             assertEqual(r_max,[20,20]);             
             assertEqual([0,0],a_class.r_min);
             assertEqual([20,40],a_class.r_max);            
              
         end
         function test_add_1handle(this)
             a_class = graph_objects_collection('test_add_1handle');                          
             hb=3.1415926000;
             a_class=add_handles(a_class,hb);
             assertEqual(numel(a_class.handles),0);
             hb=uicontrol('Parent',this.fig,'Style','text','String','AAAA','HorizontalAlignment','left','Visible','off','Position',[100,200,10,20]);                           
             a_class=add_handles(a_class,hb);       
             assertEqual(numel(a_class.handles),1);             
             assertEqual([100,200],a_class.r_min);
             assertEqual([110,220],a_class.r_max);                        
         end
         function test_add_handles(this)
             set(this.h0,'Position',[100,200,5,10]);
             
             hb{1}=uicontrol('Parent',this.fig,'Style','text','String','AAAA','HorizontalAlignment','left','Visible','off','Position',[100,200,10,20]);                           
             hb{2}=uicontrol('Parent',this.fig,'Style','text','String','BBBB','HorizontalAlignment','left','Visible','off','Position',[110,220,10,20]);                                        
             hb{3}=[];
             a_class=add_handles(this.gr_obj,hb);       
             assertEqual(numel(a_class.handles),3);             
             assertEqual([100,200],a_class.r_min);
             assertEqual([120,240],a_class.r_max);                        
         end         
    end
end

