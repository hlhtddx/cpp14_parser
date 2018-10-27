class Project {
    string engine;
    string packages;
};

class Id {
    int __id__;
    void write_value() {
        = __id__;
    }
};

class Uuid {
    string __uuid__;
    void write_value() {
        = __uuid__;
    }
};

class Vec2
{
    float x;
    float y;
    void write_value() {
        = "Vec2(", x, ", ", y, ")";
    }
};

class Vec3
{
    float x;
    float y;
    float z;
    void write_value() {
        = "Vec3(", x, ", ", y, ", ", z, ")";
    }
};

class Size
{
    float width;
    float height;
    void write_value() {
        = "Size(", width, ", ", height, ")";
    }
};

class Rect
{
    float x;
    float y;
    float w;
    float h;
    void write_value() {
        = "Rect(", x, ", ", y, ", ", w, ", ", h, ")";
    }
};

class Color3B
{
    ubyte r;
    ubyte g;
    ubyte b;
    void write_value() {
        = "Color3B(", r, ", ", g, ", ", b, ")";
    }
};

class Color4B
{
    ubyte r;
    ubyte g;
    ubyte b;
    ubyte a;
    void write_value() {
        = "Color4B(", r, ", ", g, ", ", b, ", ", a, ")";
    }
};

class Item : "cc.Item" {
    string __type__;
	string name : "_name";
    Id node;
    Id parent : "_parent";
    Id@ children : "_children";
    Id@ components : "_components";
    void __ctor__() {
        Root = parent_item;
    }

    void post_init() {
        Parent = Root.find(parent);
        Children = Root.find_all_items(children);
        Components = Root.find_all_items(components);

        if(name)
            Name = qualified_name(name) + "_" + make_string(id);
        else
            Name = "node_" + make_string(id);
    }

    void get_component(string __type__) {
        for component in Components {
            if (component.__type__ == __type__) {
                return component;
            }
        }
        return null;
    }

    void write_header() {
        = {
            Children, Components;
        }
    }

    void write_create_children() {
        = "/* Start Children=", id, ", name=", Name, ", type=", __type__, " */";
        for child in Children {
            Node node = child;
            node.write_create_scene();
        }
        = "/* End Children=", id, ", name=", Name, ", type=", __type__, " */";
    }

    void write_setup_children() {
        for child in Children {
            Node node = child;
            node.write_setup_scene();
        }
    }

    bool write_setup_node(Node node) {
        return false;
    }

    bool write_create_node(Node node) {
        return false;
    }

    void write_property() {
    }

internal:
    Fire Root;
    string Name;
    Item Parent;
    Item@ Children;
    Item@ Components;
    int id;
};

class Node : "cc.Node" extends Item {
	Size contentSize : "_contentSize";
	bool active : "_active";
	bool enabled : "_enabled";
	Vec2 anchorPoint : "_anchorPoint";
	bool cascadeOpacityEnabled : "_cascadeOpacityEnabled";
	Color3B color : "_color";
	int globalZOrder : "_globalZOrder";
	int localZOrder : "_localZOrder";
	int opacity : "_opacity";
	bool opacityModifyColor3B : "_opacityModifyColor3B";
	Vec2 position : "_position";
	int rotationSkewX : "_rotationX";
	int rotationSkewY : "_rotationY";
	float scaleX : "_scaleX";
	float scaleY : "_scaleY";
	int skewX : "_skewX";
	int skewY : "_skewY";
	int tag : "_tag";
	int groupIndex : "groupIndex";
    int objFlags : "_objFlags" = 0;
    string rawFiles : "_rawFiles";
    string visible;

internal:
    void addChild() {
    }

    void write_create_scene() {
        bool is_component = false;
        for component in Components {
            if(component.write_create_node(this)) {
                is_component = true;
                break;
            }
        }
        if(!is_component) {
            write_create_node(this);
            write_add_child();
        }
        write_create_children();
    }

