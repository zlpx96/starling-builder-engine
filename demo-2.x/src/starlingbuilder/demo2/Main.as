/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package starlingbuilder.demo2 {
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    import starling.core.Starling;

    import starlingbuilder.engine.util.StageUtil;

    [SWF(frameRate=60, width=640, height=960)]
    public class Main extends Sprite
    {
        private var _starling : Starling;

        public function Main()
        {
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }

        private function _start(e:Event):void
        {
            _starling.stage3D.removeEventListener(Event.CONTEXT3D_CREATE, _start);

            var stageUtil:StageUtil = new StageUtil(stage);
            var size:Point = stageUtil.getScaledStageSize(stage.stageWidth, stage.stageHeight);
            _starling.viewPort = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
            _starling.stage.stageWidth = size.x;
            _starling.stage.stageHeight = size.y;
            _starling.start();
        }

        private function onEnterFrame(event:Event):void
        {
            removeEventListener(Event.ENTER_FRAME, onEnterFrame);
            init();
        }

        private function init():void
        {
            _starling = new Starling(UIBuilderDemo, stage);
            _starling.showStats = true ;
            _starling.stage3D.addEventListener(Event.CONTEXT3D_CREATE, _start);
        }
    }
}

