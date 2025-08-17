# Heimdall Configuration Reference

This document provides a complete reference for all configuration options available in Heimdall quickshell.

**Schema Version**: 2.0.0


## Table of Contents

- [Overview](#overview)

- [Required Fields](#required-fields)

- [Modules](#modules)

  - [Appearance](#appearance)

  - [General](#general)

  - [Background](#background)

  - [Bar](#bar)

  - [Border](#border)

  - [Dashboard](#dashboard)

  - [Control Center](#control-center)

  - [Launcher](#launcher)

  - [Notifications](#notifications)

  - [Osd](#osd)

  - [Session](#session)

  - [Lock](#lock)

  - [Ui Components](#ui-components)

  - [Animation](#animation)

  - [Services Integration](#services-integration)

  - [Behavior](#behavior)

- [Validation Rules](#validation-rules)

- [Migration Guide](#migration-guide)

- [Best Practices](#best-practices)


## Overview

The Heimdall configuration system uses a JSON format with the following structure:

```json
{
  "version": "2.0.0",
  "modules": {
    // Module configurations
  }
}
```


## Required Fields

The following fields are required in every configuration:

- **version**: Configuration schema version (format: X.Y.Z)


## Modules


### Appearance

Configuration for appearance module


#### Properties


##### `rounding`

- **Type**: `string`

- **Default**: `"Rounding {}"`


##### `spacing`

- **Type**: `string`

- **Default**: `"Spacing {}"`


##### `padding`

- **Type**: `string`

- **Default**: `"Padding {}"`


##### `font`

- **Type**: `string`

- **Default**: `"FontStuff {}"`


##### `anim`

- **Type**: `string`

- **Default**: `"Anim {}"`


##### `transparency`

- **Type**: `string`

- **Default**: `"Transparency {}"`


##### `scale`

- **Type**: `number`

- **Default**: `1.0`


##### `small`

- **Type**: `integer`


##### `normal`

- **Type**: `integer`


##### `large`

- **Type**: `integer`


##### `full`

- **Type**: `integer`


##### `smaller`

- **Type**: `integer`


##### `larger`

- **Type**: `integer`


##### `sans`

- **Type**: `string`

- **Default**: `"IBM Plex Sans"`


##### `mono`

- **Type**: `string`

- **Default**: `"JetBrains Mono NF"`


##### `material`

- **Type**: `string`

- **Default**: `"Material Symbols Rounded"`


##### `extraLarge`

- **Type**: `integer`


##### `family`

- **Type**: `string`

- **Default**: `"FontFamily {}"`


##### `size`

- **Type**: `string`

- **Default**: `"FontSize {}"`


##### `expressiveFastSpatial`

- **Type**: `integer`


##### `expressiveDefaultSpatial`

- **Type**: `integer`


##### `expressiveEffects`

- **Type**: `integer`


##### `curves`

- **Type**: `string`

- **Default**: `"AnimCurves {}"`


##### `durations`

- **Type**: `string`

- **Default**: `"AnimDurations {}"`

- **Constraints**: min: 0, max: 10000


##### `enabled`

- **Type**: `boolean`

- **Default**: `False`


##### `base`

- **Type**: `number`

- **Default**: `0.85`


##### `layers`

- **Type**: `number`

- **Default**: `0.4`


#### Example

```json

{
  "modules": {
    "appearance": {
      "rounding": "Rounding {}",
      "spacing": "Spacing {}",
      "padding": "Padding {}",
      "font": "FontStuff {}",
      "anim": "Anim {}",
      "transparency": "Transparency {}",
      "scale": 1.0,
      "small": 0,
      "normal": 0,
      "large": 0,
      "full": 0,
      "smaller": 0,
      "larger": 0,
      "sans": "IBM Plex Sans",
      "mono": "JetBrains Mono NF",
      "material": "Material Symbols Rounded",
      "extraLarge": 0,
      "family": "FontFamily {}",
      "size": "FontSize {}",
      "expressiveFastSpatial": 0,
      "expressiveDefaultSpatial": 0,
      "expressiveEffects": 0,
      "curves": "AnimCurves {}",
      "durations": "AnimDurations {}",
      "enabled": false,
      "base": 0.85,
      "layers": 0.4
    }
  }
}
```


### General

Configuration for general module


#### Properties


##### `apps`

- **Type**: `string`

- **Default**: `"Apps {}"`


#### Example

```json

{
  "modules": {
    "general": {
      "apps": "Apps {}"
    }
  }
}
```


### Background

Configuration for background module


#### Properties


##### `enabled`

- **Type**: `boolean`

- **Default**: `True`


##### `desktopClock`

- **Type**: `string`

- **Default**: `"DesktopClock {}"`


#### Example

```json

{
  "modules": {
    "background": {
      "enabled": true,
      "desktopClock": "DesktopClock {}"
    }
  }
}
```


### Bar

Configuration for bar module


#### Properties


##### `persistent`

- **Type**: `boolean`

- **Default**: `True`


##### `showOnHover`

- **Type**: `boolean`

- **Default**: `True`


##### `dragThreshold`

- **Type**: `integer`

- **Default**: `20`


##### `workspaces`

- **Type**: `string`

- **Default**: `"Workspaces {}"`


##### `status`

- **Type**: `string`

- **Default**: `"Status {}"`


##### `sizes`

- **Type**: `string`

- **Default**: `"Sizes {}"`


##### `shown`

- **Type**: `integer`

- **Default**: `5`


##### `rounded`

- **Type**: `boolean`

- **Default**: `True`


##### `activeIndicator`

- **Type**: `boolean`

- **Default**: `True`


##### `occupiedBg`

- **Type**: `boolean`

- **Default**: `False`


##### `showWindows`

- **Type**: `boolean`

- **Default**: `True`


##### `activeTrail`

- **Type**: `boolean`

- **Default**: `False`


##### `label`

- **Type**: `string`

- **Default**: `"  "`


##### `occupiedLabel`

- **Type**: `string`

- **Default**: `"󰮯 "`


##### `activeLabel`

- **Type**: `string`

- **Default**: `"󰮯 "`


##### `showAudio`

- **Type**: `boolean`

- **Default**: `False`


##### `showKbLayout`

- **Type**: `boolean`

- **Default**: `False`


##### `showNetwork`

- **Type**: `boolean`

- **Default**: `True`


##### `showBluetooth`

- **Type**: `boolean`

- **Default**: `True`


##### `showBattery`

- **Type**: `boolean`

- **Default**: `True`


##### `innerHeight`

- **Type**: `integer`

- **Default**: `30`


##### `windowPreviewSize`

- **Type**: `integer`

- **Default**: `400`


##### `trayMenuWidth`

- **Type**: `integer`

- **Default**: `300`


##### `batteryWidth`

- **Type**: `integer`

- **Default**: `250`


##### `networkWidth`

- **Type**: `integer`

- **Default**: `320`


#### Example

```json

{
  "modules": {
    "bar": {
      "persistent": true,
      "showOnHover": true,
      "dragThreshold": 20,
      "workspaces": "Workspaces {}",
      "status": "Status {}",
      "sizes": "Sizes {}",
      "shown": 5,
      "rounded": true,
      "activeIndicator": true,
      "occupiedBg": false,
      "showWindows": true,
      "activeTrail": false,
      "label": "\uf444  ",
      "occupiedLabel": "\udb82\udfaf ",
      "activeLabel": "\udb82\udfaf ",
      "showAudio": false,
      "showKbLayout": false,
      "showNetwork": true,
      "showBluetooth": true,
      "showBattery": true,
      "innerHeight": 30,
      "windowPreviewSize": 400,
      "trayMenuWidth": 300,
      "batteryWidth": 250,
      "networkWidth": 320
    }
  }
}
```


### Border

Configuration for border module


#### Properties


##### `thickness`

- **Type**: `integer`


##### `rounding`

- **Type**: `integer`


#### Example

```json

{
  "modules": {
    "border": {
      "thickness": 0,
      "rounding": 0
    }
  }
}
```


### Dashboard

Configuration for dashboard module


#### Properties


##### `enabled`

- **Type**: `boolean`

- **Default**: `True`


##### `showOnHover`

- **Type**: `boolean`

- **Default**: `True`


##### `mediaUpdateInterval`

- **Type**: `integer`

- **Default**: `500`


##### `visualiserBars`

- **Type**: `integer`

- **Default**: `45`


##### `dragThreshold`

- **Type**: `integer`

- **Default**: `50`


##### `sizes`

- **Type**: `string`

- **Default**: `"Sizes {}"`


##### `tabIndicatorHeight`

- **Type**: `integer`

- **Default**: `3`


##### `tabIndicatorSpacing`

- **Type**: `integer`

- **Default**: `5`


##### `infoWidth`

- **Type**: `integer`

- **Default**: `200`


##### `infoIconSize`

- **Type**: `integer`

- **Default**: `25`


##### `dateTimeWidth`

- **Type**: `integer`

- **Default**: `110`


##### `mediaWidth`

- **Type**: `integer`

- **Default**: `200`


##### `mediaProgressSweep`

- **Type**: `integer`

- **Default**: `180`


##### `mediaProgressThickness`

- **Type**: `integer`

- **Default**: `8`


##### `resourceProgessThickness`

- **Type**: `integer`

- **Default**: `10`


##### `weatherWidth`

- **Type**: `integer`

- **Default**: `250`


##### `mediaCoverArtSize`

- **Type**: `integer`

- **Default**: `150`


##### `mediaVisualiserSize`

- **Type**: `integer`

- **Default**: `80`


##### `resourceSize`

- **Type**: `integer`

- **Default**: `200`


#### Example

```json

{
  "modules": {
    "dashboard": {
      "enabled": true,
      "showOnHover": true,
      "mediaUpdateInterval": 500,
      "visualiserBars": 45,
      "dragThreshold": 50,
      "sizes": "Sizes {}",
      "tabIndicatorHeight": 3,
      "tabIndicatorSpacing": 5,
      "infoWidth": 200,
      "infoIconSize": 25,
      "dateTimeWidth": 110,
      "mediaWidth": 200,
      "mediaProgressSweep": 180,
      "mediaProgressThickness": 8,
      "resourceProgessThickness": 10,
      "weatherWidth": 250,
      "mediaCoverArtSize": 150,
      "mediaVisualiserSize": 80,
      "resourceSize": 200
    }
  }
}
```


### Control Center

Configuration for controlCenter module


#### Properties


##### `sizes`

- **Type**: `string`

- **Default**: `"Sizes {}"`


##### `heightMult`

- **Type**: `number`

- **Default**: `0.7`


##### `ratio`

- **Type**: `number`

- **Default**: `16.0`


#### Example

```json

{
  "modules": {
    "controlCenter": {
      "sizes": "Sizes {}",
      "heightMult": 0.7,
      "ratio": 16.0
    }
  }
}
```


### Launcher

Configuration for launcher module


#### Properties


##### `enabled`

- **Type**: `boolean`

- **Default**: `True`


##### `maxShown`

- **Type**: `integer`

- **Default**: `8`


##### `maxWallpapers`

- **Type**: `integer`

- **Default**: `9`


##### `actionPrefix`

- **Type**: `string`

- **Default**: `">"`


##### `enableDangerousActions`

- **Type**: `boolean`

- **Default**: `False`


##### `dragThreshold`

- **Type**: `integer`

- **Default**: `50`


##### `vimKeybinds`

- **Type**: `boolean`

- **Default**: `True`


##### `useFuzzy`

- **Type**: `string`

- **Default**: `"UseFuzzy {}"`


##### `sizes`

- **Type**: `string`

- **Default**: `"Sizes {}"`


##### `apps`

- **Type**: `boolean`

- **Default**: `False`


##### `actions`

- **Type**: `boolean`

- **Default**: `False`


##### `schemes`

- **Type**: `boolean`

- **Default**: `False`


##### `variants`

- **Type**: `boolean`

- **Default**: `False`


##### `wallpapers`

- **Type**: `boolean`

- **Default**: `False`


##### `itemWidth`

- **Type**: `integer`

- **Default**: `600`


##### `itemHeight`

- **Type**: `integer`

- **Default**: `57`


##### `wallpaperWidth`

- **Type**: `integer`

- **Default**: `280`


##### `wallpaperHeight`

- **Type**: `integer`

- **Default**: `200`


#### Example

```json

{
  "modules": {
    "launcher": {
      "enabled": true,
      "maxShown": 8,
      "maxWallpapers": 9,
      "actionPrefix": ">",
      "enableDangerousActions": false,
      "dragThreshold": 50,
      "vimKeybinds": true,
      "useFuzzy": "UseFuzzy {}",
      "sizes": "Sizes {}",
      "apps": false,
      "actions": false,
      "schemes": false,
      "variants": false,
      "wallpapers": false,
      "itemWidth": 600,
      "itemHeight": 57,
      "wallpaperWidth": 280,
      "wallpaperHeight": 200
    }
  }
}
```


### Notifications

Configuration for notifications module


#### Properties


##### `expire`

- **Type**: `boolean`

- **Default**: `True`


##### `defaultExpireTimeout`

- **Type**: `integer`

- **Default**: `5000`


##### `clearThreshold`

- **Type**: `number`

- **Default**: `0.3`


##### `expandThreshold`

- **Type**: `integer`

- **Default**: `20`


##### `actionOnClick`

- **Type**: `boolean`

- **Default**: `False`


##### `sizes`

- **Type**: `string`

- **Default**: `"Sizes {}"`


##### `width`

- **Type**: `integer`

- **Default**: `400`


##### `image`

- **Type**: `integer`

- **Default**: `41`


##### `badge`

- **Type**: `integer`

- **Default**: `20`


#### Example

```json

{
  "modules": {
    "notifications": {
      "expire": true,
      "defaultExpireTimeout": 5000,
      "clearThreshold": 0.3,
      "expandThreshold": 20,
      "actionOnClick": false,
      "sizes": "Sizes {}",
      "width": 400,
      "image": 41,
      "badge": 20
    }
  }
}
```


### Osd

Configuration for osd module


#### Properties


##### `enabled`

- **Type**: `boolean`

- **Default**: `True`


##### `hideDelay`

- **Type**: `integer`

- **Default**: `2000`


##### `sizes`

- **Type**: `string`

- **Default**: `"Sizes {}"`


##### `sliderWidth`

- **Type**: `integer`

- **Default**: `30`


##### `sliderHeight`

- **Type**: `integer`

- **Default**: `150`


#### Example

```json

{
  "modules": {
    "osd": {
      "enabled": true,
      "hideDelay": 2000,
      "sizes": "Sizes {}",
      "sliderWidth": 30,
      "sliderHeight": 150
    }
  }
}
```


### Session

Configuration for session module


#### Properties


##### `enabled`

- **Type**: `boolean`

- **Default**: `True`


##### `dragThreshold`

- **Type**: `integer`

- **Default**: `30`


##### `vimKeybinds`

- **Type**: `boolean`

- **Default**: `True`


##### `commands`

- **Type**: `string`

- **Default**: `"Commands {}"`


##### `sizes`

- **Type**: `string`

- **Default**: `"Sizes {}"`


##### `button`

- **Type**: `integer`

- **Default**: `80`


#### Example

```json

{
  "modules": {
    "session": {
      "enabled": true,
      "dragThreshold": 30,
      "vimKeybinds": true,
      "commands": "Commands {}",
      "sizes": "Sizes {}",
      "button": 80
    }
  }
}
```


### Lock

Configuration for lock module


#### Properties


##### `maxNotifs`

- **Type**: `integer`

- **Default**: `5`


##### `sizes`

- **Type**: `string`

- **Default**: `"Sizes {}"`


##### `border`

- **Type**: `integer`

- **Default**: `100`


##### `clockWidth`

- **Type**: `integer`

- **Default**: `800`


##### `clockHeight`

- **Type**: `integer`

- **Default**: `200`


##### `inputWidth`

- **Type**: `integer`

- **Default**: `600`


##### `inputHeight`

- **Type**: `integer`

- **Default**: `200`


##### `faceSize`

- **Type**: `integer`

- **Default**: `100`


##### `weatherWidth`

- **Type**: `integer`

- **Default**: `400`


##### `weatherHeight`

- **Type**: `integer`

- **Default**: `100`


##### `mediaWidth`

- **Type**: `integer`

- **Default**: `600`


##### `mediaWidthSmall`

- **Type**: `integer`

- **Default**: `450`


##### `mediaHeight`

- **Type**: `integer`

- **Default**: `170`


##### `mediaHeightSmall`

- **Type**: `integer`

- **Default**: `150`


##### `mediaCoverSize`

- **Type**: `integer`

- **Default**: `150`


##### `mediaCoverSizeSmall`

- **Type**: `integer`

- **Default**: `120`


##### `mediaCoverBorder`

- **Type**: `integer`

- **Default**: `3`


##### `largeScreenWidth`

- **Type**: `integer`

- **Default**: `2560`


##### `smallScreenWidth`

- **Type**: `integer`

- **Default**: `1080`


##### `buttonsWidth`

- **Type**: `integer`

- **Default**: `400`


##### `buttonsWidthSmall`

- **Type**: `integer`

- **Default**: `300`


#### Example

```json

{
  "modules": {
    "lock": {
      "maxNotifs": 5,
      "sizes": "Sizes {}",
      "border": 100,
      "clockWidth": 800,
      "clockHeight": 200,
      "inputWidth": 600,
      "inputHeight": 200,
      "faceSize": 100,
      "weatherWidth": 400,
      "weatherHeight": 100,
      "mediaWidth": 600,
      "mediaWidthSmall": 450,
      "mediaHeight": 170,
      "mediaHeightSmall": 150,
      "mediaCoverSize": 150,
      "mediaCoverSizeSmall": 120,
      "mediaCoverBorder": 3,
      "largeScreenWidth": 2560,
      "smallScreenWidth": 1080,
      "buttonsWidth": 400,
      "buttonsWidthSmall": 300
    }
  }
}
```


### Ui Components

Configuration for uiComponents module


#### Properties


##### `switch_`

- **Type**: `object`


**Nested Properties:**


##### `widthRatio`

- **Type**: `number`

- **Description**: Width to height ratio

- **Default**: `1.7`


##### `thumbWidthRatio`

- **Type**: `number`

- **Description**: Thumb width ratio when pressed

- **Default**: `1.3`


##### `iconStartX`

- **Type**: `number`

- **Description**: Icon start X position ratio

- **Default**: `0.15`


##### `iconEndX`

- **Type**: `number`

- **Description**: Icon end X position ratio

- **Default**: `0.85`


##### `strokeWidth`

- **Type**: `integer`

- **Description**: Icon stroke width

- **Default**: `2`


##### `slider`

- **Type**: `object`


**Nested Properties:**


##### `handleSize`

- **Type**: `integer`

- **Description**: Slider handle size

- **Default**: `20`


##### `trackHeight`

- **Type**: `integer`

- **Description**: Slider track height

- **Default**: `4`


##### `handleScale`

- **Type**: `number`

- **Description**: Handle scale when pressed

- **Default**: `1.2`


##### `scrollBar`

- **Type**: `object`


**Nested Properties:**


##### `width`

- **Type**: `integer`

- **Description**: ScrollBar width

- **Default**: `8`


##### `minHeight`

- **Type**: `integer`

- **Description**: Minimum thumb height

- **Default**: `20`


##### `hoverScale`

- **Type**: `number`

- **Description**: Scale factor on hover

- **Default**: `1.5`


##### `margin`

- **Type**: `integer`

- **Description**: Margin from edge

- **Default**: `2`


##### `busyIndicator`

- **Type**: `object`


**Nested Properties:**


##### `defaultSize`

- **Type**: `integer`

- **Description**: Default size

- **Default**: `48`


##### `strokeWidth`

- **Type**: `integer`

- **Description**: Stroke width

- **Default**: `4`


##### `rotationDuration`

- **Type**: `integer`

- **Description**: Full rotation duration in ms

- **Default**: `1000`


##### `radioButton`

- **Type**: `object`


**Nested Properties:**


##### `indicatorSize`

- **Type**: `integer`

- **Description**: Indicator size

- **Default**: `20`


##### `innerCircleRatio`

- **Type**: `integer`

- **Description**: Inner circle size ratio


##### `rippleSize`

- **Type**: `integer`

- **Description**: Ripple effect size

- **Default**: `40`


##### `spinBox`

- **Type**: `object`


**Nested Properties:**


##### `buttonWidth`

- **Type**: `integer`

- **Description**: Up/down button width

- **Default**: `32`


##### `stepSize`

- **Type**: `integer`

- **Description**: Default step size

- **Default**: `1`


##### `accelerationDelay`

- **Type**: `integer`

- **Description**: Delay before acceleration

- **Default**: `300`


##### `textField`

- **Type**: `object`


**Nested Properties:**


##### `cursorWidth`

- **Type**: `integer`

- **Description**: Cursor width

- **Default**: `2`


##### `cursorBlinkRate`

- **Type**: `integer`

- **Description**: Cursor blink rate in ms

- **Default**: `500`


##### `selectionHandleSize`

- **Type**: `integer`

- **Description**: Touch selection handle size

- **Default**: `20`


##### `toolTip`

- **Type**: `object`


**Nested Properties:**


##### `delay`

- **Type**: `integer`

- **Description**: Show delay in ms

- **Default**: `500`


##### `timeout`

- **Type**: `integer`

- **Description**: Auto-hide timeout in ms

- **Default**: `5000`


##### `maxWidth`

- **Type**: `integer`

- **Description**: Maximum width

- **Default**: `300`


##### `offset`

- **Type**: `integer`

- **Description**: Offset from cursor

- **Default**: `8`


##### `dialog`

- **Type**: `object`


**Nested Properties:**


##### `minWidth`

- **Type**: `integer`

- **Description**: Minimum dialog width

- **Default**: `300`


##### `minHeight`

- **Type**: `integer`

- **Description**: Minimum dialog height

- **Default**: `200`


##### `buttonSpacing`

- **Type**: `integer`

- **Description**: Button spacing

- **Default**: `8`


##### `contentMargin`

- **Type**: `integer`

- **Description**: Content margin

- **Default**: `24`


##### `list`

- **Type**: `object`


**Nested Properties:**


##### `itemHeight`

- **Type**: `integer`

- **Description**: Default item height

- **Default**: `48`


##### `itemSpacing`

- **Type**: `integer`

- **Description**: Item spacing

- **Default**: `0`


##### `sectionHeight`

- **Type**: `integer`

- **Description**: Section header height

- **Default**: `32`


##### `alternatingRows`

- **Type**: `boolean`

- **Description**: Alternating row colors

- **Default**: `False`


##### `grid`

- **Type**: `object`


**Nested Properties:**


##### `cellWidth`

- **Type**: `integer`

- **Description**: Default cell width

- **Default**: `100`


##### `cellHeight`

- **Type**: `integer`

- **Description**: Default cell height

- **Default**: `100`


##### `spacing`

- **Type**: `integer`

- **Description**: Grid spacing

- **Default**: `8`


##### `columns`

- **Type**: `integer`

- **Description**: Default column count

- **Default**: `4`


##### `tab`

- **Type**: `object`


**Nested Properties:**


##### `height`

- **Type**: `integer`

- **Description**: Tab height

- **Default**: `48`


##### `minWidth`

- **Type**: `integer`

- **Description**: Minimum tab width

- **Default**: `90`


##### `maxWidth`

- **Type**: `integer`

- **Description**: Maximum tab width

- **Default**: `360`


##### `indicatorHeight`

- **Type**: `integer`

- **Description**: Selected indicator height

- **Default**: `3`


##### `menu`

- **Type**: `object`


**Nested Properties:**


##### `itemHeight`

- **Type**: `integer`

- **Description**: Menu item height

- **Default**: `36`


##### `minWidth`

- **Type**: `integer`

- **Description**: Minimum menu width

- **Default**: `200`


##### `maxWidth`

- **Type**: `integer`

- **Description**: Maximum menu width

- **Default**: `400`


##### `submenuDelay`

- **Type**: `integer`

- **Description**: Submenu show delay

- **Default**: `300`


##### `iconSize`

- **Type**: `integer`

- **Description**: Menu icon size

- **Default**: `20`


##### `separatorHeight`

- **Type**: `integer`

- **Description**: Separator height

- **Default**: `1`


##### `progress`

- **Type**: `object`


**Nested Properties:**


##### `barHeight`

- **Type**: `integer`

- **Description**: Progress bar height

- **Default**: `4`


##### `circularSize`

- **Type**: `integer`

- **Description**: Circular progress size

- **Default**: `48`


##### `strokeWidth`

- **Type**: `integer`

- **Description**: Circular stroke width

- **Default**: `4`


##### `indeterminate`

- **Type**: `boolean`

- **Description**: Indeterminate mode

- **Default**: `False`


##### `badge`

- **Type**: `object`


**Nested Properties:**


##### `size`

- **Type**: `integer`

- **Description**: Badge size

- **Default**: `20`


##### `fontSize`

- **Type**: `integer`

- **Description**: Badge font size

- **Default**: `12`


##### `maxCount`

- **Type**: `integer`

- **Description**: Maximum count to display

- **Default**: `99`


##### `overflowText`

- **Type**: `string`

- **Description**: Text for overflow

- **Default**: `"99+"`


##### `chip`

- **Type**: `object`


**Nested Properties:**


##### `height`

- **Type**: `integer`

- **Description**: Chip height

- **Default**: `32`


##### `iconSize`

- **Type**: `integer`

- **Description**: Chip icon size

- **Default**: `18`


##### `deleteIconSize`

- **Type**: `integer`

- **Description**: Delete icon size

- **Default**: `18`


##### `spacing`

- **Type**: `integer`

- **Description**: Internal spacing

- **Default**: `8`


##### `avatar`

- **Type**: `object`


**Nested Properties:**


##### `smallSize`

- **Type**: `integer`

- **Description**: Small avatar size

- **Default**: `32`


##### `mediumSize`

- **Type**: `integer`

- **Description**: Medium avatar size

- **Default**: `48`


##### `largeSize`

- **Type**: `integer`

- **Description**: Large avatar size

- **Default**: `64`


##### `borderWidth`

- **Type**: `integer`

- **Description**: Border width

- **Default**: `2`


##### `divider`

- **Type**: `object`


**Nested Properties:**


##### `thickness`

- **Type**: `integer`

- **Description**: Divider thickness

- **Default**: `1`


##### `margin`

- **Type**: `integer`

- **Description**: Margin around divider

- **Default**: `8`


##### `opacity`

- **Type**: `number`

- **Description**: Divider opacity

- **Default**: `0.12`


##### `fab`

- **Type**: `object`


**Nested Properties:**


##### `size`

- **Type**: `integer`

- **Description**: FAB size

- **Default**: `56`


##### `miniSize`

- **Type**: `integer`

- **Description**: Mini FAB size

- **Default**: `40`


##### `iconSize`

- **Type**: `integer`

- **Description**: Icon size

- **Default**: `24`


##### `extendedPadding`

- **Type**: `integer`

- **Description**: Extended FAB padding

- **Default**: `16`


##### `widthRatio`

- **Type**: `number`

- **Default**: `1.7`


##### `thumbWidthRatio`

- **Type**: `number`

- **Default**: `1.3`


##### `iconStartX`

- **Type**: `number`

- **Default**: `0.15`


##### `iconEndX`

- **Type**: `number`

- **Default**: `0.85`


##### `strokeWidth`

- **Type**: `integer`

- **Default**: `2`


##### `handleSize`

- **Type**: `integer`

- **Default**: `20`


##### `trackHeight`

- **Type**: `integer`

- **Default**: `4`


##### `handleScale`

- **Type**: `number`

- **Default**: `1.2`


##### `width`

- **Type**: `integer`

- **Default**: `8`


##### `minHeight`

- **Type**: `integer`

- **Default**: `20`


##### `hoverScale`

- **Type**: `number`

- **Default**: `1.5`


##### `margin`

- **Type**: `integer`

- **Default**: `2`


##### `defaultSize`

- **Type**: `integer`

- **Default**: `48`


##### `rotationDuration`

- **Type**: `integer`

- **Default**: `1000`


##### `indicatorSize`

- **Type**: `integer`

- **Default**: `20`


##### `innerCircleRatio`

- **Type**: `integer`


##### `rippleSize`

- **Type**: `integer`

- **Default**: `40`


##### `buttonWidth`

- **Type**: `integer`

- **Default**: `32`


##### `stepSize`

- **Type**: `integer`

- **Default**: `1`


##### `accelerationDelay`

- **Type**: `integer`

- **Default**: `300`


##### `cursorWidth`

- **Type**: `integer`

- **Default**: `2`


##### `cursorBlinkRate`

- **Type**: `integer`

- **Default**: `500`


##### `selectionHandleSize`

- **Type**: `integer`

- **Default**: `20`


##### `delay`

- **Type**: `integer`

- **Default**: `500`


##### `timeout`

- **Type**: `integer`

- **Default**: `5000`


##### `maxWidth`

- **Type**: `integer`

- **Default**: `300`


##### `offset`

- **Type**: `integer`

- **Default**: `8`


##### `minWidth`

- **Type**: `integer`

- **Default**: `300`


##### `buttonSpacing`

- **Type**: `integer`

- **Default**: `8`


##### `contentMargin`

- **Type**: `integer`

- **Default**: `24`


##### `itemHeight`

- **Type**: `integer`

- **Default**: `48`


##### `itemSpacing`

- **Type**: `integer`

- **Default**: `0`


##### `sectionHeight`

- **Type**: `integer`

- **Default**: `32`


##### `alternatingRows`

- **Type**: `boolean`

- **Default**: `False`


##### `cellWidth`

- **Type**: `integer`

- **Default**: `100`


##### `cellHeight`

- **Type**: `integer`

- **Default**: `100`


##### `spacing`

- **Type**: `integer`

- **Default**: `8`


##### `columns`

- **Type**: `integer`

- **Default**: `4`


##### `height`

- **Type**: `integer`

- **Default**: `48`


##### `indicatorHeight`

- **Type**: `integer`

- **Default**: `3`


##### `submenuDelay`

- **Type**: `integer`

- **Default**: `300`


##### `iconSize`

- **Type**: `integer`

- **Default**: `20`


##### `separatorHeight`

- **Type**: `integer`

- **Default**: `1`


##### `barHeight`

- **Type**: `integer`

- **Default**: `4`


##### `circularSize`

- **Type**: `integer`

- **Default**: `48`


##### `indeterminate`

- **Type**: `boolean`

- **Default**: `False`


##### `size`

- **Type**: `integer`

- **Default**: `20`


##### `fontSize`

- **Type**: `integer`

- **Default**: `12`


##### `maxCount`

- **Type**: `integer`

- **Default**: `99`


##### `overflowText`

- **Type**: `string`

- **Default**: `"99+"`


##### `deleteIconSize`

- **Type**: `integer`

- **Default**: `18`


##### `smallSize`

- **Type**: `integer`

- **Default**: `32`


##### `mediumSize`

- **Type**: `integer`

- **Default**: `48`


##### `largeSize`

- **Type**: `integer`

- **Default**: `64`


##### `borderWidth`

- **Type**: `integer`

- **Default**: `2`


##### `thickness`

- **Type**: `integer`

- **Default**: `1`


##### `opacity`

- **Type**: `number`

- **Default**: `0.12`


##### `miniSize`

- **Type**: `integer`

- **Default**: `40`


##### `extendedPadding`

- **Type**: `integer`

- **Default**: `16`


#### Example

```json

{
  "modules": {
    "uiComponents": {
      "switch_": {},
      "slider": {},
      "scrollBar": {},
      "busyIndicator": {},
      "radioButton": {},
      "spinBox": {},
      "textField": {},
      "toolTip": {},
      "dialog": {},
      "list": {},
      "grid": {},
      "tab": {},
      "menu": {},
      "progress": {},
      "badge": {},
      "chip": {},
      "avatar": {},
      "divider": {},
      "fab": {},
      "widthRatio": 1.7,
      "thumbWidthRatio": 1.3,
      "iconStartX": 0.15,
      "iconEndX": 0.85,
      "strokeWidth": 2,
      "handleSize": 20,
      "trackHeight": 4,
      "handleScale": 1.2,
      "width": 8,
      "minHeight": 20,
      "hoverScale": 1.5,
      "margin": 2,
      "defaultSize": 48,
      "rotationDuration": 1000,
      "indicatorSize": 20,
      "innerCircleRatio": 0,
      "rippleSize": 40,
      "buttonWidth": 32,
      "stepSize": 1,
      "accelerationDelay": 300,
      "cursorWidth": 2,
      "cursorBlinkRate": 500,
      "selectionHandleSize": 20,
      "delay": 500,
      "timeout": 5000,
      "maxWidth": 300,
      "offset": 8,
      "minWidth": 300,
      "buttonSpacing": 8,
      "contentMargin": 24,
      "itemHeight": 48,
      "itemSpacing": 0,
      "sectionHeight": 32,
      "alternatingRows": false,
      "cellWidth": 100,
      "cellHeight": 100,
      "spacing": 8,
      "columns": 4,
      "height": 48,
      "indicatorHeight": 3,
      "submenuDelay": 300,
      "iconSize": 20,
      "separatorHeight": 1,
      "barHeight": 4,
      "circularSize": 48,
      "indeterminate": false,
      "size": 20,
      "fontSize": 12,
      "maxCount": 99,
      "overflowText": "99+",
      "deleteIconSize": 18,
      "smallSize": 32,
      "mediumSize": 48,
      "largeSize": 64,
      "borderWidth": 2,
      "thickness": 1,
      "opacity": 0.12,
      "miniSize": 40,
      "extendedPadding": 16
    }
  }
}
```


### Animation

Configuration for animation module


#### Properties


##### `durations`

- **Type**: `object`


**Nested Properties:**


##### `instant`

- **Type**: `integer`

- **Default**: `0`


##### `fast`

- **Type**: `integer`

- **Default**: `150`


##### `normal`

- **Type**: `integer`

- **Default**: `300`


##### `slow`

- **Type**: `integer`

- **Default**: `500`


##### `verySlow`

- **Type**: `integer`

- **Default**: `800`


##### `expressiveDefaultSpatial`

- **Type**: `integer`

- **Default**: `400`


##### `expressiveDefaultNonSpatial`

- **Type**: `integer`

- **Description**: Component-specific durations

- **Default**: `300`


##### `fadeIn`

- **Type**: `integer`

- **Default**: `200`


##### `fadeOut`

- **Type**: `integer`

- **Default**: `150`


##### `slideIn`

- **Type**: `integer`

- **Default**: `300`


##### `slideOut`

- **Type**: `integer`

- **Default**: `250`


##### `expand`

- **Type**: `integer`

- **Default**: `350`


##### `collapse`

- **Type**: `integer`

- **Default**: `300`


##### `ripple`

- **Type**: `integer`

- **Default**: `600`


##### `hover`

- **Type**: `integer`

- **Default**: `150`


##### `focus`

- **Type**: `integer`

- **Default**: `200`


##### `curves`

- **Type**: `object`


**Nested Properties:**


##### `emphasized`

- **Type**: `object`

- **Default**: `"[0.2, 0.0, 0.0, 1.0]"`


##### `emphasizedDecelerate`

- **Type**: `object`

- **Default**: `"[0.05, 0.7, 0.1, 1.0]"`


##### `emphasizedAccelerate`

- **Type**: `object`

- **Default**: `"[0.3, 0.0, 0.8, 0.15]"`


##### `standard`

- **Type**: `object`

- **Default**: `"[0.2, 0.0, 0.0, 1.0]"`


##### `standardDecelerate`

- **Type**: `object`

- **Default**: `"[0.0, 0.0, 0.0, 1.0]"`


##### `standardAccelerate`

- **Type**: `object`

- **Default**: `"[0.3, 0.0, 1.0, 1.0]"`


##### `expressiveDefaultSpatial`

- **Type**: `object`

- **Default**: `"[0.2, 0.0, 0.0, 1.0]"`


##### `expressiveDefaultNonSpatial`

- **Type**: `object`

- **Description**: Additional easing options

- **Default**: `"[0.2, 0.0, 0.0, 1.0]"`


##### `linear`

- **Type**: `integer`


##### `inQuad`

- **Type**: `integer`


##### `outQuad`

- **Type**: `integer`


##### `inOutQuad`

- **Type**: `integer`


##### `inCubic`

- **Type**: `integer`


##### `outCubic`

- **Type**: `integer`


##### `inOutCubic`

- **Type**: `integer`


##### `inQuart`

- **Type**: `integer`


##### `outQuart`

- **Type**: `integer`


##### `inOutQuart`

- **Type**: `integer`


##### `inQuint`

- **Type**: `integer`


##### `outQuint`

- **Type**: `integer`


##### `inOutQuint`

- **Type**: `integer`


##### `inExpo`

- **Type**: `integer`


##### `outExpo`

- **Type**: `integer`


##### `inOutExpo`

- **Type**: `integer`


##### `inCirc`

- **Type**: `integer`


##### `outCirc`

- **Type**: `integer`


##### `inOutCirc`

- **Type**: `integer`


##### `inElastic`

- **Type**: `integer`


##### `outElastic`

- **Type**: `integer`


##### `inOutElastic`

- **Type**: `integer`


##### `inBack`

- **Type**: `integer`


##### `outBack`

- **Type**: `integer`


##### `inOutBack`

- **Type**: `integer`


##### `inBounce`

- **Type**: `integer`


##### `outBounce`

- **Type**: `integer`


##### `inOutBounce`

- **Type**: `integer`


##### `transitions`

- **Type**: `object`


**Nested Properties:**


##### `page`

- **Type**: `string`

- **Default**: `"QtObject {"`


##### `type`

- **Type**: `string`

- **Description**: "slide", "fade", "scale", "flip", "none"

- **Default**: `"slide"`


##### `duration`

- **Type**: `integer`

- **Default**: `300`


##### `easing`

- **Type**: `object`

- **Default**: `"curves.emphasized"`


##### `direction`

- **Type**: `string`

- **Description**: "horizontal", "vertical"

- **Default**: `"horizontal"`


##### `modal`

- **Type**: `object`


**Nested Properties:**


##### `type`

- **Type**: `string`

- **Description**: "fade", "scale", "fade-scale", "slide-up", "none"

- **Default**: `"fade-scale"`


##### `duration`

- **Type**: `integer`

- **Default**: `250`


##### `easing`

- **Type**: `object`

- **Default**: `"curves.emphasizedDecelerate"`


##### `scaleFrom`

- **Type**: `number`

- **Default**: `0.9`


##### `scaleTo`

- **Type**: `number`

- **Default**: `1.0`


##### `listItem`

- **Type**: `object`


**Nested Properties:**


##### `type`

- **Type**: `string`

- **Description**: "fade", "slide", "fade-slide", "none"

- **Default**: `"fade-slide"`


##### `duration`

- **Type**: `integer`

- **Default**: `200`


##### `stagger`

- **Type**: `integer`

- **Description**: Delay between items

- **Default**: `50`


##### `easing`

- **Type**: `object`

- **Default**: `"curves.standardDecelerate"`


##### `tab`

- **Type**: `object`


**Nested Properties:**


##### `type`

- **Type**: `string`

- **Description**: "slide", "fade", "none"

- **Default**: `"slide"`


##### `duration`

- **Type**: `integer`

- **Default**: `300`


##### `easing`

- **Type**: `object`

- **Default**: `"curves.standard"`


##### `tooltip`

- **Type**: `object`


**Nested Properties:**


##### `type`

- **Type**: `string`

- **Description**: "fade", "scale", "fade-scale", "none"

- **Default**: `"fade"`


##### `fadeInDuration`

- **Type**: `integer`

- **Default**: `150`


##### `fadeOutDuration`

- **Type**: `integer`

- **Default**: `75`


##### `easing`

- **Type**: `object`

- **Default**: `"curves.standardDecelerate"`


##### `menu`

- **Type**: `object`


**Nested Properties:**


##### `type`

- **Type**: `string`

- **Description**: "fade", "scale", "fade-scale", "slide", "none"

- **Default**: `"fade-scale"`


##### `duration`

- **Type**: `integer`

- **Default**: `200`


##### `easing`

- **Type**: `object`

- **Default**: `"curves.emphasizedDecelerate"`


##### `scaleOrigin`

- **Type**: `number`

- **Default**: `0.95`


##### `spring`

- **Type**: `object`


**Nested Properties:**


##### `damping`

- **Type**: `number`

- **Default**: `0.8`


##### `mass`

- **Type**: `number`

- **Default**: `1.0`


##### `stiffness`

- **Type**: `number`

- **Default**: `100.0`


##### `velocity`

- **Type**: `number`

- **Default**: `0.0`


##### `epsilon`

- **Type**: `number`

- **Default**: `0.01`


##### `modulus`

- **Type**: `integer`

- **Default**: `0`


##### `parallax`

- **Type**: `object`


**Nested Properties:**


##### `enabled`

- **Type**: `boolean`

- **Default**: `True`


##### `factor`

- **Type**: `number`

- **Description**: Parallax movement factor

- **Default**: `0.5`


##### `duration`

- **Type**: `integer`

- **Default**: `300`


##### `easing`

- **Type**: `object`

- **Default**: `"curves.standard"`


##### `ripple`

- **Type**: `object`


**Nested Properties:**


##### `enabled`

- **Type**: `boolean`

- **Default**: `True`


##### `duration`

- **Type**: `integer`

- **Default**: `600`


##### `maxRadius`

- **Type**: `number`

- **Default**: `100.0`


##### `opacity`

- **Type**: `number`

- **Default**: `0.12`


##### `easing`

- **Type**: `object`

- **Default**: `"curves.standardDecelerate"`


##### `hover`

- **Type**: `object`


**Nested Properties:**


##### `enabled`

- **Type**: `boolean`

- **Default**: `True`


##### `duration`

- **Type**: `integer`

- **Default**: `150`


##### `scale`

- **Type**: `number`

- **Default**: `1.05`


##### `opacity`

- **Type**: `number`

- **Default**: `0.08`


##### `easing`

- **Type**: `object`

- **Default**: `"curves.standard"`


##### `focus`

- **Type**: `object`


**Nested Properties:**


##### `enabled`

- **Type**: `boolean`

- **Default**: `True`


##### `duration`

- **Type**: `integer`

- **Default**: `200`


##### `glowRadius`

- **Type**: `integer`

- **Default**: `4`


##### `glowOpacity`

- **Type**: `number`

- **Default**: `0.12`


##### `easing`

- **Type**: `object`

- **Default**: `"curves.emphasizedDecelerate"`


##### `scroll`

- **Type**: `object`


**Nested Properties:**


##### `smoothScrolling`

- **Type**: `boolean`

- **Default**: `True`


##### `duration`

- **Type**: `integer`

- **Default**: `250`


##### `easing`

- **Type**: `object`

- **Default**: `"curves.standardDecelerate"`


##### `bounceEffect`

- **Type**: `boolean`

- **Default**: `True`


##### `bounceDamping`

- **Type**: `number`

- **Default**: `0.5`


##### `loading`

- **Type**: `object`


**Nested Properties:**


##### `type`

- **Type**: `string`

- **Description**: "spinner", "dots", "pulse", "skeleton"

- **Default**: `"spinner"`


##### `duration`

- **Type**: `integer`

- **Default**: `1000`


##### `dotCount`

- **Type**: `integer`

- **Default**: `3`


##### `dotDelay`

- **Type**: `integer`

- **Default**: `200`


##### `enabled`

- **Type**: `boolean`

- **Default**: `True`


##### `speedMultiplier`

- **Type**: `number`

- **Default**: `1.0`


##### `instant`

- **Type**: `integer`

- **Default**: `0`


##### `fast`

- **Type**: `integer`

- **Default**: `150`


##### `normal`

- **Type**: `integer`

- **Default**: `300`


##### `slow`

- **Type**: `integer`

- **Default**: `500`


##### `verySlow`

- **Type**: `integer`

- **Default**: `800`


##### `expressiveDefaultSpatial`

- **Type**: `integer`

- **Default**: `400`


##### `expressiveDefaultNonSpatial`

- **Type**: `integer`

- **Default**: `300`


##### `fadeIn`

- **Type**: `integer`

- **Default**: `200`


##### `fadeOut`

- **Type**: `integer`

- **Default**: `150`


##### `slideIn`

- **Type**: `integer`

- **Default**: `300`


##### `slideOut`

- **Type**: `integer`

- **Default**: `250`


##### `expand`

- **Type**: `integer`

- **Default**: `350`


##### `collapse`

- **Type**: `integer`

- **Default**: `300`


##### `emphasized`

- **Type**: `object`

- **Default**: `"[0.2, 0.0, 0.0, 1.0]"`


##### `emphasizedDecelerate`

- **Type**: `object`

- **Default**: `"[0.05, 0.7, 0.1, 1.0]"`


##### `emphasizedAccelerate`

- **Type**: `object`

- **Default**: `"[0.3, 0.0, 0.8, 0.15]"`


##### `standard`

- **Type**: `object`

- **Default**: `"[0.2, 0.0, 0.0, 1.0]"`


##### `standardDecelerate`

- **Type**: `object`

- **Default**: `"[0.0, 0.0, 0.0, 1.0]"`


##### `standardAccelerate`

- **Type**: `object`

- **Default**: `"[0.3, 0.0, 1.0, 1.0]"`


##### `linear`

- **Type**: `integer`


##### `inQuad`

- **Type**: `integer`


##### `outQuad`

- **Type**: `integer`


##### `inOutQuad`

- **Type**: `integer`


##### `inCubic`

- **Type**: `integer`


##### `outCubic`

- **Type**: `integer`


##### `inOutCubic`

- **Type**: `integer`


##### `inQuart`

- **Type**: `integer`


##### `outQuart`

- **Type**: `integer`


##### `inOutQuart`

- **Type**: `integer`


##### `inQuint`

- **Type**: `integer`


##### `outQuint`

- **Type**: `integer`


##### `inOutQuint`

- **Type**: `integer`


##### `inExpo`

- **Type**: `integer`


##### `outExpo`

- **Type**: `integer`


##### `inOutExpo`

- **Type**: `integer`


##### `inCirc`

- **Type**: `integer`


##### `outCirc`

- **Type**: `integer`


##### `inOutCirc`

- **Type**: `integer`


##### `inElastic`

- **Type**: `integer`


##### `outElastic`

- **Type**: `integer`


##### `inOutElastic`

- **Type**: `integer`


##### `inBack`

- **Type**: `integer`


##### `outBack`

- **Type**: `integer`


##### `inOutBack`

- **Type**: `integer`


##### `inBounce`

- **Type**: `integer`


##### `outBounce`

- **Type**: `integer`


##### `inOutBounce`

- **Type**: `integer`


##### `page`

- **Type**: `string`

- **Default**: `"QtObject {"`


##### `type`

- **Type**: `string`

- **Default**: `"slide"`


##### `duration`

- **Type**: `integer`

- **Default**: `300`


##### `easing`

- **Type**: `object`

- **Default**: `"curves.emphasized"`


##### `direction`

- **Type**: `string`

- **Default**: `"horizontal"`


##### `scaleFrom`

- **Type**: `number`

- **Default**: `0.9`


##### `scaleTo`

- **Type**: `number`

- **Default**: `1.0`


##### `stagger`

- **Type**: `integer`

- **Default**: `50`


##### `fadeInDuration`

- **Type**: `integer`

- **Default**: `150`


##### `fadeOutDuration`

- **Type**: `integer`

- **Default**: `75`


##### `scaleOrigin`

- **Type**: `number`

- **Default**: `0.95`


##### `damping`

- **Type**: `number`

- **Default**: `0.8`


##### `mass`

- **Type**: `number`

- **Default**: `1.0`


##### `stiffness`

- **Type**: `number`

- **Default**: `100.0`


##### `velocity`

- **Type**: `number`

- **Default**: `0.0`


##### `epsilon`

- **Type**: `number`

- **Default**: `0.01`


##### `modulus`

- **Type**: `integer`

- **Default**: `0`


##### `factor`

- **Type**: `number`

- **Default**: `0.5`


##### `maxRadius`

- **Type**: `number`

- **Default**: `100.0`


##### `opacity`

- **Type**: `number`

- **Default**: `0.12`


##### `scale`

- **Type**: `number`

- **Default**: `1.05`


##### `glowRadius`

- **Type**: `integer`

- **Default**: `4`


##### `glowOpacity`

- **Type**: `number`

- **Default**: `0.12`


##### `smoothScrolling`

- **Type**: `boolean`

- **Default**: `True`


##### `bounceEffect`

- **Type**: `boolean`

- **Default**: `True`


##### `bounceDamping`

- **Type**: `number`

- **Default**: `0.5`


##### `dotCount`

- **Type**: `integer`

- **Default**: `3`


##### `dotDelay`

- **Type**: `integer`

- **Default**: `200`


#### Example

```json

{
  "modules": {
    "animation": {
      "durations": {},
      "curves": {},
      "transitions": {},
      "modal": {},
      "listItem": {},
      "tab": {},
      "tooltip": {},
      "menu": {},
      "spring": {},
      "parallax": {},
      "ripple": {},
      "hover": {},
      "focus": {},
      "scroll": {},
      "loading": {},
      "enabled": true,
      "speedMultiplier": 1.0,
      "instant": 0,
      "fast": 150,
      "normal": 300,
      "slow": 500,
      "verySlow": 800,
      "expressiveDefaultSpatial": 400,
      "expressiveDefaultNonSpatial": 300,
      "fadeIn": 200,
      "fadeOut": 150,
      "slideIn": 300,
      "slideOut": 250,
      "expand": 350,
      "collapse": 300,
      "emphasized": "[0.2, 0.0, 0.0, 1.0]",
      "emphasizedDecelerate": "[0.05, 0.7, 0.1, 1.0]",
      "emphasizedAccelerate": "[0.3, 0.0, 0.8, 0.15]",
      "standard": "[0.2, 0.0, 0.0, 1.0]",
      "standardDecelerate": "[0.0, 0.0, 0.0, 1.0]",
      "standardAccelerate": "[0.3, 0.0, 1.0, 1.0]",
      "linear": 0,
      "inQuad": 0,
      "outQuad": 0,
      "inOutQuad": 0,
      "inCubic": 0,
      "outCubic": 0,
      "inOutCubic": 0,
      "inQuart": 0,
      "outQuart": 0,
      "inOutQuart": 0,
      "inQuint": 0,
      "outQuint": 0,
      "inOutQuint": 0,
      "inExpo": 0,
      "outExpo": 0,
      "inOutExpo": 0,
      "inCirc": 0,
      "outCirc": 0,
      "inOutCirc": 0,
      "inElastic": 0,
      "outElastic": 0,
      "inOutElastic": 0,
      "inBack": 0,
      "outBack": 0,
      "inOutBack": 0,
      "inBounce": 0,
      "outBounce": 0,
      "inOutBounce": 0,
      "page": "QtObject {",
      "type": "slide",
      "duration": 300,
      "easing": "curves.emphasized",
      "direction": "horizontal",
      "scaleFrom": 0.9,
      "scaleTo": 1.0,
      "stagger": 50,
      "fadeInDuration": 150,
      "fadeOutDuration": 75,
      "scaleOrigin": 0.95,
      "damping": 0.8,
      "mass": 1.0,
      "stiffness": 100.0,
      "velocity": 0.0,
      "epsilon": 0.01,
      "modulus": 0,
      "factor": 0.5,
      "maxRadius": 100.0,
      "opacity": 0.12,
      "scale": 1.05,
      "glowRadius": 4,
      "glowOpacity": 0.12,
      "smoothScrolling": true,
      "bounceEffect": true,
      "bounceDamping": 0.5,
      "dotCount": 3,
      "dotDelay": 200
    }
  }
}
```


### Services Integration

Configuration for servicesIntegration module


#### Properties


##### `api`

- **Type**: `object`


**Nested Properties:**


##### `baseUrl`

- **Type**: `string`

- **Description**: localhost:8080"

- **Default**: `""http:"`


##### `timeout`

- **Type**: `integer`

- **Description**: Request timeout in ms

- **Default**: `30000`


##### `retryCount`

- **Type**: `integer`

- **Default**: `3`


##### `retryDelay`

- **Type**: `integer`

- **Description**: Delay between retries in ms

- **Default**: `1000`


##### `enableCache`

- **Type**: `boolean`

- **Default**: `True`


##### `cacheExpiry`

- **Type**: `integer`

- **Description**: Cache expiry in ms (5 minutes)

- **Default**: `300000`


##### `auth`

- **Type**: `string`

- **Default**: `"QtObject {"`


##### `type`

- **Type**: `string`

- **Description**: "none", "bearer", "api-key", "basic"

- **Default**: `"none"`


##### `token`

- **Type**: `string`


##### `apiKey`

- **Type**: `string`


##### `username`

- **Type**: `string`


##### `password`

- **Type**: `string`


##### `weather`

- **Type**: `object`


**Nested Properties:**


##### `enabled`

- **Type**: `boolean`

- **Default**: `True`


##### `provider`

- **Type**: `string`

- **Description**: "openweathermap", "weatherapi", "meteo"

- **Default**: `"openweathermap"`


##### `apiKey`

- **Type**: `string`


##### `location`

- **Type**: `string`

- **Description**: "auto" or specific location

- **Default**: `"auto"`


##### `units`

- **Type**: `string`

- **Description**: "metric", "imperial"

- **Default**: `"metric"`


##### `updateInterval`

- **Type**: `integer`

- **Description**: 30 minutes

- **Default**: `1800000`


##### `retryInterval`

- **Type**: `integer`

- **Description**: 1 minute on error

- **Default**: `60000`


##### `showAlerts`

- **Type**: `boolean`

- **Default**: `True`


##### `maxForecastDays`

- **Type**: `integer`

- **Default**: `5`


##### `network`

- **Type**: `object`


**Nested Properties:**


##### `enabled`

- **Type**: `boolean`

- **Default**: `True`


##### `pingInterval`

- **Type**: `integer`

- **Description**: Network check interval in ms

- **Default**: `5000`


##### `pingTarget`

- **Type**: `string`

- **Default**: `"8.8.8.8"`


##### `pingTimeout`

- **Type**: `integer`

- **Default**: `3000`


##### `monitorBandwidth`

- **Type**: `boolean`

- **Default**: `True`


##### `bandwidthUpdateInterval`

- **Type**: `integer`

- **Default**: `1000`


##### `showIPAddress`

- **Type**: `boolean`

- **Default**: `True`


##### `showHostname`

- **Type**: `boolean`

- **Default**: `True`


##### `systemMonitor`

- **Type**: `object`


**Nested Properties:**


##### `enabled`

- **Type**: `boolean`

- **Default**: `True`


##### `updateInterval`

- **Type**: `integer`

- **Description**: Update interval in ms

- **Default**: `1000`


##### `monitorCPU`

- **Type**: `boolean`

- **Default**: `True`


##### `monitorMemory`

- **Type**: `boolean`

- **Default**: `True`


##### `monitorDisk`

- **Type**: `boolean`

- **Default**: `True`


##### `monitorGPU`

- **Type**: `boolean`

- **Default**: `False`


##### `monitorTemperature`

- **Type**: `boolean`

- **Default**: `True`


##### `monitorBattery`

- **Type**: `boolean`

- **Default**: `True`


##### `historySize`

- **Type**: `integer`

- **Description**: Number of data points to keep

- **Default**: `60`


##### `cpuWarningThreshold`

- **Type**: `number`

- **Description**: Percentage

- **Default**: `80.0`


##### `memoryWarningThreshold`

- **Type**: `number`

- **Description**: Percentage

- **Default**: `90.0`


##### `temperatureWarningThreshold`

- **Type**: `number`

- **Description**: Celsius

- **Default**: `80.0`


##### `mediaPlayer`

- **Type**: `object`


**Nested Properties:**


##### `enabled`

- **Type**: `boolean`

- **Default**: `True`


##### `preferredPlayer`

- **Type**: `string`

- **Description**: "auto", "spotify", "mpd", "vlc", etc.

- **Default**: `"auto"`


##### `showAlbumArt`

- **Type**: `boolean`

- **Default**: `True`


##### `albumArtSize`

- **Type**: `integer`

- **Default**: `64`


##### `showProgress`

- **Type**: `boolean`

- **Default**: `True`


##### `updateInterval`

- **Type**: `integer`

- **Default**: `500`


##### `enableControls`

- **Type**: `boolean`

- **Default**: `True`


##### `enableGestures`

- **Type**: `boolean`

- **Default**: `True`


##### `seekStep`

- **Type**: `integer`

- **Description**: Seek step in ms

- **Default**: `5000`


##### `notifications`

- **Type**: `object`


**Nested Properties:**


##### `enabled`

- **Type**: `boolean`

- **Default**: `True`


##### `maxNotifications`

- **Type**: `integer`

- **Default**: `10`


##### `defaultTimeout`

- **Type**: `integer`

- **Description**: Default notification timeout in ms

- **Default**: `5000`


##### `groupByApp`

- **Type**: `boolean`

- **Default**: `True`


##### `showActions`

- **Type**: `boolean`

- **Default**: `True`


##### `playSound`

- **Type**: `boolean`

- **Default**: `True`


##### `soundFile`

- **Type**: `string`


##### `showOnLockScreen`

- **Type**: `boolean`

- **Default**: `False`


##### `position`

- **Type**: `string`

- **Description**: "top-left", "top-right", "bottom-left", "bottom-right"

- **Default**: `"top-right"`


##### `spacing`

- **Type**: `integer`

- **Default**: `8`


##### `width`

- **Type**: `integer`

- **Default**: `350`


##### `persistentHistory`

- **Type**: `boolean`

- **Default**: `True`


##### `historySize`

- **Type**: `integer`

- **Default**: `50`


##### `bluetooth`

- **Type**: `object`


**Nested Properties:**


##### `enabled`

- **Type**: `boolean`

- **Default**: `True`


##### `scanInterval`

- **Type**: `integer`

- **Description**: Device scan interval in ms

- **Default**: `10000`


##### `scanDuration`

- **Type**: `integer`

- **Description**: Scan duration in ms

- **Default**: `5000`


##### `autoConnect`

- **Type**: `boolean`

- **Default**: `True`


##### `trustedDevices`

- **Type**: `object`

- **Description**: List of MAC addresses


##### `showBatteryLevel`

- **Type**: `boolean`

- **Default**: `True`


##### `notifyOnConnect`

- **Type**: `boolean`

- **Default**: `True`


##### `notifyOnDisconnect`

- **Type**: `boolean`

- **Default**: `True`


##### `audio`

- **Type**: `object`


**Nested Properties:**


##### `enabled`

- **Type**: `boolean`

- **Default**: `True`


##### `defaultSink`

- **Type**: `string`

- **Default**: `"@DEFAULT_SINK@"`


##### `defaultSource`

- **Type**: `string`

- **Default**: `"@DEFAULT_SOURCE@"`


##### `volumeStep`

- **Type**: `integer`

- **Description**: Volume change step percentage

- **Default**: `5`


##### `showVolumeOSD`

- **Type**: `boolean`

- **Default**: `True`


##### `osdTimeout`

- **Type**: `integer`

- **Default**: `1500`


##### `muteOnLock`

- **Type**: `boolean`

- **Default**: `False`


##### `pauseOnLock`

- **Type**: `boolean`

- **Default**: `True`


##### `updateInterval`

- **Type**: `integer`

- **Default**: `100`


##### `calendar`

- **Type**: `object`


**Nested Properties:**


##### `enabled`

- **Type**: `boolean`

- **Default**: `True`


##### `provider`

- **Type**: `string`

- **Description**: "local", "google", "outlook", "caldav"

- **Default**: `"local"`


##### `calendarUrl`

- **Type**: `string`


##### `username`

- **Type**: `string`


##### `password`

- **Type**: `string`


##### `syncInterval`

- **Type**: `integer`

- **Description**: 5 minutes

- **Default**: `300000`


##### `eventLookahead`

- **Type**: `integer`

- **Description**: Days to look ahead

- **Default**: `7`


##### `showAllDayEvents`

- **Type**: `boolean`

- **Default**: `True`


##### `showDeclinedEvents`

- **Type**: `boolean`

- **Default**: `False`


##### `notifyUpcoming`

- **Type**: `boolean`

- **Default**: `True`


##### `notifyMinutesBefore`

- **Type**: `integer`

- **Default**: `15`


##### `email`

- **Type**: `object`


**Nested Properties:**


##### `enabled`

- **Type**: `boolean`

- **Default**: `False`


##### `provider`

- **Type**: `string`

- **Description**: "imap", "gmail", "outlook"

- **Default**: `"imap"`


##### `server`

- **Type**: `string`


##### `port`

- **Type**: `integer`

- **Default**: `993`


##### `ssl`

- **Type**: `boolean`

- **Default**: `True`


##### `username`

- **Type**: `string`


##### `password`

- **Type**: `string`


##### `checkInterval`

- **Type**: `integer`

- **Description**: 5 minutes

- **Default**: `300000`


##### `notifyNewMail`

- **Type**: `boolean`

- **Default**: `True`


##### `maxPreviewLength`

- **Type**: `integer`

- **Default**: `100`


##### `folders`

- **Type**: `object`

- **Default**: `"["INBOX"]"`


##### `fileWatcher`

- **Type**: `object`


**Nested Properties:**


##### `enabled`

- **Type**: `boolean`

- **Default**: `True`


##### `watchPaths`

- **Type**: `object`

- **Description**: Paths to watch


##### `recursive`

- **Type**: `boolean`

- **Default**: `True`


##### `notifyOnChange`

- **Type**: `boolean`

- **Default**: `True`


##### `debounceDelay`

- **Type**: `integer`

- **Description**: Debounce file change events

- **Default**: `500`


##### `commands`

- **Type**: `object`


**Nested Properties:**


##### `enabled`

- **Type**: `boolean`

- **Default**: `True`


##### `defaultTimeout`

- **Type**: `integer`

- **Description**: Default command timeout in ms

- **Default**: `10000`


##### `logOutput`

- **Type**: `boolean`

- **Default**: `False`


##### `notifyOnError`

- **Type**: `boolean`

- **Default**: `True`


##### `environment`

- **Type**: `object`

- **Default**: `"{"`


##### `websocket`

- **Type**: `object`


**Nested Properties:**


##### `enabled`

- **Type**: `boolean`

- **Default**: `False`


##### `url`

- **Type**: `string`

- **Description**: localhost:8080/ws"

- **Default**: `""ws:"`


##### `autoReconnect`

- **Type**: `boolean`

- **Default**: `True`


##### `reconnectInterval`

- **Type**: `integer`

- **Default**: `5000`


##### `pingInterval`

- **Type**: `integer`

- **Default**: `30000`


##### `pingTimeout`

- **Type**: `integer`

- **Default**: `5000`


##### `maxReconnectAttempts`

- **Type**: `integer`

- **Default**: `10`


##### `database`

- **Type**: `object`


**Nested Properties:**


##### `enabled`

- **Type**: `boolean`

- **Default**: `True`


##### `type`

- **Type**: `string`

- **Description**: "sqlite", "mysql", "postgresql"

- **Default**: `"sqlite"`


##### `host`

- **Type**: `string`

- **Default**: `"localhost"`


##### `port`

- **Type**: `integer`

- **Default**: `3306`


##### `name`

- **Type**: `string`

- **Default**: `"heimdall"`


##### `username`

- **Type**: `string`


##### `password`

- **Type**: `string`


##### `connectionPoolSize`

- **Type**: `integer`

- **Default**: `5`


##### `queryTimeout`

- **Type**: `integer`

- **Default**: `5000`


##### `backup`

- **Type**: `object`


**Nested Properties:**


##### `enabled`

- **Type**: `boolean`

- **Default**: `True`


##### `autoBackup`

- **Type**: `boolean`

- **Default**: `True`


##### `backupInterval`

- **Type**: `integer`

- **Description**: 24 hours

- **Default**: `86400000`


##### `maxBackups`

- **Type**: `integer`

- **Default**: `10`


##### `compressBackups`

- **Type**: `boolean`

- **Default**: `True`


##### `encryptBackups`

- **Type**: `boolean`

- **Default**: `False`


##### `encryptionKey`

- **Type**: `string`


##### `baseUrl`

- **Type**: `string`

- **Default**: `""http:"`


##### `timeout`

- **Type**: `integer`

- **Default**: `30000`


##### `retryCount`

- **Type**: `integer`

- **Default**: `3`


##### `retryDelay`

- **Type**: `integer`

- **Default**: `1000`


##### `enableCache`

- **Type**: `boolean`

- **Default**: `True`


##### `cacheExpiry`

- **Type**: `integer`

- **Default**: `300000`


##### `auth`

- **Type**: `string`

- **Default**: `"QtObject {"`


##### `type`

- **Type**: `string`

- **Default**: `"none"`


##### `token`

- **Type**: `string`


##### `apiKey`

- **Type**: `string`


##### `username`

- **Type**: `string`


##### `password`

- **Type**: `string`


##### `enabled`

- **Type**: `boolean`

- **Default**: `True`


##### `provider`

- **Type**: `string`

- **Default**: `"openweathermap"`


##### `location`

- **Type**: `string`

- **Default**: `"auto"`


##### `units`

- **Type**: `string`

- **Default**: `"metric"`


##### `updateInterval`

- **Type**: `integer`

- **Default**: `1800000`


##### `retryInterval`

- **Type**: `integer`

- **Default**: `60000`


##### `showAlerts`

- **Type**: `boolean`

- **Default**: `True`


##### `maxForecastDays`

- **Type**: `integer`

- **Default**: `5`


##### `pingInterval`

- **Type**: `integer`

- **Default**: `5000`


##### `pingTarget`

- **Type**: `string`

- **Default**: `"8.8.8.8"`


##### `pingTimeout`

- **Type**: `integer`

- **Default**: `3000`


##### `monitorBandwidth`

- **Type**: `boolean`

- **Default**: `True`


##### `bandwidthUpdateInterval`

- **Type**: `integer`

- **Default**: `1000`


##### `showIPAddress`

- **Type**: `boolean`

- **Default**: `True`


##### `showHostname`

- **Type**: `boolean`

- **Default**: `True`


##### `monitorCPU`

- **Type**: `boolean`

- **Default**: `True`


##### `monitorMemory`

- **Type**: `boolean`

- **Default**: `True`


##### `monitorDisk`

- **Type**: `boolean`

- **Default**: `True`


##### `monitorGPU`

- **Type**: `boolean`

- **Default**: `False`


##### `monitorTemperature`

- **Type**: `boolean`

- **Default**: `True`


##### `monitorBattery`

- **Type**: `boolean`

- **Default**: `True`


##### `historySize`

- **Type**: `integer`

- **Default**: `60`


##### `cpuWarningThreshold`

- **Type**: `number`

- **Default**: `80.0`


##### `memoryWarningThreshold`

- **Type**: `number`

- **Default**: `90.0`


##### `temperatureWarningThreshold`

- **Type**: `number`

- **Default**: `80.0`


##### `preferredPlayer`

- **Type**: `string`

- **Default**: `"auto"`


##### `showAlbumArt`

- **Type**: `boolean`

- **Default**: `True`


##### `albumArtSize`

- **Type**: `integer`

- **Default**: `64`


##### `showProgress`

- **Type**: `boolean`

- **Default**: `True`


##### `enableControls`

- **Type**: `boolean`

- **Default**: `True`


##### `enableGestures`

- **Type**: `boolean`

- **Default**: `True`


##### `seekStep`

- **Type**: `integer`

- **Default**: `5000`


##### `maxNotifications`

- **Type**: `integer`

- **Default**: `10`


##### `defaultTimeout`

- **Type**: `integer`

- **Default**: `5000`


##### `groupByApp`

- **Type**: `boolean`

- **Default**: `True`


##### `showActions`

- **Type**: `boolean`

- **Default**: `True`


##### `playSound`

- **Type**: `boolean`

- **Default**: `True`


##### `soundFile`

- **Type**: `string`


##### `showOnLockScreen`

- **Type**: `boolean`

- **Default**: `False`


##### `position`

- **Type**: `string`

- **Default**: `"top-right"`


##### `spacing`

- **Type**: `integer`

- **Default**: `8`


##### `width`

- **Type**: `integer`

- **Default**: `350`


##### `persistentHistory`

- **Type**: `boolean`

- **Default**: `True`


##### `scanInterval`

- **Type**: `integer`

- **Default**: `10000`


##### `scanDuration`

- **Type**: `integer`

- **Default**: `5000`


##### `autoConnect`

- **Type**: `boolean`

- **Default**: `True`


##### `trustedDevices`

- **Type**: `object`


##### `showBatteryLevel`

- **Type**: `boolean`

- **Default**: `True`


##### `notifyOnConnect`

- **Type**: `boolean`

- **Default**: `True`


##### `notifyOnDisconnect`

- **Type**: `boolean`

- **Default**: `True`


##### `defaultSink`

- **Type**: `string`

- **Default**: `"@DEFAULT_SINK@"`


##### `defaultSource`

- **Type**: `string`

- **Default**: `"@DEFAULT_SOURCE@"`


##### `volumeStep`

- **Type**: `integer`

- **Default**: `5`


##### `showVolumeOSD`

- **Type**: `boolean`

- **Default**: `True`


##### `osdTimeout`

- **Type**: `integer`

- **Default**: `1500`


##### `muteOnLock`

- **Type**: `boolean`

- **Default**: `False`


##### `pauseOnLock`

- **Type**: `boolean`

- **Default**: `True`


##### `calendarUrl`

- **Type**: `string`


##### `syncInterval`

- **Type**: `integer`

- **Default**: `300000`


##### `eventLookahead`

- **Type**: `integer`

- **Default**: `7`


##### `showAllDayEvents`

- **Type**: `boolean`

- **Default**: `True`


##### `showDeclinedEvents`

- **Type**: `boolean`

- **Default**: `False`


##### `notifyUpcoming`

- **Type**: `boolean`

- **Default**: `True`


##### `notifyMinutesBefore`

- **Type**: `integer`

- **Default**: `15`


##### `server`

- **Type**: `string`


##### `port`

- **Type**: `integer`

- **Default**: `993`


##### `ssl`

- **Type**: `boolean`

- **Default**: `True`


##### `checkInterval`

- **Type**: `integer`

- **Default**: `300000`


##### `notifyNewMail`

- **Type**: `boolean`

- **Default**: `True`


##### `maxPreviewLength`

- **Type**: `integer`

- **Default**: `100`


##### `folders`

- **Type**: `object`

- **Default**: `"["INBOX"]"`


##### `watchPaths`

- **Type**: `object`


##### `recursive`

- **Type**: `boolean`

- **Default**: `True`


##### `notifyOnChange`

- **Type**: `boolean`

- **Default**: `True`


##### `debounceDelay`

- **Type**: `integer`

- **Default**: `500`


##### `ignorePatterns`

- **Type**: `object`

- **Default**: `"["*.tmp", "*.swp", ".git"`


##### `shell`

- **Type**: `string`


##### `logOutput`

- **Type**: `boolean`

- **Default**: `False`


##### `notifyOnError`

- **Type**: `boolean`

- **Default**: `True`


##### `environment`

- **Type**: `object`


##### `url`

- **Type**: `string`

- **Default**: `""ws:"`


##### `autoReconnect`

- **Type**: `boolean`

- **Default**: `True`


##### `reconnectInterval`

- **Type**: `integer`

- **Default**: `5000`


##### `maxReconnectAttempts`

- **Type**: `integer`

- **Default**: `10`


##### `path`

- **Type**: `string`

- **Default**: `""~"`


##### `host`

- **Type**: `string`

- **Default**: `"localhost"`


##### `name`

- **Type**: `string`

- **Default**: `"heimdall"`


##### `connectionPoolSize`

- **Type**: `integer`

- **Default**: `5`


##### `queryTimeout`

- **Type**: `integer`

- **Default**: `5000`


##### `autoBackup`

- **Type**: `boolean`

- **Default**: `True`


##### `backupInterval`

- **Type**: `integer`

- **Default**: `86400000`


##### `backupPath`

- **Type**: `string`

- **Default**: `""~"`


##### `maxBackups`

- **Type**: `integer`

- **Default**: `10`


##### `compressBackups`

- **Type**: `boolean`

- **Default**: `True`


##### `encryptBackups`

- **Type**: `boolean`

- **Default**: `False`


##### `encryptionKey`

- **Type**: `string`


#### Example

```json

{
  "modules": {
    "servicesIntegration": {
      "api": {},
      "weather": {},
      "network": {},
      "systemMonitor": {},
      "mediaPlayer": {},
      "notifications": {},
      "bluetooth": {},
      "audio": {},
      "calendar": {},
      "email": {},
      "fileWatcher": {},
      "commands": {},
      "websocket": {},
      "database": {},
      "backup": {},
      "baseUrl": "\"http:",
      "timeout": 30000,
      "retryCount": 3,
      "retryDelay": 1000,
      "enableCache": true,
      "cacheExpiry": 300000,
      "auth": "QtObject {",
      "type": "none",
      "token": "example",
      "apiKey": "example",
      "username": "example",
      "password": "example",
      "enabled": true,
      "provider": "openweathermap",
      "location": "auto",
      "units": "metric",
      "updateInterval": 1800000,
      "retryInterval": 60000,
      "showAlerts": true,
      "maxForecastDays": 5,
      "pingInterval": 5000,
      "pingTarget": "8.8.8.8",
      "pingTimeout": 3000,
      "monitorBandwidth": true,
      "bandwidthUpdateInterval": 1000,
      "showIPAddress": true,
      "showHostname": true,
      "monitorCPU": true,
      "monitorMemory": true,
      "monitorDisk": true,
      "monitorGPU": false,
      "monitorTemperature": true,
      "monitorBattery": true,
      "historySize": 60,
      "cpuWarningThreshold": 80.0,
      "memoryWarningThreshold": 90.0,
      "temperatureWarningThreshold": 80.0,
      "preferredPlayer": "auto",
      "showAlbumArt": true,
      "albumArtSize": 64,
      "showProgress": true,
      "enableControls": true,
      "enableGestures": true,
      "seekStep": 5000,
      "maxNotifications": 10,
      "defaultTimeout": 5000,
      "groupByApp": true,
      "showActions": true,
      "playSound": true,
      "soundFile": "example",
      "showOnLockScreen": false,
      "position": "top-right",
      "spacing": 8,
      "width": 350,
      "persistentHistory": true,
      "scanInterval": 10000,
      "scanDuration": 5000,
      "autoConnect": true,
      "trustedDevices": {},
      "showBatteryLevel": true,
      "notifyOnConnect": true,
      "notifyOnDisconnect": true,
      "defaultSink": "@DEFAULT_SINK@",
      "defaultSource": "@DEFAULT_SOURCE@",
      "volumeStep": 5,
      "showVolumeOSD": true,
      "osdTimeout": 1500,
      "muteOnLock": false,
      "pauseOnLock": true,
      "calendarUrl": "example",
      "syncInterval": 300000,
      "eventLookahead": 7,
      "showAllDayEvents": true,
      "showDeclinedEvents": false,
      "notifyUpcoming": true,
      "notifyMinutesBefore": 15,
      "server": "example",
      "port": 993,
      "ssl": true,
      "checkInterval": 300000,
      "notifyNewMail": true,
      "maxPreviewLength": 100,
      "folders": "[\"INBOX\"]",
      "watchPaths": {},
      "recursive": true,
      "notifyOnChange": true,
      "debounceDelay": 500,
      "ignorePatterns": "[\"*.tmp\", \"*.swp\", \".git",
      "shell": "example",
      "logOutput": false,
      "notifyOnError": true,
      "environment": {},
      "url": "\"ws:",
      "autoReconnect": true,
      "reconnectInterval": 5000,
      "maxReconnectAttempts": 10,
      "path": "\"~",
      "host": "localhost",
      "name": "heimdall",
      "connectionPoolSize": 5,
      "queryTimeout": 5000,
      "autoBackup": true,
      "backupInterval": 86400000,
      "backupPath": "\"~",
      "maxBackups": 10,
      "compressBackups": true,
      "encryptBackups": false,
      "encryptionKey": "example"
    }
  }
}
```


### Behavior

Configuration for behavior module


#### Properties


##### `interaction`

- **Type**: `object`


**Nested Properties:**


##### `click`

- **Type**: `string`

- **Default**: `"QtObject {"`


##### `singleClickDelay`

- **Type**: `integer`

- **Description**: Max delay for single click

- **Default**: `250`


##### `doubleClickInterval`

- **Type**: `integer`

- **Description**: Max interval between clicks for double-click

- **Default**: `400`


##### `longPressDelay`

- **Type**: `integer`

- **Description**: Delay for long press

- **Default**: `500`


##### `clickRadius`

- **Type**: `integer`

- **Description**: Movement tolerance in pixels

- **Default**: `5`


##### `vibrateFeedback`

- **Type**: `boolean`

- **Description**: Haptic feedback on click

- **Default**: `False`


##### `drag`

- **Type**: `object`


**Nested Properties:**


##### `enabled`

- **Type**: `boolean`

- **Default**: `True`


##### `threshold`

- **Type**: `integer`

- **Description**: Pixels before drag starts

- **Default**: `10`


##### `sensitivity`

- **Type**: `number`

- **Description**: Drag sensitivity multiplier

- **Default**: `1.0`


##### `showGhost`

- **Type**: `boolean`

- **Description**: Show ghost image while dragging

- **Default**: `True`


##### `ghostOpacity`

- **Type**: `number`

- **Default**: `0.5`


##### `snapToGrid`

- **Type**: `boolean`

- **Default**: `False`


##### `gridSize`

- **Type**: `integer`

- **Default**: `10`


##### `swipe`

- **Type**: `object`


**Nested Properties:**


##### `enabled`

- **Type**: `boolean`

- **Default**: `True`


##### `minDistance`

- **Type**: `integer`

- **Description**: Minimum swipe distance in pixels

- **Default**: `50`


##### `maxDuration`

- **Type**: `integer`

- **Description**: Maximum swipe duration in ms

- **Default**: `300`


##### `minVelocity`

- **Type**: `number`

- **Description**: Minimum velocity for swipe

- **Default**: `0.5`


##### `leftAction`

- **Type**: `string`

- **Default**: `"back"`


##### `rightAction`

- **Type**: `string`

- **Default**: `"forward"`


##### `upAction`

- **Type**: `string`

- **Default**: `"refresh"`


##### `downAction`

- **Type**: `string`

- **Default**: `"close"`


##### `pinch`

- **Type**: `object`


**Nested Properties:**


##### `enabled`

- **Type**: `boolean`

- **Default**: `True`


##### `minScale`

- **Type**: `number`

- **Default**: `0.5`


##### `maxScale`

- **Type**: `number`

- **Default**: `3.0`


##### `sensitivity`

- **Type**: `number`

- **Default**: `1.0`


##### `smoothScaling`

- **Type**: `boolean`

- **Default**: `True`


##### `hover`

- **Type**: `object`


**Nested Properties:**


##### `enabled`

- **Type**: `boolean`

- **Default**: `True`


##### `enterDelay`

- **Type**: `integer`

- **Description**: Delay before hover state

- **Default**: `0`


##### `exitDelay`

- **Type**: `integer`

- **Description**: Delay before leaving hover state

- **Default**: `0`


##### `showTooltip`

- **Type**: `boolean`

- **Default**: `True`


##### `tooltipDelay`

- **Type**: `integer`

- **Default**: `500`


##### `highlightOnHover`

- **Type**: `boolean`

- **Default**: `True`


##### `focus`

- **Type**: `object`


**Nested Properties:**


##### `enabled`

- **Type**: `boolean`

- **Default**: `True`


##### `showIndicator`

- **Type**: `boolean`

- **Default**: `True`


##### `trapFocus`

- **Type**: `boolean`

- **Description**: Trap focus within component

- **Default**: `False`


##### `autoFocus`

- **Type**: `boolean`

- **Description**: Auto-focus first element

- **Default**: `False`


##### `traversalMode`

- **Type**: `string`

- **Description**: "natural", "horizontal", "vertical"

- **Default**: `"natural"`


##### `keyboard`

- **Type**: `object`


**Nested Properties:**


##### `enabled`

- **Type**: `boolean`

- **Default**: `True`


##### `vimMode`

- **Type**: `boolean`

- **Description**: Enable vim-style navigation

- **Default**: `False`


##### `emacsMode`

- **Type**: `boolean`

- **Description**: Enable emacs-style navigation

- **Default**: `False`


##### `navigation`

- **Type**: `string`

- **Default**: `"QtObject {"`


##### `up`

- **Type**: `string`

- **Default**: `"Up"`


##### `down`

- **Type**: `string`

- **Default**: `"Down"`


##### `left`

- **Type**: `string`

- **Default**: `"Left"`


##### `right`

- **Type**: `string`

- **Default**: `"Right"`


##### `pageUp`

- **Type**: `string`

- **Default**: `"PageUp"`


##### `pageDown`

- **Type**: `string`

- **Default**: `"PageDown"`


##### `home`

- **Type**: `string`

- **Default**: `"Home"`


##### `end`

- **Type**: `string`

- **Default**: `"End"`


##### `tab`

- **Type**: `string`

- **Default**: `"Tab"`


##### `shiftTab`

- **Type**: `string`

- **Default**: `"Shift+Tab"`


##### `actions`

- **Type**: `object`


**Nested Properties:**


##### `select`

- **Type**: `string`

- **Default**: `"Return"`


##### `cancel`

- **Type**: `string`

- **Default**: `"Escape"`


##### `delete`

- **Type**: `string`

- **Default**: `"Delete"`


##### `cut`

- **Type**: `string`

- **Default**: `"Ctrl+X"`


##### `copy`

- **Type**: `string`

- **Default**: `"Ctrl+C"`


##### `paste`

- **Type**: `string`

- **Default**: `"Ctrl+V"`


##### `undo`

- **Type**: `string`

- **Default**: `"Ctrl+Z"`


##### `redo`

- **Type**: `string`

- **Default**: `"Ctrl+Shift+Z"`


##### `selectAll`

- **Type**: `string`

- **Default**: `"Ctrl+A"`


##### `find`

- **Type**: `string`

- **Default**: `"Ctrl+F"`


##### `replace`

- **Type**: `string`

- **Default**: `"Ctrl+H"`


##### `global`

- **Type**: `object`


**Nested Properties:**


##### `launcher`

- **Type**: `string`

- **Default**: `"Meta+Space"`


##### `dashboard`

- **Type**: `string`

- **Default**: `"Meta+D"`


##### `controlCenter`

- **Type**: `string`

- **Default**: `"Meta+C"`


##### `notifications`

- **Type**: `string`

- **Default**: `"Meta+N"`


##### `lock`

- **Type**: `string`

- **Default**: `"Meta+L"`


##### `logout`

- **Type**: `string`

- **Default**: `"Meta+Shift+L"`


##### `screenshot`

- **Type**: `string`

- **Default**: `"Print"`


##### `volumeUp`

- **Type**: `string`

- **Default**: `"XF86AudioRaiseVolume"`


##### `volumeDown`

- **Type**: `string`

- **Default**: `"XF86AudioLowerVolume"`


##### `volumeMute`

- **Type**: `string`

- **Default**: `"XF86AudioMute"`


##### `repeat`

- **Type**: `object`


**Nested Properties:**


##### `enabled`

- **Type**: `boolean`

- **Default**: `True`


##### `delay`

- **Type**: `integer`

- **Description**: Initial delay before repeat

- **Default**: `500`


##### `rate`

- **Type**: `integer`

- **Description**: Repeat rate in ms

- **Default**: `30`


##### `mouse`

- **Type**: `object`


**Nested Properties:**


##### `naturalScroll`

- **Type**: `boolean`

- **Description**: Reverse scroll direction

- **Default**: `False`


##### `scrollSpeed`

- **Type**: `integer`

- **Description**: Lines per scroll

- **Default**: `3`


##### `scrollMultiplier`

- **Type**: `number`

- **Default**: `1.0`


##### `smoothScroll`

- **Type**: `boolean`

- **Default**: `True`


##### `wheelDelta`

- **Type**: `integer`

- **Description**: Standard wheel delta

- **Default**: `120`


##### `middleClickPaste`

- **Type**: `boolean`

- **Default**: `True`


##### `rightClickAction`

- **Type**: `string`

- **Description**: "contextMenu", "back", "none"

- **Default**: `"contextMenu"`


##### `cursorSize`

- **Type**: `integer`

- **Default**: `24`


##### `cursorAutoHide`

- **Type**: `boolean`

- **Default**: `True`


##### `cursorHideDelay`

- **Type**: `integer`

- **Default**: `3000`


##### `touch`

- **Type**: `object`


**Nested Properties:**


##### `enabled`

- **Type**: `boolean`

- **Default**: `True`


##### `tapRadius`

- **Type**: `integer`

- **Description**: Touch tap radius

- **Default**: `20`


##### `multiTouch`

- **Type**: `boolean`

- **Default**: `True`


##### `maxTouchPoints`

- **Type**: `integer`

- **Default**: `10`


##### `edgeSwipe`

- **Type**: `boolean`

- **Default**: `True`


##### `edgeSwipeThreshold`

- **Type**: `integer`

- **Default**: `20`


##### `kineticScroll`

- **Type**: `boolean`

- **Default**: `True`


##### `friction`

- **Type**: `number`

- **Default**: `0.9`


##### `window`

- **Type**: `object`


**Nested Properties:**


##### `rememberPosition`

- **Type**: `boolean`

- **Default**: `True`


##### `rememberSize`

- **Type**: `boolean`

- **Default**: `True`


##### `centerOnOpen`

- **Type**: `boolean`

- **Default**: `False`


##### `snapToEdges`

- **Type**: `boolean`

- **Default**: `True`


##### `snapDistance`

- **Type**: `integer`

- **Default**: `10`


##### `showInTaskbar`

- **Type**: `boolean`

- **Default**: `True`


##### `alwaysOnTop`

- **Type**: `boolean`

- **Default**: `False`


##### `skipTaskbar`

- **Type**: `boolean`

- **Default**: `False`


##### `skipPager`

- **Type**: `boolean`

- **Default**: `False`


##### `focusPolicy`

- **Type**: `string`

- **Description**: "click", "hover", "none"

- **Default**: `"click"`


##### `raiseonFocus`

- **Type**: `boolean`

- **Default**: `True`


##### `state`

- **Type**: `object`


**Nested Properties:**


##### `persistent`

- **Type**: `boolean`

- **Description**: Save state between sessions

- **Default**: `True`


##### `autoSave`

- **Type**: `boolean`

- **Default**: `True`


##### `autoSaveInterval`

- **Type**: `integer`

- **Description**: Auto-save interval in ms

- **Default**: `60000`


##### `compressState`

- **Type**: `boolean`

- **Default**: `True`


##### `maxStateHistory`

- **Type**: `integer`

- **Default**: `10`


##### `restoreOnCrash`

- **Type**: `boolean`

- **Default**: `True`


##### `search`

- **Type**: `object`


**Nested Properties:**


##### `enabled`

- **Type**: `boolean`

- **Default**: `True`


##### `liveSearch`

- **Type**: `boolean`

- **Description**: Search as you type

- **Default**: `True`


##### `searchDelay`

- **Type**: `integer`

- **Description**: Delay before search starts

- **Default**: `300`


##### `fuzzySearch`

- **Type**: `boolean`

- **Default**: `True`


##### `caseSensitive`

- **Type**: `boolean`

- **Default**: `False`


##### `regexSearch`

- **Type**: `boolean`

- **Default**: `False`


##### `highlightMatches`

- **Type**: `boolean`

- **Default**: `True`


##### `maxResults`

- **Type**: `integer`

- **Default**: `50`


##### `searchHistory`

- **Type**: `boolean`

- **Default**: `True`


##### `historySize`

- **Type**: `integer`

- **Default**: `100`


##### `accessibility`

- **Type**: `object`


**Nested Properties:**


##### `enabled`

- **Type**: `boolean`

- **Default**: `False`


##### `screenReader`

- **Type**: `boolean`

- **Default**: `False`


##### `highContrast`

- **Type**: `boolean`

- **Default**: `False`


##### `reducedMotion`

- **Type**: `boolean`

- **Default**: `False`


##### `largeText`

- **Type**: `boolean`

- **Default**: `False`


##### `textScale`

- **Type**: `number`

- **Default**: `1.0`


##### `keyboardOnly`

- **Type**: `boolean`

- **Default**: `False`


##### `announceChanges`

- **Type**: `boolean`

- **Default**: `True`


##### `announceDelay`

- **Type**: `integer`

- **Default**: `100`


##### `performance`

- **Type**: `object`


**Nested Properties:**


##### `enableGPU`

- **Type**: `boolean`

- **Default**: `True`


##### `enableCaching`

- **Type**: `boolean`

- **Default**: `True`


##### `cacheSize`

- **Type**: `integer`

- **Description**: MB

- **Default**: `100`


##### `lazyLoading`

- **Type**: `boolean`

- **Default**: `True`


##### `lazyLoadThreshold`

- **Type**: `integer`

- **Description**: Pixels from viewport

- **Default**: `100`


##### `virtualScrolling`

- **Type**: `boolean`

- **Default**: `True`


##### `virtualBufferSize`

- **Type**: `integer`

- **Description**: Screens worth of content

- **Default**: `3`


##### `throttleUpdates`

- **Type**: `boolean`

- **Default**: `True`


##### `updateThrottle`

- **Type**: `integer`

- **Description**: ms (60 FPS)

- **Default**: `16`


##### `reducedEffects`

- **Type**: `boolean`

- **Default**: `False`


##### `errorHandling`

- **Type**: `object`


**Nested Properties:**


##### `showErrors`

- **Type**: `boolean`

- **Default**: `True`


##### `logErrors`

- **Type**: `boolean`

- **Default**: `True`


##### `notifyOnError`

- **Type**: `boolean`

- **Default**: `True`


##### `errorNotificationTimeout`

- **Type**: `integer`

- **Default**: `5000`


##### `autoRecover`

- **Type**: `boolean`

- **Default**: `True`


##### `maxRetries`

- **Type**: `integer`

- **Default**: `3`


##### `reportCrashes`

- **Type**: `boolean`

- **Default**: `False`


##### `crashReportUrl`

- **Type**: `string`


##### `updates`

- **Type**: `object`


**Nested Properties:**


##### `autoCheck`

- **Type**: `boolean`

- **Default**: `True`


##### `checkInterval`

- **Type**: `integer`

- **Description**: 24 hours

- **Default**: `86400000`


##### `autoDownload`

- **Type**: `boolean`

- **Default**: `False`


##### `autoInstall`

- **Type**: `boolean`

- **Default**: `False`


##### `notifyAvailable`

- **Type**: `boolean`

- **Default**: `True`


##### `updateChannel`

- **Type**: `string`

- **Description**: "stable", "beta", "nightly"

- **Default**: `"stable"`


##### `updateUrl`

- **Type**: `string`


##### `click`

- **Type**: `string`

- **Default**: `"QtObject {"`


##### `singleClickDelay`

- **Type**: `integer`

- **Default**: `250`


##### `doubleClickInterval`

- **Type**: `integer`

- **Default**: `400`


##### `longPressDelay`

- **Type**: `integer`

- **Default**: `500`


##### `clickRadius`

- **Type**: `integer`

- **Default**: `5`


##### `vibrateFeedback`

- **Type**: `boolean`

- **Default**: `False`


##### `enabled`

- **Type**: `boolean`

- **Default**: `True`


##### `threshold`

- **Type**: `integer`

- **Default**: `10`


##### `sensitivity`

- **Type**: `number`

- **Default**: `1.0`


##### `showGhost`

- **Type**: `boolean`

- **Default**: `True`


##### `ghostOpacity`

- **Type**: `number`

- **Default**: `0.5`


##### `snapToGrid`

- **Type**: `boolean`

- **Default**: `False`


##### `gridSize`

- **Type**: `integer`

- **Default**: `10`


##### `minDistance`

- **Type**: `integer`

- **Default**: `50`


##### `maxDuration`

- **Type**: `integer`

- **Default**: `300`


##### `minVelocity`

- **Type**: `number`

- **Default**: `0.5`


##### `leftAction`

- **Type**: `string`

- **Default**: `"back"`


##### `rightAction`

- **Type**: `string`

- **Default**: `"forward"`


##### `upAction`

- **Type**: `string`

- **Default**: `"refresh"`


##### `downAction`

- **Type**: `string`

- **Default**: `"close"`


##### `minScale`

- **Type**: `number`

- **Default**: `0.5`


##### `maxScale`

- **Type**: `number`

- **Default**: `3.0`


##### `smoothScaling`

- **Type**: `boolean`

- **Default**: `True`


##### `enterDelay`

- **Type**: `integer`

- **Default**: `0`


##### `exitDelay`

- **Type**: `integer`

- **Default**: `0`


##### `showTooltip`

- **Type**: `boolean`

- **Default**: `True`


##### `tooltipDelay`

- **Type**: `integer`

- **Default**: `500`


##### `highlightOnHover`

- **Type**: `boolean`

- **Default**: `True`


##### `showIndicator`

- **Type**: `boolean`

- **Default**: `True`


##### `trapFocus`

- **Type**: `boolean`

- **Default**: `False`


##### `autoFocus`

- **Type**: `boolean`

- **Default**: `False`


##### `traversalMode`

- **Type**: `string`

- **Default**: `"natural"`


##### `vimMode`

- **Type**: `boolean`

- **Default**: `False`


##### `emacsMode`

- **Type**: `boolean`

- **Default**: `False`


##### `navigation`

- **Type**: `string`

- **Default**: `"QtObject {"`


##### `up`

- **Type**: `string`

- **Default**: `"Up"`


##### `down`

- **Type**: `string`

- **Default**: `"Down"`


##### `left`

- **Type**: `string`

- **Default**: `"Left"`


##### `right`

- **Type**: `string`

- **Default**: `"Right"`


##### `pageUp`

- **Type**: `string`

- **Default**: `"PageUp"`


##### `pageDown`

- **Type**: `string`

- **Default**: `"PageDown"`


##### `home`

- **Type**: `string`

- **Default**: `"Home"`


##### `end`

- **Type**: `string`

- **Default**: `"End"`


##### `tab`

- **Type**: `string`

- **Default**: `"Tab"`


##### `shiftTab`

- **Type**: `string`

- **Default**: `"Shift+Tab"`


##### `select`

- **Type**: `string`

- **Default**: `"Return"`


##### `cancel`

- **Type**: `string`

- **Default**: `"Escape"`


##### `delete`

- **Type**: `string`

- **Default**: `"Delete"`


##### `cut`

- **Type**: `string`

- **Default**: `"Ctrl+X"`


##### `copy`

- **Type**: `string`

- **Default**: `"Ctrl+C"`


##### `paste`

- **Type**: `string`

- **Default**: `"Ctrl+V"`


##### `undo`

- **Type**: `string`

- **Default**: `"Ctrl+Z"`


##### `redo`

- **Type**: `string`

- **Default**: `"Ctrl+Shift+Z"`


##### `selectAll`

- **Type**: `string`

- **Default**: `"Ctrl+A"`


##### `find`

- **Type**: `string`

- **Default**: `"Ctrl+F"`


##### `replace`

- **Type**: `string`

- **Default**: `"Ctrl+H"`


##### `launcher`

- **Type**: `string`

- **Default**: `"Meta+Space"`


##### `dashboard`

- **Type**: `string`

- **Default**: `"Meta+D"`


##### `controlCenter`

- **Type**: `string`

- **Default**: `"Meta+C"`


##### `notifications`

- **Type**: `string`

- **Default**: `"Meta+N"`


##### `lock`

- **Type**: `string`

- **Default**: `"Meta+L"`


##### `logout`

- **Type**: `string`

- **Default**: `"Meta+Shift+L"`


##### `screenshot`

- **Type**: `string`

- **Default**: `"Print"`


##### `volumeUp`

- **Type**: `string`

- **Default**: `"XF86AudioRaiseVolume"`


##### `volumeDown`

- **Type**: `string`

- **Default**: `"XF86AudioLowerVolume"`


##### `volumeMute`

- **Type**: `string`

- **Default**: `"XF86AudioMute"`


##### `delay`

- **Type**: `integer`

- **Default**: `500`


##### `rate`

- **Type**: `integer`

- **Default**: `30`


##### `naturalScroll`

- **Type**: `boolean`

- **Default**: `False`


##### `scrollSpeed`

- **Type**: `integer`

- **Default**: `3`


##### `scrollMultiplier`

- **Type**: `number`

- **Default**: `1.0`


##### `smoothScroll`

- **Type**: `boolean`

- **Default**: `True`


##### `wheelDelta`

- **Type**: `integer`

- **Default**: `120`


##### `middleClickPaste`

- **Type**: `boolean`

- **Default**: `True`


##### `rightClickAction`

- **Type**: `string`

- **Default**: `"contextMenu"`


##### `cursorSize`

- **Type**: `integer`

- **Default**: `24`


##### `cursorAutoHide`

- **Type**: `boolean`

- **Default**: `True`


##### `cursorHideDelay`

- **Type**: `integer`

- **Default**: `3000`


##### `tapRadius`

- **Type**: `integer`

- **Default**: `20`


##### `multiTouch`

- **Type**: `boolean`

- **Default**: `True`


##### `maxTouchPoints`

- **Type**: `integer`

- **Default**: `10`


##### `edgeSwipe`

- **Type**: `boolean`

- **Default**: `True`


##### `edgeSwipeThreshold`

- **Type**: `integer`

- **Default**: `20`


##### `kineticScroll`

- **Type**: `boolean`

- **Default**: `True`


##### `friction`

- **Type**: `number`

- **Default**: `0.9`


##### `rememberPosition`

- **Type**: `boolean`

- **Default**: `True`


##### `rememberSize`

- **Type**: `boolean`

- **Default**: `True`


##### `centerOnOpen`

- **Type**: `boolean`

- **Default**: `False`


##### `snapToEdges`

- **Type**: `boolean`

- **Default**: `True`


##### `snapDistance`

- **Type**: `integer`

- **Default**: `10`


##### `showInTaskbar`

- **Type**: `boolean`

- **Default**: `True`


##### `alwaysOnTop`

- **Type**: `boolean`

- **Default**: `False`


##### `skipTaskbar`

- **Type**: `boolean`

- **Default**: `False`


##### `skipPager`

- **Type**: `boolean`

- **Default**: `False`


##### `focusPolicy`

- **Type**: `string`

- **Default**: `"click"`


##### `raiseonFocus`

- **Type**: `boolean`

- **Default**: `True`


##### `persistent`

- **Type**: `boolean`

- **Default**: `True`


##### `autoSave`

- **Type**: `boolean`

- **Default**: `True`


##### `autoSaveInterval`

- **Type**: `integer`

- **Default**: `60000`


##### `statePath`

- **Type**: `string`

- **Default**: `""~"`


##### `compressState`

- **Type**: `boolean`

- **Default**: `True`


##### `maxStateHistory`

- **Type**: `integer`

- **Default**: `10`


##### `restoreOnCrash`

- **Type**: `boolean`

- **Default**: `True`


##### `liveSearch`

- **Type**: `boolean`

- **Default**: `True`


##### `searchDelay`

- **Type**: `integer`

- **Default**: `300`


##### `fuzzySearch`

- **Type**: `boolean`

- **Default**: `True`


##### `caseSensitive`

- **Type**: `boolean`

- **Default**: `False`


##### `regexSearch`

- **Type**: `boolean`

- **Default**: `False`


##### `highlightMatches`

- **Type**: `boolean`

- **Default**: `True`


##### `maxResults`

- **Type**: `integer`

- **Default**: `50`


##### `searchHistory`

- **Type**: `boolean`

- **Default**: `True`


##### `historySize`

- **Type**: `integer`

- **Default**: `100`


##### `screenReader`

- **Type**: `boolean`

- **Default**: `False`


##### `highContrast`

- **Type**: `boolean`

- **Default**: `False`


##### `reducedMotion`

- **Type**: `boolean`

- **Default**: `False`


##### `largeText`

- **Type**: `boolean`

- **Default**: `False`


##### `textScale`

- **Type**: `number`

- **Default**: `1.0`


##### `keyboardOnly`

- **Type**: `boolean`

- **Default**: `False`


##### `announceChanges`

- **Type**: `boolean`

- **Default**: `True`


##### `announceDelay`

- **Type**: `integer`

- **Default**: `100`


##### `enableGPU`

- **Type**: `boolean`

- **Default**: `True`


##### `enableCaching`

- **Type**: `boolean`

- **Default**: `True`


##### `cacheSize`

- **Type**: `integer`

- **Default**: `100`


##### `lazyLoading`

- **Type**: `boolean`

- **Default**: `True`


##### `lazyLoadThreshold`

- **Type**: `integer`

- **Default**: `100`


##### `virtualScrolling`

- **Type**: `boolean`

- **Default**: `True`


##### `virtualBufferSize`

- **Type**: `integer`

- **Default**: `3`


##### `throttleUpdates`

- **Type**: `boolean`

- **Default**: `True`


##### `updateThrottle`

- **Type**: `integer`

- **Default**: `16`


##### `reducedEffects`

- **Type**: `boolean`

- **Default**: `False`


##### `showErrors`

- **Type**: `boolean`

- **Default**: `True`


##### `logErrors`

- **Type**: `boolean`

- **Default**: `True`


##### `errorLogPath`

- **Type**: `string`

- **Default**: `""~"`


##### `notifyOnError`

- **Type**: `boolean`

- **Default**: `True`


##### `errorNotificationTimeout`

- **Type**: `integer`

- **Default**: `5000`


##### `autoRecover`

- **Type**: `boolean`

- **Default**: `True`


##### `maxRetries`

- **Type**: `integer`

- **Default**: `3`


##### `reportCrashes`

- **Type**: `boolean`

- **Default**: `False`


##### `crashReportUrl`

- **Type**: `string`


##### `autoCheck`

- **Type**: `boolean`

- **Default**: `True`


##### `checkInterval`

- **Type**: `integer`

- **Default**: `86400000`


##### `autoDownload`

- **Type**: `boolean`

- **Default**: `False`


##### `autoInstall`

- **Type**: `boolean`

- **Default**: `False`


##### `notifyAvailable`

- **Type**: `boolean`

- **Default**: `True`


##### `updateChannel`

- **Type**: `string`

- **Default**: `"stable"`


##### `updateUrl`

- **Type**: `string`


#### Example

```json

{
  "modules": {
    "behavior": {
      "interaction": {},
      "drag": {},
      "swipe": {},
      "pinch": {},
      "hover": {},
      "focus": {},
      "keyboard": {},
      "actions": {},
      "global": {},
      "repeat": {},
      "mouse": {},
      "touch": {},
      "window": {},
      "state": {},
      "search": {},
      "accessibility": {},
      "performance": {},
      "errorHandling": {},
      "updates": {},
      "click": "QtObject {",
      "singleClickDelay": 250,
      "doubleClickInterval": 400,
      "longPressDelay": 500,
      "clickRadius": 5,
      "vibrateFeedback": false,
      "enabled": true,
      "threshold": 10,
      "sensitivity": 1.0,
      "showGhost": true,
      "ghostOpacity": 0.5,
      "snapToGrid": false,
      "gridSize": 10,
      "minDistance": 50,
      "maxDuration": 300,
      "minVelocity": 0.5,
      "leftAction": "back",
      "rightAction": "forward",
      "upAction": "refresh",
      "downAction": "close",
      "minScale": 0.5,
      "maxScale": 3.0,
      "smoothScaling": true,
      "enterDelay": 0,
      "exitDelay": 0,
      "showTooltip": true,
      "tooltipDelay": 500,
      "highlightOnHover": true,
      "showIndicator": true,
      "trapFocus": false,
      "autoFocus": false,
      "traversalMode": "natural",
      "vimMode": false,
      "emacsMode": false,
      "navigation": "QtObject {",
      "up": "Up",
      "down": "Down",
      "left": "Left",
      "right": "Right",
      "pageUp": "PageUp",
      "pageDown": "PageDown",
      "home": "Home",
      "end": "End",
      "tab": "Tab",
      "shiftTab": "Shift+Tab",
      "select": "Return",
      "cancel": "Escape",
      "delete": "Delete",
      "cut": "Ctrl+X",
      "copy": "Ctrl+C",
      "paste": "Ctrl+V",
      "undo": "Ctrl+Z",
      "redo": "Ctrl+Shift+Z",
      "selectAll": "Ctrl+A",
      "find": "Ctrl+F",
      "replace": "Ctrl+H",
      "launcher": "Meta+Space",
      "dashboard": "Meta+D",
      "controlCenter": "Meta+C",
      "notifications": "Meta+N",
      "lock": "Meta+L",
      "logout": "Meta+Shift+L",
      "screenshot": "Print",
      "volumeUp": "XF86AudioRaiseVolume",
      "volumeDown": "XF86AudioLowerVolume",
      "volumeMute": "XF86AudioMute",
      "delay": 500,
      "rate": 30,
      "naturalScroll": false,
      "scrollSpeed": 3,
      "scrollMultiplier": 1.0,
      "smoothScroll": true,
      "wheelDelta": 120,
      "middleClickPaste": true,
      "rightClickAction": "contextMenu",
      "cursorSize": 24,
      "cursorAutoHide": true,
      "cursorHideDelay": 3000,
      "tapRadius": 20,
      "multiTouch": true,
      "maxTouchPoints": 10,
      "edgeSwipe": true,
      "edgeSwipeThreshold": 20,
      "kineticScroll": true,
      "friction": 0.9,
      "rememberPosition": true,
      "rememberSize": true,
      "centerOnOpen": false,
      "snapToEdges": true,
      "snapDistance": 10,
      "showInTaskbar": true,
      "alwaysOnTop": false,
      "skipTaskbar": false,
      "skipPager": false,
      "focusPolicy": "click",
      "raiseonFocus": true,
      "persistent": true,
      "autoSave": true,
      "autoSaveInterval": 60000,
      "statePath": "\"~",
      "compressState": true,
      "maxStateHistory": 10,
      "restoreOnCrash": true,
      "liveSearch": true,
      "searchDelay": 300,
      "fuzzySearch": true,
      "caseSensitive": false,
      "regexSearch": false,
      "highlightMatches": true,
      "maxResults": 50,
      "searchHistory": true,
      "historySize": 100,
      "screenReader": false,
      "highContrast": false,
      "reducedMotion": false,
      "largeText": false,
      "textScale": 1.0,
      "keyboardOnly": false,
      "announceChanges": true,
      "announceDelay": 100,
      "enableGPU": true,
      "enableCaching": true,
      "cacheSize": 100,
      "lazyLoading": true,
      "lazyLoadThreshold": 100,
      "virtualScrolling": true,
      "virtualBufferSize": 3,
      "throttleUpdates": true,
      "updateThrottle": 16,
      "reducedEffects": false,
      "showErrors": true,
      "logErrors": true,
      "errorLogPath": "\"~",
      "notifyOnError": true,
      "errorNotificationTimeout": 5000,
      "autoRecover": true,
      "maxRetries": 3,
      "reportCrashes": false,
      "crashReportUrl": "example",
      "autoCheck": true,
      "checkInterval": 86400000,
      "autoDownload": false,
      "autoInstall": false,
      "notifyAvailable": true,
      "updateChannel": "stable",
      "updateUrl": "example"
    }
  }
}
```


## Validation Rules

The configuration system enforces the following validation rules:


### Type Validation

All properties are validated against their expected types:

- `string`: Text values

- `integer`: Whole numbers

- `number`: Decimal numbers

- `boolean`: true/false values

- `object`: Nested configuration objects

- `array`: Lists of values


### Range Validation

Numeric properties may have minimum and maximum constraints:

- Duration values: 0-10000ms

- Opacity values: 0.0-1.0

- Size values: Must be positive


### Cross-field Validation

Some fields have dependencies on others:

- Animation settings are ignored when `animation.enabled` is false

- Service API keys are required when the service is enabled

- Conflicting keyboard modes (vim/emacs) cannot be enabled simultaneously


## Migration Guide

### From Version 1.x to 2.0

The configuration structure has changed significantly in version 2.0:


**Key Changes:**

1. All module configurations are now under the `modules` key

2. `colours` has been renamed to `colors`

3. New configuration modules added for animations, services, and behavior


**Migration Example:**

```json

// Version 1.x

{
  "launcher": { ... },
  "colours": { ... }
}


// Version 2.0

{
  "version": "2.0.0",
  "modules": {
    "launcher": { ... }
  },
  "colors": { ... }
}

```


**Automatic Migration:**

The configuration system will automatically migrate old configurations when detected.

A backup is created before migration.


## Best Practices

### General Guidelines

1. **Always specify version**: Include the `version` field for compatibility

2. **Start with defaults**: Only override settings you need to change

3. **Test incrementally**: Make small changes and test before adding more

4. **Use comments**: JSON doesn't support comments, but you can document in a separate file


### Performance Optimization

- Disable unused services to reduce resource usage

- Increase update intervals for non-critical services

- Use `performance.reducedEffects` on lower-end hardware

- Enable `performance.lazyLoading` for better startup times


### Common Configurations


**Minimal Configuration:**

```json
{
  "version": "2.0.0"
}
```


**Performance-Optimized:**

```json

{
  "version": "2.0.0",
  "modules": {

    "animation": {
      "speedMultiplier": 0.5
    },

    "behavior": {
      "performance": {

        "reducedEffects": true,
        "lazyLoading": true

      }
    }
  }
}

```


**Accessibility-Focused:**

```json

{
  "version": "2.0.0",
  "modules": {

    "behavior": {
      "accessibility": {

        "enabled": true,
        "largeText": true,

        "textScale": 1.5,
        "reducedMotion": true

      }
    }
  }
}

```