    void write_setup_scene() {
        bool is_component = false;
        for component in Components {
            if(component.write_setup_node(this)) {
                is_component = true;
                break;
            }
        }
        if(!is_component) {
            write_setup_node(this);
        }
        write_setup_children();
    }

    void write_add_child() {
        = Parent.Name.addChild(Name);
    }

    bool write_create_node(Node node) {
        = {
        "// cc.Node";
        "auto ", Name, " = Node::create();";
        $ write_property();
        }
        return true;
    }

    void write_property() {
        = {
        string name_str = "\"" + Name + "\"";
        Name.globalZOrder = globalZOrder;
        Name.localZOrder = localZOrder;
        Name.name = name_str;
        Name.anchorPoint = anchorPoint;
        Name.color = color;
        Name.opacity = opacity;
        Name.opacityModifyColor3B = opacityModifyColor3B;
        Name.position = position;
        Name.rotationSkewX = rotationSkewX;
        Name.rotationSkewY = rotationSkewY;
        Name.scaleX = scaleX;
        Name.scaleY = scaleY;
        Name.skewX = skewX;
        Name.skewY = skewY;
        Name.tag = tag;
        Name.contentSize = contentSize;
        Name.visible = enabled;
        }
    }
};

class Fire {
    string name;
    Item@ items;
internal:
    string _uuid;

    void __ctor__() {
        Scene scene = items[1];
        scene.name = qualified_name(name);
        _uuid = scene.id;
        int i = 0;
        for item in items {
            item.id = i;
            item.post_init();
            i = i + 1;
        }
    }

    string get_uuid() {
        return _uuid;
    }

    void write_header() {
        = {
        "#include \"cocos2d.h\"";
        "#include \"ui/CocosGUI.h\"";
        ;
        "USING_NS_CC;";
        ;
        "class " + qualified_name(name) + " : public Node {";
        > {
            "public:";
            "// create scene";
            "static cocos2d::Scene* createScene();";
            "void setupScene();";
            ;
        }
        "};";
        ;
        }
    }

    void write_source() {
        = {
        "#include \"" + name + ".h\"";
        ;
        }
        SceneAsset asset = items[0];
        asset.write_source();
    }

    Item find(Id pid) {
    if(pid)
        return items[pid.__id__];
    }

    Item@ find_all_items(Id@ item_ids) {
        Item@ sub_items;
        for item_id in item_ids {
            sub_items.append(items[item_id.__id__]);
        }
        return sub_items;
    }
};

class Meta : "cc.Meta" {
    string ver;
    string uuid;
    bool isGroup;
    string type;
    string wrapMode;
    string filterMode;
    variant subMetas;
internal:
    string _uuid;
    Meta@ subMetaList;
    void __ctor__() {
        if (subMetas) {
            subMetaList = get_sub_metas(this);
            _uuid = subMetaList[0].uuid;
        } else {
            _uuid = uuid;
        }
    }

    string get_uuid() {
        return _uuid;
    }
};

class SceneAsset : "cc.SceneAsset" extends Item {
    Id scene;

    void write_source() {
        Scene _scene = Root.items[scene.__id__];
        _scene.write_create_scene();
        _scene.write_setup_scene();
    }
};

class Scene : "cc.Scene" extends Item {
    string id : "_id";
    bool autoReleaseAssets;

    void __ctor__() {
        name = "scene";
    }

    void write_setup_scene() {
        = {
        "void ", name, "::setupScene() {";
        > {
            "auto director = cocos2d::Director::getInstance();";
            "auto glview = director->getOpenGLView();";
            $ write_setup_children();
        }
        "}";
        ;
        }
    }

    void write_create_scene() {
        = {
        "Scene* " + name + "::createScene() {";
        > {
            "auto ", Name, " = Scene::create();";
            autoReleaseAssets = autoReleaseAssets;
            $ write_create_children();
            "return ", Name, ";";
        }
        "}";
        ;
        }
    }
};

