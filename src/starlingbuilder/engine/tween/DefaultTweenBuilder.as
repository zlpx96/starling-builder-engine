/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package starlingbuilder.engine.tween
{
    import flash.utils.Dictionary;
    import starling.animation.Tween;
    import starling.core.Starling;
    import starling.display.DisplayObject;
    import starling.display.DisplayObjectContainer;

    import starlingbuilder.engine.UIBuilder;

    /**
     * Default implementation of ITweenBuilder
     *
     * <p>Example data1:</p>
     * <p>{"time":1, "properties":{"scaleX":0.9, "scaleY":0.9, "repeatCount":0, "reverse":true}}</p>
     * <p>Example data2:</p>
     * <p>[{"properties":{"repeatCount":0,"scaleY":0.9,"reverse":true,"scaleX":0.9},"time":1},{"properties":{"repeatCount":0,"alpha":0,"reverse":true},"time":0.5}]</p>
     * <p>Example data3:</p>
     * <p>{"time":0.5,"properties":{"repeatCount":0,"reverse":true},"delta":{"y":-10}}</p>
     *
     * @see ITweenBuilder
     */
    public class DefaultTweenBuilder implements ITweenBuilder
    {
        private var _saveData:Dictionary;

        /**
         * Constructor
         */
        public function DefaultTweenBuilder()
        {
            _saveData = new Dictionary();
        }

        /**
         * @inheritDoc
         */
        public function start(root:DisplayObject, paramsDict:Dictionary, names:Array = null):void
        {
            stop(root, paramsDict, names);

            var array:Array = getDisplayObjectsByNames(root, paramsDict, names);

            for each (var obj:DisplayObject in array)
            {
                var data:Object = paramsDict[obj];

                var tweenData:Object = data.tweenData;

                if (tweenData)
                {
                    if (tweenData is Array)
                    {
                        for each (var item:Object in tweenData)
                            createTweenFrom(obj, item);
                    }
                    else
                    {
                        createTweenFrom(obj, tweenData);
                    }
                }
            }
        }

        private function getDisplayObjectsByNames(root:DisplayObject, paramsDict:Dictionary, names:Array):Array
        {
            var array:Array = [];

            if (names)
            {
                for each (var name:String in names)
                {
                    array.push(UIBuilder.find(root as DisplayObjectContainer, name));
                }
            }
            else
            {
                for (var obj:Object in paramsDict)
                {
                    if (paramsDict[obj].hasOwnProperty("tweenData"))
                        array.push(obj);
                }
            }

            return array;
        }

        private function createTweenFrom(obj:DisplayObject, data:Object):void
        {
            if (!data.hasOwnProperty("time"))
            {
                trace("Missing tween param: time");
                return;
            }

            if (!data.hasOwnProperty("properties"))
            {
                trace("Missing tween param: properties");
                return;
            }

            var initData:Object = saveInitData(obj, data.properties, data.delta);

            setFrom(obj, data.from);

            var properties:Object = UIBuilder.cloneObject(data.properties);

            setDelta(obj, data.delta, properties);

            var tween:Object = Starling.current.juggler.tween(obj, data.time, properties);

            if (!_saveData[obj]) _saveData[obj] = [];

            _saveData[obj].push({tween:tween, init:initData});
        }

        /**
         * @inheritDoc
         */
        public function stop(root:DisplayObject, paramsDict:Dictionary = null, names:Array = null):void
        {
            if (paramsDict == null || names == null)
            {
                stopAll(root);
            }
            else
            {
                var array:Array = getDisplayObjectsByNames(root, paramsDict, names);

                for each (var obj:DisplayObject in array)
                {
                    stopTween(obj);
                }
            }
        }

        private function stopTween(obj:DisplayObject):void
        {
            var array:Array = _saveData[obj];

            if (array)
            {
                for each (var data:Object in array)
                {
                    var initData:Object = data.init;
                    recoverInitData(obj, initData);

                    var tween:Object = data.tween;

                    if (tween is Tween) //Starling 1.x
                    {
                        Starling.current.juggler.remove(tween as Tween);
                    }
                    else //Starling 2.x
                    {
                        Starling.current.juggler["removeByID"](tween as uint);
                    }
                }
            }

            delete _saveData[obj];
        }

        private function setFrom(obj:Object, from:Object):void
        {
            for (var name:String in from)
            {
                if (obj.hasOwnProperty(name))
                {
                    obj[name] = from[name];
                }
            }
        }

        private function setDelta(obj:Object, delta:Object, properties:Object):void
        {
            for (var id:String in delta)
            {
                properties[id] = obj[id] + delta[id];
            }
        }

        private function recoverInitData(obj:Object, initData:Object):void
        {
            for (var name:String in initData)
            {
                obj[name] = initData[name];
            }
        }

        private function saveInitData(obj:Object, properties:Object, delta:Object):Object
        {
            var data:Object = {};
            var name:String;

            for (name in properties)
            {
                if (obj.hasOwnProperty(name))
                {
                    data[name] = obj[name];
                }
            }

            for (name in delta)
            {
                if (obj.hasOwnProperty(name))
                {
                    data[name] = obj[name];
                }
            }

            return data;
        }

        private function stopAll(root:DisplayObject):void
        {
            var container:DisplayObjectContainer = root as DisplayObjectContainer;

            for (var obj:Object in _saveData)
            {
                if (root === obj || container && container.contains(obj as DisplayObject))
                    stopTween(obj as DisplayObject);
            }
        }

    }
}
