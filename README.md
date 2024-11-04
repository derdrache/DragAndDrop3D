# Godot DragAndDrop3D plugin
 
A universal Drag and Drop System for Godot version 4.X

## 🌟 Highlights

- easy to use
- light weight

## 🚀 Usage
<img src="addons/DragAndDrop3D/dragIcon.png" width="16"/> DragAndDrop3D - Add it to your scene to activate the Drag and Drop System

<img src="addons/DragAndDrop3D/dragIcon.png" width="16"/> DraggingObject3D - This must be the Parent of your Object that you want to drag

### Add Script to DraggingObject3D
If you want to add a script on the DraggingObject3D, you have to remove the existing script.
The new script must have as extends DraggingObject3D and the ready function should start with super()

```
extends DraggingObject3D

func _ready():
    super()
```


## ⬇️ Installation
If you don't have a "addons" folder in your project tree:

    copy the "addons" folder in your project tree
    
elif you have a "addons" folder already:

    copy the "DragAndDrop3D" folder in your "addons" folder

At the end it should look like this:

<img src="documentation/images/plugin_installation_screen.png"/>

## 💭 Feedback and Contributing
You are always welcome to open issues for improvements or bugs:
https://github.com/derdrache/DragAndDrop3D/issues

or with a pull request to extend the code (there are no guidelines)