class Canvas : "cc.Canvas" extends Item {
    Size designResolution : "_designResolution";
    bool fitWidth : "_fitWidth";
    bool fitHeight : "_fitHeight";

    bool write_create_node(Node node) {
        // No node will be created for canvas
        = "// cc.Canvas";
        node.Name = node.Parent.Name;
        return true;
    }

    bool write_setup_node(Node node) {
        = {
        "// cc.Canvas";
        "const auto designResolution = ", designResolution, ";";
        string policy;
        if (fitWidth && fitHeight)
            policy = "ResolutionPolicy::SHOW_ALL";
        else if (fitHeight)
            policy = "ResolutionPolicy::FIXED_HEIGHT";
        else if (fitWidth)
            policy = "ResolutionPolicy::FIXED_WIDTH";
        else
            policy = "ResolutionPolicy::NO_BORDER";

        "glview->setDesignResolutionSize(designResolution.width, designResolution.height, ", policy, ");";
        }
        return true;
    }
};

class Camera : "cc.Camera" extends Item  {
    int cullingMask : "_cullingMask" = -1;
    int clearFlags : "_clearFlags";
    Color4B backgroundColor : "_backgroundColor";
    int depth : "_depth";
    int zoomRatio : "_zoomRatio";
    Uuid targetTexture : "_targetTexture" = null;

    bool write_create_node(Node node) {
        return true;
    }
};

class Button : "cc.Button" extends Item {
    int transition;
    float duration;
    float zoomScale;

    Color4B normalColor : "_N$normalColor";
    Color4B disabledColor : "_N$disabledColor";
    Color4B pressColor;
    Color4B hoverColor;

    Uuid normalSprite : "_N$normalSprite";
    Uuid disabledSprite : "_N$disabledSprite";
    Uuid pressedSprite;
    Uuid hoverSprite;

    Id target : "_N$target";
    bool pressedActionEnabled;

    bool interactable : "_N$interactable";
    bool enableAutoGrayEffect : "_N$enableAutoGrayEffect";
    Id@ clickEvents;

internal:
    bool ignoreContentAdaptWithSize = false;

    bool write_create_node(Node node) {
        = "// cc.Button";
        Sprite sprite = node.get_component("cc.Sprite");
        if (sprite && sprite.spriteFrame) {
            = {
            string spriteFrameName = find_resource_by_uuid(sprite.spriteFrame);
            string pressedSpriteName = find_resource_by_uuid(pressedSprite);
            string disabledSpriteName = find_resource_by_uuid(disabledSprite);
            "auto ", node.Name, " = ui::Button::create(";
                > {
                "\"",spriteFrameName, "\",";
                "\"", pressedSpriteName, "\",";
                "\"", disabledSpriteName, "\");";
                }
            }
        } else {
            = {
            "auto ", node.Name, " = ui::Button::create();";
            }
        }

        node.write_property();

        = {
            node.Name.ignoreContentAdaptWithSize(ignoreContentAdaptWithSize);
            if(transition == 3) {
                node.Name.zoomScale = zoomScale;
                node.Name.pressedActionEnabled = true;
            }
        }
        node.write_add_child();
        return true;
    }
};

class EditBox : "cc.EditBox" extends Item {
    bool useOriginalSize : "_useOriginalSize";
    string text : "_string";
    float tabIndex : "_tabIndex";
    Id@ editingDidBegan;
    Id@ textChanged;
    Id@ editingDidEnded;
    Id@ editingReturn;
    Uuid backgroundImage : "_N$backgroundImage";
    int returnType : "_N$returnType";
    int inputFlag : "_N$inputFlag";
    int inputMode : "_N$inputMode";
    int fontSize : "_N$fontSize";
    int lineHeight : "_N$lineHeight";
    Color4B fontColor : "_N$fontColor";
    string placeHolder : "_N$placeholder";
    int placeholderFontSize : "_N$placeholderFontSize";
    Color4B placeholderFontColor : "_N$placeholderFontColor";
    int maxLength : "_N$maxLength";
    bool stayOnTop : "_N$stayOnTop";

