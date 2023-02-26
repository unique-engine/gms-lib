# Unique Engine - Library for Game Maker Studio 2

This library allows to load and draw a 3D model previously exported through the [Unique Model Converter](https://github.com/unique-engine/model-converter).

**Example to load a model:**

```js
// Create event
model = ue_model_load("cat.unique");

// Draw event
model.draw()
```

## How to use

Drag and drop the `gms_lib.yymps` file into your project to import the scripts.

There are two scripts included to setup a basic 3D camera, mainly used to quickly test your model.