    bool write_create_node(Node node) {
        = "// cc.EditBox";
        string spriteFrameName = find_resource_by_uuid(backgroundImage);
        = {
        "auto ", node.Name, " = ui::EditBox::create(", node.contentSize , ", \"", spriteFrameName, "\", ui::Widget::TextureResType::PLIST);";

        $ node.write_property();

        string input_flag_param = "static_cast<ui::EditBox::InputFlag>(" + make_string(inputFlag) + ")";
        string input_mode_param = "static_cast<ui::EditBox::InputMode>(" + make_string(inputMode) + ")";
        string placeholder_param = "\"" + placeHolder + "\"";
        string text_param = "\"" + text + "\"";
        node.Name.returnType = returnType;
        node.Name.inputFlag = input_flag_param;
        node.Name.inputMode = input_mode_param;
        node.Name.fontSize = fontSize;
        node.Name.fontColor = fontColor;
        node.Name.placeHolder = placeholder_param;
        node.Name.placeholderFontSize = placeholderFontSize;
        node.Name.placeholderFontColor = placeholderFontColor;
        node.Name.maxLength = maxLength;
        node.Name.text = text_param;
        }
        node.write_add_child();
        return true;
    }
};

class Label : "cc.Label" extends Item {
    bool useOriginalSize : "_useOriginalSize";
    int actualFontSize : "_actualFontSize";
    int fontSize : "_fontSize";
    int lineHeight : "_lineHeight";
    bool enableWrap : "_enableWrapText";
    Uuid file : "_N$file";
    bool isSystemFontUsed : "_isSystemFontUsed";
    int spacingX : "_spacingX";
    string _string : "_N$string";
    int horizontalAlign : "_N$horizontalAlign";
    int verticalAlign : "_N$verticalAlign";
    int overflow : "_N$overflow";

internal:
    void setAlignment;
    bool write_create_node(Node node) {
        = "// cc.Label";

        string text = "\"" + _string + "\"";
        if (isSystemFontUsed) {
            = "auto ", node.Name, " = Label::createWithTTF(", text, ", \"arial\", ", fontSize, ");";
        } else {
            string font_name = find_resource_by_uuid(file);
            string font_name_str = "\"" + font_name + "\"";
            if (ends_with(font_name, ".ttf")) {
                = "auto ", node.Name, " = Label::createWithTTF(", text, ", ", font_name_str, ", ", fontSize, ");";
            } else if (ends_with(font_name, ".fnt")) {
                = "auto ", node.Name, " = Label::createWithBMFont(", font_name_str,", ", text,  ");";
            }
        }

        node.write_property();
        string horizontal_alignment = "static_cast<TextHAlignment>(" + make_string(horizontalAlign) + ")";
        string vertical_alignment = "static_cast<TextVAlignment>(" + make_string(verticalAlign) + ")";
        string overflow_type = "static_cast<Label::Overflow>(" + make_string(overflow) + ")";
        = {
            if (!isSystemFontUsed) {
                node.Name.lineHeight = lineHeight;
            }
            node.Name.enableWrap(enableWrap);
            node.Name.setAlignment(horizontal_alignment, vertical_alignment);
            node.Name.overflow = overflow_type;
        }
        node.write_add_child();
        return true;
    }
};

class ProgressBar : "cc.ProgressBar" extends Item {
    int totalLength : "_N$totalLength";
    Id barSprite : "_N$barSprite";
    int mode : "_N$mode";
    float progress : "_N$progress";
    bool reverse : "_N$reverse";
internal:
    void loadTexture;
    void setDirection;
    bool write_create_node(Node node) {
        = {
            "// cc.ProgressBar";
            "auto ", node.Name, " = ui::LoadingBar::create();";
            node.Name, "->ignoreContentAdaptWithSize(false);";
        }
        node.write_property();

        if (barSprite) {
            Sprite bar_sprite = Root.find(barSprite);
            if (bar_sprite) {
                string bar_sprite_name = "\"" + find_resource_by_uuid(bar_sprite.spriteFrame) + "\"";
                = node.Name.loadTexture(bar_sprite_name);
            }
        }

        Sprite bg_sprite = node.get_component("cc.Sprite");
        if (bg_sprite) {
            string spriteFrameName = "\"" + find_resource_by_uuid(bg_sprite.spriteFrame) + "\"";
            = {
                "auto sprite = cocos2d::Sprite::create(", spriteFrameName, ");";
                "sprite->setStretchEnabled(true);";
                "sprite->setContentSize(", node.Name, "->getContentSize());";
                "sprite->setAnchorPoint(cocos2d::Vec2(0,0));";
                node.Name, "->addChild(sprite, -1);";
            }
        }
        if (reverse) {
            = node.Name.setDirection("cocos2d::ui::LoadingBar::Direction::RIGHT");
        }
        node.write_add_child();
        return true;
    }
};

class Slider : "cc.Slider" extends Item {
     int direction;
     Id@ slideEvents;
    Id handle : "_N$handle";
    int percent : "_N$progress";
internal:
    void loadTexture;
    void loadSlidBallTextureNormal;
    void loadSlidBallTexturePressed;
    void loadSlidBallTextureDisabled;
    void maxPercent;
    void scale9Enabled;

    bool write_create_node(Node node) {
        = {
            "// cc.Slider";
            "auto ", node.Name, " = ui::Slider::create();";
            node.Name.percent = percent * 100;
            node.Name.maxPercent = 100;
            node.Name.scale9Enabled = true;
        }
        node.write_property();
        Button button = Root.find(handle);
        if (button) {
            Node base_node = Root.find(button.target);
            if (button.normalSprite) {
                string sprite_name = "\"" + find_resource_by_uuid(button.normalSprite) + "\"";
                = {
                    node.Name.loadSlidBallTextureNormal(sprite_name);
                    "auto render = ", node.Name, "->getSlidBallNormalRenderer();";
                    "const auto&& ball = ", node.Name, "->getSlidBallRenderer();";
                    "const auto _size = render->getContentSize();";
                    "ball->setScale(", base_node.contentSize.width, " / _size.width, ", base_node.contentSize.height, " / _size.height);";
                }
            }
            if (button.pressedSprite) {
                string sprite_name = "\"" + find_resource_by_uuid(button.pressedSprite) + "\"";
                = node.Name.loadSlidBallTexturePressed(sprite_name);
            }
            if (button.disabledSprite) {
                string sprite_name = "\"" + find_resource_by_uuid(button.disabledSprite) + "\"";
                = node.Name.loadSlidBallTextureDisabled(sprite_name);
            }
        }
        node.write_add_child();
        return true;
    }
};

class Toggle : "cc.Toggle" extends Button {
    Id toggleGroup;
    Id checkMark;
    Id@ checkEvents;
    bool selected : "_N$isChecked";

internal:
    void ignoreContentAdaptWithSize;
    void touchEnabled;

    bool write_create_node(Node node) {
        Node background = Root.find(target);
        Sprite bg_sprite = background.Components[0];
        Sprite check_mark = Root.find(checkMark);
        string bg_sprite_name = "\"\"";
        string cross_sprite_name = "\"\"";

        if (bg_sprite.spriteFrame) {
            bg_sprite_name = "\"" + find_resource_by_uuid(bg_sprite.spriteFrame) + "\"";
        }

        if (check_mark.spriteFrame) {
            cross_sprite_name = "\"" + find_resource_by_uuid(check_mark.spriteFrame) + "\"";
        }

        = {
            "// cc.Toggle";
            "auto ", node.Name, " = ui::CheckBox::create(", bg_sprite_name, ", ", cross_sprite_name, ");";
            node.Name.selected = selected;
            node.Name.touchEnabled = true;
            node.Name.ignoreContentAdaptWithSize(false);
        }

        node.write_add_child();
        return true;
    }
};

class ToggleGroup : "cc.ToggleGroup" extends Item {
    bool allowedNoSelection : "allowSwitchOff";

    bool write_create_node(Node node) {
        = "auto ", node.Name, " = ui::RadioButtonGroup::create();";
        = node.Name.allowedNoSelection = allowedNoSelection;
        node.write_add_child();
        return true;
    }
};

class ScrollView : "cc.ScrollView" extends Item {
    Id content;
    bool horizontal;
    bool vertical;
    bool inertia;
    float brake;
    bool elastic;
    float bounceDuration;
    Id@ scrollEvents;
    bool cancelInnerEvents;
    Id horizontalScrollBar : "_N$horizontalScrollBar";
    Id verticalScrollBar : "_N$verticalScrollBar";
};

class ParticleSystem : "cc.ParticleSystem" extends Item {
    bool custom : "_custom";
    Uuid file : "_file";
    int srcBlendFactor : "_srcBlendFactor";
    int dstBlendFactor : "_dstBlendFactor";
    bool playOnLoad;
    bool autoRemoveOnFinish : "_autoRemoveOnFinish";
    int totalParticles : "_totalParticles";
    int duration : "_duration";
    int emissionRate : "_emissionRate";
    int life : "_life";
    int lifeVar : "_lifeVar";
    Color4B startColor : "_startColor";
    Color4B startColorVar : "_startColorVar";
    Color4B endColor : "_endColor";
    Color4B endColorVar : "_endColorVar";
    int angle : "_angle";
    int angleVar : "_angleVar";
    int startSize : "_startSize";
    int startSizeVar : "_startSizeVar";
    int endSize : "_endSize";
    int endSizeVar : "_endSizeVar";
    int startSpin : "_startSpin";
    int startSpinVar : "_startSpinVar";
    int endSpin : "_endSpin";
    int endSpinVar : "_endSpinVar";
    Vec2 sourcePos : "_sourcePos";
    Vec2 posVar : "_posVar";
    int positionType : "_positionType";
    int emitterMode : "_emitterMode";
    Vec2 gravity : "_gravity";
    int speed : "_speed";
    int speedVar : "_speedVar";
    int tangentialAccel : "_tangentialAccel";
    int tangentialAccelVar : "_tangentialAccelVar";
    int radialAccel : "_radialAccel";
    int radialAccelVar : "_radialAccelVar";
    bool rotationIsDir : "_rotationIsDir";
    int startRadius : "_startRadius";
    int startRadiusVar : "_startRadiusVar";
    int endRadius : "_endRadius";
    int endRadiusVar : "_endRadiusVar";
    int rotatePerS : "_rotatePerS";
    int rotatePerSVar : "_rotatePerSVar";
    bool preview : "_N$preview";
};

class Sprite : "cc.Sprite" extends Item {
    Uuid spriteFrame : "_spriteFrame";
    int type : "_type";
    int sizeMode : "_sizeMode";
    int fillType : "_fillType";
    Vec2 fillCenter : "_fillCenter";
    int fillStart : "_fillStart";
    int fillRange : "_fillRange";
    bool isTrimmedMode : "_isTrimmedMode";
    int srcBlendFactor : "_srcBlendFactor";
    int dstBlendFactor : "_dstBlendFactor";
    Uuid atlas : "_atlas";
};

class Skeleton : "sp.Skeleton" extends Item {
    bool paused : "_paused";
    string defaultSkin;
    string defaultAnimation;
    bool loop;
    bool premultipliedAlpha : "_premultipliedAlpha";
    Uuid skeletonData : "_N$skeletonData";
    int timeScale : "_N$timeScale";
    bool debugSlots : "_N$debugSlots";
    bool debugBones : "_N$debugBones";
};

class TileMap : "cc.TiledMap" extends Item {
    Uuid tmxFile : "_tmxFile";
};

class Mask : "cc.Mask" extends Item {
    int type : "_type";
    int segements : "_segements";
    Uuid spriteFrame : "_N$spriteFrame";
    float alphaThreshold : "_N$alphaThreshold";
    bool inverted : "_N$inverted";
};

class PageView : "cc.PageView" extends Item {
    Id content;
    bool horizontal;
    bool vertical;
    bool inertia;
    float brake;
    bool elastic;
    float bounceDuration;
    Id@ scrollEvents;
    bool cancelInnerEvents;
    float scrollThreshold;
    int autoPageTurningThreshold;
    float pageTurningEventTiming;
    Id@ pageEvents;
    int sizeMode : "_N$sizeMode";
    int direction : "_N$direction";
    Id indicator : "_N$indicator";
};

class Prefab : "cc.Prefab" {
    Item@ nodes;
};

class RichText : "cc.RichText" extends Item {
    string _string : "_N$string";
    int horizontalAlign : "_N$horizontalAlign";
    int fontSize : "_N$fontSize";
    Uuid font : "_N$font";
    int maxWidth : "_N$maxWidth";
    int lineHeight : "_N$lineHeight";
    Uuid imageAtlas : "_N$imageAtlas";
    bool handleTouchEvent : "_N$handleTouchEvent";
};

class VideoPlayer : "cc.VideoPlayer" extends Item {
    int resourceType : "_resourceType";
    string remoteURL : "_remoteURL";
    Uuid clip : "_clip";
    Id@ videoPlayerEvent;
    bool keepAspectRatio : "_N$keepAspectRatio";
    bool isFullscreen : "_N$isFullscreen";
};

class WebView : "cc.WebView" extends Item {
    bool useOriginalSize : "_useOriginalSize";
    string url : "_url";
    Id@ webviewEvents;
};

class ArmatureDisplay : "dragonBones.ArmatureDisplay" extends Item {
    string armatureName : "_armatureName";
    string animationName : "_animationName";
    int playTimes;
    Uuid dragonAsset : "_N$dragonAsset";
    Uuid dragonAtlasAsset : "_N$dragonAtlasAsset";
    int _defaultArmatureIndex : "_N$_defaultArmatureIndex";
    int _animationIndex : "_N$_animationIndex";
    int timeScale : "_N$timeScale";
    bool debugBones : "_N$debugBones";
};

class BoxCollider : "cc.BoxCollider" extends Item {
    Vec2 offset : "_offset";
    Size size : "_size";
};

class CircleCollider : "cc.CircleCollider" extends Item {
    Vec2 offset : "_offset";
    Vec2@ points;
};

class PolygonCollider : "cc.PolygonCollider" extends Item {
    Vec2 offset : "_offset";
    Size size : "_size";
};

class LabelOutline : "cc.LabelOutline" extends Item {
    Color4B color;
    float width;
};

class Layout : "cc.Layout" extends Item {
    Size layoutSize : "_layoutSize";
    int resize : "_resize";
    int layoutType : "_N$layoutType";
    int padding : "_N$padding";
    Size cellSize : "_N$cellSize";
    int startAxis : "_N$startAxis";
    int paddingLeft : "_N$paddingLeft";
    int paddingRight : "_N$paddingRight";
    int paddingTop : "_N$paddingTop";
    int paddingBottom : "_N$paddingBottom";
    int spacingX : "_N$spacingX";
    int spacingY : "_N$spacingY";
    int verticalDirection : "_N$verticalDirection";
    int horizontalDirection : "_N$horizontalDirection";
};

class MotionStreak : "cc.MotionStreak" extends Item {
    int fadeTime : "_fadeTime";
    int minSeg : "_minSeg";
    int stroke : "_stroke";
    Uuid texture : "_texture";
    Color4B color : "_color";
    bool fastMode : "_fastMode";
    bool preview : "_N$preview";
};

class PageViewIndicator : "cc.PageViewIndicator" extends Item
{
    string layout : "_layout";
    Id pageView : "_pageView";
    Id@ _indicators;
    Uuid spriteFrame;
    int direction;
    Size cellSize;
    int spacing;
};

class PrefabInfo : "cc.PrefabInfo" {
    Id root;
    Uuid asset;
    string fileId;
    bool sync;
};

class Scrollbar : "cc.Scrollbar" extends Item {
    Id scrollView : "_scrollView";
    bool touching : "_touching";
    int opacity : "_opacity";
    bool enableAutoHide;
    int autoHideTime;
    Id handle;
    int direction;
};

class Animation : "cc.Animation" extends Item {
    Uuid defaultClip : "_defaultClip";
    Uuid@ _clips;
    bool playOnLoad;
};

class Widget : "cc.Widget" extends Item {
    bool isAlignOnce;
    string target : "_target";
    int alignFlags : "_alignFlags";
    float left : "_left";
    float right : "_right";
    float top : "_top";
    float bottom : "_bottom";
    int verticalCenter : "_verticalCenter";
    int horizontalCenter : "_horizontalCenter";
    bool isAbsLeft : "_isAbsLeft";
    bool isAbsRight : "_isAbsRight";
    bool isAbsTop : "_isAbsTop";
    bool isAbsBottom : "_isAbsBottom";
    bool isAbsHorizontalCenter : "_isAbsHorizontalCenter";
    bool isAbsVerticalCenter : "_isAbsVerticalCenter";
    int originalWidth : "_originalWidth";
    int originalHeight : "_originalHeight";
};

class ClickEvent : "cc.ClickEvent" {
    Id target;
    string component;
    string handler;
    string customEventData;
};

class AnimationFrameInt {
    float frame;
    int value;
};

class AnimationFrameFloat {
    float frame;
    float value;
};

class AnimationFrameVec2 {
    float frame;
    Vec2 value;
};

class AnimationFramePosition {
    float frame;
    int@ value;
    int@ motionPath;
    string curve;
};

class AnimationFrameColor {
    float frame;
    Color4B value;
};

class AnimationFrameUuid {
    float frame;
    Uuid value;
};

class AnimationFrameBool {
    float frame;
    bool value;
};

class AnimationCurveProp {
    AnimationFrameInt@ rotation;
    AnimationFramePosition@ position;
    AnimationFrameFloat@ scaleX;
    AnimationFrameFloat@ scaleY;
    AnimationFrameInt@ width;
    AnimationFrameInt@ height;
    AnimationFrameColor@ color;
    AnimationFrameInt@ opacity;
    AnimationFrameFloat@ anchorX;
    AnimationFrameFloat@ anchorY;
    AnimationFrameFloat@ skewX;
    AnimationFrameFloat@ skewY;
};

class AnimationSpriteFrames {
    AnimationFrameBool@ enabled;
    AnimationFrameUuid@ spriteFrame;
    AnimationFrameInt@ fillType;
    AnimationFrameVec2@ fillCenter;
    AnimationFrameInt@ fillStart;
    AnimationFrameInt@ fillRange;
};

class AnimationComps {
    AnimationSpriteFrames sprite : "cc.Sprite";
};

class AnimationCurveData {
    AnimationCurveProp props;
    AnimationComps comps;
    Id@ event;
};

class TiledLayer : "cc.TiledLayer" extends Item {
};

class AnimationClip : "cc.AnimationClip" {
  float duration : "_duration";
  int sample;
  int speed;
  int wrapMode;
  AnimationCurveData curveData;
};
